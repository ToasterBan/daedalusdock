// Wintercoat
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon = 'icons/obj/clothing/suits/wintercoat.dmi'
	icon_state = "coatwinter"
	worn_icon = 'icons/mob/clothing/suits/wintercoat.dmi'
	inhand_icon_state = "coatwinter"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/hooded/wintercoat/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/tablet/pda,
		/obj/item/radio,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/toy,
		/obj/item/storage/bag/books,
	)

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 0, ACID = 0)

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A cozy winter hood attached to a heavy winter jacket."
	icon = 'icons/obj/clothing/head/winterhood.dmi'
	icon_state = "hood_winter"
	worn_icon = 'icons/mob/clothing/head/winterhood.dmi'
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

// CentCom
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/centcom)
	default_armor = list(BLUNT = 35, PUNCTURE = 40, SLASH = 0, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, FIRE = 10, ACID = 60)

/obj/item/clothing/suit/hooded/wintercoat/centcom
	name = "centcom winter coat"
	desc = "A luxurious winter coat woven in the bright green and gold colours of Central Command. It has a small pin in the shape of the Nanotrasen logo for a zipper."
	icon_state = "coatcentcom"
	inhand_icon_state = "coatcentcom"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/centcom
	supports_variations_flags = NONE

/obj/item/clothing/suit/hooded/wintercoat/centcom/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/centcom)
	default_armor = list(BLUNT = 35, PUNCTURE = 40, SLASH = 0, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, FIRE = 10, ACID = 60)

/obj/item/clothing/head/hooded/winterhood/centcom
	icon_state = "hood_centcom"
	supports_variations_flags = NONE

// Captain
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/captain)
	default_armor = list(BLUNT = 25, PUNCTURE = 30, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, FIRE = 0, ACID = 50)

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	desc = "A luxurious winter coat, stuffed with the down of the endangered Uka bird and trimmed with genuine sable. The fabric is an indulgently soft micro-fiber, \
			and the deep ultramarine colour is only one that could be achieved with minute amounts of crystalline bluespace dust woven into the thread between the plectrums. \
			Extremely lavish, and extremely durable."
	icon_state = "coatcaptain"
	inhand_icon_state = "coatcaptain"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain
	supports_variations_flags = NONE

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/captain)
	default_armor = list(BLUNT = 25, PUNCTURE = 30, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, FIRE = 0, ACID = 50)

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "hood_captain"
	supports_variations_flags = NONE

// Head of Personnel
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/hop)
	default_armor = list(BLUNT = 10, PUNCTURE = 15, SLASH = 0, LASER = 15, ENERGY = 25, BOMB = 10, BIO = 0, FIRE = 0, ACID = 35)

/obj/item/clothing/suit/hooded/wintercoat/hop
	name = "head of personnel's winter coat"
	desc = "A cozy winter coat, covered in thick fur. The breast features a proud yellow chevron, reminding everyone that you're the second banana."
	icon_state = "coathop"
	inhand_icon_state = "coathop"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hop
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/winterhood/hop
	icon_state = "hood_hop"

// Botanist
/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	desc = "A green and blue winter coat. The zipper tab looks like the flower from a member of Rosa Hesperrhodos, a pretty pink-and-white rose. The colours absolutely clash."
	icon_state = "coathydro"
	inhand_icon_state = "coathydro"
	allowed = list(
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/seeds,
		/obj/item/storage/bag/plants,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/winterhood/hydro
	desc = "A green winter coat hood."
	icon_state = "hood_hydro"

// Janitor
/obj/item/clothing/suit/hooded/wintercoat/janitor
	name = "janitors winter coat"
	desc = "A purple-and-beige winter coat that smells of space cleaner."
	icon_state = "coatjanitor"
	inhand_icon_state = "coatjanitor"
	allowed = list(
		/obj/item/grenade/chem_grenade,
		/obj/item/holosign_creator,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/spray,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/janitor
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/winterhood/janitor
	desc = "A purple hood that smells of space cleaner."
	icon_state = "hood_janitor"

// Security Officer
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/security)
	default_armor = list(BLUNT = 25, PUNCTURE = 15, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, FIRE = 0, ACID = 45)

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	desc = "A red, armour-padded winter coat. It glitters with a mild ablative coating and a robust air of authority.  The zipper tab is a pair of jingly little handcuffs that get annoying after the first ten seconds."
	icon_state = "coatsecurity"
	inhand_icon_state = "coatsecurity"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_wintercoat_allowed

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/security)
	default_armor = list(BLUNT = 25, PUNCTURE = 15, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, FIRE = 0, ACID = 45)

