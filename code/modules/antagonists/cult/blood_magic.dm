/datum/action/innate/cult/blood_magic //Blood magic handles the creation of blood spells (formerly talismans)
	name = "Prepare Blood Magic"
	button_icon_state = "carve"
	desc = "Prepare blood magic by carving runes into your flesh. This is easier with an <b>empowering rune</b>."
	default_button_position = DEFAULT_BLOODSPELLS
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/cult/blood_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/cult/blood_magic/IsAvailable(feedback = FALSE)
	if(!IS_CULTIST(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/blood_magic/proc/Positioning()
	for(var/datum/hud/hud as anything in viewers)
		var/our_view = hud.mymob?.client?.view || "15x15"
		var/atom/movable/screen/movable/action_button/button = viewers[hud]
		var/position = screen_loc_to_offset(button.screen_loc)
		var/spells_iterated = 0
		for(var/datum/action/innate/cult/blood_spell/blood_spell in spells)
			spells_iterated += 1
			if(blood_spell.positioned)
				continue
			var/atom/movable/screen/movable/action_button/moving_button = blood_spell.viewers[hud]
			if(!moving_button)
				continue
			var/our_x = position[1] + spells_iterated * world.icon_size // Offset any new buttons into our list
			hud.position_action(moving_button, offset_to_screen_loc(our_x, position[2], our_view))
			blood_spell.positioned = TRUE

/datum/action/innate/cult/blood_magic/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	for(var/obj/effect/rune/empower/R in range(1, owner))
		rune = TRUE
		break
	if(rune)
		limit = MAX_BLOODCHARGE
	if(length(spells) >= limit)
		if(rune)
			to_chat(owner, span_cultitalic("You cannot store more than [MAX_BLOODCHARGE] spells. <b>Pick a spell to remove.</b>"))
		else
			to_chat(owner, span_cultitalic("<b><u>You cannot store more than [RUNELESS_MAX_BLOODCHARGE] spells without an empowering rune! Pick a spell to remove.</b></u>"))
		var/nullify_spell = tgui_input_list(owner, "Spell to remove", "Current Spells", spells)
		if(isnull(nullify_spell))
			return
		qdel(nullify_spell)
	var/entered_spell_name
	var/datum/action/innate/cult/blood_spell/BS
	var/list/possible_spells = list()
	for(var/I in subtypesof(/datum/action/innate/cult/blood_spell))
		var/datum/action/innate/cult/blood_spell/J = I
		var/cult_name = initial(J.name)
		possible_spells[cult_name] = J
	possible_spells += "(REMOVE SPELL)"
	entered_spell_name = tgui_input_list(owner, "Blood spell to prepare", "Spell Choices", possible_spells)
	if(isnull(entered_spell_name))
		return
	if(entered_spell_name == "(REMOVE SPELL)")
		var/nullify_spell = tgui_input_list(owner, "Spell to remove", "Current Spells", spells)
		if(isnull(nullify_spell))
			return
		qdel(nullify_spell)
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS || (rune && !(locate(/obj/effect/rune/empower) in range(1, owner))) || (length(spells) >= limit))
		return
	to_chat(owner,span_warning("You begin to carve unnatural symbols into your flesh!"))
	SEND_SOUND(owner, sound('sound/weapons/slice.ogg',0,1,10))
	if(!channeling)
		channeling = TRUE
	else
		to_chat(owner, span_cultitalic("You are already invoking blood magic!"))
		return
	if(do_after(owner, time = 100 - rune*60))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.bleed(40 - rune*32)
		var/datum/action/innate/cult/blood_spell/new_spell = new BS(owner)
		new_spell.Grant(owner, src)
		spells += new_spell
		Positioning()
		to_chat(owner, span_warning("Your wounds glow with power, you have prepared a [new_spell.name] invocation!"))
	channeling = FALSE

/datum/action/innate/cult/blood_spell //The next generation of talismans, handles storage/creation of blood magic
	name = "Blood Magic"
	button_icon_state = "telerune"
	desc = "Fear the Old Blood."
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/blood_magic/hand_magic
	var/datum/action/innate/cult/blood_magic/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation
	var/health_cost = 0
	/// Have we already been positioned into our starting location?
	var/positioned = FALSE

/datum/action/innate/cult/blood_spell/Grant(mob/living/owner, datum/action/innate/cult/blood_magic/BM)
	if(health_cost)
		desc += "<br>Deals <u>[health_cost] damage</u> to your arm per use."
	base_desc = desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	all_magic = BM
	return ..()

/datum/action/innate/cult/blood_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/cult/blood_spell/IsAvailable(feedback = FALSE)
	if(!IS_CULTIST(owner) || owner.incapacitated() || !charges)
		return FALSE
	return ..()

/datum/action/innate/cult/blood_spell/Activate()
	if(magic_path) //If this spell flows from the hand
		if(!hand_magic)
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, span_warning("You have no empty hand for invoking blood magic!"))
				return
			to_chat(owner, span_notice("Your wounds glow as you invoke the [name]."))
			return
		if(hand_magic)
			qdel(hand_magic)
			hand_magic = null
			to_chat(owner, span_warning("You snuff out the spell, saving it for later."))


