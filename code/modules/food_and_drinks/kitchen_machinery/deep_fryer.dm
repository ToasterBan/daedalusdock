
#define DEEPFRYER_COOKTIME 60
#define DEEPFRYER_BURNTIME 120

GLOBAL_LIST_INIT(oilfry_blacklisted_items, typecacheof(list(
	/obj/item/reagent_containers/cup,
	/obj/item/reagent_containers/syringe,
	/obj/item/reagent_containers/condiment,
	/obj/item/storage,
	/obj/item/delivery,
	/obj/item/his_grace)))

/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/deep_fryer
	var/obj/item/food/deepfryholder/frying //What's being fried RIGHT NOW?
	var/cook_time = 0
	var/oil_use = 0.025 //How much cooking oil is used per second
	var/fry_speed = 1 //How quickly we fry food
	var/frying_fried //If the object has been fried; used for messages
	var/frying_burnt //If the object has been burnt
	var/datum/looping_sound/deep_fryer/fry_loop
	var/static/list/deepfry_blacklisted_items = typecacheof(list(
	/obj/item/screwdriver,
	/obj/item/crowbar,
	/obj/item/wrench,
	/obj/item/wirecutters,
	/obj/item/multitool,
	/obj/item/weldingtool))

/obj/machinery/deepfryer/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/consumable/cooking_oil, 25)
	fry_loop = new(src, FALSE)

/obj/machinery/deepfryer/Destroy()
	QDEL_NULL(fry_loop)
	return ..()

/obj/machinery/deepfryer/RefreshParts()
	. = ..()
	var/oil_efficiency
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		oil_efficiency += M.rating
	oil_use = initial(oil_use) - (oil_efficiency * 0.00475)
	fry_speed = oil_efficiency

/obj/machinery/deepfryer/examine(mob/user)
	. = ..()
	if(frying)
		. += "You can make out \a [frying] in the oil."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Frying at <b>[fry_speed*100]%</b> speed.<br>Using <b>[oil_use]</b> units of oil per second.")

/obj/machinery/deepfryer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/deepfryer/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/reagent_containers/pill))
		if(!reagents.total_volume)
			to_chat(user, span_warning("There's nothing to dissolve [weapon] in!"))
			return
		user.visible_message(span_notice("[user] drops [weapon] into [src]."), span_notice("You dissolve [weapon] in [src]."))
		weapon.reagents.trans_to(src, weapon.reagents.total_volume, transfered_by = user)
		qdel(weapon)
		return
	if(!reagents.has_reagent(/datum/reagent/consumable/cooking_oil))
		to_chat(user, span_warning("[src] has no cooking oil to fry with!"))
		return
	if(weapon.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("You don't feel it would be wise to fry [weapon]..."))
		return
	if(istype(weapon, /obj/item/food/deepfryholder))
		to_chat(user, span_userdanger("Your cooking skills are not up to the legendary Doublefry technique."))
		return
	if(default_deconstruction_screwdriver(user, "fryer_off", "fryer_off", weapon)) //where's the open maint panel icon?!
		return
	else
		if(is_type_in_typecache(weapon, deepfry_blacklisted_items) || is_type_in_typecache(weapon, GLOB.oilfry_blacklisted_items) || weapon.atom_storage || HAS_TRAIT(weapon, TRAIT_NODROP) || (weapon.item_flags & (ABSTRACT | DROPDEL)))
			return ..()
		else if(!frying && user.transferItemToLoc(weapon, src))
			fry(weapon, user)

/obj/machinery/deepfryer/process(delta_time)
	..()
	var/datum/reagent/consumable/cooking_oil/C = reagents.has_reagent(/datum/reagent/consumable/cooking_oil)
	if(!C)
		return
	reagents.chem_temp = C.fry_temperature
	if(frying)
		reagents.trans_to(frying, oil_use * delta_time, multiplier = fry_speed * 3) //Fried foods gain more of the reagent thanks to space magic
		cook_time += fry_speed * delta_time
		if(cook_time >= DEEPFRYER_COOKTIME && !frying_fried)
			frying_fried = TRUE //frying... frying... fried
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
			audible_message(span_notice("[src] dings!"))
		else if (cook_time >= DEEPFRYER_BURNTIME && !frying_burnt)
			frying_burnt = TRUE
			visible_message(span_warning("[src] emits an acrid smell!"))

		use_power(active_power_usage)


/obj/machinery/deepfryer/attack_ai(mob/user)
	return

/obj/machinery/deepfryer/attack_hand(mob/living/user, list/modifiers)
	if(frying)
		if(frying.loc == src)
			to_chat(user, span_notice("You eject [frying] from [src]."))
			frying.fry(cook_time)
			icon_state = "fryer_off"
			frying.forceMove(drop_location())
			if(Adjacent(user) && !issilicon(user))
				user.put_in_hands(frying)
			frying = null
			cook_time = 0
			frying_fried = FALSE
			frying_burnt = FALSE
			fry_loop.stop()
			return
	return ..()

/obj/machinery/deepfryer/attack_grab(mob/living/user, atom/movable/victim, obj/item/hand_item/grab/grab, list/params)
	. = ..()
	if(!iscarbon(victim) || !reagents.total_volume)
		return

	if(grab.current_grab.damage_stage < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You need a better grip to do that!"))
		return

	var/mob/living/carbon/dunking_target = victim

	log_combat(user, dunking_target, "dunked", null, "into [src]")
	user.visible_message(span_danger("[user] dunks [dunking_target]'s face in [src]!"))
	reagents.expose(dunking_target, TOUCH)

	var/permeability = 1 - dunking_target.get_permeability_protection(list(HEAD))
	var/target_temp = dunking_target.bodytemperature
	var/cold_multiplier = 1
	if(target_temp < TCMB + 10) // a tiny bit of leeway
		dunking_target.visible_message(span_userdanger("[dunking_target] explodes from the entropic difference! Holy fuck!"))
		dunking_target.gib()
		log_combat(user, dunking_target, "blew up", null, "by dunking them into [src]")
		return

	else if(target_temp < T0C)
		cold_multiplier += round(target_temp * 1.5 / T0C, 0.01)

	dunking_target.apply_damage(min(30 * permeability * cold_multiplier, reagents.total_volume), BURN, BODY_ZONE_HEAD)
	if(reagents.reagent_list) //This can runtime if reagents has nothing in it.
		reagents.remove_all((reagents.total_volume/2))

	dunking_target.Paralyze(60)
	user.changeNext_move(CLICK_CD_MELEE)

/obj/machinery/deepfryer/proc/fry(obj/item/frying_item, mob/user)
	to_chat(user, span_notice("You put [frying_item] into [src]."))
	frying = new /obj/item/food/deepfryholder(src, frying_item)
	icon_state = "fryer_on"
	fry_loop.start()

/obj/machinery/deepfryer/proc/blow_up()
	visible_message(span_userdanger("[src] blows up from the entropic reaction!"))
	explosion(src, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flame_range = 7)
	qdel(src)

#undef DEEPFRYER_COOKTIME
#undef DEEPFRYER_BURNTIME
