/**
 * The base type for nearly all physical objects in SS13

 * Lots and lots of functionality lives here, although in general we are striving to move
 * as much as possible to the components/elements system
 */
TYPEINFO_DEF(/atom)
	var/list/default_armor
	var/list/default_materials

/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND|LONG_GLIDE

	/// Has this atom's constructor ran?
	var/tmp/initialized = FALSE

	///Reagents holder
	var/tmp/datum/reagents/reagents = null
	/// the datum handler for our contents - see create_storage() for creation method
	var/tmp/datum/storage/atom_storage
	/// Forensics datum, initialzed when needed.
	var/tmp/datum/forensics/forensics

	///all of this atom's HUD (med/sec, etc) images. Associative list of the form: list(hud category = hud image or images for that category).
	///most of the time hud category is associated with a single image, sometimes its associated with a list of images.
	///not every hud in this list is actually used. for ones available for others to see, look at active_hud_list.
	var/tmp/list/image/hud_list = null
	///all of this atom's HUD images which can actually be seen by players with that hud
	var/tmp/list/image/active_hud_list = null
	/// A list of atom huds this object is within
	var/tmp/list/in_atom_huds = null

	///HUD images that this atom can provide.
	var/list/hud_possible

	/**
	 * used to store the different colors on an atom
	 *
	 * its inherent color, the colored paint applied on it, special color effect etc...
	 */
	var/tmp/list/atom_colours

	/// a very temporary list of overlays to remove
	var/tmp/list/remove_overlays
	/// a very temporary list of overlays to add
	var/tmp/list/add_overlays

	///overlays managed by [update_overlays][/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc. Single items are stored on their own, not in a list.
	var/tmp/list/managed_overlays

	///Cooldown tick timer for buckle messages
	var/tmp/buckle_message_cooldown = 0
	///Last fingerprints to touch this atom
	var/tmp/fingerprintslast

	var/tmp/list/filter_data //For handling persistent filters

	//List of datums orbiting this atom
	var/tmp/datum/component/orbiter/orbiters

	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	///This is ONLY to be set by set_custom_materials(), if you want to set an initial value, use Typeinfo.
	///The list referenced by this var can be shared by multiple objects and should not be directly modified. Instead, use [set_custom_materials][/atom/proc/set_custom_materials].
	var/tmp/list/datum/material/custom_materials

	var/tmp/datum/wires/wires = null

	var/tmp/list/alternate_appearances

	/// Last name used to calculate a color for the chatmessage overlays
	var/tmp/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/tmp/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/tmp/chat_color_darkened
	/// Class to attach to runechat.
	var/tmp/chat_class

	///Holds merger groups currently active on the atom. Do not access directly, use GetMergeGroup() instead.
	var/tmp/list/datum/merger/mergers

	///Reference to atom being orbited
	var/tmp/atom/orbit_target

	/// !DO NOT DIRECTLY EDIT! Can mobs "interact" with this item? THIS IS ONLY USED FOR MOUSE ICONS. SEE interactables.dm.
	var/tmp/is_mouseover_interactable

	/// pass_flags that we are. If any of this matches a pass_flag on a moving thing, by default, we let them through.
	var/pass_flags_self = NONE

	///If non-null, overrides a/an/some in all cases
	var/article

	///First atom flags var
	var/flags_1 = NONE
	///Second atom flags var
	var/flags_2 = NONE

	///Intearaction flags
	var/interaction_flags_atom = NONE

	/// Determines behavior for how fingerprints are given during item_interaction()
	var/fingerprint_flags_item_interaction = ALL

	var/flags_ricochet = NONE

	///When a projectile tries to ricochet off this atom, the projectile ricochet chance is multiplied by this
	var/receive_ricochet_chance_mod = 1
	///When a projectile ricochets off this atom, it deals the normal damage * this modifier to this atom
	var/receive_ricochet_damage_coeff = 0.33

	///Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	///Bitfield for how the atom handles materials.
	var/material_flags = NONE
	///Modifier that raises/lowers the effect of the amount of a material, prevents small and easy to get items from being death machines.
	var/material_modifier = 1

	///Light systems, both shouldn't be active at the same time.
	var/light_system = COMPLEX_LIGHT
	///Range of the maximum brightness of light in tiles. Zero means no light.
	var/light_inner_range = 0
	///Range where light begins to taper into darkness in tiles.
	var/light_outer_range = 0
	///Adjusts curve for falloff gradient
	var/light_falloff_curve = LIGHTING_DEFAULT_FALLOFF_CURVE
	///Intensity of the light. The stronger, the less shadows you will see on the lit area.
	var/light_power = 1
	///Hexadecimal RGB string representing the colour of the light. White by default.
	var/light_color = COLOR_WHITE
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = TRUE
	///Bitflags to determine lighting-related atom properties.
	var/light_flags = NONE
	///Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/datum/light_source/light
	///Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/tmp/list/light_sources

	///Default pixel x shifting for the atom's icon.
	var/base_pixel_x = 0
	///Default pixel y shifting for the atom's icon.
	var/base_pixel_y = 0
	///Used for changing icon states for different base sprites.
	var/base_icon_state

	///The config type to use for greyscaled sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config
	///A string of hex format colors to be used by greyscale sprites, ex: "#0054aa#badcff"
	var/greyscale_colors

	///Icon-smoothing behavior.
	var/tmp/smoothing_flags = NONE
	///What directions this is currently smoothing with. IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
	var/tmp/smoothing_junction = null //This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.
	///Smoothing variable
	var/tmp/top_left_corner
	///Smoothing variable
	var/tmp/top_right_corner
	///Smoothing variable
	var/tmp/bottom_left_corner
	///Smoothing variable
	var/tmp/bottom_right_corner
	///What smoothing groups does this atom belongs to, to match canSmoothWith. If null, nobody can smooth with it. Must be sorted.
	var/tmp/list/smoothing_groups = null
	///List of smoothing groups this atom can smooth with. If this is null and atom is smooth, it smooths only with itself. Must be sorted.
	var/tmp/list/canSmoothWith = null

	///AI controller that controls this atom. type on init, then turned into an instance during runtime.
	///Note: If you are for some reason giving this to a non-mob, it needs to create it's own in Initialize()
	var/datum/ai_controller/ai_controller

	///any atom that uses integrity and can be damaged must set this to true, otherwise the integrity procs will throw an error
	var/uses_integrity = FALSE

	///Atom armor. Use returnArmor()
	VAR_PRIVATE/tmp/datum/armor/armor
	VAR_PRIVATE/atom_integrity //defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior, otherwise is a percentage of at what point the atom breaks. 0.5 being 50%
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	var/resistance_flags = NONE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

	/// How this atom should react to having its astar blocking checked
	var/can_astar_pass = CANASTARPASS_DENSITY

/**
 * Called when an atom is created in byond (built in engine proc)
 *
 * Not a lot happens here in SS13 code, as we offload most of the work to the
 * [Intialization][/atom/proc/Initialize] proc, mostly we run the preloader
 * if the preloader is being used and then call [InitAtom][/datum/controller/subsystem/atoms/proc/InitAtom] of which the ultimate
 * result is that the Intialize proc is called.
 *
 */
/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(use_preloader && (type == global._preloader_path))//in case the instanciated atom is creating other atoms in New()
		world.preloader_load(src)

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, FALSE, args))
			//we were deleted
			return

/**
 * The primary method that objects are setup in SS13 with
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth
 *
 * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
 * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
 * is also true for loading map templates as well, so they don't Initalize until all objects
 * in the map file are parsed and present in the world
 *
 * If you're creating an object at any point after SSInit has run then this proc will be
 * immediately be called from New.
 *
 * mapload: This parameter is true if the atom being loaded is either being intialized during
 * the Atom subsystem intialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is intialized then
 * it's false.
 *
 * The mapload argument occupies the same position as loc when Initialize() is called by New().
 * loc will no longer be needed after it passed New(), and thus it is being overwritten
 * with mapload at the end of atom/New() before this proc (atom/Initialize()) is called.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * You must not sleep in this proc, or any subprocs
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * Note: the following functions don't call the base for optimization and must copypasta handling:
 * * [/turf/proc/Initialize]
 * * [/turf/open/space/proc/Initialize]
 */
/atom/proc/Initialize(mapload, ...)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")

	initialized = TRUE

	if(greyscale_config && greyscale_colors)
		update_greyscale()

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_system == COMPLEX_LIGHT && light_power && (light_inner_range || light_outer_range))
		update_light()

	if(uses_integrity)
		#ifdef UNIT_TESTS
		if (!(islist(armor) || isnull(armor) || istype(armor)))
			stack_trace("Invalid armor found on atom of type [type] during /atom/Initialize()! Value: [armor]")
		#endif

		atom_integrity = max_integrity

	// Not typeinfo() for speed reasons. Hot ass code!
	var/datum/typeinfo/atom/typeinfo = __typeinfo_cache[type] ||= new __typeinfo_path

	// apply materials properly from the default_materials value in typeinfo
	// This MUST come after atom_integrity is set above, as if old materials get removed,
	// atom_integrity is checked against max_integrity and can BREAK the atom.
	// The integrity to max_integrity ratio is still preserved.
	if(length(typeinfo.default_materials) && isnull(custom_materials))
		set_custom_materials(typeinfo.default_materials)

	return INITIALIZE_HINT_NORMAL

