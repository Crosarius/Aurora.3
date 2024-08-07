/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machinery/gateway.dmi'
	icon_state = "off"
	density = 1
	anchored = 1
	var/active = 0


/obj/machinery/gateway/Initialize()
	. = ..()
	update_icon()
	if(dir == 2)
		density = 0


/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
		return
	icon_state = "off"



//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = 1
	icon_state = "offcenter"

	//warping vars
	var/list/linked_gateways = list()
	var/ready = 0				//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null

/obj/machinery/gateway/centerstation/Initialize()
	. = ..()
	update_icon()
	wait = world.time + GLOB.config.gateway_delay	//+ thirty minutes default
	awaygate = locate(/obj/machinery/gateway/centeraway)


/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"



/obj/machinery/gateway/centerstation/process()
	if(stat & (NOPOWER))
		if(active) toggleoff()
		return

	if(active)
		use_power_oneoff(5000)


/obj/machinery/gateway/centerstation/proc/detect()
	linked_gateways = list()	//clear the list
	var/turf/T = loc

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked_gateways.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked_gateways.len == 8)
		ready = 1


/obj/machinery/gateway/centerstation/proc/toggleon(mob/user as mob)
	if(!ready)			return
	if(linked_gateways.len != 8)	return
	if(!powered())		return
	if(!awaygate)
		to_chat(user, SPAN_NOTICE("Error: No destination found."))
		return
	if(world.time < wait)
		to_chat(user, SPAN_NOTICE("Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes."))
		return

	for(var/obj/machinery/gateway/G in linked_gateways)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()


/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked_gateways)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()


/obj/machinery/gateway/centerstation/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/CollidedWith(atom/bumped_atom)
	. = ..()

	if(!ready || !active || !awaygate)
		return

	if(!ismovable(bumped_atom))
		return

	var/atom/movable/AM = bumped_atom

	if(awaygate.calibrated)
		AM.forceMove(get_step(awaygate.loc, SOUTH))
		AM.set_dir(SOUTH)
		return
	else
		var/obj/effect/landmark/dest = pick(GLOB.awaydestinations)
		if(dest)
			AM.forceMove(dest.loc)
			AM.set_dir(SOUTH)
			use_power_oneoff(5000)
		return


/obj/machinery/gateway/centerstation/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.ismultitool())
		to_chat(user, "\black The gate is already calibrated, there is no work for you to do here.")
		return

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = 1
	icon_state = "offcenter"
	use_power = POWER_USE_OFF
	var/calibrated = 1
	var/list/linked_gateways = list()	//a list of the connected gateway chunks
	var/ready = 0
	var/obj/machinery/gateway/centeraway/stationgate = null


/obj/machinery/gateway/centeraway/Initialize()
	. = ..()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation)


/obj/machinery/gateway/centeraway/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"


/obj/machinery/gateway/centeraway/proc/detect()
	linked_gateways = list()	//clear the list
	var/turf/T = loc

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked_gateways.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked_gateways.len == 8)
		ready = 1


/obj/machinery/gateway/centeraway/proc/toggleon(mob/user as mob)
	if(!ready)			return
	if(linked_gateways.len != 8)	return
	if(!stationgate)
		to_chat(user, SPAN_NOTICE("Error: No destination found."))
		return

	for(var/obj/machinery/gateway/G in linked_gateways)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()


/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked_gateways)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()


/obj/machinery/gateway/centeraway/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


/obj/machinery/gateway/centeraway/CollidedWith(atom/bumped_atom)
	. = ..()

	if(!ready || !active)
		return

	if(!ismovable(bumped_atom))
		return

	var/atom/movable/AM = bumped_atom

	if(iscarbon(AM))
		for(var/obj/item/implant/exile/E in AM)//Checking that there is an exile implant in the contents
			if(E.imp_in == AM)//Checking that it's actually implanted vs just in their pocket
				to_chat(AM, "\black The station gate has detected your exile implant and is blocking your entry.")
				return
	AM.forceMove(get_step(stationgate.loc, SOUTH))
	AM.set_dir(SOUTH)


/obj/machinery/gateway/centeraway/attackby(obj/item/attacking_item, mob/user)
	if(attacking_item.ismultitool())
		if(calibrated)
			to_chat(user, "\black The gate is already calibrated, there is no work for you to do here.")
			return
		else
			to_chat(user, SPAN_NOTICE("<b>Recalibration successful!</b>: \black This gate's systems have been fine tuned.  Travel to this gate will now be on target."))
			calibrated = 1
			return
