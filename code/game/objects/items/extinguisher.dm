TYPEINFO_DEF(/obj/item/extinguisher)
	default_materials = list(/datum/material/iron = 90)

/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "fire_extinguisher0"
	worn_icon_state = "fire_extinguisher"
	inhand_icon_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'

	flags_1 = CONDUCT_1
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	throw_range = 7
	force = 10
	stamina_damage = 25
	stamina_cost = 20
	stamina_critical_chance = 35

	attack_verb_continuous = list("slams", "whacks", "bashes", "thunks", "batters", "bludgeons", "thrashes")
	attack_verb_simple = list("slam", "whack", "bash", "thunk", "batter", "bludgeon", "thrash")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	var/max_water = 50
	var/last_use = 1
	var/chem = /datum/reagent/water
	var/safety = TRUE
	var/refilling = FALSE
	var/tanktype = /obj/structure/reagent_dispensers/watertank
	var/sprite_name = "fire_extinguisher"
	var/power = 5 //Maximum distance launched water will travel
	var/precision = FALSE //By default, turfs picked from a spray are random, set to 1 to make it always have at least one water effect per row
	var/cooling_power = 2 //Sets the cooling_temperature of the water reagent datum inside of the extinguisher when it is refilled
	/// Icon state when inside a tank holder
	var/tank_holder_icon_state = "holder_extinguisher"

TYPEINFO_DEF(/obj/item/extinguisher/mini)
	default_materials = list(/datum/material/iron = 50, /datum/material/glass = 40)

/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	worn_icon_state = "miniFE"
	inhand_icon_state = "miniFE"
	hitsound = null //it is much lighter, after all.
	flags_1 = null //doesn't CONDUCT_1
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	max_water = 30
	sprite_name = "miniFE"
	dog_fashion = null

TYPEINFO_DEF(/obj/item/extinguisher/crafted)
	default_materials = list(/datum/material/iron = 50, /datum/material/glass = 40)

/obj/item/extinguisher/crafted
	name = "Improvised cooling spray"
	desc = "Spraycan turned coolant dipsenser. Can be sprayed on containers to cool them. Refll using water."
	icon_state = "coolant0"
	worn_icon_state = "miniFE"
	inhand_icon_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags_1 = null //doesn't CONDUCT_1
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	max_water = 30
	sprite_name = "coolant"
	dog_fashion = null
	cooling_power = 1.5
	power = 3

/obj/item/extinguisher/crafted/attack_self(mob/user)
	safety = !safety
	icon_state = "[sprite_name][!safety]"
	to_chat(user, "[safety ? "You remove the straw and put it on the side of the cool canister" : "You insert the straw, readying it for use"].")

/obj/item/extinguisher/proc/refill()
	if(!chem)
		return
	create_reagents(max_water, AMOUNT_VISIBLE)
	reagents.add_reagent(chem, max_water)

/obj/item/extinguisher/Initialize(mapload)
	. = ..()
	refill()
	if(tank_holder_icon_state)
		AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)

/obj/item/extinguisher/advanced
	name = "advanced fire extinguisher"
	desc = "Used to stop thermonuclear fires from spreading inside your engine."
	icon_state = "foam_extinguisher0"
	worn_icon_state = "foam_extinguisher"
	inhand_icon_state = "foam_extinguisher"
	tank_holder_icon_state = "holder_foam_extinguisher"
	dog_fashion = null
	chem = /datum/reagent/firefighting_foam
	tanktype = /obj/structure/reagent_dispensers/foamtank
	sprite_name = "foam_extinguisher"
	precision = TRUE

/obj/item/extinguisher/suicide_act(mob/living/carbon/user)
	if (!safety && (reagents.total_volume >= 1))
		user.visible_message(span_suicide("[user] puts the nozzle to [user.p_their()] mouth. It looks like [user.p_theyre()] trying to extinguish the spark of life!"))
		afterattack(user,user)
		return OXYLOSS
	else if (safety && (reagents.total_volume >= 1))
		user.visible_message(span_warning("[user] puts the nozzle to [user.p_their()] mouth... The safety's still on!"))
		return SHAME
	else
		user.visible_message(span_warning("[user] puts the nozzle to [user.p_their()] mouth... [src] is empty!"))
		return SHAME

/obj/item/extinguisher/attack_self(mob/user)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	to_chat(user, "<span class='infoplain'>The safety is [safety ? "on" : "off"].</span>")
	return

/obj/item/extinguisher/attack_obj(obj/O, mob/living/user, params)
	if(AttemptRefill(O, user))
		refilling = TRUE
		return FALSE
	else
		return ..()

/obj/item/extinguisher/examine(mob/user)
	. = ..()
	. += span_notice("The safety is [safety ? "on" : "off"].")