/**
 * Late Intialization, for code that should run after all atoms have run Intialization
 *
 * To have your LateIntialize proc be called, your atoms [Initalization][/atom/proc/Initialize]
 *  proc must return the hint
 * [INITIALIZE_HINT_LATELOAD] otherwise you will never be called.
 *
 * useful for doing things like finding other machines using INSTANCES_OF() because you can guarantee
 * that all atoms will actually exist in the "WORLD" at this time and that all their Intialization
 * code has been run
 */
/atom/proc/LateInitialize()
	set waitfor = FALSE

/**
 * Top level of the destroy chain for most atoms
 *
 * Cleans up the following:
 * * Removes alternate apperances from huds that see them
 * * qdels the reagent holder from atoms if it exists
 * * clears the orbiters list
 * * clears overlays and priority overlays
 * * clears the light object
 */
/atom/Destroy(force)
	if(alternate_appearances)
		for(var/current_alternate_appearance in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/selected_alternate_appearance = alternate_appearances[current_alternate_appearance]
			selected_alternate_appearance.remove_atom_from_hud(src)

	if(reagents)
		QDEL_NULL(reagents)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	if(forensics)
		QDEL_NULL(forensics)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	if(length(overlays))
		overlays.Cut()

	if(light)
		QDEL_NULL(light)

	if(ai_controller)
		QDEL_NULL(ai_controller)

	LAZYNULL(managed_overlays)

	if(length(light_sources))
		light_sources.len = 0

	if(smoothing_flags & SMOOTH_QUEUED)
		SSicon_smooth.remove_from_queues(src)

	return ..()

/// A quick and easy way to create a storage datum for an atom
/atom/proc/create_storage(
	max_slots,
	max_specific_storage,
	max_total_storage,
	numerical_stacking = FALSE,
	allow_quick_gather = FALSE,
	allow_quick_empty = FALSE,
	collection_mode = COLLECT_ONE,
	attack_hand_interact = TRUE,
	list/canhold,
	list/canthold,
	type = /datum/storage,
)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new type(src, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, collection_mode, attack_hand_interact)

	if(canhold || canthold)
		atom_storage.set_holdable(canhold, canthold)

	return atom_storage

/// A quick and easy way to /clone/ a storage datum for an atom (does not copy over contents, only the datum details)
/atom/proc/clone_storage(datum/storage/cloning)
	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new cloning.type(src, cloning.max_slots, cloning.max_specific_storage, cloning.max_total_storage, cloning.numerical_stacking, cloning.allow_quick_gather, cloning.collection_mode, cloning.attack_hand_interact)

	if(cloning.can_hold || cloning.cant_hold)
		atom_storage.set_holdable(cloning.can_hold, cloning.cant_hold)

	return atom_storage

/// Creates our forensics datum
/atom/proc/create_forensics()
	if(QDELING(src))
		return
	forensics = new(src)

/atom/proc/handle_ricochet(obj/projectile/ricocheting_projectile)
	var/turf/p_turf = get_turf(ricocheting_projectile)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (ricocheting_projectile.Angle + 180))
	var/a_incidence_s = abs(incidence_s)
	if(a_incidence_s > 90 && a_incidence_s < 270)
		return FALSE
	if((ricocheting_projectile.armor_flag in list(PUNCTURE, BOMB)) && ricocheting_projectile.ricochet_incidence_leeway)
		if((a_incidence_s < 90 && a_incidence_s < 90 - ricocheting_projectile.ricochet_incidence_leeway) || (a_incidence_s > 270 && a_incidence_s -270 > ricocheting_projectile.ricochet_incidence_leeway))
			return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	ricocheting_projectile.set_angle(new_angle_s)
	return TRUE

/// Whether the mover object can avoid being blocked by this atom, while arriving from (or leaving through) the border_dir.
/atom/proc/CanPass(atom/movable/mover, border_dir)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(!mover)
		return FALSE
	if(mover.movement_type & PHASING)
		return TRUE
	. = CanAllowThrough(mover, border_dir)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, REVERSE_DIR(border_dir), .)

/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, border_dir)
	SHOULD_CALL_PARENT(TRUE)
	//SHOULD_BE_PURE(TRUE)
	if(mover.pass_flags & pass_flags_self)
		return TRUE
	if(mover.throwing && (pass_flags_self & LETPASSTHROW))
		return TRUE
	return !density

/// A version of CanPass() that accounts for vertical movement.
/atom/proc/CanMoveOnto(atom/movable/mover, border_dir)
	return ((border_dir & DOWN) && HAS_TRAIT(src, TRAIT_CLIMBABLE)) || CanPass(mover, border_dir)

/**
 * Is this atom currently located on centcom
 *
 * Specifically, is it on the z level and within the centcom areas
 *
 * You can also be in a shuttleshuttle during endgame transit
 *
 * Used in gamemode to identify mobs who have escaped and for some other areas of the code
 * who don't want atoms where they shouldn't be
 */
/atom/proc/onCentCom()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE

	if(is_reserved_level(current_turf.z))
		for(var/obj/docking_port/mobile/mobile_docking_port as anything in SSshuttle.mobile_docking_ports)
			if(mobile_docking_port.launch_status != ENDGAME_TRANSIT)
				continue
			for(var/area/shuttle/shuttle_area as anything in mobile_docking_port.shuttle_areas)
				if(current_turf in shuttle_area)
					return TRUE

	if(!is_centcom_level(current_turf.z))//if not, don't bother
		return FALSE

	//Check for centcom itself
	if(istype(current_turf.loc, /area/centcom))
		return TRUE

	//Check for centcom shuttles
	for(var/obj/docking_port/mobile/mobile_docking_port as anything in SSshuttle.mobile_docking_ports)
		if(mobile_docking_port.launch_status == ENDGAME_LAUNCHED)
			for(var/place as anything in mobile_docking_port.shuttle_areas)
				var/area/shuttle/shuttle_area = place
				if(current_turf in shuttle_area)
					return TRUE

/**
 * Is the atom in any of the centcom syndicate areas
 *
 * Either in the syndie base on centcom, or any of their shuttles
 *
 * Also used in gamemode code for win conditions
 */
