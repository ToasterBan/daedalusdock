/obj/structure/speaking_tile
	name = "strange tile"
	desc = "A weird tile that beckons you towards it. Maybe it can help you get out of this mess..."
	verb_say = "intones"
	icon = 'icons/obj/structures.dmi'
	icon_state = "speaking_tile"
	layer = FLY_LAYER
	resistance_flags = INDESTRUCTIBLE
	var/speaking = FALSE
	var/times_spoken_to = 0
	var/list/shenanigans = list()

/obj/structure/speaking_tile/Initialize(mapload)
	. = ..()
	var/json_file = file("data/npc_saves/Poly.json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	shenanigans = json["phrases"]

/obj/structure/speaking_tile/interact(mob/user)
	if(!isliving(user) || speaking)
		return
	speaking = TRUE

	switch(times_spoken_to)
		if(0)
			SpeakPeace(list("Welcome to the error handling room.","Something's goofed up bad to send you here.","You should probably tell an admin what you were doing, or make a bug report."))
			for(var/obj/structure/signpost/salvation/S in orange(7))
				S.invisibility = 0
				var/datum/effect_system/fluid_spread/smoke/smoke = new
				smoke.set_up(1, location = S.loc)
				smoke.start()
				break
		if(1)
			SpeakPeace(list("Take that ladder up.","It'll send you back to the station.","Hopefully you'll never need to see this place again."))
		if(2)
			SpeakPeace(list("Curious about what happened?","Somehow your corporeal form was sent to nullspace with you still in it.","Lucky for you this room exists to save you from that horrible fate."))
		if(3)
			SpeakPeace(list("So yeah, you're welcome.","Anyway don't you have things to do?","There's no real point to sticking around here forever."))
		if(4)
			SpeakPeace(list("I'm flattered you care this much about this room.","However it's not proper to just stand in here all shift and see what I'll say.","I'm going to work hard to be more boring so you'll leave."))
		if(5 to 8)
			SpeakPeace(list("..."))
		if(9)
			SpeakPeace(list("Alright maybe that's <b>too</b> boring.", "I can't keep manually typing these lines out though.", "It's hard to explain but the code structure I'm using is kind of terrible."))
		if(10)
			SpeakPeace(list("Oh I have an idea!", "Lets outsource this endless banter to Poly!", "Then you'll be able to keep listening to this without getting bored!"))
			if(isnull(shenanigans) || !shenanigans.len)
				shenanigans = list("Except the poly file is missing...")
		if(11 to 14, 16 to 50, 52 to 99, 103 to 107, 109 to 203, 205 to 249, 252 to 665, 667 to 999, 1001 to 5642)
			SpeakPeace(list(pick(shenanigans),pick(shenanigans),pick(shenanigans)))
			if(times_spoken_to % 10 == 0)
				SpeakPeace(list("That's [times_spoken_to] times you've spoken to me by the way."))
		if(15)
			SpeakPeace(list("See? Isn't this fun?","Now you can mash this for hours without getting bored.","Anyway I'll leave you it."))
		if(51)
			SpeakPeace(list("The fun never ends around here.", "The Poly text files stores up to 500 statements.", "But you've probably heard a few repeats by now."))
		if(100)
			SpeakPeace(list("And that's a solid hundred.", "Good hustle I guess.", "You've probably heard a lot of repeats by now."))
		if(101)
			SpeakPeace(list("I hope you're getting the reference this room is presenting.", "As well as the more obscure meta reference this conversation is presenting.", "This stuff has layers."))
		if(102)
			SpeakPeace(list("I am very tempted to just stretch this out forever.","It's technically easier than doing this.","Just an option."))
		if(108)
			SpeakPeace(list("But you have my respect for being this dedicated to the joke.", "So tell you what we're going to do, we're going to set a goal.", "250 is your final mission."))
		if(204)
			SpeakPeace(list("Notice how there was no special message at 200?", "The slow automation of what used to be meaningful milestones?","It's all part of the joke."))
		if(250)
			SpeakPeace(list("Congratulations.", "By my very loose calculations you've now wasted a decent chunk of the round doing this.", "But you've seen this meme to its conclusion, and that's an experience in itself, right?"))
		if(251)
			SpeakPeace(list("Anyway, here.", "I can't give you anything that would impact the progression of the round.","But you've earned this at least."))
			var/obj/item/reagent_containers/cup/glass/trophy/silver_cup/the_ride = new(get_turf(user))
			the_ride.name = "Overextending The Joke: Second Place"
			the_ride.desc = "There's a point where this needed to stop, and we've clearly passed it."
		if(252)
			SpeakPeace(list("You know what this means right?", "Of course it's not over!", "The question becomes now is it more impressive to solider on to an unknown finish, or to have to common sense to stop here?"))
		if(666)
			SpeakPeace(list("The darkness in your heart won't be filled by simple platitudes.","You won't stop now, you're in this to the end.", "Will you reach the finish line before the round ends?"))
		if(1000)
			SpeakPeace(list("The ends exists somewhere beyond meaningful milestones.", "There will be no more messages until then.", "You disgust me."))
		else
			y += 2
	speaking = FALSE
	times_spoken_to++

/obj/structure/speaking_tile/attackby(obj/item/W, mob/user, params)
	return interact(user)

/obj/structure/speaking_tile/attack_paw(mob/user, list/modifiers)
	return interact(user)

/obj/structure/speaking_tile/attack_hulk(mob/user)
	return

/obj/structure/speaking_tile/attack_larva(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_ai(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_slime(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_animal(mob/user, list/modifiers)
	return interact(user)

/obj/structure/speaking_tile/proc/SpeakPeace(list/statements)
	for(var/i in 1 to statements.len)
		say(span_deadsay("[statements[i]]"), sanitize=FALSE)
		if(i != statements.len)
			sleep(30)

TYPEINFO_DEF(/obj/item/rupee)
	default_materials = list(/datum/material/glass = 500)

/obj/item/rupee
	name = "weird crystal"
	desc = "Your excitement boils away as you realize it's just colored glass. Why would someone hoard these things?"
	icon = 'icons/obj/economy.dmi'
	icon_state = "rupee"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/rupee/Initialize(mapload)
	. = ..()
	var/newcolor = pick(10;COLOR_GREEN, 5;COLOR_BLUE, 3;COLOR_RED, 1;COLOR_PURPLE)
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/rupee/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == src)
		return
	if(!ismob(AM))
		return
	INVOKE_ASYNC(src, PROC_REF(put_in_crossers_hands), AM)

/obj/item/rupee/proc/put_in_crossers_hands(mob/crosser)
	if(crosser.put_in_hands(src))
		if(src != crosser.get_active_held_item())
			crosser.try_swap_hand()
		equip_to_best_slot(crosser)

/obj/item/rupee/equipped(mob/user, slot)
	playsound(get_turf(loc), 'sound/misc/server-ready.ogg', 50, TRUE, -1)
	..()

/obj/effect/landmark/error
	name = "error"
	icon_state = "error_room"