/obj/item/clothing/head/hooded/winterhood/security
	desc = "A red, armour-padded winter hood. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "hood_security"
	supports_variations_flags = NONE

// Security Marshal
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/security/hos)
	default_armor = list(BLUNT = 35, PUNCTURE = 25, SLASH = 0, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 0, FIRE = 0, ACID = 55)

/obj/item/clothing/suit/hooded/wintercoat/security/hos
	name = "security marshal's winter coat"
	desc = "A red, armour-padded winter coat, lovingly woven with a Kevlar interleave and reinforced with semi-ablative polymers and a silver azide fill material. The zipper tab looks like a tiny replica of Beepsky."
	icon_state = "coathos"
	inhand_icon_state = "coathos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/hos
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/winterhood/security/hos
	desc = "A red, armour-padded winter hood, lovingly woven with a Kevlar interleave. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "hood_hos"

// Medical Doctor
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/medical)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, FIRE = 10, ACID = 20)

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	desc = "An arctic white winter coat with a small blue caduceus instead of a plastic zipper tab. Snazzy."
	icon_state = "coatmedical"
	inhand_icon_state = "coatmedical"
	allowed = list(
		/obj/item/flashlight/pen,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/gun/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical
	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/medical)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 40, FIRE = 10, ACID = 20)

/obj/item/clothing/head/hooded/winterhood/medical
	desc = "A white winter coat hood."
	icon_state = "hood_medical"
	supports_variations_flags = NONE

// Medical Director
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/medical/cmo)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 20, ACID = 30)

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	name = "medical director's winter coat"
	desc = "A winter coat in a vibrant shade of blue with a small silver caduceus instead of a plastic zipper tab. The normal liner is replaced with an exceptionally thick, soft layer of fur."
	icon_state = "coatcmo"
	inhand_icon_state = "coatcmo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/medical/cmo)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 20, ACID = 30)

/obj/item/clothing/head/hooded/winterhood/medical/cmo
	desc = "A blue winter coat hood."
	icon_state = "hood_cmo"

// Chemist
/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry
	name = "chemistry winter coat"
	desc = "A lab-grade winter coat made with acid resistant polymers. For the enterprising chemist who was exiled to a frozen wasteland on the go."
	icon_state = "coatchemistry"
	inhand_icon_state = "coatchemistry"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/chemistry

/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/chemistry

/obj/item/clothing/head/hooded/winterhood/medical/chemistry
	desc = "A white winter coat hood."
	icon_state = "hood_chemistry"

// Virologist
/obj/item/clothing/suit/hooded/wintercoat/medical/viro
	name = "virology winter coat"
	desc = "A white winter coat with green markings. Warm, but wont fight off the common cold or any other disease. Might make people stand far away from you in the hallway. The zipper tab looks like an oversized bacteriophage."
	icon_state = "coatviro"
	inhand_icon_state = "coatviro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/viro

/obj/item/clothing/suit/hooded/wintercoat/medical/viro/Initialize(mapload)
	. = ..()
	allowed += /obj/item/storage/bag/bio

/obj/item/clothing/head/hooded/winterhood/medical/viro
	desc = "A white winter coat hood with green markings."
	icon_state = "hood_viro"

// Paramedic
/obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	desc = "A winter coat with blue markings. Warm, but probably won't protect from biological agents. For the cozy doctor on the go."
	icon_state = "coatparamed"
	inhand_icon_state = "coatparamed"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/paramedic
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/head/hooded/winterhood/medical/paramedic
	desc = "A white winter coat hood with blue markings."
	icon_state = "hood_paramed"
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