//Cult Blood Spells
/datum/action/innate/cult/blood_spell/stun
	name = "Stun"
	desc = "Empowers your hand to stun and mute a victim on contact."
	button_icon_state = "hand"
	magic_path = "/obj/item/melee/blood_magic/stun"
	health_cost = 10

/datum/action/innate/cult/blood_spell/teleport
	name = "Teleport"
	desc = "Empowers your hand to teleport yourself or another cultist to a teleport rune on contact."
	button_icon_state = "tele"
	magic_path = "/obj/item/melee/blood_magic/teleport"
	health_cost = 7

/datum/action/innate/cult/blood_spell/emp
	name = "Electromagnetic Pulse"
	desc = "Emits a large electromagnetic pulse."
	button_icon_state = "emp"
	health_cost = 10
	invocation = "Ta'gh fara'qha fel d'amar det!"

/datum/action/innate/cult/blood_spell/emp/Activate()
	owner.whisper(invocation, language = /datum/language/common)
	owner.visible_message(span_warning("[owner]'s hand flashes a bright blue!"), \
		span_cultitalic("You speak the cursed words, emitting an EMP blast from your hand."))
	empulse(owner, 2, 5)
	charges--
	if(charges<=0)
		qdel(src)

/datum/action/innate/cult/blood_spell/shackles
	name = "Shadow Shackles"
	desc = "Empowers your hand to start handcuffing victim on contact, and mute them if successful."
	button_icon_state = "cuff"
	charges = 4
	magic_path = "/obj/item/melee/blood_magic/shackles"

/datum/action/innate/cult/blood_spell/construction
	name = "Twisted Construction"
	desc = "Empowers your hand to corrupt certain metalic objects.<br><u>Converts:</u><br>Plasteel into runed metal<br>50 metal into a construct shell<br>Living cyborgs into constructs after a delay<br>Cyborg shells into construct shells<br>Purified soulstones (and any shades inside) into cultist soulstones<br>Airlocks into brittle runed airlocks after a delay (harm intent)"
	button_icon_state = "transmute"
	magic_path = "/obj/item/melee/blood_magic/construction"
	health_cost = 12

/datum/action/innate/cult/blood_spell/equipment
	name = "Summon Combat Equipment"
	desc = "Empowers your hand to summon combat gear onto a cultist you touch, including cult armor, a cult bola, and a cult sword. Not recommended for use before the blood cult's presence has been revealed."
	button_icon_state = "equip"
	magic_path = "/obj/item/melee/blood_magic/armor"

/datum/action/innate/cult/blood_spell/dagger
	name = "Summon Ritual Dagger"
	desc = "Allows you to summon a ritual dagger, in case you've lost the dagger that was given to you."
	invocation = "Wur d'dai leev'mai k'sagan!" //where did I leave my keys, again?
	button_icon_state = "equip" //this is the same icon that summon equipment uses, but eh, I'm not a spriter
	/// The item given to the cultist when the spell is invoked. Typepath.
	var/obj/item/summoned_type = /obj/item/melee/cultblade/dagger

/datum/action/innate/cult/blood_spell/dagger/Activate()
	var/turf/owner_turf = get_turf(owner)
	owner.whisper(invocation, language = /datum/language/common)
	owner.visible_message(span_warning("[owner]'s hand glows red for a moment."), \
		span_cultitalic("Your plea for aid is answered, and light begins to shimmer and take form within your hand!"))
	var/obj/item/summoned_blade = new summoned_type(owner_turf)
	if(owner.put_in_hands(summoned_blade))
		to_chat(owner, span_warning("A [summoned_blade] appears in your hand!"))
	else
		owner.visible_message(span_warning("A [summoned_blade] appears at [owner]'s feet!"), \
			span_cultitalic("A [summoned_blade] materializes at your feet."))
	SEND_SOUND(owner, sound('sound/effects/magic.ogg', FALSE, 0, 25))
	charges--
	if(charges <= 0)
		qdel(src)

