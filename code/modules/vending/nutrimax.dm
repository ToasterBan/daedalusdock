/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	panel_type = "panel2"
	light_mask = "nutri-light-mask"
	products = list(
		/obj/item/reagent_containers/cup/bottle/nutrient/ez = 5,
		/obj/item/reagent_containers/cup/bottle/nutrient/l4z = 5,
		/obj/item/reagent_containers/cup/bottle/nutrient/rh = 5,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/storage/bag/plants = 5,
		/obj/item/shovel/spade = 3,
		/obj/item/plant_analyzer = 4
	)

	contraband = list(
		/obj/item/reagent_containers/cup/bottle/ammonia = 10,
		/obj/item/reagent_containers/cup/bottle/diethylamine = 5
	)

	refill_canister = /obj/item/vending_refill/hydronutrients
	default_price = PAYCHECK_ASSISTANT * 0.8
	extra_price = PAYCHECK_HARD * 0.8
	payment_department = ACCOUNT_STATION_MASTER

	discount_access = ACCESS_HYDROPONICS

/obj/item/vending_refill/hydronutrients
	machine_name = "NutriMax"
	icon_state = "refill_plant"
