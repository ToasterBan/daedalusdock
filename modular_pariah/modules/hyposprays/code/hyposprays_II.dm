#define HYPO_SPRAY 0
#define HYPO_INJECT 1

#define WAIT_SPRAY 15
#define WAIT_INJECT 20
#define SELF_SPRAY 15
#define SELF_INJECT 15

#define DELUXE_WAIT_SPRAY 0
#define DELUXE_WAIT_INJECT 5
#define DELUXE_SELF_SPRAY 10
#define DELUXE_SELF_INJECT 10

#define COMBAT_WAIT_SPRAY 0
#define COMBAT_WAIT_INJECT 0
#define COMBAT_SELF_SPRAY 0
#define COMBAT_SELF_INJECT 0

/obj/item/hypospray/mkii
	name = "hypospray mk.II"
	icon_state = "hypo2"
	icon = 'modular_pariah/modules/hyposprays/icons/hyposprays.dmi'
	desc = "An experimental high-capacity refillable auto injector."
	w_class = WEIGHT_CLASS_TINY
	var/list/allowed_containers = list(/obj/item/reagent_containers/cup/vial/small)
	/// Is the hypospray only able to use small vials. Relates to the loaded overlays
	var/small_only = TRUE
	//Inject or spray?
	var/mode = HYPO_INJECT
	var/obj/item/reagent_containers/cup/vial/vial
	var/start_vial = /obj/item/reagent_containers/cup/vial/small
	var/spawnwithvial = TRUE

	//Time taken to inject others
	var/inject_wait = WAIT_INJECT
	//Time taken to spray others
	var/spray_wait = WAIT_SPRAY
	//Time taken to inject self
	var/inject_self = SELF_INJECT
	//Time taken to spray self
	var/spray_self = SELF_SPRAY

	//Can you hotswap vials? - now all hyposprays can!
	var/quickload = TRUE
	//Does it penetrate clothing?
	var/penetrates = null

/obj/item/hypospray/mkii/cmo
	name = "hypospray mk.II"
	allowed_containers = list(/obj/item/reagent_containers/cup/vial/small, /obj/item/reagent_containers/cup/vial/large)
	icon_state = "cmo2"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	start_vial = /obj/item/reagent_containers/cup/vial/large/deluxe
	small_only = FALSE
	inject_wait = DELUXE_WAIT_INJECT
	spray_wait = DELUXE_WAIT_SPRAY
	spray_self = DELUXE_SELF_SPRAY
	inject_self = DELUXE_SELF_INJECT
	penetrates = INJECT_CHECK_PENETRATE_THICK

/obj/item/hypospray/mkii/Initialize()
	. = ..()
	if(!spawnwithvial)
		update_appearance()
		return

	if(start_vial)
		vial = new start_vial
		update_appearance()

	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)

/obj/item/hypospray/mkii/update_overlays()
	. = ..()
	if(!vial)
		return
	if(!vial.reagents.total_volume)
		return
	var/vial_spritetype = "chem-color"
	if(!small_only)
		vial_spritetype += "[vial.type_suffix]"
	else
		vial_spritetype += "-s"
	var/mutable_appearance/chem_loaded = mutable_appearance('modular_pariah/modules/hyposprays/icons/hyposprays.dmi', vial_spritetype)
	chem_loaded.color = vial.chem_color
	. += chem_loaded

/obj/item/hypospray/mkii/update_icon_state()
	. = ..()
	var/icon_suffix = "-s"
	if(!small_only && vial)
		icon_suffix = vial.type_suffix //Sets the suffix used to the correspoding vial.
	icon_state = "[initial(icon_state)][vial ? "[icon_suffix]" : ""]"

/obj/item/hypospray/mkii/examine(mob/user)
	. = ..()
	if(vial)
		. += "[vial] has [vial.reagents.total_volume]u remaining."
	else
		. += "It has no vial loaded in."

/obj/item/hypospray/mkii/proc/unload_hypo(obj/item/hypo, mob/user)
	if((istype(hypo, /obj/item/reagent_containers/cup/vial)))
		var/obj/item/reagent_containers/cup/vial/container = hypo
		container.forceMove(user.loc)
		user.put_in_hands(container)
		to_chat(user, span_notice("You remove [vial] from [src]."))
		vial = null
		update_icon()
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1)
	else
		to_chat(user, span_notice("This hypo isn't loaded!"))
		return

/obj/item/hypospray/mkii/proc/insert_vial(obj/item/new_vial, mob/living/user, obj/item/current_vial)
	var/obj/item/reagent_containers/cup/vial/container = new_vial
	var/old_loc //The location of and old vial.
	if(!is_type_in_list(container, allowed_containers))
		to_chat(user, span_notice("[src] doesn't accept this type of vial."))
		return FALSE
	if(current_vial)
		old_loc = container.loc
		var/obj/item/reagent_containers/cup/vial/old_container = current_vial
		old_container.forceMove(drop_location())
	if(!user.transferItemToLoc(container, src))
		return FALSE
	vial = container
	user.visible_message(span_notice("[user] has loaded a vial into [src]."), span_notice("You have loaded [vial] into [src]."))
	playsound(loc, 'sound/weapons/autoguninsert.ogg', 35, 1)
	update_appearance()
	if(current_vial)
		if(old_loc == user)
			user.put_in_hands(current_vial)
		else
			current_vial.forceMove(old_loc)