/atom/proc/onSyndieBase()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE

	if(!is_centcom_level(current_turf.z))//if not, don't bother
		return FALSE

	if(istype(current_turf.loc, /area/shuttle/syndicate) || istype(current_turf.loc, /area/centcom/syndicate_mothership) || istype(current_turf.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

/**
 * Is the atom in an away mission
 *
 * Must be in the away mission z-level to return TRUE
 *
 * Also used in gamemode code for win conditions
 */
/atom/proc/onAwayMission()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE

	if(is_away_level(current_turf.z))
		return TRUE

	return FALSE



///This atom has been hit by a hulkified mob in hulk mode (user)
/atom/proc/attack_hulk(mob/living/carbon/human/user)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)

/**
 * Ensure a list of atoms/reagents exists inside this atom
 *
 * Goes throught he list of passed in parts, if they're reagents, adds them to our reagent holder
 * creating the reagent holder if it exists.
 *
 * If the part is a moveable atom and the  previous location of the item was a mob/living,
 * it calls the inventory handler transferItemToLoc for that mob/living and transfers the part
 * to this atom
 *
 * Otherwise it simply forceMoves the atom into this atom
 */
/atom/proc/CheckParts(list/parts_list, datum/crafting_recipe/current_recipe)
	SEND_SIGNAL(src, COMSIG_ATOM_CHECKPARTS, parts_list, current_recipe)
	if(!parts_list)
		return
	for(var/part in parts_list)
		if(istype(part, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(part)
		else if(ismovable(part))
			var/atom/movable/object = part
			if(isliving(object.loc))
				var/mob/living/living = object.loc
				living.transferItemToLoc(object, src)
			else
				object.forceMove(src)
			SEND_SIGNAL(object, COMSIG_ATOM_USED_IN_CRAFT, src)
	parts_list.Cut()

///Take air from the passed in gas mixture datum
/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

///Remove air from this atom
/atom/proc/remove_air(amount)
	return null

///Return the current air environment in this atom
/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

///Return the current air environment in this atom. If this atom is a turf, it will not automatically update the zone.
/atom/proc/unsafe_return_air()
	return return_air()


///Return the air if we can analyze it
/atom/proc/return_analyzable_air()
	return null

///Return air that a contained mob will be breathing.
/atom/proc/return_breathable_air()
	return return_air()

///Check if this atoms eye is still alive (probably)
/atom/proc/check_eye(mob/user)
	SIGNAL_HANDLER
	return

/atom/proc/BumpedBy(atom/movable/bumped_atom)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, bumped_atom)

/// Convenience proc to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/// Is this atom injectable into other atoms
/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (INJECTABLE | REFILLABLE))

/// Can we draw from this atom with an injectable atom
/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (reagents.flags & (DRAWABLE | DRAINABLE))

/// Can this atoms reagents be refilled
/atom/proc/is_refillable()
	return reagents && (reagents.flags & REFILLABLE)

/// Is this atom drainable of reagents
/atom/proc/is_drainable()
	return reagents && (reagents.flags & DRAINABLE)

/** Handles exposing this atom to a list of reagents.
 *
 * Sends COMSIG_ATOM_EXPOSE_REAGENTS
 * Calls expose_atom() for every reagent in the reagent list.
 *
 * Arguments:
 * - [reagents][/list]: The list of reagents the atom is being exposed to.
 * - [source][/datum/reagents]: The reagent holder the reagents are being sourced from.
 * - methods: How the atom is being exposed to the reagents. Bitflags.
 * - volume_modifier: Volume multiplier.
 * - show_message: Whether to display anything to mobs when they are exposed.
 * - exposed_temperature: The temperature of the reagent during exposure
 */
/atom/proc/expose_reagents(list/reagents, datum/reagents/source, methods=TOUCH, volume_modifier=1, show_message=TRUE, exposed_temperature)
	. = SEND_SIGNAL(src, COMSIG_ATOM_EXPOSE_REAGENTS, reagents, source, methods, volume_modifier, show_message)
	if(. & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	SEND_SIGNAL(source, COMSIG_REAGENTS_EXPOSE_ATOM, src, reagents, methods, volume_modifier, show_message, exposed_temperature)
	for(var/datum/reagent/current_reagent as anything in reagents)
		. |= current_reagent.expose_atom(src, reagents[current_reagent], exposed_temperature)

/// Are you allowed to drop this atom
/atom/proc/AllowDrop()
	return FALSE

///Is this atom within 1 tile of another atom
/atom/proc/HasProximity(atom/movable/proximity_check_mob as mob|obj)
	return

/**
 * React to an EMP of the given severity
 *
 * Default behaviour is to send the [COMSIG_ATOM_EMP_ACT] signal
 *
 * If the signal does not return protection, and there are attached wires then we call
 * [emp_pulse][/datum/wires/proc/emp_pulse] on the wires
 *
 * We then return the protection value
 */
/atom/proc/emp_act(severity)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
		wires.emp_pulse()
	return protection // Pass the protection value collected here upwards

/**
 * React to a hit by a projectile object
 *
 * Default behaviour is to send the [COMSIG_ATOM_BULLET_ACT] and then call [on_hit][/obj/projectile/proc/on_hit] on the projectile.
 *
 * @params
 * hitting_projectile - projectile
 * def_zone - zone hit
 * piercing_hit - is this hit piercing or normal?
 */
/atom/proc/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, hitting_projectile, def_zone)
	// This armor check only matters for the visuals and messages in on_hit(), it's not actually used to reduce damage since
	// only living mobs use armor to reduce damage, but on_hit() is going to need the value no matter what is shot.
	var/visual_armor_check = check_projectile_armor(def_zone, hitting_projectile)
	. = hitting_projectile.on_hit(src, visual_armor_check, def_zone, piercing_hit)
	spawn_debris(hitting_projectile)

///Return true if we're inside the passed in atom
/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user)
	var/list/name_list = list(name)

	SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, name_list)
	if(gender == PLURAL)
		return jointext(name_list, " ")

	else
		return "\a [jointext(name_list, " ")]"

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	var/that_string = gender == PLURAL ? "Those are " : "That is "
	return "[icon2html(src, user)] [thats? that_string :""][get_examine_name(user)]"

/**
 * Returns an extended list of examine strings for any contained ID cards.
 *
 * Arguments:
 * * user - The user who is doing the examining.
 */
/atom/proc/get_id_examine_strings(mob/user)
	. = list()
	return

///Used to insert text after the name but before the description in examine()
/atom/proc/get_name_chaser(mob/user, list/name_chaser = list())
	return name_chaser

/**
 * Called when a mob examines (shift click or verb) this atom
 *
 * Default behaviour is to get the name and icon of the object and it's reagents where
 * the [TRANSPARENT] flag is set on the reagents holder
 *
 * Produces a signal [COMSIG_PARENT_EXAMINE]
 */
/atom/proc/examine(mob/user)
	. = list("[get_examine_string(user, TRUE)].")
	. += get_name_chaser(user)

	if(desc)
		. += desc

	. += "<hr>"

	var/list/properties = examine_properties(user)
	if(length(properties))
		. += "<i>[jointext(properties, ", ")]</i>"
		. += "<hr>"

	var/place_linebreak = FALSE
	var/datum/codex_entry/entry = SScodex.get_codex_entry(get_codex_value(user))
	if(entry)
		var/information_type = length(entry.controls_text) ? "controls" : "relevant information"
		. += "<span class='obviousnotice'>The codex has <b><a href='?src=\ref[SScodex];show_examined_info=\ref[src];show_to=\ref[user]'>[information_type]</a></b> available.</span>"
		place_linebreak = TRUE

	if(isitem(src) && length(slapcraft_examine_hints_for_type(type)))
		. += "<span class='obviousnotice'><b><a href='?src=\ref[user.client];show_slapcraft_hints=[type];'>You could craft [(length(slapcraft_examine_hints_for_type(type)) > 1) ? "several things" : "something"] with it.</a><b></span>"
		place_linebreak = TRUE

	if(place_linebreak)
		. += ""

	if(z && user.z && user.z != z)
		var/diff = abs(user.z - z)
		. += span_notice("<b>[p_theyre(TRUE)] [diff] level\s below you.</b>")

	if(custom_materials)
		var/list/materials_list = list()
		for(var/datum/material/current_material as anything in custom_materials)
			materials_list += "[current_material.name]"
		. += span_notice("It is made out of [english_list(materials_list)].")

	if(reagents)
		if(reagents.flags & TRANSPARENT)
			if(!length(reagents.reagent_list))
				. += span_alert("It looks empty.")
			else
				if(user.can_see_reagents()) //Show each individual reagent
					. += span_notice("You see the following reagents:")
					for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
						. += span_notice("* [round(current_reagent.volume, CHEMICAL_VOLUME_ROUNDING)] units of [current_reagent.name].")

					if(reagents.is_reacting)
						. += span_alert("A chemical reaction is taking place.")

					. += span_notice("The solution's temperature is [reagents.chem_temp]K.")

				else //Otherwise, just show the total volume
					. += span_notice("It looks about [reagents.total_volume / reagents.maximum_volume * 100]% full.")

		else if(reagents.flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += span_notice("It looks about [reagents.total_volume / reagents.maximum_volume * 100]% full.")
			else
				. += span_alert("It looks empty.")

	if(ishuman(user) && !ismovable(loc) && !ismob(src))
		var/mob/living/carbon/human/human_user = user
		human_user.forensic_analysis_roll(src)

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/**
 * Called by examine()
 *
 * This is where you put generic property tags that can be moused over for more information.
 *
 * Produces a signal [COMSIG_PARENT_EXAMINE_PROPERTIES]
 */
/atom/proc/examine_properties(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE_PROPERTIES, user, .)

/**
 * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_WINDOW (default 1 second)
 *
 * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
 * moments, while allowing people to manually double-examine to take a closer look
 *
 * Produces a signal [COMSIG_PARENT_EXAMINE_MORE]
 */
/atom/proc/examine_more(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE_MORE, user, .)

/**
 * Called when a human examines (shift click or verb) this atom. Called after the examine text is displayed.
 *
 * This is for placing disco elysium style flavor text that follows an examine message only once.
 * * Arguments:
 * - user: The mob examining.
 * - nearby: Set to TRUE if the mob is within 1 turf.
 */
/atom/proc/disco_flavor(mob/living/carbon/human/user, nearby = FALSE, is_station_level = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_DISCO_FLAVOR, user, nearby, is_station_level)


/**
 * Updates the appearence of the icon
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 */
/atom/proc/update_appearance(updates=ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		. |= update_name(updates)
	if(updates & UPDATE_DESC)
		. |= update_desc(updates)
	if(updates & UPDATE_ICON)
		. |= update_icon(updates)

	// This is not an override for performance.
	if (ismovable(src))
		UPDATE_OO_IF_PRESENT

/// Updates the name of the atom
/atom/proc/update_name(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)

/// Updates the description of the atom
/atom/proc/update_desc(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)

/// Updates the icon of the atom
/atom/proc/update_icon(updates=ALL)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_OVERLAYS)
		var/list/new_overlays = update_overlays(updates)
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			if (length(new_overlays) == 1)
				managed_overlays = new_overlays[1]
			else
				managed_overlays = new_overlays
			add_overlay(new_overlays)
		. |= UPDATE_OVERLAYS

	. |= SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates, .)

/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/// Handles updates to greyscale value updates.
/// The colors argument can be either a list or the full color string.
/// Child procs should call parent last so the update happens after all changes.
/atom/proc/set_greyscale(list/colors, new_config)
	SHOULD_CALL_PARENT(TRUE)
	if(islist(colors))
		colors = jointext(colors, "")
	if(!isnull(colors) && greyscale_colors != colors) // If you want to disable greyscale stuff then give a blank string
		greyscale_colors = colors

	if(!isnull(new_config) && greyscale_config != new_config)
		greyscale_config = new_config

	update_greyscale()

