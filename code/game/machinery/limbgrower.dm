/// The limbgrower. Makes organd and limbs with synthflesh and chems.
/// See [limbgrower_designs.dm] for everything we can make.
/obj/machinery/limbgrower
	name = "limb grower"
	desc = "It grows new limbs using Synthflesh."
	icon = 'icons/obj/machines/limbgrower.dmi'
	icon_state = "limbgrower_idleoff"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/limbgrower

	var/allowed_buildtypes = LIMBGROWER
	/// The category of limbs we're browing in our UI.
	var/selected_category = SPECIES_HUMAN
	/// If we're currently printing something.
	var/busy = FALSE
	/// How efficient our machine is. Better parts = less chemicals used and less power used. Range of 1 to 0.25.
	var/production_coefficient = 1
	/// How long it takes for us to print a limb. Affected by production_coefficient.
	var/production_speed = 3 SECONDS
	/// The design we're printing currently.
	var/datum/design/being_built

	/// All the categories of organs we can print.
	var/list/categories = list(SPECIES_HUMAN, SPECIES_LIZARD, SPECIES_MOTH, SPECIES_ETHEREAL, "other")

/obj/machinery/limbgrower/Initialize(mapload)
	create_reagents(100, OPENCONTAINER)
	. = ..()

	var/datum/c4_file/fab_design_bundle/dundle = new(
		SStech.fetch_designs(
			list(
				/datum/design/leftarm,
				/datum/design/leftleg,
				/datum/design/rightarm,
				/datum/design/rightleg,
				/datum/design/heart,
				/datum/design/lungs,
				/datum/design/liver,
				/datum/design/stomach,
				/datum/design/appendix,
				/datum/design/eyes,
				/datum/design/ears,
				/datum/design/tongue,
			)
		)
	)
	dundle.name = FABRICATOR_FILE_NAME
	disk_write_file(dundle, internal_disk)

/obj/machinery/limbgrower/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Limbgrower")
		ui.open()

/obj/machinery/limbgrower/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/limbgrower/ui_data(mob/user)
	var/list/data = list()

	for(var/datum/reagent/reagent_id in reagents.reagent_list)
		var/list/reagent_data = list(
			reagent_name = reagent_id.name,
			reagent_amount = reagent_id.volume,
			reagent_type = reagent_id.type
		)
		data["reagents"] += list(reagent_data)

	data["total_reagents"] = reagents.total_volume
	data["max_reagents"] = reagents.maximum_volume
	data["busy"] = busy

	return data

/obj/machinery/limbgrower/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()

	var/species_categories = categories.Copy()
	for(var/species in species_categories)
		species_categories[species] = list()
	var/list/datum/design/design_list = disk_get_designs(FABRICATOR_FILE_NAME, internal_disk)
	for(var/datum/design/limb_design as anything in design_list)
		for(var/found_category in species_categories)
			if(found_category in limb_design.category)
				species_categories[found_category] += limb_design

	for(var/category in species_categories)
		var/list/category_data = list(
			name = category,
			designs = list(),
		)
		for(var/datum/design/found_design in species_categories[category])
			var/list/all_reagents = list()
			for(var/reagent_typepath in found_design.reagents_list)
				var/datum/reagent/reagent_id = find_reagent_object_from_type(reagent_typepath)
				var/list/reagent_data = list(
					name = reagent_id.name,
					amount = (found_design.reagents_list[reagent_typepath] * production_coefficient),
				)
				all_reagents += list(reagent_data)

			category_data["designs"] += list(list(
				parent_category = category,
				name = found_design.name,
				id = found_design.id,
				needed_reagents = all_reagents,
			))

		data["categories"] += list(category_data)

	return data

/obj/machinery/limbgrower/on_deconstruction()
	for(var/obj/item/reagent_containers/cup/our_beaker in component_parts)
		reagents.trans_to(our_beaker, our_beaker.reagents.maximum_volume)
	..()

/obj/machinery/limbgrower/attackby(obj/item/user_item, mob/living/user, params)
	if (busy)
		to_chat(user, span_warning("The Limb Grower is busy. Please wait for completion of previous operation."))
		return

	if(default_deconstruction_screwdriver(user, "limbgrower_panelopen", "limbgrower_idleoff", user_item))
		ui_close(user)
		return

	if(panel_open && default_deconstruction_crowbar(user_item))
		return

	if(user.combat_mode) //so we can hit the machine
		return ..()

/obj/machinery/limbgrower/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if (busy)
		to_chat(usr, span_warning("The limb grower is busy. Please wait for completion of previous operation."))
		return

	if(!(params["active_tab"] in categories))
		return

	switch(action)

		if("empty_reagent")
			reagents.del_reagent(text2path(params["reagent_type"]))
			. = TRUE

		if("make_limb")
			being_built = SStech.sanitize_design_id(src, params["design_id"])
			if(!being_built)
				CRASH("[src] was passed an invalid design id!")

			/// All the reagents we're using to make our organ.
			var/list/consumed_reagents_list = being_built.reagents_list.Copy()
			/// The amount of power we're going to use, based on how much reagent we use.
			var/power = 0

			for(var/reagent_id in consumed_reagents_list)
				consumed_reagents_list[reagent_id] *= production_coefficient
				if(!reagents.has_reagent(reagent_id, consumed_reagents_list[reagent_id]))
					audible_message(span_notice("The [src] buzzes."))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
					return

				power = max(active_power_usage, (power + consumed_reagents_list[reagent_id]))

			busy = TRUE
			use_power(power)
			z_flick("limbgrower_fill",src)
			icon_state = "limbgrower_idleon"
			selected_category = params["active_tab"]
			addtimer(CALLBACK(src, PROC_REF(build_item), consumed_reagents_list), production_speed * production_coefficient)
			. = TRUE

	return