/datum/action/innate/cult/blood_spell/horror
	name = "Hallucinations"
	desc = "Gives hallucinations to a target at range. A silent and invisible spell."
	button_icon_state = "horror"
	charges = 4
	click_action = TRUE
	enable_text = span_cult("You prepare to horrify a target...")
	disable_text = span_cult("You dispel the magic...")

/datum/action/innate/cult/blood_spell/horror/InterceptClickOn(mob/living/invoker, params, atom/clicked_on)
	var/turf/caller_turf = get_turf(invoker)
	if(!isturf(caller_turf))
		return FALSE

	if(!ishuman(clicked_on) || get_dist(invoker, clicked_on) > 7)
		return FALSE

	var/mob/living/carbon/human/human_clicked = clicked_on
	if(IS_CULTIST(human_clicked))
		return FALSE

	return ..()

/datum/action/innate/cult/blood_spell/horror/do_ability(mob/living/invoker, mob/living/carbon/human/clicked_on)

	clicked_on.hallucination = max(clicked_on.hallucination, 120)
	SEND_SOUND(invoker, sound('sound/effects/ghost.ogg', FALSE, TRUE, 50))

	var/image/sparkle_image = image('icons/effects/cult/effects.dmi', clicked_on, "bloodsparkles", ABOVE_MOB_LAYER)
	clicked_on.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/cult, "cult_apoc", sparkle_image, NONE)

	addtimer(CALLBACK(clicked_on, TYPE_PROC_REF(/atom, remove_alt_appearance), "cult_apoc", TRUE), 4 MINUTES, TIMER_OVERRIDE|TIMER_UNIQUE)
	to_chat(invoker, span_cultbold("[clicked_on] has been cursed with living nightmares!"))

	charges--
	desc = base_desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	build_all_button_icons()
	if(charges <= 0)
		to_chat(invoker, span_cult("You have exhausted the spell's power!"))
		qdel(src)

	return TRUE

/datum/action/innate/cult/blood_spell/veiling
	name = "Conceal Presence"
	desc = "Alternates between hiding and revealing nearby cult structures and runes."
	invocation = "Kla'atu barada nikt'o!"
	button_icon_state = "gone"
	charges = 10
	var/revealing = FALSE //if it reveals or not

/datum/action/innate/cult/blood_spell/veiling/Activate()
	if(!revealing)
		owner.visible_message(span_warning("Thin grey dust falls from [owner]'s hand!"), \
			span_cultitalic("You invoke the veiling spell, hiding nearby runes."))
		charges--
		SEND_SOUND(owner, sound('sound/magic/smoke.ogg',0,1,25))
		owner.whisper(invocation, language = /datum/language/common)
		for(var/obj/effect/rune/R in range(5,owner))
			R.conceal()
		for(var/obj/structure/destructible/cult/S in range(5,owner))
			S.conceal()
		for(var/turf/open/floor/engine/cult/T  in range(5,owner))
			if(!T.realappearance)
				continue
			T.realappearance.alpha = 0
		for(var/obj/machinery/door/airlock/cult/AL in range(5, owner))
			AL.conceal()
		revealing = TRUE
		name = "Reveal Runes"
		button_icon_state = "back"
	else
		owner.visible_message(span_warning("A flash of light shines from [owner]'s hand!"), \
			span_cultitalic("You invoke the counterspell, revealing nearby runes."))
		charges--
		owner.whisper(invocation, language = /datum/language/common)
		SEND_SOUND(owner, sound('sound/magic/enter_blood.ogg',0,1,25))
		for(var/obj/effect/rune/R in range(7,owner)) //More range in case you weren't standing in exactly the same spot
			R.reveal()
		for(var/obj/structure/destructible/cult/S in range(6,owner))
			S.reveal()
		for(var/turf/open/floor/engine/cult/T  in range(6,owner))
			if(!T.realappearance)
				continue
			T.realappearance.alpha = initial(T.realappearance.alpha)
		for(var/obj/machinery/door/airlock/cult/AL in range(6, owner))
			AL.reveal()
		revealing = FALSE
		name = "Conceal Runes"
		button_icon_state = "gone"
	if(charges<= 0)
		qdel(src)
	desc = base_desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	build_all_button_icons()