/// Checks if this atom uses the GAGS system and if so updates the icon
/atom/proc/update_greyscale()
	SHOULD_CALL_PARENT(TRUE)
	if(greyscale_colors && greyscale_config)
		icon = SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors)
	if(!smoothing_flags) // This is a bitfield but we're just checking that some sort of smoothing is happening
		return
	update_atom_colour()
	QUEUE_SMOOTH(src)

/**
 * An atom we are buckled or is contained within us has tried to move
 *
 * Default behaviour is to send a warning that the user can't move while buckled as long
 * as the [buckle_message_cooldown][/atom/var/buckle_message_cooldown] has expired (50 ticks)
 */
/atom/proc/relaymove(mob/living/user, direction)
	if(SEND_SIGNAL(src, COMSIG_ATOM_RELAYMOVE, user, direction) & COMSIG_BLOCK_RELAYMOVE)
		return
	if(buckle_message_cooldown <= world.time)
		buckle_message_cooldown = world.time + 50
		to_chat(user, span_warning("You are unable to move while buckled to [src]."))
	return

/**
 * A special case of relaymove() in which the person relaying the move may be "driving" this atom
 *
 * This is a special case for vehicles and ridden animals where the relayed movement may be handled
 * by the riding component attached to this atom. Returns TRUE as long as there's nothing blocking
 * the movement, or FALSE if the signal gets a reply that specifically blocks the movement
 */
/atom/proc/relaydrive(mob/living/user, direction)
	return !(SEND_SIGNAL(src, COMSIG_RIDDEN_DRIVER_MOVE, user, direction) & COMPONENT_DRIVER_BLOCK_MOVE)

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	for(var/atom/movable/movable_thing as anything in contents)
		if(QDELETED(movable_thing))
			continue

		switch(severity)
			if(EXPLODE_DEVASTATE)
				EX_ACT(movable_thing, EXPLODE_DEVASTATE)
			if(EXPLODE_HEAVY)
				EX_ACT(movable_thing, EXPLODE_HEAVY)
			if(EXPLODE_LIGHT)
				EX_ACT(movable_thing, EXPLODE_LIGHT)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
 * React to being hit by an explosion
 *
 * Should be called through the [EX_ACT] wrapper macro.
 * The wrapper takes care of the [COMSIG_ATOM_EX_ACT] signal.
 * as well as calling [/atom/proc/contents_explosion].
 */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE

/**
 * React to a hit by a blob objecd
 *
 * default behaviour is to send the [COMSIG_ATOM_BLOB_ACT] signal
 */
/atom/proc/blob_act(obj/structure/blob/attacking_blob)
	var/blob_act_result = SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, attacking_blob)
	if (blob_act_result & COMPONENT_CANCEL_BLOB_ACT)
		return FALSE
	return TRUE

/atom/proc/fire_act(exposed_temperature, exposed_volume, turf/adjacent)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return

/**
 * React to being hit by a thrown object
 *
 * Default behaviour is to call [hitby_react][/atom/proc/hitby_react] on ourselves after 2 seconds if we are dense
 * and under normal gravity.
 *
 * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
 * deleted shortly after hitting something (during explosions or other massive events that
 * throw lots of items around - singularity being a notable example)
 */
/atom/proc/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(src, COMSIG_ATOM_HITBY, hitting_atom, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(hitting_atom)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), hitting_atom), 2)

/**
 * We have have actually hit the passed in atom
 *
 * Default behaviour is to move back from the item that hit us
 */
/atom/proc/hitby_react(atom/movable/harmed_atom)
	if(harmed_atom && isturf(harmed_atom.loc))
		step(harmed_atom, turn(harmed_atom.dir, 180))

///Handle the atom being slipped over
/atom/proc/handle_slip(mob/living/carbon/slipped_carbon, knockdown_amount, obj/slipping_object, lube, paralyze, force_drop)
	return

///returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	return list("ANIMAL DNA" = GET_BLOOD_REF(/datum/blood/animal))

/mob/proc/get_trace_dna()
	return

/mob/living/get_trace_dna()
	return "ANIMAL DNA"

/mob/living/carbon/get_trace_dna()
	if(dna)
		return dna.unique_enzymes
	return "UNKNOWN DNA"

///Get the mobs dna list
/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != /datum/reagent/blood)
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

/mob/living/silicon/get_blood_dna_list()
	return

///to add a mob's dna info into an object's blood_dna list.
/atom/proc/transfer_mob_blood_dna(mob/living/injected_mob)
	// Returns 0 if we have that blood already
	var/new_blood_dna = injected_mob.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	var/old_length = blood_DNA_length()
	add_blood_DNA(new_blood_dna)
	if(blood_DNA_length() == old_length)
		return FALSE
	return TRUE

///to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/injected_mob)
	var/list/blood_dna = injected_mob.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	return add_blood_DNA(blood_dna)

///Is this atom in space
/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

///Used for making a sound when a mob involuntarily falls into the ground.
/atom/proc/handle_fall(mob/faller)
	return

///Respond to the singularity eating this atom
/atom/proc/singularity_act()
	return

/**
 * Respond to the singularity pulling on us
 *
 * Default behaviour is to send [COMSIG_ATOM_SING_PULL] and return
 */
/atom/proc/singularity_pull(obj/singularity/singularity, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, singularity, current_size)


/**
 * Respond to acid being used on our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_ACID_ACT] and return
 */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)
	return FALSE

/**
 * Respond to an emag being used on our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_EMAG_ACT] and return
 */
/atom/proc/emag_act(mob/user, obj/item/card/emag/emag_card)
	SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user, emag_card)

/**
 * Respond to narsie eating our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_NARSIE_ACT] and return
 */
/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)


///Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE


/**
 * Respond to an RCD acting on our item
 *
 * Default behaviour is to send [COMSIG_ATOM_RCD_ACT] and return FALSE
 */
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/**
 * Respond to an electric bolt action on our item
 *
 * Returns an amount of power to use for future shocks.
 */
/atom/proc/zap_act(power, zap_flags)
	ADD_TRAIT(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS, TIMER_UNIQUE|TIMER_NO_HASH_WAIT)
	return 0

/**s
 * If someone's trying to dump items onto our atom, where should they be dumped to?
 *
 * Return a loc to place objects, or null to stop dumping.
 */
/atom/proc/get_dumping_location()
	return null

/**
 * This proc is called when an atom in our contents has it's [Destroy][/atom/proc/Destroy] called
 *
 * Default behaviour is to simply send [COMSIG_ATOM_CONTENTS_DEL]
 */
/atom/proc/handle_atom_del(atom/deleting_atom)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, deleting_atom)

/**
 * the vision impairment to give to the mob whose perspective is set to that atom
 *
 * (e.g. an unfocused camera giving you an impaired vision when looking through it)
 */
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

/**
 * the sight changes to give to the mob whose perspective is set to that atom
 *
 * (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
 */
/atom/proc/update_remote_sight(mob/living/user)
	return


/**
 * Hook for running code when a dir change occurs
 *
 * Not recommended to use, listen for the [COMSIG_ATOM_DIR_CHANGE] signal instead (sent by this proc)
 */
/atom/proc/setDir(newdir)
	SHOULD_CALL_PARENT(TRUE)
	if(newdir == dir)
		return null

	. = dir
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir
	return .

/**
 * Called when the atom log's in or out
 *
 * Default behaviour is to call on_log on the location this atom is in
 */
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)


/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


///Adds an instance of colour_type to the atom's atom_colours list
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!length(atom_colours))
		atom_colours = new /list(COLOUR_PRIORITY_AMOUNT)
	if(isnull(coloration))
		return
	if(colour_priority > length(atom_colours))
		CRASH("Invalid color priority supplied to add_atom_color!")

	atom_colours[colour_priority] = coloration
	update_atom_colour()


///Removes an instance of colour_type from the atom's atom_colours list
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		return
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/proc/update_atom_colour()
	if(!length(atom_colours))
		return
	for(var/checked_color in atom_colours)
		if(isnull(checked_color))
			continue
		if(islist(checked_color) && length(checked_color))
			color = checked_color
			return

		color = checked_color
		return
		if(isnull(checked_color))
			continue
		if(islist(checked_color) && length(checked_color))
			color = checked_color
			return

		color = checked_color
		return

	color = null


/**
 * Wash this atom
 *
 * This will clean it off any temporary stuff like blood. Override this in your item to add custom cleaning behavior.
 * Returns true if any washing was necessary and thus performed
 * Arguments:
 * * clean_types: any of the CLEAN_ constants
 */
/atom/proc/wash(clean_types)
	SHOULD_CALL_PARENT(TRUE)

	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, clean_types) & COMPONENT_CLEANED)
		. = TRUE

	if(forensics)
		. = forensics.wash(clean_types) || .

	// Basically "if has washable coloration"
	if(length(atom_colours) >= WASHABLE_COLOUR_PRIORITY && atom_colours[WASHABLE_COLOUR_PRIORITY])
		remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		return TRUE

