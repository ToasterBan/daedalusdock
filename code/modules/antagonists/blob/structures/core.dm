TYPEINFO_DEF(/obj/structure/blob/special/core)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 75, ACID = 90)

/obj/structure/blob/special/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	max_integrity = BLOB_CORE_MAX_HP
	explosion_block = 6
	point_return = -1
	health_regen = 0 //we regen in Life() instead of when pulsed
	resistance_flags = LAVA_PROOF
	strong_reinforce_range = BLOB_CORE_STRONG_REINFORCE_RANGE
	reflector_reinforce_range = BLOB_CORE_REFLECTOR_REINFORCE_RANGE
	claim_range = BLOB_CORE_CLAIM_RANGE
	pulse_range = BLOB_CORE_PULSE_RANGE
	expand_range = BLOB_CORE_EXPAND_RANGE
	max_spores = BLOB_CORE_MAX_SPORES
	ignore_syncmesh_share = TRUE

/obj/structure/blob/special/core/Initialize(mapload, client/new_overmind = null, placed = 0)
	. = ..()
	if(!placed && !overmind)
		return INITIALIZE_HINT_QDEL
	GLOB.blob_cores += src
	START_PROCESSING(SSobj, src)
	SSpoints_of_interest.make_point_of_interest(src)
	update_appearance() //so it atleast appears
	if(overmind)
		overmind.blobstrain.on_gain()
		update_appearance()

/obj/structure/blob/special/core/Destroy()
	GLOB.blob_cores -= src
	if(overmind)
		overmind.blob_core = null
		overmind = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/special/core/scannerreport()
	return "Directs the blob's expansion, gradually expands, and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/special/core/update_overlays()
	. = ..()
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		blob_overlay.color = overmind.blobstrain.color
	. += blob_overlay
	. += mutable_appearance('icons/mob/blob.dmi', "blob_core_overlay")

/obj/structure/blob/special/core/update_icon()
	. = ..()
	color = null

/obj/structure/blob/special/core/ex_act(severity, target)
	var/damage = 10 * (severity + 1) //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, BOMB, 0)

/obj/structure/blob/special/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, overmind_reagent_trigger = 1)
	. = ..()
	if(atom_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/blob/special/core/process(delta_time)
	if(QDELETED(src))
		return

	if(!overmind)
		qdel(src)

	if(overmind)
		overmind.blobstrain.core_process()
		overmind.update_health_hud()
	pulse_area(overmind, claim_range, pulse_range, expand_range)
	reinforce_area(delta_time)
	produce_spores()

/obj/structure/blob/special/core/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

/obj/structure/blob/special/core/on_changed_z_level(turf/old_turf, turf/new_turf)
	if(overmind && is_station_level(new_turf?.z))
		overmind.forceMove(get_turf(src))
	return ..()
