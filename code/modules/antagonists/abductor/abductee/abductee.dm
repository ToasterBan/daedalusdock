/**
 * ## Abductees
 *
 * Abductees are created by being operated on by abductors. They get some instructions about not
 * remembering the abduction, plus some random weird objectives for them to act crazy with.
 */
/datum/antagonist/abductee
	name = "\improper Abductee"
	roundend_category = "abductees"
	antagpanel_category = "Other"
	antag_hud_name = "abductee"

/datum/antagonist/abductee/on_gain()
	give_objective()
	. = ..()

/datum/antagonist/abductee/greet()
	to_chat(owner, span_warning("<b>Your mind snaps!</b>"))
	to_chat(owner, "<big>[span_warning("<b>You can't remember how you got here...</b>")]</big>")

/datum/antagonist/abductee/proc/give_objective()
	var/objtype = (prob(75) ? /datum/objective/abductee/random : pick(subtypesof(/datum/objective/abductee/) - /datum/objective/abductee/random))
	var/datum/objective/abductee/O = new objtype()
	objectives += O
