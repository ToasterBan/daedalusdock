#define CELL_DRAIN_TIME 35
#define CELL_POWER_GAIN 60
#define CELL_POWER_DRAIN 750

TYPEINFO_DEF(/obj/item/stock_parts/cell)
	default_materials = list(/datum/material/iron=700, /datum/material/glass=50)

/**
 * # Power cell
 *
 * Batteries.
 */
/obj/item/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	inhand_icon_state = "cell"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 5
	throwforce = 5
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	///Current charge in cell units
	var/charge = 0
	///Maximum charge in cell units
	var/maxcharge = 1000
	grind_results = list(/datum/reagent/lithium = 15, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	///If the cell has been booby-trapped by injecting it with plasma. Chance on use() to explode.
	var/rigged = FALSE
	///If the power cell was damaged by an explosion, chance for it to become corrupted and function the same as rigged.
	var/corrupted = FALSE
	///how much power is given every tick in a recharger
	var/chargerate = 100
	///If true, the cell will state it's maximum charge in it's description
	var/ratingdesc = TRUE
	///If it's a grown that acts as a battery, add a wire overlay to it.
	var/grown_battery = FALSE
	///What charge lige sprite to use, null if no light
	var/charge_light_type = "standard"
	///What connector sprite to use when in a cell charger, null if no connectors
	var/connector_type = "standard"
	///Does the cell start without any charge?
	var/empty = FALSE

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/Initialize(mapload, override_maxcharge)
	. = ..()
	create_reagents(5, INJECTABLE | DRAINABLE)
	if (override_maxcharge)
		maxcharge = override_maxcharge
	rating = max(round(maxcharge / 10000, 1), 1)
	if(!charge)
		charge = maxcharge
	if(empty)
		charge = 0
	if(ratingdesc)
		desc += " This one has a rating of [display_energy(maxcharge)][prob(10) ? ", and you should not swallow it" : ""]." //joke works better if it's not on every cell
	update_appearance()

/obj/item/stock_parts/cell/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, PROC_REF(on_reagents_del))

/// Handles properly detaching signal hooks.
/obj/item/stock_parts/cell/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_PARENT_QDELETING))
	return NONE

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += mutable_appearance('icons/obj/power.dmi', "grown_wires")
	if((charge < 0.01) || !charge_light_type)
		return
	. += mutable_appearance('icons/obj/power.dmi', "cell-[charge_light_type]-o[(percent() >= 99.5) ? 2 : 1]")

/obj/item/stock_parts/cell/proc/percent() // return % charge of cell
	return 100 * charge / maxcharge

// use power from a cell
/obj/item/stock_parts/cell/use(amount, force)
	if(rigged && amount > 0)
		explode()
		return FALSE
	if(!force && charge < amount)
		return FALSE
	charge = max(charge - amount, 0)
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.record_feedback("tally", "cell_used", 1, type)
	return TRUE

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()
	if(rigged)
		. += span_danger("This power cell seems to be faulty!")
	else
		. += "The charge meter reads [CEILING(percent(), 0.1)]%." //so it doesn't say 0% charge when the overlay indicates it still has charge

/obj/item/stock_parts/cell/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (FIRELOSS)

/obj/item/stock_parts/cell/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	rigged = (corrupted || holder.has_reagent(/datum/reagent/toxin/plasma, 5)) ? TRUE : FALSE //has_reagent returns the reagent datum
	return NONE


/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
	if (charge==0)
		return
	var/range_devastation = -1 //round(charge/11000)
	var/range_heavy = round(sqrt(charge)/60)
	var/range_light = round(sqrt(charge)/30)
	var/range_flash = range_light
	if (range_light==0)
		rigged = FALSE
		corrupt()
		return

	message_admins("[ADMIN_LOOKUPFLW(usr)] has triggered a rigged/corrupted power cell explosion at [AREACOORD(T)].")
	log_game("[key_name(usr)] has triggered a rigged/corrupted power cell explosion at [AREACOORD(T)].")

	//explosion(T, 0, 1, 2, 2)
	explosion(src, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash)
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (prob(10))
		rigged = TRUE //broken batterys are dangerous
		corrupted = TRUE