/obj/item/extinguisher/proc/AttemptRefill(atom/target, mob/user)
	if(istype(target, tanktype) && target.Adjacent(user))
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, span_warning("\The [src] is already full!"))
			return TRUE
		var/obj/structure/reagent_dispensers/W = target //will it work?
		var/transferred = W.reagents.trans_to(src, max_water, transfered_by = user)
		if(transferred > 0)
			to_chat(user, span_notice("\The [src] has been refilled by [transferred] units."))
			playsound(src.loc, 'sound/effects/refill.ogg', 50, TRUE, -6)
			reagents.chem_temp = W.reagents.chem_temp
		else
			to_chat(user, span_warning("\The [W] is empty!"))

		return TRUE
	else
		return FALSE

/obj/item/extinguisher/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.loc == user)
		return NONE

	// Always skip interaction if it's a bag or table (that's not on fire)
	if(!(interacting_with.resistance_flags & ON_FIRE) && ATOM_HAS_FIRST_CLASS_INTERACTION(interacting_with))
		return NONE

	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/extinguisher/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	//TODO; Add support for reagents in water.
	if(refilling)
		refilling = FALSE
		return NONE

	if (safety)
		return NONE

	if (src.reagents.total_volume < 1)
		to_chat(usr, span_warning("\The [src] is empty!"))
		return ITEM_INTERACT_BLOCKING

	if (world.time < src.last_use + 12)
		return ITEM_INTERACT_BLOCKING

	src.last_use = world.time

	playsound(src.loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)

	var/direction = get_dir(src,interacting_with)

	if(user.buckled && isobj(user.buckled) && !user.buckled.anchored)
		var/obj/B = user.buckled
		var/movementdirection = turn(direction,180)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/extinguisher, move_chair), B, movementdirection), 1)
	else
		user.newtonian_move(turn(direction, 180))

	//Get all the turfs that can be shot at
	var/turf/T = get_turf(interacting_with)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)
	if(precision)
		var/turf/T3 = get_step(T1, turn(direction, 90))
		var/turf/T4 = get_step(T2,turn(direction, -90))
		the_targets.Add(T3,T4)

	var/list/water_particles = list()
	for(var/a in 1 to 5)
		var/obj/effect/particle_effect/water/extinguisher/water = new /obj/effect/particle_effect/water/extinguisher(get_turf(src))
		var/my_target = pick(the_targets)
		water_particles[water] = my_target
		// If precise, remove turf from targets so it won't be picked more than once
		if(precision)
			the_targets -= my_target
		var/datum/reagents/water_reagents = new /datum/reagents(5)
		water.reagents = water_reagents
		water_reagents.my_atom = water
		reagents.trans_to(water, 1, transfered_by = user)

	//Make em move dat ass, hun
	move_particles(water_particles)
	return ITEM_INTERACT_SUCCESS

//Particle movement loop
/obj/item/extinguisher/proc/move_particles(list/particles)
	var/delay = 2
	// Second loop: Get all the water particles and make them move to their target
	for(var/obj/effect/particle_effect/water/extinguisher/water as anything in particles)
		water.move_at(particles[water], delay, power)

//Chair movement loop
/obj/item/extinguisher/proc/move_chair(obj/buckled_object, movementdirection)
	var/datum/move_loop/loop = SSmove_manager.move(buckled_object, movementdirection, 1, timeout = 9, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	//This means the chair slowing down is dependant on the extinguisher existing, which is weird
	//Couldn't figure out a better way though
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(manage_chair_speed))

/obj/item/extinguisher/proc/manage_chair_speed(datum/move_loop/move/source)
	SIGNAL_HANDLER
	switch(source.lifetime)
		if(1 to 3)
			source.delay = 3
		if(4 to 5)
			source.delay = 2

/obj/item/extinguisher/AltClick(mob/user)
	if(!user.canUseTopic(src, USE_CLOSE|USE_NEED_HANDS|USE_DEXTERITY))
		return
	if(!user.is_holding(src))
		to_chat(user, span_notice("You must be holding the [src] in your hands do this!"))
		return
	EmptyExtinguisher(user)

/obj/item/extinguisher/proc/EmptyExtinguisher(mob/user)
	if(loc == user && reagents.total_volume)
		reagents.clear_reagents()

		var/turf/T = get_turf(loc)
		if(isopenturf(T))
			var/turf/open/theturf = T
			theturf.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

		user.visible_message(span_notice("[user] empties out \the [src] onto the floor using the release valve."), span_info("You quietly empty out \the [src] using its release valve."))

//firebot assembly
/obj/item/extinguisher/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/bodypart/arm/left/robot) || istype(O, /obj/item/bodypart/arm/right/robot))
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/firebot)
	else
		..()