/*
 * The process of beginning to build a limb or organ.
 * Goes through and sanity checks that we actually have enough reagent to build our item.
 * Then, remove those reagents from our reagents datum.
 *
 * After the reagents are handled, we can proceede with making the limb or organ. (Limbs are handled in a separate proc)
 *
 * modified_consumed_reagents_list - the list of reagents we will consume on build, modified by the production coefficient.
 */
/obj/machinery/limbgrower/proc/build_item(list/modified_consumed_reagents_list)
	for(var/reagent_id in modified_consumed_reagents_list)
		if(!reagents.has_reagent(reagent_id, modified_consumed_reagents_list[reagent_id]))
			audible_message(span_notice("The [src] buzzes."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
			break

		reagents.remove_reagent(reagent_id, modified_consumed_reagents_list[reagent_id])

	var/built_typepath = being_built.build_path
	if(ispath(built_typepath, /obj/item/bodypart))
		build_limb(create_buildpath())
	else
		//Just build whatever it is
		new built_typepath(loc)

	busy = FALSE
	flick("limbgrower_unfill", src)
	icon_state = "limbgrower_idleoff"

/*
 * The process of putting together a limb.
 * This is called from after we remove the reagents, so this proc is just initializing the limb type.
 *
 * This proc handles skin / mutant color, greyscaling, names and descriptions, and various other limb creation steps.
 *
 * buildpath - the path of the bodypart we're building.
 */
/obj/machinery/limbgrower/proc/build_limb(buildpath)
	/// The limb we're making with our buildpath, so we can edit it.
	//i need to create a body part manually using a set icon (otherwise it doesnt appear)
	var/obj/item/bodypart/limb
	limb = new buildpath(loc)
	limb.name = "\improper synthetic [selected_category] [limb.plaintext_zone]"
	limb.limb_id = selected_category
	limb.add_color_override("#62A262", LIMB_COLOR_LIMBGROWER)
	limb.update_icon_dropped()

///Returns a valid limb typepath based on the selected option
/obj/machinery/limbgrower/proc/create_buildpath()
	var/part_type = being_built.id //their ids match bodypart typepaths
	var/species = selected_category
	var/path
	if(species == SPECIES_HUMAN) //Humans use the parent type.
		path = "/obj/item/bodypart/[part_type]"
	else
		path = "/obj/item/bodypart/[part_type]/[species]"
	return text2path(path)

/obj/machinery/limbgrower/RefreshParts()
	. = ..()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/cup/our_beaker in component_parts)
		reagents.maximum_volume += our_beaker.volume
		our_beaker.reagents.trans_to(src, our_beaker.reagents.total_volume)
	production_coefficient = 1.25
	for(var/obj/item/stock_parts/manipulator/our_manipulator in component_parts)
		production_coefficient -= our_manipulator.rating * 0.25
	production_coefficient = clamp(production_coefficient, 0, 1) // coefficient goes from 1 -> 0.75 -> 0.5 -> 0.25

/obj/machinery/limbgrower/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[reagents.maximum_volume]u</b> of reagents.<br>Reagent consumption rate at <b>[production_coefficient * 100]%</b>.")

/*
 * Checks our reagent list to see if a design can be built.
 *
 * limb_design - the design we're checking for buildability.
 *
 * returns TRUE if we have enough reagent to build it. Returns FALSE if we do not.
 */
/obj/machinery/limbgrower/proc/can_build(datum/design/limb_design)
	for(var/datum/reagent/reagent_id in limb_design.reagents_list)
		if(!reagents.has_reagent(reagent_id, limb_design.reagents_list[reagent_id] * production_coefficient))
			return FALSE
	return TRUE

/obj/machinery/limbgrower/fullupgrade //Inherently cheaper organ production. This is to NEVER be inherently emagged, no valids.
	desc = "It grows new limbs using Synthflesh. This alien model seems more efficient."
	obj_flags = CAN_BE_HIT
	flags_1 = NODECONSTRUCT_1
	circuit = /obj/item/circuitboard/machine/limbgrower/fullupgrade

/obj/machinery/limbgrower/fullupgrade/Initialize(mapload)
	. = ..()
	var/list/L = list()
	for(var/datum/design/found_design as anything in SStech.designs)
		if((found_design.build_type & LIMBGROWER) && !("emagged" in found_design.category))
			L += found_design
	var/datum/c4_file/fab_design_bundle/dundle = disk_get_file(FABRICATOR_FILE_NAME)
	dundle.included_designs = L //This should be safe?

/// Emagging a limbgrower allows you to build synthetic armblades.
/obj/machinery/limbgrower/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return

	var/list/designs_on_emag = SStech.fetch_designs(
		list(
			/datum/design/armblade,
		)
	)

	var/datum/c4_file/fab_design_bundle/dundle = disk_get_file(FABRICATOR_FILE_NAME)
	if(isnull(dundle)) //If the file just doesn't exist for some reason...
		dundle = new(list())
		dundle.name = FABRICATOR_FILE_NAME
		disk_write_file(dundle, internal_disk)
	if(!istype(dundle)) //But if it's completely the wrong type...
		to_chat(user, span_warning("Disk partition error, Design database unreadable!"))
		return

	dundle.included_designs += designs_on_emag

	to_chat(user, span_warning("Safety overrides have been deactivated!"))
	obj_flags |= EMAGGED
	update_static_data(user)