/obj/item/stock_parts/cell/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0

/obj/item/stock_parts/cell/ex_act(severity, target)
	. = ..()
	if(QDELETED(src))
		return

	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				corrupt()
		if(EXPLODE_LIGHT)
			if(prob(25))
				corrupt()

/obj/item/stock_parts/cell/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/stomach/maybe_stomach = H.getorganslot(ORGAN_SLOT_STOMACH)

		if(istype(maybe_stomach, /obj/item/organ/stomach/ethereal))

			var/charge_limit = ETHEREAL_CHARGE_DANGEROUS - CELL_POWER_GAIN
			var/obj/item/organ/stomach/ethereal/stomach = maybe_stomach
			if((stomach.drain_time > world.time) || !stomach)
				return
			if(charge < CELL_POWER_DRAIN)
				to_chat(H, span_warning("[src] doesn't have enough power!"))
				return
			if(stomach.crystal_charge > charge_limit)
				to_chat(H, span_warning("Your charge is full!"))
				return
			to_chat(H, span_notice("You begin clumsily channeling power from [src] into your body."))
			stomach.drain_time = world.time + CELL_DRAIN_TIME
			if(do_after(user, src, CELL_DRAIN_TIME))
				if((charge < CELL_POWER_DRAIN) || (stomach.crystal_charge > charge_limit))
					return
				if(istype(stomach))
					to_chat(H, span_notice("You receive some charge from [src], wasting some in the process."))
					stomach.adjust_charge(CELL_POWER_GAIN)
					charge -= CELL_POWER_DRAIN //you waste way more than you receive, so that ethereals cant just steal one cell and forget about hunger
				else
					to_chat(H, span_warning("You can't receive charge from [src]!"))
			return


/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	EX_ACT(src, EXPLODE_DEVASTATE)

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return clamp(20 + round(charge/25000), 20, 195) + rand(-5,5)
	else
		return 0

/obj/item/stock_parts/cell/get_part_rating()
	return maxcharge * 10 + charge

/* Cell variants*/
/obj/item/stock_parts/cell/empty
	empty = TRUE

TYPEINFO_DEF(/obj/item/stock_parts/cell/crap)
	default_materials = list(/datum/material/glass=40)

/obj/item/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = 500

/obj/item/stock_parts/cell/crap/empty
	empty = TRUE

TYPEINFO_DEF(/obj/item/stock_parts/cell/upgraded)
	default_materials = list(/datum/material/glass=50)

/obj/item/stock_parts/cell/upgraded
	name = "upgraded power cell"
	desc = "A power cell with a slightly higher capacity than normal!"
	maxcharge = 2500
	chargerate = 1000

/obj/item/stock_parts/cell/upgraded/plus
	name = "upgraded power cell+"
	desc = "A power cell with an even higher capacity than the base model!"
	maxcharge = 5000

TYPEINFO_DEF(/obj/item/stock_parts/cell/secborg)
	default_materials = list(/datum/material/glass=40)

/obj/item/stock_parts/cell/secborg
	name = "security borg rechargeable D battery"
	maxcharge = 600 //600 max charge / 100 charge per shot = six shots

/obj/item/stock_parts/cell/secborg/empty
	empty = TRUE

/obj/item/stock_parts/cell/mini_egun
	name = "miniature energy gun power cell"
	maxcharge = 600

/obj/item/stock_parts/cell/hos_gun
	name = "X-01 multiphase energy gun power cell"
	maxcharge = 1200

/obj/item/stock_parts/cell/pulse //200 pulse shots
	name = "pulse rifle power cell"
	maxcharge = 40000
	chargerate = 1500

/obj/item/stock_parts/cell/pulse/carbine //25 pulse shots
	name = "pulse carbine power cell"
	maxcharge = 5000

/obj/item/stock_parts/cell/pulse/pistol //10 pulse shots
	name = "pulse pistol power cell"
	maxcharge = 2000

TYPEINFO_DEF(/obj/item/stock_parts/cell/high)
	default_materials = list(/datum/material/glass=60)

/obj/item/stock_parts/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = 10000
	chargerate = 1500

/obj/item/stock_parts/cell/high/empty
	empty = TRUE

TYPEINFO_DEF(/obj/item/stock_parts/cell/super)
	default_materials = list(/datum/material/glass=300)

/obj/item/stock_parts/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = 20000
	chargerate = 2000

/obj/item/stock_parts/cell/super/empty
	empty = TRUE

TYPEINFO_DEF(/obj/item/stock_parts/cell/hyper)
	default_materials = list(/datum/material/glass=400)

/obj/item/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = 30000
	chargerate = 3000

/obj/item/stock_parts/cell/hyper/empty
	empty = TRUE

TYPEINFO_DEF(/obj/item/stock_parts/cell/bluespace)
	default_materials = list(/datum/material/glass=600)

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable transdimensional power cell."
	icon_state = "bscell"
	maxcharge = 40000
	chargerate = 4000

/obj/item/stock_parts/cell/bluespace/empty
	empty = TRUE

TYPEINFO_DEF(/obj/item/stock_parts/cell/infinite)
	default_materials = list(/datum/material/glass=1000)

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell"
	icon_state = "icell"
	maxcharge = INFINITY //little disappointing if you examine it and it's not huge
	chargerate = INFINITY
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/use()
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell that produces energy seemingly out of nowhere."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cell"
	maxcharge = 50000
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/abductor/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

TYPEINFO_DEF(/obj/item/stock_parts/cell/potato)
	default_materials = null

/obj/item/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch based power cell."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	charge = 100
	maxcharge = 300
	charge_light_type = null
	connector_type = null
	grown_battery = TRUE //it has the overlays for wires
	custom_premium_price = PAYCHECK_ASSISTANT

/obj/item/stock_parts/cell/emproof
	name = "\improper EMP-proof cell"
	desc = "An EMP-proof cell."
	maxcharge = 500

/obj/item/stock_parts/cell/emproof/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/item/stock_parts/cell/emproof/empty
	empty = TRUE

/obj/item/stock_parts/cell/emproof/corrupt()
	return

TYPEINFO_DEF(/obj/item/stock_parts/cell/emproof/slime)
	default_materials = null

/obj/item/stock_parts/cell/emproof/slime
	name = "EMP-proof slime core"
	desc = "A yellow slime core infused with plasma. Its organic nature makes it immune to EMPs."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	maxcharge = 5000
	charge_light_type = null
	connector_type = "slimecore"

/obj/item/stock_parts/cell/beam_rifle
	name = "beam rifle capacitor"
	desc = "A high powered capacitor that can provide huge amounts of energy in an instant."
	maxcharge = 50000
	chargerate = 5000 //Extremely energy intensive

/obj/item/stock_parts/cell/beam_rifle/corrupt()
	return

/obj/item/stock_parts/cell/beam_rifle/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	charge = clamp((charge-(10000/severity)),0,maxcharge)

TYPEINFO_DEF(/obj/item/stock_parts/cell/emergency_light)
	default_materials = list(/datum/material/glass = 20)

/obj/item/stock_parts/cell/emergency_light
	name = "miniature power cell"
	desc = "A tiny power cell with a very low power capacity. Used in light fixtures to power them in the event of an outage."
	maxcharge = 120 //Emergency lights use 0.2 W per tick, meaning ~10 minutes of emergency power from a cell
	w_class = WEIGHT_CLASS_TINY

/obj/item/stock_parts/cell/emergency_light/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(!A.lightswitch || !A.light_power)
		charge = 0 //For naturally depowered areas, we start with no power

TYPEINFO_DEF(/obj/item/stock_parts/cell/crystal_cell)
	default_materials = null

/obj/item/stock_parts/cell/crystal_cell
	name = "crystal power cell"
	desc = "A very high power cell made from crystallized plasma"
	icon_state = "crystal_cell"
	maxcharge = 50000
	chargerate = 0
	charge_light_type = null
	connector_type = "crystal"
	grind_results = null

/obj/item/stock_parts/cell/inducer_supply
	maxcharge = 5000

#undef CELL_DRAIN_TIME
#undef CELL_POWER_GAIN
#undef CELL_POWER_DRAIN
