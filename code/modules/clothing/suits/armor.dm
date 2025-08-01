TYPEINFO_DEF(/obj/item/clothing/suit/armor)
	default_armor = list(BLUNT = 35, PUNCTURE = 10, SLASH = 50, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/armor
	fallback_colors = list(list(14, 18))
	fallback_icon_state = "armor"
	allowed = null
	clothing_flags = parent_type::clothing_flags | THICKMATERIAL
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE

/obj/item/clothing/suit/armor/Initialize(mapload)
	. = ..()
	if(!allowed)
		allowed = GLOB.security_vest_allowed

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest)
	default_armor = list(BLUNT = 35, PUNCTURE = 20, SLASH = 35, LASER = 20, ENERGY = 30, BOMB = 25, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/armor/vest
	name = "armor vest"
	desc = "A tough armored vest made with hard composite plates. Great for stopping blunt force and cutting."
	icon_state = "armor"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION //need to do these

/obj/item/clothing/suit/armor/vest/sec
	name = "martian armor vest"
	desc = "An old composite vest with a faded corporate logo. While outdated, it will still protect your chest from heavy blows and cuts."
	icon_state = "armorsec"
	inhand_icon_state = "armor"

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/ballistic)
	default_armor = list(BLUNT = 15, PUNCTURE = 40, SLASH = 10, LASER = 30, ENERGY = 30, BOMB = 10, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/armor/vest/ballistic
	name = "ballistic vest"
	desc = "A thick, flexible kevlar vest. Keeps your chest protected from stabbings and shootings, but it won't do much against blunt force."
	icon_state = "armoralt"
	inhand_icon_state = "armoralt"

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/marine)
	default_armor = list(BLUNT = 50, PUNCTURE = 20, SLASH = 70, LASER = 30, ENERGY = 25, BOMB = 50, BIO = 100, FIRE = 40, ACID = 50)

/obj/item/clothing/suit/armor/vest/marine
	name = "tactical armor vest"
	desc = "A set of the finest mass produced, stamped plasteel armor plates, containing an environmental protection unit for all-condition door kicking."
	icon_state = "marine_command"
	inhand_icon_state = "armor"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_VOX_VARIATION | CLOTHING_TESHARI_VARIATION



/obj/item/clothing/suit/armor/vest/marine/security
	name = "large tactical armor vest"
	icon_state = "marine_security"

/obj/item/clothing/suit/armor/vest/marine/engineer
	name = "tactical utility armor vest"
	icon_state = "marine_engineer"

/obj/item/clothing/suit/armor/vest/marine/medic
	name = "tactical medic's armor vest"
	icon_state = "marine_medic"

/obj/item/clothing/suit/armor/vest/old
	name = "degrading armor vest"
	desc = "Older generation Type 1 armored vest. Due to degradation over time the vest is far less maneuverable to move in."
	icon_state = "armor"
	inhand_icon_state = "armor"
	slowdown = 1

/obj/item/clothing/suit/armor/vest/blueshirt
	name = "large armor vest"
	desc = "A large, yet comfortable piece of armor, protecting you from some threats."
	icon_state = "blueshift"
	inhand_icon_state = "blueshift"
	custom_premium_price = PAYCHECK_HARD
	supports_variations_flags = NONE

/obj/item/clothing/suit/armor/vest/cuirass
	name = "cuirass"
	desc = "A lighter plate armor used to still keep out those pesky arrows, while retaining the ability to move."
	icon_state = "cuirass"
	inhand_icon_state = "armor"
	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/suit/armor/hos)
	default_armor = list(BLUNT = 20, PUNCTURE = 0, SLASH = 30, LASER = 30, ENERGY = 40, BOMB = 25, BIO = 0, FIRE = 70, ACID = 90)

/obj/item/clothing/suit/armor/hos
	name = "armored greatcoat"
	desc = "A greatcoat enhanced with a special alloy for some extra protection and style for those with a commanding presence."
	icon_state = "hos"
	inhand_icon_state = "greatcoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 80
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/armor/hos/trenchcoat
	name = "armored trenchcoat"
	desc = "A trenchcoat enhanced with a special lightweight kevlar. The epitome of tactical plainclothes."
	icon_state = "hostrench"
	inhand_icon_state = "hostrench"
	flags_inv = 0
	strip_delay = 80

/obj/item/clothing/suit/armor/hos/hos_formal
	name = "\improper Security Marshal's parade jacket"
	desc = "For when an armoured vest isn't fashionable enough."
	icon_state = "hosformal"
	inhand_icon_state = "hostrench"
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/suit/armor/hos/hos_formal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/armor/vest/warden
	name = "warden's jacket"
	desc = "A navy-blue armored jacket with blue shoulder designations and '/Warden/' stitched into one of the chest pockets."
	icon_state = "warden_alt"
	inhand_icon_state = "armor"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS|HANDS
	heat_protection = CHEST|GROIN|ARMS|HANDS
	strip_delay = 70
	resistance_flags = FLAMMABLE
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "warden's armored jacket"
	desc = "A red jacket with silver rank pips and body armor strapped on top."
	icon_state = "warden_jacket"

/obj/item/clothing/suit/armor/vest/leather
	name = "security overcoat"
	desc = "Lightly armored leather overcoat meant as casual wear for high-ranking officers. Bears the crest of Mars Security."
	icon_state = "leathercoat-sec"
	inhand_icon_state = "hostrench"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	dog_fashion = null
	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/capcarapace)
	default_armor = list(BLUNT = 50, PUNCTURE = 20, SLASH = 70, LASER = 50, ENERGY = 50, BOMB = 25, BIO = 0, FIRE = 100, ACID = 90)

/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "A fireproof armored chestpiece reinforced with ceramic plates and plasteel pauldrons to provide additional protection whilst still offering maximum mobility and flexibility. Issued only to the station's finest, although it does chafe your nipples."
	icon_state = "capcarapace"
	inhand_icon_state = "armor"
	body_parts_covered = CHEST|GROIN
	dog_fashion = null
	resistance_flags = FIRE_PROOF
	supports_variations_flags = NONE

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	name = "syndicate captain's vest"
	desc = "A sinister looking vest of advanced armor worn over a black and red fireproof jacket. The gold collar and shoulders denote that this belongs to a high ranking syndicate officer."
	icon_state = "syndievest"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal
	name = "captain's parade coat"
	desc = "For when an armoured vest isn't fashionable enough."
	icon_state = "capformal"
	inhand_icon_state = "capspacesuit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