/datum/action/innate/cult/blood_spell/manipulation
	name = "Blood Rites"
	desc = "Empowers your hand to absorb blood to be used for advanced rites, or heal a cultist on contact. Use the spell in-hand to cast advanced rites."
	invocation = "Fel'th Dol Ab'orod!"
	button_icon_state = "manip"
	charges = 5
	magic_path = "/obj/item/melee/blood_magic/manipulator"


// The "magic hand" items
/obj/item/melee/blood_magic
	name = "\improper magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/invocation
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the spell
	var/datum/action/innate/cult/blood_spell/source

/obj/item/melee/blood_magic/Initialize(mapload, spell)
	. = ..()
	if(spell)
		source = spell
		uses = source.charges
		health_cost = source.health_cost

/obj/item/melee/blood_magic/Destroy()
	if(!QDELETED(source))
		if(uses <= 0)
			source.hand_magic = null
			qdel(source)
			source = null
		else
			source.hand_magic = null
			source.charges = uses
			source.desc = source.base_desc
			source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
			source.build_all_button_icons()
	return ..()

/obj/item/melee/blood_magic/attack_self(mob/living/user)
	cast_spell(user, user)

/obj/item/melee/blood_magic/attack(mob/living/M, mob/living/carbon/user)
	if(!cast_spell(M, user))
		return
	log_combat(user, M, "used a cult spell on", source.name, "")
	SSblackbox.record_feedback("tally", "cult_spell_invoke", 1, "[name]")
	user.do_attack_animation(M)

/obj/item/melee/blood_magic/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(user) || !IS_CULTIST(user))
		uses = 0
		qdel(src)
		return ITEM_INTERACT_BLOCKING

	if(isliving(interacting_with))
		return ITEM_INTERACT_ATTACK

	if(!cast_spell(interacting_with, user))
		return ITEM_INTERACT_BLOCKING

	user.do_attack_animation(interacting_with)
	log_combat(user, interacting_with, "used a cult spell on", source.name, "")
	SSblackbox.record_feedback("tally", "cult_spell_invoke", 1, "[name]")
	return ITEM_INTERACT_SUCCESS

/obj/item/melee/blood_magic/proc/cast_spell(atom/target, mob/living/carbon/user)
	if(invocation)
		user.whisper(invocation, language = /datum/language/common, forced = "cult invocation")
	if(health_cost)
		if(user.active_hand_index == 1)
			user.apply_damage(health_cost, BRUTE, BODY_ZONE_L_ARM)
		else
			user.apply_damage(health_cost, BRUTE, BODY_ZONE_R_ARM)
	if(uses <= 0)
		qdel(src)
		return TRUE
	if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
		source.build_all_button_icons()
	return TRUE

//Stun
/obj/item/melee/blood_magic/stun
	name = "Stunning Aura"
	desc = "Will stun and mute a weak-minded victim on contact."
	color = RUNE_COLOR_RED
	invocation = "Fuu ma'jin!"