/**
 * call back when a var is edited on this atom
 *
 * Can be used to implement special handling of vars
 *
 * At the atom level, if you edit a var named "color" it will add the atom colour with
 * admin level priority to the atom colours list
 *
 * Also, if GLOB.Debug2 is FALSE, it sets the [ADMIN_SPAWNED_1] flag on [flags_1][/atom/var/flags_1], which signifies
 * the object has been admin edited
 */
/atom/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, light_inner_range))
			if(light_system == COMPLEX_LIGHT)
				set_light(l_outer_range = light_outer_range, l_inner_range = var_value, )
				. = TRUE
		if(NAMEOF(src, light_outer_range))
			if(light_system == COMPLEX_LIGHT)
				set_light(l_outer_range = var_value, l_inner_range = light_inner_range)
			else
				set_light_range(var_value)
			. = TRUE
		if(NAMEOF(src, light_power))
			if(light_system == COMPLEX_LIGHT)
				set_light(l_power = var_value)
			else
				set_light_power(var_value)
			. = TRUE
		if(NAMEOF(src, light_color))
			if(light_system == COMPLEX_LIGHT)
				set_light(l_color = var_value)
			else
				set_light_color(var_value)
			. = TRUE
		if(NAMEOF(src, light_on))
			if(light_system == COMPLEX_LIGHT)
				set_light(l_on = var_value)
			else
				set_light_color(var_value)
			. = TRUE
		if(NAMEOF(src, light_flags))
			set_light_flags(var_value)
			. = TRUE
		if(NAMEOF(src, smoothing_junction))
			set_smoothed_icon_state(var_value)
			. = TRUE
		if(NAMEOF(src, opacity))
			set_opacity(var_value)
			. = TRUE
		if(NAMEOF(src, base_pixel_x))
			set_base_pixel_x(var_value)
			. = TRUE
		if(NAMEOF(src, base_pixel_y))
			set_base_pixel_y(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	if(!GLOB.Debug2)
		flags_1 |= ADMIN_SPAWNED_1

	. = ..()

	switch(var_name)
		if(NAMEOF(src, color))
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)


/**
 * Return the markup to for the dropdown list for the VV panel for this atom
 *
 * Override in subtypes to add custom VV handling in the VV panel
 */
/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	if(!ismovable(src))
		var/turf/curturf = get_turf(src)
		if(curturf)
			. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]'>Jump To</option>"
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_SHOW_HIDDENPRINTS, "Show Hiddenprint log")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_FILTERS, "Edit Filters")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_COLOR_MATRIX, "Edit Color as Matrix")
	VV_DROPDOWN_OPTION(VV_HK_ADD_AI, "Add AI controller")
	if(greyscale_colors)
		VV_DROPDOWN_OPTION(VV_HK_MODIFY_GREYSCALE, "Modify greyscale colors")

/atom/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ADD_REAGENT] && check_rights(R_VAREDIT))
		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num|null
			if(amount)
				create_reagents(amount)

		if(reagents)
			var/datum/reagent/chosen_id
			switch(tgui_alert(usr, "Choose a method.", "Add Reagents", list("Search", "Choose from a list", "I'm feeling lucky")))
				if("Search")
					var/valid_id
					while(!valid_id)
						chosen_id = input(usr, "Enter the ID of the reagent you want to add.", "Search reagents") as null|text
						if(isnull(chosen_id)) //Get me out of here!
							break
						if (!ispath(text2path(chosen_id)))
							chosen_id = pick_closest_path(chosen_id, make_types_fancy(subtypesof(/datum/reagent)))
							if (ispath(chosen_id) && !isabstract(chosen_id))
								valid_id = TRUE
						else
							valid_id = TRUE
						if(!valid_id)
							to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
				if("Choose from a list")
					chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in sort_list(subtypesof(/datum/reagent), GLOBAL_PROC_REF(cmp_typepaths_asc))
				if("I'm feeling lucky")
					chosen_id = pick(subtypesof(/datum/reagent))
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num|null
				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src]")
					message_admins(span_notice("[key_name(usr)] has added [amount] units of [chosen_id] to [src]"))

	if(href_list[VV_HK_TRIGGER_EXPLOSION] && check_rights(R_FUN))
		usr.client.cmd_admin_explosion(src)

	if(href_list[VV_HK_TRIGGER_EMP] && check_rights(R_FUN))
		usr.client.cmd_admin_emp(src)

	if(href_list[VV_HK_SHOW_HIDDENPRINTS] && check_rights(R_ADMIN))
		usr.client.cmd_show_hiddenprints(src)


	if(href_list[VV_HK_ADD_AI])
		if(!check_rights(R_VAREDIT))
			return
		var/result = input(usr, "Choose the AI controller to apply to this atom WARNING: Not all AI works on all atoms.", "AI controller") as null|anything in subtypesof(/datum/ai_controller)
		if(!result)
			return
		ai_controller = new result(src)

	if(href_list[VV_HK_MODIFY_TRANSFORM] && check_rights(R_VAREDIT))
		var/result = input(usr, "Choose the transformation to apply","Transform Mod") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = transform
		if(!result)
			return
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(isnull(x) || isnull(y))
					return
				transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod (negative = left, positive = right)","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod (negative = down, positive = up)","Transform Mod") as null|num
				if(isnull(x) || isnull(y))
					return
				transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate","Transform Mod") as null|num
				if(isnull(angle))
					return
				transform = M.Turn(angle)

		SEND_SIGNAL(src, COMSIG_ATOM_VV_MODIFY_TRANSFORM)

	if(href_list[VV_HK_AUTO_RENAME] && check_rights(R_VAREDIT))
		var/newname = input(usr, "What do you want to rename this to?", "Automatic Rename") as null|text
		// Check the new name against the chat filter. If it triggers the IC chat filter, give an option to confirm.
		if(newname && !(is_ic_filtered(newname) || is_soft_ic_filtered(newname) && tgui_alert(usr, "Your selected name contains words restricted by IC chat filters. Confirm this new name?", "IC Chat Filter Conflict", list("Confirm", "Cancel")) != "Confirm"))
			vv_auto_rename(newname)

	if(href_list[VV_HK_EDIT_FILTERS] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_filter_editor(src)

	if(href_list[VV_HK_EDIT_COLOR_MATRIX] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_color_matrix_editor(src)

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

///Where atoms should drop if taken from this atom
/atom/proc/drop_location()
	RETURN_TYPE(/atom)
	var/atom/location = loc
	if(!location)
		return null
	return location.AllowDrop() ? location : location.drop_location()

/atom/proc/vv_auto_rename(newname)
	name = newname

/**
 * An atom has entered this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_ENTERED]
 */
/atom/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, arrived, old_loc, old_locs)
	SEND_SIGNAL(arrived, COMSIG_ATOM_ENTERING, src, old_loc, old_locs)

/**
 * An atom is attempting to exit this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_EXIT]
 */
/atom/Exit(atom/movable/leaving, direction, no_side_effects)
	// Don't call `..()` here, otherwise `Uncross()` gets called.
	// See the doc comment on `Uncross()` to learn why this is bad.

	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, leaving, direction, no_side_effects) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

	return TRUE

/**
 * An atom has exited this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_EXITED]
 */
/atom/Exited(atom/movable/gone, direction)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, gone, direction)

///Return atom temperature
/atom/proc/return_temperature()
	return

/atom/proc/process_recipes(mob/living/user, obj/item/processed_object, list/processing_recipes)
	//Only one recipe? use the first
	if(processing_recipes.len == 1)
		StartProcessingAtom(user, processed_object, processing_recipes[1])
		return
	//Otherwise, select one with a radial
	ShowProcessingGui(user, processed_object, processing_recipes)

///Creates the radial and processes the selected option
/atom/proc/ShowProcessingGui(mob/living/user, obj/item/processed_object, list/possible_options)
	var/list/choices_to_options = list() //Dict of object name | dict of object processing settings
	var/list/choices = list()

	for(var/list/current_option as anything in possible_options)
		var/atom/current_option_type = current_option[TOOL_PROCESSING_RESULT]
		choices_to_options[initial(current_option_type.name)] = current_option
		var/image/option_image = image(icon = initial(current_option_type.icon), icon_state = initial(current_option_type.icon_state))
		choices += list("[initial(current_option_type.name)]" = option_image)

	var/pick = show_radial_menu(user, src, choices, radius = 36, require_near = TRUE)
	if(!pick)
		return

	StartProcessingAtom(user, processed_object, choices_to_options[pick])