/obj/item/hypospray/mkii/attackby(obj/item/used_item, mob/living/user)
	if((istype(used_item, /obj/item/reagent_containers/cup/vial) && vial != null))
		if(!quickload)
			to_chat(user, span_warning("[src] can not hold more than one vial!"))
			return FALSE
		else
			insert_vial(used_item, user, vial)
			return TRUE

	if((istype(used_item, /obj/item/reagent_containers/cup/vial)))
		insert_vial(used_item, user)
		return TRUE

/obj/item/hypospray/mkii/attack_self(mob/user)
	. = ..()
	if(vial)
		vial.attack_self(user)
		return TRUE

/obj/item/hypospray/mkii/attack_self_secondary(mob/user)
	. = ..()
	if(vial)
		vial.attack_self_secondary(user)
		return TRUE

/obj/item/hypospray/mkii/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		to_chat(user, "[src] happens to be already overcharged.")
		return
	//all these are 0
	inject_wait = COMBAT_WAIT_INJECT
	spray_wait = COMBAT_WAIT_SPRAY
	spray_self = COMBAT_SELF_INJECT
	inject_self = COMBAT_SELF_SPRAY
	penetrates = INJECT_CHECK_PENETRATE_THICK
	to_chat(user, "You overcharge [src]'s control circuit.")
	obj_flags |= EMAGGED
	return TRUE

/obj/item/hypospray/mkii/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/reagent_containers/cup/vial))
		insert_vial(interacting_with, user, vial)
		return ITEM_INTERACT_SUCCESS

	if(!vial || !isliving(interacting_with))
		return NONE

	var/mob/living/injectee = interacting_with

	if(!injectee.reagents || !injectee.can_inject(user, user.zone_selected, penetrates))
		return ITEM_INTERACT_BLOCKING

	if(iscarbon(injectee))
		var/obj/item/bodypart/affecting = injectee.get_bodypart(deprecise_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, span_warning("The limb is missing!"))
			return ITEM_INTERACT_BLOCKING

	//Always log attemped injections for admins
	var/contained = vial.reagents.get_reagent_log_string()
	log_combat(user, injectee, "attemped to inject", src, addition="which had [contained]")

	if(!vial)
		to_chat(user, span_notice("[src] doesn't have any vial installed!"))
		return ITEM_INTERACT_BLOCKING

	if(!vial.reagents.total_volume)
		to_chat(user, span_notice("[src]'s vial is empty!"))
		return ITEM_INTERACT_BLOCKING

	mode = modifiers?[RIGHT_CLICK] ? HYPO_SPRAY: HYPO_INJECT
	var/fp_verb = mode == HYPO_SPRAY ? "spray" : "inject"

	if(injectee != user)
		injectee.visible_message(span_danger("[user] is trying to [fp_verb] [injectee] with [src]!"), \
						span_userdanger("[user] is trying to [fp_verb] you with [src]!"))
	if(!do_after(user, injectee, inject_wait, extra_checks = CALLBACK(injectee, TYPE_PROC_REF(/mob/living, can_inject), user, user.zone_selected, penetrates)))
		return ITEM_INTERACT_BLOCKING

	if(!vial.reagents.total_volume)
		return ITEM_INTERACT_BLOCKING

	log_attack("<font color='red'>[user.name] ([user.ckey]) applied [src] to [injectee.name] ([injectee.ckey]), which had [contained] (COMBAT MODE: [uppertext(user.combat_mode)]) (MODE: [mode])</font>")
	if(injectee != user)
		injectee.visible_message(span_danger("[user] uses the [src] on [injectee]!"), \
						span_userdanger("[user] uses the [src] on you!"))
	else
		injectee.log_message("<font color='orange'>applied [src] to themselves ([contained]).</font>", LOG_ATTACK)

	switch(mode)
		if(HYPO_INJECT)
			vial.reagents.trans_to(injectee, vial.amount_per_transfer_from_this, methods = INJECT)
		if(HYPO_SPRAY)
			vial.reagents.trans_to(injectee, vial.amount_per_transfer_from_this, methods = TOUCH)

	var/long_sound = vial.amount_per_transfer_from_this >= 15
	playsound(loc, long_sound ? 'modular_pariah/modules/hyposprays/sound/hypospray_long.ogg' : pick('modular_pariah/modules/hyposprays/sound/hypospray.ogg','modular_pariah/modules/hyposprays/sound/hypospray2.ogg'), 50, 1, -1)
	to_chat(user, span_notice("You [fp_verb] [vial.amount_per_transfer_from_this] units of the solution. The hypospray's cartridge now contains [vial.reagents.total_volume] units."))
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/hypospray/mkii/attack_hand(mob/living/user)
	if(user && loc == user && user.is_holding(src))
		if(user.incapacitated())
			return
		else if(!vial)
			. = ..()
			return
		else
			unload_hypo(vial,user)
	else
		. = ..()

/obj/item/hypospray/mkii/examine(mob/user)
	. = ..()
	. += span_notice("<b>Left-Click</b> on patients to inject, <b>Right-Click</b> to spray.")

#undef HYPO_SPRAY
#undef HYPO_INJECT
#undef WAIT_SPRAY
#undef WAIT_INJECT
#undef SELF_SPRAY
#undef SELF_INJECT
#undef DELUXE_WAIT_SPRAY
#undef DELUXE_WAIT_INJECT
#undef DELUXE_SELF_SPRAY
#undef DELUXE_SELF_INJECT
#undef COMBAT_WAIT_SPRAY
#undef COMBAT_WAIT_INJECT
#undef COMBAT_SELF_SPRAY
#undef COMBAT_SELF_INJECT