/obj/item/melee/blood_magic/stun/cast_spell(mob/living/target, mob/living/carbon/user)
	if(!isliving(target))
		return
	if(IS_CULTIST(target))
		return

	if(IS_CULTIST(user))
		user.visible_message(span_warning("[user] holds up [user.p_their()] hand, which explodes in a flash of red light!"), \
							span_cultitalic("You attempt to stun [target] with the spell!"))

		user.mob_light(_range = 3, _color = LIGHT_COLOR_BLOOD_MAGIC, _duration = 0.2 SECONDS)

		if(target.can_block_magic())
			to_chat(user, span_warning("The spell had no effect!"))
		else
			to_chat(user, span_cultitalic("In a brilliant flash of red, [target] falls to the ground!"))
			target.Paralyze(16 SECONDS)
			target.flash_act(1, TRUE)
			if(issilicon(target))
				var/mob/living/silicon/silicon_target = target
				silicon_target.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/carbon_target = target
				carbon_target.silent += 6
				carbon_target.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/speech/stutter)
				carbon_target.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/speech/slurring/cult)
				carbon_target.set_timed_status_effect(30 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		uses--
	return ..()

//Teleportation
/obj/item/melee/blood_magic/teleport
	name = "Teleporting Aura"
	color = RUNE_COLOR_TELEPORT
	desc = "Will teleport a cultist to a teleport rune on contact."
	invocation = "Sas'so c'arta forbici!"

/obj/item/melee/blood_magic/teleport/cast_spell(atom/target, mob/living/carbon/user)
	var/mob/mob_target = target
	if(istype(mob_target) && !IS_CULTIST(mob_target))
		to_chat(user, span_warning("You can only teleport cultists with this spell!"))
		return

	if(!IS_CULTIST(user))
		return

	var/list/potential_runes = list()
	var/list/teleportnames = list()
	for(var/obj/effect/rune/teleport/teleport_rune as anything in GLOB.teleport_runes)
		potential_runes[avoid_assoc_duplicate_keys(teleport_rune.listkey, teleportnames)] = teleport_rune

	if(!length(potential_runes))
		to_chat(user, span_warning("There are no valid runes to teleport to!"))
		return

	var/turf/T = get_turf(src)
	if(is_away_level(T.z))
		to_chat(user, span_cultitalic("You are not in the right dimension!"))
		return

	var/input_rune_key = tgui_input_list(user, "Rune to teleport to", "Teleportation Target", potential_runes) //we know what key they picked
	if(isnull(input_rune_key))
		return
	if(isnull(potential_runes[input_rune_key]))
		to_chat(user, span_warning("You must pick a valid rune!"))
		return
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !actual_selected_rune)
		return
	var/turf/dest = get_turf(actual_selected_rune)
	if(dest.is_blocked_turf(TRUE))
		to_chat(user, span_warning("The target rune is blocked. You cannot teleport there."))
		return
	uses--
	var/turf/origin = get_turf(user)
	var/mob/living/L = target
	if(do_teleport(L, dest, channel = TELEPORT_CHANNEL_CULT))
		origin.visible_message(span_warning("Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] with a sharp crack!"), \
			span_cultitalic("You speak the words of the talisman and find yourself somewhere else!"), "<i>You hear a sharp crack.</i>")
		dest.visible_message(span_warning("There is a boom of outrushing air as something appears above the rune!"), null, "<i>You hear a boom.</i>")
	return ..()

//Shackles
/obj/item/melee/blood_magic/shackles
	name = "Shackling Aura"
	desc = "Will start handcuffing a victim on contact, and mute them if successful."
	invocation = "In'totum Lig'abis!"
	color = "#000000" // black

/obj/item/melee/blood_magic/shackles/cast_spell(atom/target, mob/living/carbon/user)
	if(IS_CULTIST(user) && iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.canBeHandcuffed())
			CuffAttack(C, user)
		else
			user.visible_message(span_cultitalic("This victim doesn't have enough arms to complete the restraint!"))
			return
		return ..()

/obj/item/melee/blood_magic/shackles/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
		C.visible_message(span_danger("[user] begins restraining [C] with dark magic!"), \
								span_userdanger("[user] begins shaping dark magic shackles around your wrists!"))
		if(do_after(user, C, 30) && C.equip_to_slot_if_possible(new /obj/item/restraints/handcuffs/energy/cult/used(C), ITEM_SLOT_HANDCUFFED, TRUE, TRUE, null, TRUE))
			C.silent += 5
			to_chat(user, span_notice("You shackle [C]."))
			log_combat(user, C, "shackled")
			uses--
		else
			to_chat(user, span_warning("You fail to shackle [C]."))
	else
		to_chat(user, span_warning("[C] is already bound."))


/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/unequipped(mob/user)
	user.visible_message(span_danger("[user]'s shackles shatter in a discharge of dark magic!"), \
							span_userdanger("Your [src] shatters in a discharge of dark magic!"))
	. = ..()


//Construction: Converts 50 iron to a construct shell, plasteel to runed metal, airlock to brittle runed airlock, a borg to a construct, or borg shell to a construct shell
/obj/item/melee/blood_magic/construction
	name = "Twisting Aura"
	desc = "Corrupts certain metalic objects on contact."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	var/channeling = FALSE