// Scientist
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/science)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 20, ACID = 0)

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	desc = "A white winter coat with an outdated atomic model instead of a plastic zipper tab."
	icon_state = "coatscience"
	inhand_icon_state = "coatscience"
	allowed = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/paper,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/xeno,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science

	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/science)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 20, ACID = 0)

/obj/item/clothing/head/hooded/winterhood/science
	desc = "A white winter coat hood. This one will keep your brain warm. About as much as the others, really."
	icon_state = "hood_science"

// Research Director
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/science/rd)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, FIRE = 30, ACID = 0)

/obj/item/clothing/suit/hooded/wintercoat/science/rd
	name = "research director's winter coat"
	desc = "A thick arctic winter coat with an outdated atomic model instead of a plastic zipper tab. Most in the know are heavily aware that Bohr's model of the atom was outdated by the time of the 1930s when the Heisenbergian and Schrodinger models were generally accepted for true. Nevertheless, we still see its use in anachronism, roleplaying, and, in this case, as a zipper tab. At least it should keep you warm on your ivory pillar."
	icon_state = "coatrd"
	inhand_icon_state = "coatrd"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/rd

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/science/rd)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, FIRE = 30, ACID = 0)

/obj/item/clothing/head/hooded/winterhood/science/rd
	desc = "A white winter coat hood. It smells faintly of hair gel."
	icon_state = "hood_rd"

// Roboticist
/obj/item/clothing/suit/hooded/wintercoat/science/robotics
	name = "robotics winter coat"
	desc = "A black winter coat with a badass flaming robotic skull for the zipper tab. This one has bright red designs and a few useless buttons."
	icon_state = "coatrobotics"
	inhand_icon_state = "coatrobotics"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/robotics

/obj/item/clothing/head/hooded/winterhood/science/robotics
	desc = "A black winter coat hood. You can pull it down over your eyes and pretend that you're an outdated, late 1980s interpretation of a futuristic mechanized police force. They'll fix you. They fix everything."
	icon_state = "hood_robotics"

// Geneticist
/obj/item/clothing/suit/hooded/wintercoat/science/genetics
	name = "genetics winter coat"
	desc = "A white winter coat with a DNA helix for the zipper tab."
	icon_state = "coatgenetics"
	inhand_icon_state = "coatgenetics"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/genetics

/obj/item/clothing/head/hooded/winterhood/science/genetics
	desc = "A white winter coat hood. It's warm."
	icon_state = "hood_genetics"

// Station Engineer
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/engineering)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 20, ACID = 0)

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	desc = "A surprisingly heavy yellow winter coat with reflective orange stripes. It has a small wrench for its zipper tab, and the inside layer is covered with a radiation-resistant silver-nylon blend. Because you're worth it."
	icon_state = "coatengineer"
	inhand_icon_state = "coatengineer"
	zmm_flags = ZMM_MANGLE_PLANES
	allowed = list(
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/t_scanner,
		/obj/item/storage/bag/construction,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering
	supports_variations_flags = NONE

/obj/item/clothing/suit/hooded/wintercoat/engineering/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = 90)

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/engineering)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 20, ACID = 0)

/obj/item/clothing/head/hooded/winterhood/engineering
	desc = "A yellow winter coat hood. Definitely not a replacement for a hard hat."
	icon_state = "hood_engineer"
	zmm_flags = ZMM_MANGLE_PLANES

/obj/item/clothing/head/hooded/winterhood/engineering/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = 90)

// Chief Engineer
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/engineering/ce)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 10)

/obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	name = "chief engineer's winter coat"
	desc = "A white winter coat with reflective green and yellow stripes. Stuffed with asbestos, treated with fire retardant PBDE, lined with a micro thin sheet of lead foil and snugly fitted to your body's measurements. This baby's ready to save you from anything except the thyroid cancer and systemic fibrosis you'll get from wearing it. The zipper tab is a tiny golden wrench."
	icon_state = "coatce"
	inhand_icon_state = "coatce"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/ce

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/engineering/ce)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 10)