/atom/proc/StartProcessingAtom(mob/living/user, obj/item/process_item, list/chosen_option)
	var/processing_time = chosen_option[TOOL_PROCESSING_TIME]
	to_chat(user, span_notice("You start working on [src]."))
	if(process_item.use_tool(src, user, processing_time, volume=50))
		var/atom/atom_to_create = chosen_option[TOOL_PROCESSING_RESULT]
		var/list/atom/created_atoms = list()
		for(var/i = 1 to chosen_option[TOOL_PROCESSING_AMOUNT])
			var/atom/created_atom = new atom_to_create(drop_location())
			if(custom_materials)
				created_atom.set_custom_materials(custom_materials, 1 / chosen_option[TOOL_PROCESSING_AMOUNT])
			created_atom.pixel_x = pixel_x
			created_atom.pixel_y = pixel_y
			if(i > 1)
				created_atom.pixel_x += rand(-8,8)
				created_atom.pixel_y += rand(-8,8)
			SEND_SIGNAL(created_atom, COMSIG_ATOM_CREATEDBY_PROCESSING, src, chosen_option)
			created_atom.OnCreatedFromProcessing(user, process_item, chosen_option, src)
			to_chat(user, span_notice("You manage to create [chosen_option[TOOL_PROCESSING_AMOUNT]] [initial(atom_to_create.name)]\s from [src]."))
			created_atoms.Add(created_atom)
		SEND_SIGNAL(src, COMSIG_ATOM_PROCESSED, user, process_item, created_atoms)
		UsedforProcessing(user, process_item, chosen_option)
		return

/atom/proc/UsedforProcessing(mob/living/user, obj/item/used_item, list/chosen_option)
	qdel(src)
	return

/atom/proc/OnCreatedFromProcessing(mob/living/user, obj/item/food, list/chosen_option, atom/original_atom)
	return

///Check if the multitool has an item in it's data buffer
/atom/proc/multitool_check_buffer(user, obj/item/multitool, silent = FALSE)
	if(!istype(multitool, /obj/item/multitool))
		if(user && !silent)
			to_chat(user, span_warning("[multitool] has no data buffer!"))
		return FALSE
	return TRUE

///Connect this atom to a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return

/**
 * Generic logging helper
 *
 * reads the type of the log
 * and writes it to the respective log file
 * unless log_globally is FALSE
 * Arguments:
 * * message - The message being logged
 * * message_type - the type of log the message is(ATTACK, SAY, etc)
 * * color - color of the log text
 * * log_globally - boolean checking whether or not we write this log to the log file
 */
/atom/proc/log_message(message, message_type, color=null, log_globally=TRUE)
	if(!log_globally)
		return

	var/log_text = "[key_name(src)] [message] [loc_name(src)]"
	switch(message_type)
		if(LOG_ATTACK)
			log_attack(log_text)
		if(LOG_SAY)
			log_say(log_text)
		if(LOG_WHISPER)
			log_whisper(log_text)
		if(LOG_EMOTE)
			log_emote(log_text)
		if(LOG_RADIO_EMOTE)
			log_radio_emote(log_text)
		if(LOG_DSAY)
			log_dsay(log_text)
		if(LOG_PDA)
			log_pda(log_text)
		if(LOG_CHAT)
			log_chat(log_text)
		if(LOG_COMMENT)
			log_comment(log_text)
		if(LOG_TELECOMMS)
			log_telecomms(log_text)
		if(LOG_ECON)
			log_econ(log_text)
		if(LOG_OOC)
			log_ooc(log_text)
		if(LOG_ADMIN)
			log_admin(log_text)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text)
		if(LOG_ASAY)
			log_adminsay(log_text)
		if(LOG_OWNERSHIP)
			log_game(log_text)
		if(LOG_GAME)
			log_game(log_text)
		if(LOG_MECHA)
			log_mecha(log_text)
		if(LOG_SHUTTLE)
			log_shuttle(log_text)
		if(LOG_MECHCOMP)
			log_mechcomp(log_text)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text)

/**
 * Helper for logging chat messages or other logs with arbitrary inputs(e.g. announcements)
 *
 * This proc compiles a log string by prefixing the tag to the message
 * and suffixing what it was forced_by if anything
 * if the message lacks a tag and suffix then it is logged on its own
 * Arguments:
 * * message - The message being logged
 * * message_type - the type of log the message is(ATTACK, SAY, etc)
 * * tag - tag that indicates the type of text(announcement, telepathy, etc)
 * * log_globally - boolean checking whether or not we write this log to the log file
 * * forced_by - source that forced the dialogue if any
 */
/atom/proc/log_talk(message, message_type, tag = null, log_globally = TRUE, forced_by = null, custom_say_emote = null)
	var/prefix = tag ? "([tag]) " : ""
	var/suffix = forced_by ? " FORCED by [forced_by]" : ""
	log_message("[prefix][custom_say_emote ? "*[custom_say_emote]*, " : ""]\"[message]\"[suffix]", message_type, log_globally=log_globally)

/// Helper for logging of messages with only one sender and receiver
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag="[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, LOG_VICTIM, tag="[tag] from [key_name(source)]", log_globally=FALSE)

/**
 * Log a combat message in the attack log
 *
 * Arguments:
 * * atom/user - argument is the actor performing the action
 * * atom/target - argument is the target of the action
 * * what_done - is a verb describing the action (e.g. punched, throwed, kicked, etc.)
 * * atom/object - is a tool with which the action was made (usually an item)
 * * addition - is any additional text, which will be appended to the rest of the log line
 */
/proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	var/ssource = key_name(user)
	var/starget = key_name(target)

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	var/sobject = ""
	if(object)
		sobject = " with [object]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp]"

	var/message = "has [what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color="red")

	if(user != target)
		var/reverse_message = "has been [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_VICTIM, color="orange", log_globally=FALSE)

/atom/proc/add_filter(name,priority,list/params)
	LAZYINITLIST(filter_data)
	var/list/copied_parameters = params.Copy()
	copied_parameters["priority"] = priority
	filter_data[name] = copied_parameters
	update_filters()

/atom/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, GLOBAL_PROC_REF(cmp_filter_data_priority), TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/atom/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/atom/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/obj/item/update_filters()
	. = ..()
	update_action_buttons()

/atom/proc/get_filter(name)
	if(filter_data && filter_data[name])
		return filters[filter_data.Find(name)]

/atom/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/atom/proc/clear_filters()
	filter_data = null
	filters = null

/atom/proc/intercept_zImpact(list/falling_movables, levels = 1)
	SHOULD_CALL_PARENT(TRUE)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, falling_movables, levels)

/// Sets the custom materials for an item.
/atom/proc/set_custom_materials(list/materials, multiplier = 1)
	if(length(custom_materials) && istype(custom_materials[1], /datum/material) && (material_flags & MATERIAL_EFFECTS)) //Only runs if custom materials existed at first and affected src.
		for(var/datum/material/material as anything in custom_materials)
			material.on_removed(src, custom_materials[material] * material_modifier, material_flags) //Remove the current materials

	if(!length(materials))
		custom_materials = null
		return

	custom_materials = SSmaterials.FindOrCreateMaterialCombo(materials, multiplier)

	if(material_flags & MATERIAL_EFFECTS)
		for(var/datum/material/material as anything in custom_materials)
			material.on_applied(src, materials[material] * multiplier * material_modifier, material_flags)

/**
 * Returns the material composition of the atom.
 *
 * Used when recycling items, specifically to turn alloys back into their component mats.
 *
 * Exists because I'd need to add a way to un-alloy alloys or otherwise deal
 * with people converting the entire stations material supply into alloys.
 *
 * Arguments:
 * - flags: A set of flags determining how exactly the materials are broken down.
 */
/atom/proc/get_material_composition(breakdown_flags=NONE)
	. = list()
	if(!(breakdown_flags & BREAKDOWN_INCLUDE_ALCHEMY) && HAS_TRAIT(src, TRAIT_MAT_TRANSMUTED))
		return

	var/list/cached_materials = custom_materials
	for(var/mat in cached_materials)
		var/datum/material/material = GET_MATERIAL_REF(mat)
		var/list/material_comp = material.return_composition(cached_materials[mat], breakdown_flags)
		for(var/comp_mat in material_comp)
			.[comp_mat] += material_comp[comp_mat]

/**
 * Fetches a list of all of the materials this object has of the desired type. Returns null if there is no valid materials of the type
 *
 * Arguments:
 * - [mat_type][/datum/material]: The type of material we are checking for
 * - exact: Whether to search for the _exact_ material type
 * - mat_amount: The minimum required amount of material
 */
/atom/proc/has_material_type(datum/material/mat_type, exact=FALSE, mat_amount=0)
	var/list/cached_materials = custom_materials
	if(!length(cached_materials))
		return null

	var/materials_of_type
	for(var/current_material in cached_materials)
		if(cached_materials[current_material] < mat_amount)
			continue
		var/datum/material/material = GET_MATERIAL_REF(current_material)
		if(exact ? material.type != current_material : !istype(material, mat_type))
			continue
		LAZYSET(materials_of_type, material, cached_materials[current_material])

	return materials_of_type

/**
 * Fetches a list of all of the materials this object has with the desired material category.
 *
 * Arguments:
 * - category: The category to check for
 * - any_flags: Any bitflags that must be present for the category
 * - all_flags: All bitflags that must be present for the category
 * - no_flags: Any bitflags that must not be present for the category
 * - mat_amount: The minimum amount of materials that must be present
 */