/obj/item/melee/blood_magic/construction/examine(mob/user)
	. = ..()
	. += {"<u>A sinister spell used to convert:</u>\n
	Plasteel into runed metal\n
	[IRON_TO_CONSTRUCT_SHELL_CONVERSION] iron into a construct shell\n
	Living cyborgs into constructs after a delay\n
	Cyborg shells into construct shells\n
	Purified soulstones (and any shades inside) into cultist soulstones\n
	Airlocks into brittle runed airlocks after a delay (harm intent)"}

/obj/item/melee/blood_magic/construction/cast_spell(atom/target, mob/living/carbon/user)
	if(IS_CULTIST(user))
		if(channeling)
			to_chat(user, span_cultitalic("You are already invoking twisted construction!"))
			return
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/iron))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(IRON_TO_CONSTRUCT_SHELL_CONVERSION))
				uses--
				to_chat(user, span_warning("A dark cloud emanates from your hand and swirls around the iron, twisting it into a construct shell!"))
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
			else
				to_chat(user, span_warning("You need [IRON_TO_CONSTRUCT_SHELL_CONVERSION] iron to produce a construct shell!"))
				return
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = candidate.amount
			if(candidate.use(quantity))
				uses --
				new /obj/item/stack/sheet/runed_metal(T,quantity)
				to_chat(user, span_warning("A dark cloud emanates from you hand and swirls around the plasteel, transforming it into runed metal!"))
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else if(istype(target,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/candidate = target
			if(candidate.mmi || candidate.shell)
				channeling = TRUE
				user.visible_message(span_danger("A dark cloud emanates from [user]'s hand and swirls around [candidate]!"))
				playsound(T, 'sound/machines/airlock_alien_prying.ogg', 80, TRUE)
				var/prev_color = candidate.color
				candidate.color = "black"
				if(do_after(user, candidate, 90))
					candidate.undeploy()
					candidate.emp_act(EMP_HEAVY)
					var/construct_class = show_radial_menu(user, src, GLOB.construct_radial_images, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
					if(!check_menu(user))
						return
					if(QDELETED(candidate))
						channeling = FALSE
						return
					candidate.grab_ghost()
					user.visible_message(span_danger("The dark cloud recedes from what was formerly [candidate], revealing a\n [construct_class]!"))
					make_new_construct_from_class(construct_class, THEME_CULT, candidate, user, FALSE, T)
					uses--
					candidate.mmi = null
					qdel(candidate)
					channeling = FALSE
				else
					channeling = FALSE
					candidate.color = prev_color
					return
			else
				uses--
				to_chat(user, span_warning("A dark cloud emanates from you hand and swirls around [candidate] - twisting it into a construct shell!"))
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
				qdel(candidate)
		else if(istype(target,/obj/machinery/door/airlock))
			channeling = TRUE
			playsound(T, 'sound/machines/doors/airlock_open_force.ogg', 50, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, user, 50))
				if(QDELETED(target))
					channeling = FALSE
					return
				target.narsie_act()
				uses--
				user.visible_message(span_warning("Black ribbons suddenly emanate from [user]'s hand and cling to the airlock - twisting and corrupting it!"))
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
				channeling = FALSE
			else
				channeling = FALSE
				return

		else if(istype(target,/obj/item/soulstone))
			var/obj/item/soulstone/candidate = target
			if(candidate.corrupt())
				uses--
				to_chat(user, span_warning("You corrupt [candidate]!"))
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else
			to_chat(user, span_warning("The spell will not work on [target]!"))
			return
		return ..()

/obj/item/melee/blood_magic/construction/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("The cult construct selection radial menu was accessed by something other than a valid user.")
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE


//Armor: Gives the target (cultist) a basic cultist combat loadout
/obj/item/melee/blood_magic/armor
	name = "Arming Aura"
	desc = "Will equip cult combat gear onto a cultist on contact."
	color = "#33cc33" // green

/obj/item/melee/blood_magic/armor/cast_spell(atom/target, mob/living/carbon/user)
	var/mob/living/carbon/carbon_target = target
	if(istype(carbon_target) && IS_CULTIST(carbon_target))
		uses--
		var/mob/living/carbon/C = target
		C.visible_message(span_warning("Otherworldly armor suddenly appears on [C]!"))
		C.equip_to_slot_or_del(new /obj/item/clothing/under/color/black,ITEM_SLOT_ICLOTHING)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(user), ITEM_SLOT_OCLOTHING)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), ITEM_SLOT_FEET)
		C.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), ITEM_SLOT_BACK)
		if(C == user)
			qdel(src) //Clears the hands
		C.put_in_hands(new /obj/item/melee/cultblade/dagger(user))
		C.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))
		return ..()

/obj/item/melee/blood_magic/manipulator
	name = "Blood Rite Aura"
	desc = "Absorbs blood from anything you touch. Touching cultists and constructs can heal them. Use in-hand to cast an advanced rite."
	color = "#7D1717"