/obj/item/clothing/head/hooded/winterhood/engineering/ce
	desc = "A white winter coat hood. Feels surprisingly heavy. The tag says that it's not child safe."
	icon_state = "hood_ce"

// Atmospherics Technician
/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	desc = "A yellow and blue winter coat. The zipper pull-tab is made to look like a miniature breath mask."
	icon_state = "coatatmos"
	inhand_icon_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	desc = "A yellow and blue winter coat hood."
	icon_state = "hood_atmos"

// Cargo Technician
/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	desc = "A tan-and-grey winter coat. The zipper tab is a small pin resembling a MULE. It fills you with the warmth of a fierce independence."
	icon_state = "coatcargo"
	inhand_icon_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo
	allowed = list(/obj/item/storage/bag/mail)
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/winterhood/cargo
	desc = "A grey hood for a winter coat."
	icon_state = "hood_cargo"

// Quartermaster
/obj/item/clothing/suit/hooded/wintercoat/qm
	name = "quartermaster's winter coat"
	desc = "A dark brown winter coat that has a golden crate pin for its zipper pully."
	icon_state = "coatqm"
	inhand_icon_state = "coatqm"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/qm

/obj/item/clothing/head/hooded/winterhood/qm
	desc = "A dark brown winter hood"
	icon_state = "hood_qm"

// Shaft Miner
TYPEINFO_DEF(/obj/item/clothing/suit/hooded/wintercoat/miner)
	default_armor = list(BLUNT = 10, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	desc = "A dusty button up winter coat. The zipper tab looks like a tiny pickaxe."
	icon_state = "coatminer"
	inhand_icon_state = "coatminer"
	allowed = list(
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		/obj/item/storage/bag/ore,
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

TYPEINFO_DEF(/obj/item/clothing/head/hooded/winterhood/miner)
	default_armor = list(BLUNT = 10, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/head/hooded/winterhood/miner
	desc = "A dusty winter coat hood."
	icon_state = "hood_miner"

/obj/item/clothing/suit/hooded/wintercoat/custom
	name = "tailored winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs, with custom colors."
	greyscale_colors = "#ffffff#ffffff#808080#808080#808080#808080"
	greyscale_config = /datum/greyscale_config/winter_coats
	greyscale_config_worn = /datum/greyscale_config/winter_coats/worn
	hoodtype = /obj/item/clothing/head/hooded/winterhood/custom
	flags_1 = IS_PLAYER_COLORABLE_1

//In case colors are changed after initialization
/obj/item/clothing/suit/hooded/wintercoat/custom/set_greyscale(list/colors, new_config, queue, new_worn_config, new_inhand_left, new_inhand_right)
	. = ..()
	// It's 5 am i really cannot be bothered rn.
	var/datum/component/hooded/hood_component = GetComponent(/datum/component/hooded)
	var/obj/item/clothing/hood = hood_component?.hood
	if(!hood)
		return

	var/list/coat_colors = SSgreyscale.ParseColorString(greyscale_colors)
	var/list/new_coat_colors = coat_colors.Copy(1,4)
	hood.set_greyscale(new_coat_colors) //Adopt the suit's grayscale coloring for visual clarity.

//But also keep old method in case the hood is (re-)created later
/obj/item/clothing/suit/hooded/wintercoat/custom/on_hood_creation(obj/item/clothing/hood)
	var/list/coat_colors = (SSgreyscale.ParseColorString(greyscale_colors))
	var/list/new_coat_colors = coat_colors.Copy(1,4)
	hood.set_greyscale(new_coat_colors) //Adopt the suit's grayscale coloring for visual clarity.

/obj/item/clothing/head/hooded/winterhood/custom
	name = "tailored winter coat hood"
	desc = "A heavy jacket hood made from 'synthetic' animal furs, with custom colors."
	greyscale_config = /datum/greyscale_config/winter_hoods
	greyscale_config_worn = /datum/greyscale_config/winter_hoods/worn