/atom/proc/has_material_category(category, any_flags=0, all_flags=0, no_flags=0, mat_amount=0)
	var/list/cached_materials = custom_materials
	if(!length(cached_materials))
		return null

	var/materials_of_category
	for(var/current_material in cached_materials)
		if(cached_materials[current_material] < mat_amount)
			continue
		var/datum/material/material = GET_MATERIAL_REF(current_material)
		var/category_flags = material?.categories[category]
		if(isnull(category_flags))
			continue
		if(any_flags && !(category_flags & any_flags))
			continue
		if(all_flags && (all_flags != (category_flags & all_flags)))
			continue
		if(no_flags && (category_flags & no_flags))
			continue
		LAZYSET(materials_of_category, material, cached_materials[current_material])
	return materials_of_category

/**
 * Gets the most common material in the object.
 */
/atom/proc/get_master_material()
	var/list/cached_materials = custom_materials
	if(!length(cached_materials))
		return null

	var/most_common_material = null
	var/max_amount = 0
	for(var/material in cached_materials)
		if(cached_materials[material] > max_amount)
			most_common_material = material
			max_amount = cached_materials[material]

	if(most_common_material)
		return GET_MATERIAL_REF(most_common_material)

/**
 * Gets the total amount of materials in this atom.
 */
/atom/proc/get_custom_material_amount()
	return isnull(custom_materials) ? 0 : counterlist_sum(custom_materials)


///Setter for the `density` variable to append behavior related to its changing.
/atom/proc/set_density(new_value)
	SHOULD_CALL_PARENT(TRUE)
	if(density == new_value)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_DENSITY_CHANGE, density, new_value)
	. = density
	density = new_value


///Setter for the `base_pixel_x` variable to append behavior related to its changing.
/atom/proc/set_base_pixel_x(new_value)
	if(base_pixel_x == new_value)
		return
	. = base_pixel_x
	base_pixel_x = new_value

	pixel_x = pixel_x + base_pixel_x - .


///Setter for the `base_pixel_y` variable to append behavior related to its changing.
/atom/proc/set_base_pixel_y(new_value)
	if(base_pixel_y == new_value)
		return
	. = base_pixel_y
	base_pixel_y = new_value

	pixel_y = pixel_y + base_pixel_y - .

/**
 * Returns true if this atom has gravity for the passed in turf
 *
 * Sends signals [COMSIG_ATOM_HAS_GRAVITY] and [COMSIG_TURF_HAS_GRAVITY], both can force gravity with
 * the forced gravity var.
 *
 * micro-optimized to hell because this proc is very hot, being called several times per movement every movement.
 *
 * HEY JACKASS, LISTEN
 * IF YOU ADD SOMETHING TO THIS PROC, MAKE SURE /mob/living ACCOUNTS FOR IT
 * Living mobs treat gravity in an event based manner. We've decomposed this proc into different checks
 * for them to use. If you add more to it, make sure you do that, or things will behave strangely
 *
 * Gravity situations:
 * * No gravity if you're not in a turf
 * * No gravity if this atom is in is a space turf
 * * Gravity if the area it's in always has gravity
 * * Gravity if there's a gravity generator on the z level
 * * Gravity if the Z level has an SSMappingTrait for ZTRAIT_GRAVITY
 * * otherwise no gravity
 */
/atom/proc/has_gravity(turf/gravity_turf)
	if(!isturf(gravity_turf))
		gravity_turf = get_turf(src)

		if(!gravity_turf)//no gravity in nullspace
			return 0

	var/list/forced_gravity = list()
	SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, gravity_turf, forced_gravity)
	SEND_SIGNAL(gravity_turf, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	if(length(forced_gravity))
		var/positive_grav = max(forced_gravity)
		var/negative_grav = min(min(forced_gravity), 0) //negative grav needs to be below or equal to 0

		//our gravity is sum of the most massive positive and negative numbers returned by the signal
		//so that adding two forced_gravity elements with an effect size of 1 each doesnt add to 2 gravity
		//but negative force gravity effects can cancel out positive ones

		return (positive_grav + negative_grav)

	var/area/turf_area = gravity_turf.loc
	return !gravity_turf.force_no_gravity && (turf_area.has_gravity || SSmapping.gravity_by_zlevel[gravity_turf.z])

/**
 * Causes effects when the atom gets hit by a rust effect from heretics
 *
 * Override this if you want custom behaviour in whatever gets hit by the rust
 */
/atom/proc/rust_heretic_act()

/**
 * Used to set something as 'open' if it's being used as a supplypod
 *
 * Override this if you want an atom to be usable as a supplypod.
 */
/atom/proc/setOpened()
	return

/**
 * Used to set something as 'closed' if it's being used as a supplypod
 *
 * Override this if you want an atom to be usable as a supplypod.
 */
/atom/proc/setClosed()
	return


///Called when something resists while this atom is its loc
/atom/proc/container_resist_act(mob/living/user)

/**
 * Used to attempt to charge an object with a payment component.
 *
 * Use this if an atom needs to attempt to charge another atom.
 */
/atom/proc/attempt_charge(atom/sender, atom/target, extra_fees = 0)
	return SEND_SIGNAL(sender, COMSIG_OBJ_ATTEMPT_CHARGE, target, extra_fees)

///Passes Stat Browser Panel clicks to the game and calls client click on an atom
/atom/Topic(href, list/href_list)
	. = ..()
	if(!usr?.client)
		return
	var/client/usr_client = usr.client
	var/list/paramslist = list()

	if(href_list["statpanel_item_click"])
		switch(href_list["statpanel_item_click"])
			if("left")
				paramslist[LEFT_CLICK] = "1"
			if("right")
				paramslist[RIGHT_CLICK] = "1"
			if("middle")
				paramslist[MIDDLE_CLICK] = "1"
			else
				return

		if(href_list["statpanel_item_shiftclick"])
			paramslist[SHIFT_CLICK] = "1"
		if(href_list["statpanel_item_ctrlclick"])
			paramslist[CTRL_CLICK] = "1"
		if(href_list["statpanel_item_altclick"])
			paramslist[ALT_CLICK] = "1"

		var/mouseparams = list2params(paramslist)
		usr_client.Click(src, loc, null, mouseparams)
		return TRUE

/**
 * Recursive getter method to return a list of all ghosts orbitting this atom
 *
 * This will work fine without manually passing arguments.
 * * processed - The list of atoms we've already convered
 * * source - Is this the atom for who we're counting up all the orbiters?
 * * ignored_stealthed_admins - If TRUE, don't count admins who are stealthmoded and orbiting this
 */
/atom/proc/get_all_orbiters(list/processed, source = TRUE, ignore_stealthed_admins = TRUE)
	var/list/output = list()
	if(!processed)
		processed = list()
	else if(src in processed)
		return output

	if(!source)
		output += src

	processed += src
	for(var/atom/atom_orbiter as anything in orbiters?.orbiter_list)
		output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output

/mob/get_all_orbiters(list/processed, source = TRUE, ignore_stealthed_admins = TRUE)
	if(!source && ignore_stealthed_admins && client?.holder?.fakekey)
		return list()
	return ..()

/**
 * Point at an atom
 *
 * Intended to enable and standardise the pointing animation for all atoms
 *
 * Not intended as a replacement for the mob verb
 */
/atom/movable/proc/point_at(atom/pointed_atom)
	if(!isturf(loc))
		return FALSE

	var/turf/tile = get_turf(pointed_atom)
	if (!tile)
		return FALSE

	var/turf/our_tile = get_turf(src)
	var/obj/visual = new /obj/effect/temp_visual/point(our_tile, invisibility)

	animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y, time = 1.7, easing = EASE_OUT)

	return TRUE

/atom/MouseEntered(location, control, params)
	SHOULD_CALL_PARENT(TRUE)
	. = !(1 || ..())
	SSmouse_entered.hovers[usr.client] = src
	SSmouse_entered.sustained_hovers[usr.client] = src

/atom/MouseExited(location, control, params)
	SHOULD_CALL_PARENT(TRUE)
	. = !(1 || ..())
	SSmouse_entered.sustained_hovers[usr.client] = null
	if(is_mouseover_interactable)
		usr.update_mouse_pointer()

/// Fired whenever this atom is the most recent to be hovered over in the tick.
/// Preferred over MouseEntered if you do not need information such as the position of the mouse.
/// Especially because this is deferred over a tick, do not trust that `client` is not null.
/atom/proc/on_mouse_enter(client/client)
	SHOULD_NOT_SLEEP(TRUE)

	var/mob/user = client?.mob
	if (isnull(user))
		return

	if(is_mouseover_interactable)
		user.update_mouse_pointer()

	set_screentip(client)

