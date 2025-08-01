TYPEINFO_DEF(/obj/item/wirecutters)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	default_materials = list(/datum/material/iron=80)

/obj/item/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters_map"
	worn_icon_state = "cutters"
	inhand_icon_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	greyscale_config = /datum/greyscale_config/wirecutters

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

	force = 8
	throw_range = 7
	stamina_damage = 15
	stamina_cost = 10
	stamina_critical_chance = 30

	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("pinches", "nips")
	attack_verb_simple = list("pinch", "nip")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	drop_sound = 'sound/items/handling/wirecutter_drop.ogg'
	pickup_sound = 'sound/items/handling/wirecutter_pickup.ogg'
	tool_behaviour = TOOL_WIRECUTTER
	toolspeed = 1
	/// If the item should be assigned a random color
	var/random_color = TRUE
	/// List of possible random colors
	var/static/list/wirecutter_colors = list(
		"blue" = "#1861d5",
		"red" = "#951710",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#d58c18"
	)

/obj/item/wirecutters/Initialize(mapload)
	if(random_color)
		var/our_color = pick(wirecutter_colors)
		set_greyscale(colors=list(wirecutter_colors[our_color]))
	return ..()

/obj/item/wirecutters/attack(mob/living/carbon/attacked_carbon, mob/user)
	if(istype(attacked_carbon) && attacked_carbon.handcuffed \
	&& istype(attacked_carbon.handcuffed, /obj/item/restraints/handcuffs/cable) | istype(attacked_carbon.handcuffed, /obj/item/restraints/handcuffs/tape))
		user.visible_message(span_notice("[user] cuts [attacked_carbon]'s restraints with [src]!"))
		qdel(attacked_carbon.handcuffed)
		return

	return ..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is cutting at [user.p_their()] arteries with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, usesound, 50, TRUE, -1)
	return (BRUTELOSS)

TYPEINFO_DEF(/obj/item/wirecutters/abductor)
	default_materials = list(/datum/material/iron = 5000, /datum/material/silver = 2500, /datum/material/plasma = 1000, /datum/material/titanium = 2000, /datum/material/diamond = 2000)

/obj/item/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Extremely sharp wirecutters, made out of a silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cutters"
	toolspeed = 0.1
	random_color = FALSE

/obj/item/wirecutters/cyborg
	name = "powered wirecutters"
	desc = "Cuts wires with the power of ELECTRICITY. Faster than normal wirecutters."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wirecutters_cyborg"
	worn_icon_state = "cutters"
	toolspeed = 0.5
	random_color = FALSE