/obj/item/melee/blood_magic/manipulator/examine(mob/user)
	. = ..()
	. += "Bloody halberd, blood bolt barrage, and blood beam cost [BLOOD_HALBERD_COST], [BLOOD_BARRAGE_COST], and [BLOOD_BEAM_COST] charges respectively."

/obj/item/melee/blood_magic/manipulator/cast_spell(atom/target, mob/living/carbon/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(NOBLOOD in H.dna.species.species_traits)
			to_chat(user,span_warning("Blood rites do not work on species with no blood!"))
			return
		if(IS_CULTIST(H))
			if(H.stat == DEAD)
				to_chat(user,span_warning("Only a revive rune can bring back the dead!"))
				return
			if(H.blood_volume < BLOOD_VOLUME_SAFE)
				var/restore_blood = BLOOD_VOLUME_SAFE - H.blood_volume
				if(uses*2 < restore_blood)
					H.blood_volume += uses*2
					to_chat(user,span_danger("You use the last of your blood rites to restore what blood you could!"))
					uses = 0
					return ..()
				else
					H.setBloodVolume(BLOOD_VOLUME_SAFE)
					uses -= round(restore_blood/2)
					to_chat(user,span_warning("Your blood rites have restored [H == user ? "your" : "[H.p_their()]"] blood to safe levels!"))

			var/overall_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss() + H.getOxyLoss()
			if(overall_damage == 0)
				to_chat(user,span_cult("That cultist doesn't require healing!"))
			else
				var/ratio = uses/overall_damage
				if(H == user)
					to_chat(user,span_cult("<b>Your blood healing is far less efficient when used on yourself!</b>"))
					ratio *= 0.35 // Healing is half as effective if you can't perform a full heal
					uses -= round(overall_damage) // Healing is 65% more "expensive" even if you can still perform the full heal
				if(ratio>1)
					ratio = 1
					uses -= round(overall_damage)
					H.visible_message(span_warning("[H] is fully healed by [H==user ? "[H.p_their()]":"[H]'s"]'s blood magic!"))
				else
					H.visible_message(span_warning("[H] is partially healed by [H==user ? "[H.p_their()]":"[H]'s"] blood magic."))
					uses = 0
				ratio *= -1
				H.adjustOxyLoss((overall_damage*ratio) * (H.getOxyLoss() / overall_damage), 0)
				H.adjustToxLoss((overall_damage*ratio) * (H.getToxLoss() / overall_damage), 0)
				H.adjustFireLoss((overall_damage*ratio) * (H.getFireLoss() / overall_damage), 0)
				H.adjustBruteLoss((overall_damage*ratio) * (H.getBruteLoss() / overall_damage), 0)
				H.updatehealth()
				playsound(get_turf(H), 'sound/magic/staff_healing.ogg', 25)
				new /obj/effect/temp_visual/cult/sparks(get_turf(H))
				user.Beam(H, icon_state="sendbeam", time = 15)
		else
			if(H.stat == DEAD)
				to_chat(user,span_warning("[H.p_their(TRUE)] blood has stopped flowing, you'll have to find another way to extract it."))
				return
			if(H.has_status_effect(/datum/status_effect/speech/slurring/cult))
				to_chat(user,span_danger("[H.p_their(TRUE)] blood has been tainted by an even stronger form of blood magic, it's no use to us like this!"))
				return
			if(H.blood_volume > BLOOD_VOLUME_SAFE)
				H.blood_volume -= 100
				uses += 50
				user.Beam(H, icon_state="drainbeam", time = 1 SECONDS)
				playsound(get_turf(H), 'sound/magic/enter_blood.ogg', 50)
				H.visible_message(span_danger("[user] drains some of [H]'s blood!"))
				to_chat(user,span_cultitalic("Your blood rite gains 50 charges from draining [H]'s blood."))
				new /obj/effect/temp_visual/cult/sparks(get_turf(H))
			else
				to_chat(user,span_warning("[H.p_theyre(TRUE)] missing too much blood - you cannot drain [H.p_them()] further!"))
				return

	if(isconstruct(target))
		var/mob/living/simple_animal/M = target
		var/missing = M.maxHealth - M.health
		if(missing)
			if(uses > missing)
				M.adjustHealth(-missing)
				M.visible_message(span_warning("[M] is fully healed by [user]'s blood magic!"))
				uses -= missing
			else
				M.adjustHealth(-uses)
				M.visible_message(span_warning("[M] is partially healed by [user]'s blood magic!"))
				uses = 0
			playsound(get_turf(M), 'sound/magic/staff_healing.ogg', 25)
			user.Beam(M, icon_state="sendbeam", time = 1 SECONDS)
	if(istype(target, /obj/effect/decal/cleanable/blood))
		blood_draw(target, user)
	return ..()

/obj/item/melee/blood_magic/manipulator/proc/blood_draw(atom/target, mob/living/carbon/human/user)
	var/temp = 0
	var/turf/T = get_turf(target)
	if(T)
		for(var/obj/effect/decal/cleanable/blood/B in view(T, 2))
			var/list/blood_DNA = B.return_blood_DNA()
			if(blood_DNA && ispath(blood_DNA[blood_DNA[1]], /datum/blood/human))
				if(B.bloodiness == 100) //Bonus for "pristine" bloodpools, also to prevent cheese with footprint spam
					temp += 30
				else
					temp += max((B.bloodiness**2)/800,1)
				new /obj/effect/temp_visual/cult/turf/floor(get_turf(B))
				qdel(B)
		for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in view(T, 2))
			qdel(TH)

		if(temp)
			user.Beam(T,icon_state="drainbeam", time = 15)
			new /obj/effect/temp_visual/cult/sparks(get_turf(user))
			playsound(T, 'sound/magic/enter_blood.ogg', 50)
			to_chat(user, span_cultitalic("Your blood rite has gained [round(temp)] charge\s from blood sources around you!"))
			uses += max(1, round(temp))

/obj/item/melee/blood_magic/manipulator/attack_self(mob/living/user)
	if(IS_CULTIST(user))
		var/static/list/spells = list(
			"Bloody Halberd (150)" = image(icon = 'icons/obj/cult/items_and_weapons.dmi', icon_state = "occultpoleaxe0"),
			"Blood Bolt Barrage (300)" = image(icon = 'icons/obj/guns/ballistic.dmi', icon_state = "arcane_barrage"),
			"Blood Beam (500)" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "disintegrate")
			)
		var/choice = show_radial_menu(user, src, spells, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
		if(!check_menu(user))
			to_chat(user, span_cultitalic("You decide against conducting a greater blood rite."))
			return
		switch(choice)
			if("Bloody Halberd (150)")
				if(uses < BLOOD_HALBERD_COST)
					to_chat(user, span_cultitalic("You need [BLOOD_HALBERD_COST] charges to perform this rite."))
				else
					uses -= BLOOD_HALBERD_COST
					var/turf/current_position = get_turf(user)
					qdel(src)
					var/datum/action/innate/cult/halberd/halberd_act_granted = new(user)
					var/obj/item/melee/cultblade/halberd/rite = new(current_position)
					halberd_act_granted.Grant(user, rite)
					rite.halberd_act = halberd_act_granted
					if(user.put_in_hands(rite))
						to_chat(user, span_cultitalic("A [rite.name] appears in your hand!"))
					else
						user.visible_message(span_warning("A [rite.name] appears at [user]'s feet!"), \
							span_cultitalic("A [rite.name] materializes at your feet."))
			if("Blood Bolt Barrage (300)")
				if(uses < BLOOD_BARRAGE_COST)
					to_chat(user, span_cultitalic("You need [BLOOD_BARRAGE_COST] charges to perform this rite."))
				else
					var/obj/rite = new /obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/blood()
					uses -= BLOOD_BARRAGE_COST
					qdel(src)
					if(user.put_in_hands(rite))
						to_chat(user, span_cult("<b>Your hands glow with power!</b>"))
					else
						to_chat(user, span_cultitalic("You need a free hand for this rite!"))
						qdel(rite)
			if("Blood Beam (500)")
				if(uses < BLOOD_BEAM_COST)
					to_chat(user, span_cultitalic("You need [BLOOD_BEAM_COST] charges to perform this rite."))
				else
					var/obj/rite = new /obj/item/blood_beam()
					uses -= BLOOD_BEAM_COST
					qdel(src)
					if(user.put_in_hands(rite))
						to_chat(user, span_cultlarge("<b>Your hands glow with POWER OVERWHELMING!!!</b>"))
					else
						to_chat(user, span_cultitalic("You need a free hand for this rite!"))
						qdel(rite)

/obj/item/melee/blood_magic/manipulator/proc/check_menu(mob/living/user)
	if(!istype(user))
		CRASH("The Blood Rites manipulator radial menu was accessed by something other than a valid user.")
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE
