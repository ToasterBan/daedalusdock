/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor
	var/icon_deny = "mining-deny"
	var/obj/item/card/id/inserted_id
	var/list/prize_list = list( //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
		new /datum/data/mining_equipment("Whiskey", /obj/item/reagent_containers/cup/glass/bottle/whiskey, 100),
		new /datum/data/mining_equipment("Absinthe", /obj/item/reagent_containers/cup/glass/bottle/absinthe/premium, 100),
		new /datum/data/mining_equipment("Bubblegum Gum Packet", /obj/item/storage/box/gum/bubblegum, 100),
		new /datum/data/mining_equipment("Cigar", /obj/item/clothing/mask/cigarette/cigar/havana, 150),
		new /datum/data/mining_equipment("Soap", /obj/item/soap/nanotrasen, 200),
		new /datum/data/mining_equipment("Laser Pointer", /obj/item/laser_pointer, 300),
		new /datum/data/mining_equipment("Alien Toy", /obj/item/clothing/mask/facehugger/toy, 300),
		new /datum/data/mining_equipment("Stabilizing Serum", /obj/item/hivelordstabilizer, 400),
		new /datum/data/mining_equipment("GAR Meson Scanners", /obj/item/clothing/glasses/meson/gar, 500),
		new /datum/data/mining_equipment("Explorer's Webbing", /obj/item/storage/belt/mining, 500),
		new /datum/data/mining_equipment("Point Transfer Card", /obj/item/card/mining_point_card, 500),
		new /datum/data/mining_equipment("Survival Medipen", /obj/item/reagent_containers/hypospray/medipen/survival, 500),
		new /datum/data/mining_equipment("Brute Medkit", /obj/item/storage/medkit/brute, 600),
		new /datum/data/mining_equipment("Tracking Implant Kit", /obj/item/storage/box/minertracker, 600),
		new /datum/data/mining_equipment("Jaunter", /obj/item/wormhole_jaunter, 750),
		new /datum/data/mining_equipment("Advanced Scanner", /obj/item/t_scanner/adv_mining_scanner, 800),
		new /datum/data/mining_equipment("Luxury Medipen", /obj/item/reagent_containers/hypospray/medipen/survival/luxury, 1000),
		new /datum/data/mining_equipment("Silver Pickaxe", /obj/item/pickaxe/silver, 1000),
		new /datum/data/mining_equipment("Mining Conscription Kit", /obj/item/storage/backpack/duffelbag/mining_conscript, 1500),
		new /datum/data/mining_equipment("Space Cash", /obj/item/stack/spacecash/c1000, 2000),
		new /datum/data/mining_equipment("Diamond Pickaxe", /obj/item/pickaxe/diamond, 2000),
		new /datum/data/mining_equipment("Kheiral Cuffs", /obj/item/kheiral_cuffs, 2000),
		new /datum/data/mining_equipment("Jump Boots", /obj/item/clothing/shoes/bhop, 2500),
		new /datum/data/mining_equipment("Ice Hiking Boots", /obj/item/clothing/shoes/winterboots/ice_boots, 2500),
		new /datum/data/mining_equipment("Mining MODsuit", /obj/item/mod/control/pre_equipped/mining, 2500),
	)

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/atom/movable/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/Initialize(mapload)
	. = ..()
	build_inventory()

/obj/machinery/mineral/equipment_vendor/proc/build_inventory()
	for(var/p in prize_list)
		var/datum/data/mining_equipment/M = p
		GLOB.vending_products[M.equipment_path] = 1

/obj/machinery/mineral/equipment_vendor/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()

// /obj/machinery/mineral/equipment_vendor/ui_assets(mob/user)
// 	return list(
// 		get_asset_datum(/datum/asset/spritesheet/vending),
// 	)

/obj/machinery/mineral/equipment_vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningVendor", name)
		ui.open()

/obj/machinery/mineral/equipment_vendor/ui_static_data(mob/user)
	. = list()
	.["product_records"] = list()
	for(var/datum/data/mining_equipment/prize in prize_list)
		var/list/product_data = list(
			path = replacetext(replacetext("[prize.equipment_path]", "/obj/item/", ""), "/", "-"),
			name = prize.equipment_name,
			price = prize.cost,
			ref = REF(prize),
			icon = initial(prize.equipment_path.icon),
			icon_state = initial(prize.equipment_path.icon_state)
		)
		.["product_records"] += list(product_data)

/obj/machinery/mineral/equipment_vendor/ui_data(mob/user)
	. = list()
	var/obj/item/card/id/C
	if(isliving(user))
		var/mob/living/L = user
		C = L.get_idcard(TRUE)
	if(C)
		.["user"] = list()
		.["user"]["points"] = C.mining_points
		if(C.registered_account)
			.["user"]["name"] = C.registered_account.account_holder
			if(C.registered_account.account_job)
				.["user"]["job"] = C.registered_account.account_job.title
			else
				.["user"]["job"] = "No Job"

/obj/machinery/mineral/equipment_vendor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase")
			var/obj/item/card/id/I
			if(isliving(usr))
				var/mob/living/L = usr
				I = L.get_idcard(TRUE)
			if(!istype(I))
				to_chat(usr, span_alert("Error: An ID is required!"))
				z_flick(icon_deny, src)
				return
			var/datum/data/mining_equipment/prize = locate(params["ref"]) in prize_list
			if(!prize || !(prize in prize_list))
				to_chat(usr, span_alert("Error: Invalid choice!"))
				z_flick(icon_deny, src)
				return
			if(prize.cost > I.mining_points)
				to_chat(usr, span_alert("Error: Insufficient points for [prize.equipment_name] on [I]!"))
				z_flick(icon_deny, src)
				return
			I.mining_points -= prize.cost
			to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
			new prize.equipment_path(loc)
			SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
			. = TRUE

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_voucher))
		RedeemVoucher(I, user)
		return
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Survival Capsule and Explorer's Webbing", "Resonator Kit", "Extraction and Rescue Kit", "Mining Conscription Kit")

	var/selection = tgui_input_list(redeemer, "Pick your equipment", "Mining Voucher Redemption", sort_list(items))
	if(isnull(selection))
		return
	if(!Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Survival Capsule and Explorer's Webbing")
			new /obj/item/storage/belt/mining/vendor(drop_location)
		if("Resonator Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/resonator(drop_location)
		if("Extraction and Rescue Kit")
			new /obj/item/extraction_pack(drop_location)
			new /obj/item/fulton_core(drop_location)
			new /obj/item/stack/marker_beacon/thirty(drop_location)
		if("Mining Conscription Kit")
			new /obj/item/storage/backpack/duffelbag/mining_conscript(drop_location)

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(severity > EXPLODE_LIGHT && prob(17 * severity))
		qdel(src)

/****************Golem Point Vendor**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor/golem

/obj/machinery/mineral/equipment_vendor/golem/Initialize(mapload)
	desc += "\nIt seems a few selections have been added."
	prize_list += list(
		new /datum/data/mining_equipment("Extra Id", /obj/item/card/id/advanced/mining, 250),
		new /datum/data/mining_equipment("Science Goggles", /obj/item/clothing/glasses/science, 250),
		new /datum/data/mining_equipment("Monkey Cube", /obj/item/food/monkeycube, 300),
		new /datum/data/mining_equipment("Toolbelt", /obj/item/storage/belt/utility, 350),
		new /datum/data/mining_equipment("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 500),
		new /datum/data/mining_equipment("Grey Slime Extract", /obj/item/slime_extract/grey, 1000),
		new /datum/data/mining_equipment("The Liberator's Legacy", /obj/item/storage/box/rndboards, 2000)
		)
	return ..()

/**********************Mining Equipment Vendor Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining points card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data_1"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(points)
			var/obj/item/card/id/C = I
			C.mining_points += points
			to_chat(user, span_info("You transfer [points] points to [C]."))
			points = 0
		else
			to_chat(user, span_alert("There's no points left on [src]."))
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += span_alert("There's [points] point\s on the card.")

/obj/item/storage/backpack/duffelbag/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."
	icon_state = "duffel-explorer"
	inhand_icon_state = "duffel-explorer"
	supports_variations_flags = NONE

/obj/item/storage/backpack/duffelbag/mining_conscript/PopulateContents()
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/head/helmet/space/nasavoid/old(src)
	new /obj/item/clothing/suit/space/nasavoid/old(src)
	new /obj/item/encryptionkey/headset_mining(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/card/id/advanced/mining(src)
	new /obj/item/knife/combat/survival(src)
	new /obj/item/flashlight/seclite(src)