TYPEINFO_DEF(/obj/item/clothing/suit/armor/riot)
	default_armor = list(BLUNT = 50, PUNCTURE = 10, SLASH = 50, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	desc = "A suit of semi-flexible polycarbonate body armor with heavy padding to protect against melee attacks. Helps the wearer resist shoving in close quarters."
	icon_state = "riot"
	inhand_icon_state = "swat_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	clothing_flags = BLOCKS_SHOVE_KNOCKDOWN
	strip_delay = 80
	equip_delay_other = 60
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

TYPEINFO_DEF(/obj/item/clothing/suit/armor/bone)
	default_armor = list(BLUNT = 35, PUNCTURE = 25, SLASH = 0, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/armor/bone
	name = "bone armor"
	desc = "A tribal armor plate, crafted from animal bone."
	icon_state = "bonearmor"
	inhand_icon_state = "bonearmor"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS

TYPEINFO_DEF(/obj/item/clothing/suit/armor/bulletproof)
	default_armor = list(BLUNT = 15, PUNCTURE = 60, SLASH = 25, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof armor"
	desc = "A Type III heavy bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	strip_delay = 70
	equip_delay_other = 50
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

TYPEINFO_DEF(/obj/item/clothing/suit/armor/laserproof)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)

/obj/item/clothing/suit/armor/laserproof
	name = "reflector vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles, as well as occasionally reflecting them."
	icon_state = "armor_reflec"
	inhand_icon_state = "armor_reflec"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/armor/laserproof/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/det_suit)
	default_armor = list(BLUNT = 20, PUNCTURE = 30, SLASH = 10, LASER = 20, ENERGY = 30, BOMB = 25, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/armor/vest/det_suit
	name = "private investigator's armor vest"
	desc = "An armored vest with a private investigator's badge on it."
	icon_state = "detective-armor"
	resistance_flags = FLAMMABLE
	dog_fashion = null
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/armor/vest/det_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.detective_vest_allowed

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/infiltrator)
	default_armor = list(BLUNT = 40, PUNCTURE = 40, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 70, BIO = 0, FIRE = 100, ACID = 100)

/obj/item/clothing/suit/armor/vest/infiltrator
	name = "infiltrator vest"
	desc = "This vest appears to be made of of highly flexible materials that absorb impacts with ease."
	icon_state = "infiltrator"
	inhand_icon_state = "infiltrator"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	strip_delay = 80
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

TYPEINFO_DEF(/obj/item/clothing/suit/armor/swat)
	default_armor = list(BLUNT = 40, PUNCTURE = 20, SLASH = 60, LASER = 30, ENERGY = 40, BOMB = 50, BIO = 90, FIRE = 100, ACID = 100)

/obj/item/clothing/suit/armor/swat
	name = "MK.I SWAT Suit"
	desc = "A tactical suit first developed in a joint effort by the defunct IS-ERI and Mars Executive Outcomes in 2321 for military operations. It has a minor slowdown, but offers decent protection."
	icon_state = "heavy"
	inhand_icon_state = "swat_suit"
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	heat_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	slowdown = 0.7
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

//All of the armor below is mostly unused

TYPEINFO_DEF(/obj/item/clothing/suit/armor/heavy)
	default_armor = list(BLUNT = 80, PUNCTURE = 80, SLASH = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	inhand_icon_state = "swat_suit"
	w_class = WEIGHT_CLASS_BULKY
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

TYPEINFO_DEF(/obj/item/clothing/suit/armor/tdome)
	default_armor = list(BLUNT = 80, PUNCTURE = 80, SLASH = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = THICKMATERIAL
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/suit/armor/tdome/red
	name = "thunderdome suit"
	desc = "Reddish armor."
	icon_state = "tdred"
	inhand_icon_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "thunderdome suit"
	desc = "Pukish armor." //classy.
	icon_state = "tdgreen"
	inhand_icon_state = "tdgreen"

TYPEINFO_DEF(/obj/item/clothing/suit/armor/tdome/holosuit)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 10, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/armor/tdome/holosuit
	name = "thunderdome suit"
	cold_protection = null
	heat_protection = null

/obj/item/clothing/suit/armor/tdome/holosuit/red
	desc = "Reddish armor."
	icon_state = "tdred"
	inhand_icon_state = "tdred"

/obj/item/clothing/suit/armor/tdome/holosuit/green
	desc = "Pukish armor."
	icon_state = "tdgreen"
	inhand_icon_state = "tdgreen"

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	inhand_icon_state = "knight_green"
	allowed = list(/obj/item/nullrod, /obj/item/claymore, /obj/item/banner, /obj/item/tank/internals/emergency_oxygen)
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"
	inhand_icon_state = "knight_yellow"

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"
	inhand_icon_state = "knight_blue"

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"
	inhand_icon_state = "knight_red"

TYPEINFO_DEF(/obj/item/clothing/suit/armor/riot/knight/greyscale)
	default_armor = list(BLUNT = 35, PUNCTURE = 0, SLASH = 50, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 40, ACID = 40)

/obj/item/clothing/suit/armor/riot/knight/greyscale
	name = "knight armour"
	desc = "A classic suit of armour, able to be made from many different materials."
	icon_state = "knight_greyscale"
	inhand_icon_state = "knight_greyscale"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS//Can change color and add prefix

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/durathread)
	default_armor = list(BLUNT = 15, PUNCTURE = 0, SLASH = 25, LASER = 30, ENERGY = 40, BOMB = 15, BIO = 0, FIRE = 40, ACID = 50)

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A vest made of durathread with strips of leather acting as trauma plates."
	icon_state = "durathread"
	inhand_icon_state = "durathread"
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 200
	resistance_flags = FLAMMABLE
	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/russian)
	default_armor = list(BLUNT = 25, PUNCTURE = 30, SLASH = 0, LASER = 0, ENERGY = 10, BOMB = 10, BIO = 0, FIRE = 20, ACID = 50)

/obj/item/clothing/suit/armor/vest/russian
	name = "russian vest"
	desc = "A bulletproof vest with forest camo. Good thing there's plenty of forests to hide in around here, right?"
	icon_state = "rus_armor"
	inhand_icon_state = "rus_armor"
	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/suit/armor/vest/russian_coat)
	default_armor = list(BLUNT = 25, PUNCTURE = 20, SLASH = 0, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 50, FIRE = -10, ACID = 50)

/obj/item/clothing/suit/armor/vest/russian_coat
	name = "russian battle coat"
	desc = "Used in extremly cold fronts, made out of real bears."
	icon_state = "rus_coat"
	inhand_icon_state = "rus_coat"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	supports_variations_flags = NONE

TYPEINFO_DEF(/obj/item/clothing/suit/armor/elder_atmosian)
	default_armor = list(BLUNT = 25, PUNCTURE = 20, SLASH = 0, LASER = 30, ENERGY = 30, BOMB = 85, BIO = 10, FIRE = 65, ACID = 40)

/obj/item/clothing/suit/armor/elder_atmosian
	name = "\improper Elder Atmosian Armor"
	desc = "A superb armor made with the toughest and rarest materials available to man."
	icon_state = "h2armor"
	inhand_icon_state = "h2armor"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS//Can change color and add prefix
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

TYPEINFO_DEF(/obj/item/clothing/suit/armor/centcom_formal)
	default_armor = list(BLUNT = 35, PUNCTURE = 40, SLASH = 50, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, FIRE = 10, ACID = 60)

/obj/item/clothing/suit/armor/centcom_formal
	name = "\improper CentCom formal coat"
	desc = "A stylish coat given to CentCom Commanders. Perfect for sending ERTs to suicide missions with style!"
	icon_state = "centcom_formal"
	inhand_icon_state = "centcom"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/armor/centcom_formal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)
