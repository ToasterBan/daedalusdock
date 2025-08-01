/*
 * These absorb the functionality of the plant bag, ore satchel, etc.
 * They use the use_to_pickup, quick_gather, and quick_empty functions
 * that were already defined in weapon/storage, but which had been
 * re-implemented in other classes.
 *
 * Contains:
 * Trash Bag
 * Mining Satchel
 * Plant Bag
 * Sheet Snatcher
 * Book Bag
 *      Biowaste Bag
 *
 * -Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/bag/Initialize()
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.numerical_stacking = TRUE

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	base_icon_state = "trashbag"
	inhand_icon_state = "trashbag"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	slot_flags = null
	w_class = WEIGHT_CLASS_TINY

	storage_type = /datum/storage/trash_bag

	///max_total_storage of the storage datum.
	var/total_holdable_weight = 30

	///If true, can be inserted into the janitor cart
	var/insertable = TRUE

/obj/item/storage/bag/trash/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = total_holdable_weight
	atom_storage.max_slots = 12
	atom_storage.set_holdable(cant_hold_list = list(/obj/item/disk/nuclear))
	RegisterSignal(src, list(COMSIG_ATOM_CONTENTS_WEIGHT_CLASS_CHANGED, COMSIG_ATOM_REMOVED_ITEM, COMSIG_ATOM_STORED_ITEM), PROC_REF(update_weight_class))

/// Called when an item enters/exits storage, or a stored item changes weight class.
/obj/item/storage/bag/trash/proc/update_weight_class(datum/source)
	SIGNAL_HANDLER

	if(QDELETED(src)) // Waste of time.
		return

	var/highest_weight = initial(w_class)
	for(var/obj/item/I in src)
		if(I.w_class > highest_weight)
			highest_weight = I.w_class

	set_weight_class(highest_weight)

/obj/item/storage/bag/trash/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!"))
	playsound(loc, 'sound/items/eatfood.ogg', 50, TRUE, -1)
	return (TOXLOSS)

/obj/item/storage/bag/trash/update_icon_state()
	var/num_items = length(contents)
	if(num_items == 0)
		icon_state = base_icon_state
	else
		var/used_ratio = round(get_used_storage_ratio(), 0.01)
		if(used_ratio <= 0.33)
			icon_state = "[base_icon_state]1"

		else if(used_ratio <= 0.66)
			icon_state = "[base_icon_state]2"

		else
			icon_state = "[base_icon_state]3"
	return ..()

/// Returns the ratio of the bag's used storage, roughly.
/obj/item/storage/bag/trash/proc/get_used_storage_ratio()
	return max(length(contents) / atom_storage.max_slots, atom_storage.get_total_weight() / atom_storage.max_total_storage)

/obj/item/storage/bag/trash/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/storage/bag/trash/filled

/obj/item/storage/bag/trash/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(1, 7))
		new /obj/effect/spawner/random/trash/garbage(src)
	update_icon_state()

/obj/item/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	inhand_icon_state = "bluetrashbag"
	item_flags = NO_MAT_REDEMPTION

/obj/item/storage/bag/trash/bluespace/Initialize()
	. = ..()
	atom_storage.max_total_storage = 60
	atom_storage.max_slots = 60

/obj/item/storage/bag/trash/bluespace/cyborg
	insertable = FALSE

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	worn_icon_state = "satchel"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_NORMAL
	var/spam_protection = FALSE //If this is TRUE, the holder won't receive any messages when they fail to pick up ore through crossing it
	var/mob/listeningTo

/obj/item/storage/bag/ore/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_HUGE
	atom_storage.max_total_storage = 50
	atom_storage.numerical_stacking = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.set_holdable(list(/obj/item/stack/ore))

/obj/item/storage/bag/ore/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(pickup_ores))
	listeningTo = user

/obj/item/storage/bag/ore/unequipped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/storage/bag/ore/proc/pickup_ores(mob/living/user)
	SIGNAL_HANDLER

	var/show_message = FALSE
	var/obj/structure/ore_box/box
	var/turf/tile = get_turf(user)

	if(!isturf(tile))
		return

	var/obj/item/hand_item/grab/G = user.get_active_held_item()
	if(isgrab(G) && istype(G.affecting, /obj/structure/ore_box))
		box = G.affecting

	if(atom_storage)
		for(var/thing in tile)
			if(!is_type_in_typecache(thing, atom_storage.can_hold))
				continue
			if(box)
				user.transferItemToLoc(thing, box)
				show_message = TRUE
			else if(atom_storage.attempt_insert(thing, user))
				show_message = TRUE
			else
				if(!spam_protection)
					to_chat(user, span_warning("Your [name] is full and can't hold any more!"))
					spam_protection = TRUE
					continue
	if(show_message)
		playsound(user, SFX_RUSTLE, 50, TRUE)

		if (box)
			user.visible_message(span_notice("[user] offloads the ores beneath [user.p_them()] into [box]."), \
				span_notice("You offload the ores beneath you into your [box]."))
		else
			user.visible_message(span_notice("[user] scoops up the ores beneath [user.p_them()]."), \
				span_notice("You scoop up the ores beneath you with your [name]."))

	spam_protection = FALSE

/obj/item/storage/bag/ore/cyborg
	name = "cyborg mining satchel"

/obj/item/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for huge amounts of ore storage. It's been outfitted with anti-malfunction safety measures."
	icon_state = "satchel_bspace"

/obj/item/storage/bag/ore/holding/Initialize()
	. = ..()
	atom_storage.max_slots = INFINITY
	atom_storage.max_specific_storage = INFINITY
	atom_storage.max_total_storage = INFINITY

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	worn_icon_state = "plantbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plants/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 100
	atom_storage.set_holdable(list(
		/obj/item/food/grown,
		/obj/item/seeds,
		/obj/item/grown,
		/obj/item/reagent_containers/honeycomb,
		))
////////

/obj/item/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"

/obj/item/storage/bag/plants/portaseeder/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/storage/bag/plants/portaseeder/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user
)

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Make seeds"
	return CONTEXTUAL_SCREENTIP_SET


/obj/item/storage/bag/plants/portaseeder/examine(mob/user)
	. = ..()
	. += span_notice("Ctrl-click to activate seed extraction.")

/obj/item/storage/bag/plants/portaseeder/CtrlClick(mob/user, list/params)
	if(user.incapacitated())
		return
	for(var/obj/item/plant in contents)
		seedify(plant, 1)

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// sorry sayu your sheet snatcher is now OBSOLETE but i'm leaving it because idc

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	worn_icon_state = "satchel"

	var/capacity = 300; //the number of sheets it can carry.

/obj/item/storage/bag/sheetsnatcher/Initialize()
	. = ..()
	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(list(
			/obj/item/stack/sheet
			),
		list(
			/obj/item/stack/sheet/mineral/sandstone,
			/obj/item/stack/sheet/mineral/wood
			))
	atom_storage.max_total_storage = capacity / 2

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

// -----------------------------
//           Book bag
// -----------------------------

/obj/item/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	worn_icon_state = "bookbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/books/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21
	atom_storage.max_slots = 7
	atom_storage.set_holdable(list(
		/obj/item/book,
		/obj/item/storage/book,
		/obj/item/spellbook
		))

/*
 * Trays - Agouri
 */
TYPEINFO_DEF(/obj/item/storage/bag/tray)
	default_materials = list(/datum/material/iron=3000)

/obj/item/storage/bag/tray
	name = "serving tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	worn_icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_range = 5
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	custom_price = PAYCHECK_ASSISTANT * 0.6

/obj/item/storage/bag/tray/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY //Plates are required bulky to keep them out of backpacks
	atom_storage.set_holdable(list(
		/obj/item/clothing/mask/cigarette,
		/obj/item/food,
		/obj/item/kitchen,
		/obj/item/lighter,
		/obj/item/organ,
		/obj/item/plate,
		/obj/item/reagent_containers/food,
		/obj/item/reagent_containers/cup,
		/obj/item/clothing/mask/cigarette,
		/obj/item/storage/fancy,
		/obj/item/storage/box/gum,
		/obj/item/storage/box/matches,
		/obj/item/food,
		/obj/item/trash,
		/obj/item/lighter,
		/obj/item/rollingpaper,
		/obj/item/kitchen,
		/obj/item/organ,
		)) //Should cover: Bottles, Beakers, Bowls, Booze, Glasses, Food, Food Containers, Food Trash, Organs, Tobacco Products, Lighters, and Kitchen Tools.
	atom_storage.insert_preposition = "on"
	atom_storage.max_slots = 7

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	atom_storage.remove_all(user)
	// Make each item scatter a bit
	for(var/obj/item/tray_item in oldContents)
		do_scatter(tray_item)

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, TRUE)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, TRUE)

	if(ishuman(M))
		if(prob(10))
			M.Paralyze(40)
	update_appearance()

/obj/item/storage/bag/tray/proc/do_scatter(obj/item/tray_item)
	var/delay = rand(2,4)
	var/datum/move_loop/loop = SSmove_manager.move_rand(tray_item, list(NORTH,SOUTH,EAST,WEST), delay, timeout = rand(1, 2) * delay, flags = MOVEMENT_LOOP_START_FAST)
	//This does mean scattering is tied to the tray. Not sure how better to handle it
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(change_speed))

/obj/item/storage/bag/tray/proc/change_speed(datum/move_loop/source)
	SIGNAL_HANDLER
	var/new_delay = rand(2, 4)
	var/count = source.lifetime / source.delay
	source.lifetime = count * new_delay
	source.delay = new_delay

/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		var/mutable_appearance/I_copy = new(I)
		I_copy.plane = FLOAT_PLANE
		I_copy.layer = FLOAT_LAYER
		. += I_copy

/obj/item/storage/bag/tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance()

/obj/item/storage/bag/tray/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()

/obj/item/storage/bag/tray/cafeteria
	name = "cafeteria tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "foodtray"
	desc = "A cheap metal tray to pile today's meal onto."

/*
 * Chemistry bag
 */

/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bag"
	worn_icon_state = "chembag"
	desc = "A bag for storing pills, patches, and bottles."
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/chemistry/Initialize()
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/chem_pack,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/chem_pack,
		/obj/item/reagent_containers/pill
		))

/*
 *  Biowaste bag (mostly for virologists)
 */

/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "biobag"
	worn_icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other virulent materials."
	resistance_flags = FLAMMABLE
	slot_flags = null //Primarily to limit slime extract storage on one person at a time

/obj/item/storage/bag/bio/Initialize()
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 25
	atom_storage.set_holdable(list(
		/obj/item/bodypart,
		/obj/item/slime_extract,
		/obj/item/food/monkeycube,
		/obj/item/healthanalyzer,
		/obj/item/organ,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/food/monkeycube,
		/obj/item/organ,
		/obj/item/healthanalyzer
		))

/*
 *  Science bag (mostly for xenobiologists)
 */

/obj/item/storage/bag/xeno
	name = "science bag"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "xenobag"
	worn_icon_state = "xenobag"
	desc = "A bag for the storage and transport of anomalous materials."
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/xeno/Initialize()
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 25
	atom_storage.set_holdable(list(
		/obj/item/bodypart,
		/obj/item/food/deadmouse,
		/obj/item/food/monkeycube,
		/obj/item/organ,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/food/deadmouse,
		/obj/item/food/monkeycube,
		/obj/item/organ,
		/obj/item/bodypart,
		))

/*
 *  Construction bag (for engineering, holds stock parts and electronics)
 */

/obj/item/storage/bag/construction
	name = "construction bag"
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	worn_icon_state = "construction_bag"
	desc = "A bag for storing small construction components."
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/construction/Initialize()
	. = ..()
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 50
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.set_holdable(list(
		/obj/item/assembly,
		/obj/item/stock_parts,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/stack/cable_coil,
		/obj/item/circuitboard,
		/obj/item/electronics,
		/obj/item/wallframe/camera
		))

/obj/item/storage/bag/harpoon_quiver
	name = "harpoon quiver"
	desc = "A quiver for holding harpoons."
	icon_state = "quiver"
	inhand_icon_state = "quiver"
	worn_icon_state = "harpoon_quiver"

/obj/item/storage/bag/harpoon_quiver/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	atom_storage.max_slots = 40
	atom_storage.max_total_storage = 100
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/caseless/harpoon
		))

/obj/item/storage/bag/harpoon_quiver/PopulateContents()
	for(var/i in 1 to 40)
		new /obj/item/ammo_casing/caseless/harpoon(src)