/// Sets the screentip in on_mouse_enter()
/atom/proc/set_screentip(client/client)
	PRIVATE_PROC(TRUE)

	// Setup a text cache
	var/static/list/screentip_text
	var/static/list/screentip_images
	if(isnull(screentip_images))
		screentip_text = list()
		screentip_images = list()
		screentip_images["LMB"] = image('icons/ui_icons/screentips/cursor_hints.dmi', "LMB")
		screentip_images["RMB"] = image('icons/ui_icons/screentips/cursor_hints.dmi', "RMB")

		screentip_text[SCREENTIP_CONTEXT_LMB] = "\icon[screentip_images["LMB"]]"
		screentip_text[SCREENTIP_CONTEXT_ALT_LMB] = "ALT \icon[screentip_images["LMB"]]"
		screentip_text[SCREENTIP_CONTEXT_CTRL_LMB] = "CTRL \icon[screentip_images["LMB"]]"
		screentip_text[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = "CTRL SHIFT \icon[screentip_images["LMB"]]"
		screentip_text[SCREENTIP_CONTEXT_SHIFT_LMB] = "SHIFT \icon[screentip_images["LMB"]]"
		screentip_text[SCREENTIP_CONTEXT_RMB] = "\icon[screentip_images["RMB"]]"

	var/mob/user = client?.mob
	if (isnull(user))
		return

	var/datum/hud/active_hud = user.hud_used
	if(!active_hud)
		return

	var/screentips_enabled = active_hud.screentips_enabled
	if(screentips_enabled == SCREENTIP_PREFERENCE_DISABLED || (flags_1 & NO_SCREENTIPS_1))
		active_hud.screentip_text.maptext = ""
		return

	active_hud.screentip_text.maptext_y = 0
	var/lmb_rmb_line = ""
	var/ctrl_lmb_alt_lmb_line = ""
	var/shift_lmb_ctrl_shift_lmb_line = ""
	var/extra_lines = 0
	var/extra_context = ""

	if (isliving(user) || isovermind(user) || isaicamera(user))
		var/obj/item/held_item = user.get_active_held_item()

		if ((flags_1 & HAS_CONTEXTUAL_SCREENTIPS_1) || (held_item?.item_flags & ITEM_HAS_CONTEXTUAL_SCREENTIPS))
			var/list/context = list()

			var/contextual_screentip_returns = \
				SEND_SIGNAL(src, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, context, held_item, user) \
				| (held_item && SEND_SIGNAL(held_item, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, context, src, user))

			if (contextual_screentip_returns & CONTEXTUAL_SCREENTIP_SET)
				// LMB and RMB on one line...
				var/lmb_text = (SCREENTIP_CONTEXT_LMB in context) ? "[screentip_text[SCREENTIP_CONTEXT_LMB]] [context[SCREENTIP_CONTEXT_LMB]]" : ""
				var/rmb_text = (SCREENTIP_CONTEXT_RMB in context) ? "[screentip_text[SCREENTIP_CONTEXT_RMB]] [context[SCREENTIP_CONTEXT_RMB]]" : ""

				if (lmb_text)
					lmb_rmb_line = lmb_text
					if (rmb_text)
						lmb_rmb_line = "[lmb_rmb_line] | [rmb_text]"

				else if (rmb_text)
					lmb_rmb_line = rmb_text

				// Ctrl-LMB, Alt-LMB on one line...
				if (length(lmb_rmb_line))
					lmb_rmb_line = "[lmb_rmb_line]<br>"
					extra_lines++

				if (SCREENTIP_CONTEXT_CTRL_LMB in context)
					ctrl_lmb_alt_lmb_line = "[ctrl_lmb_alt_lmb_line][screentip_text[SCREENTIP_CONTEXT_CTRL_LMB]] [context[SCREENTIP_CONTEXT_CTRL_LMB]]"

				if (SCREENTIP_CONTEXT_ALT_LMB in context)
					if (length(ctrl_lmb_alt_lmb_line))
						ctrl_lmb_alt_lmb_line = "[ctrl_lmb_alt_lmb_line] | "
					ctrl_lmb_alt_lmb_line = "[ctrl_lmb_alt_lmb_line][screentip_text[SCREENTIP_CONTEXT_ALT_LMB]] [context[SCREENTIP_CONTEXT_ALT_LMB]]"

				// Shift-LMB, Ctrl-Shift-LMB on one line...
				if (length(ctrl_lmb_alt_lmb_line))
					ctrl_lmb_alt_lmb_line = "[ctrl_lmb_alt_lmb_line]<br>"
					extra_lines++

				if (SCREENTIP_CONTEXT_SHIFT_LMB in context)
					shift_lmb_ctrl_shift_lmb_line = "[shift_lmb_ctrl_shift_lmb_line][screentip_text[SCREENTIP_CONTEXT_SHIFT_LMB]] [context[SCREENTIP_CONTEXT_SHIFT_LMB]]"

				if (SCREENTIP_CONTEXT_CTRL_SHIFT_LMB in context)
					if (length(shift_lmb_ctrl_shift_lmb_line))
						shift_lmb_ctrl_shift_lmb_line = "[shift_lmb_ctrl_shift_lmb_line] | "
					shift_lmb_ctrl_shift_lmb_line = "[shift_lmb_ctrl_shift_lmb_line][screentip_text[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB]] [context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB]]"

				if (length(shift_lmb_ctrl_shift_lmb_line))
					extra_lines++

				if(extra_lines)
					extra_context = "<br><span style='font-size: 7px'>[lmb_rmb_line][ctrl_lmb_alt_lmb_line][shift_lmb_ctrl_shift_lmb_line]</span>"
					//first extra line pushes atom name line up 10px, subsequent lines push it up 9px, this offsets that and keeps the first line in the same place
					active_hud.screentip_text.maptext_y = -10 + (extra_lines - 1) * -9

	if (screentips_enabled == SCREENTIP_PREFERENCE_CONTEXT_ONLY && !length(extra_context))
		active_hud.screentip_text.maptext = ""
	else
		//We inline a MAPTEXT() here, because there's no good way to statically add to a string like this
		active_hud.screentip_text.maptext = "<b><span class='maptext' style='text-align: center; font-size: 32px; color: [active_hud.screentip_color]'>[uppertext(name)][extra_context]</span></b>"

/// Gets a merger datum representing the connected blob of objects in the allowed_types argument
/atom/proc/GetMergeGroup(id, list/allowed_types)
	RETURN_TYPE(/datum/merger)
	var/datum/merger/candidate
	if(mergers)
		candidate = mergers[id]
	if(!candidate)
		new /datum/merger(id, allowed_types, src)
		candidate = mergers[id]
	return candidate

/**
 * This proc is used for telling whether something can pass by this atom in a given direction, for use by the pathfinding system.
 *
 * Trying to generate one long path across the station will call this proc on every single object on every single tile that we're seeing if we can move through, likely
 * multiple times per tile since we're likely checking if we can access said tile from multiple directions, so keep these as lightweight as possible.
 *
 * For turfs this will only be used if pathing_pass_method is TURF_PATHING_PASS_PROC
 *
 * Arguments:
 * * to_dir - What direction we're trying to move in, relevant for things like directional windows that only block movement in certain directions
 * * pass_info - Datum that stores info about the thing that's trying to pass us
 *
 * IMPORTANT NOTE: /turf/proc/LinkBlockedWithAccess assumes that overrides of CanAStarPass will always return true if density is FALSE
 * If this is NOT you, ensure you edit your can_astar_pass variable. Check __DEFINES/path.dm
 **/
/atom/proc/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info && (pass_info.pass_flags & pass_flags_self))
		return TRUE
	. = !density

/atom/proc/speaker_location()
	return src

///What atom is actually "Hearing".
//Currently only changed by Observers to be hearing through their orbit target.
/atom/proc/hear_location()
	return src

/// Add an atom or list of atoms to our vis_contents
/atom/proc/add_viscontents(atom/A)
	src:vis_contents += A

/// Add an atom or list of atoms to our vis_contents, atoms already present will be ignored
/atom/proc/distinct_add_viscontents(atom/A)
	src:vis_contents |= A

/// Remove an atom or list of atoms from our vis_contents
/atom/proc/remove_viscontents(atom/A)
	src:vis_contents -= A

/// Cut our vis_contents
/atom/proc/cut_viscontents()
	src:vis_contents:len = 0

/// Makes this atom look like a "hologram"
/// So transparent, blue and with a scanline
/atom/proc/makeHologram(color = rgb(125,180,225, 0.5 * 255))
	// First, we'll make things blue (roughly) and sorta transparent
	add_filter("HOLO: Color and Transparent", 1, color_matrix_filter(color))
	// Now we're gonna do a scanline effect
	// Gonna take this atom and give it a render target, then use it as a source for a filter
	// (We use an atom because it seems as if setting render_target on an MA is just invalid. I hate this engine)
	var/atom/movable/scanline = new /atom/movable{icon = 'icons/effects/effects.dmi'; icon_state = "scanline"}(null)
	scanline.appearance_flags |= RESET_TRANSFORM
	// * so it doesn't render
	var/static/uid_scan = 0
	scanline.render_target = "*HoloScanline [uid_scan]"
	uid_scan++
	// Now we add it as a filter, and overlay the appearance so the render source is always around
	add_filter("HOLO: Scanline", 2, alpha_mask_filter(render_source = scanline.render_target))
	add_overlay(scanline)
	qdel(scanline)

///Reset plane and layer values to their defaults.
/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)

///returns how much the object blocks an explosion. Used by subtypes.
/atom/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
