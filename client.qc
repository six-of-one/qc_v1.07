
// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float	modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};



void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}

// remove items
	self.items = self.items - (self.items & 
	(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );

#ifdef hip_items
//MED
	self.items2 = self.items2 - (self.items2 & (HIP_IT_WETSUIT | HIP_IT_EMPATHY_SHIELDS ) );
#endifdef

#ifdef HIPNOTIC
//MED
	self.gravity = 1.0;
#endifdef

// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
};

void() SetNewParms =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
};

void() DecodeLevelParms =
{
	if (serverflags & 15)
#ifdef opgrade
	if (!deathmatch)
#endifdef

	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}
	
#ifdef HIPNOTIC
// take away all stuff on starting new episode
	if (world.model == "maps/hip1m1.bsp")
		SetNewParms ();
	if (world.model == "maps/hip2m1.bsp")
		SetNewParms ();
	if (world.model == "maps/hip3m1.bsp")
		SetNewParms ();
#endifdef
	
	
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
#ifdef map_hack
	if (mh)
	while (spot.oh != mh)
			spot = find (spot, classname, "info_intermission");
#endifdef

	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
#ifdef map_hack
			if (mh)
			while (spot.oh != mh)
					spot = find (spot, classname, "info_intermission");
#endifdef
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
#ifdef map_hack
	if (mh)
	while (spot.oh != mh)
			spot = find (spot, classname, "info_player_start");
#endifdef
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
#ifdef noobjerr
	return world;
#else
	objerror ("FindIntermission: no spot");					//opgrade protected
#endifdef
	
};


string nextmap;
void() GotoNextMap =
{
#ifdef map_hack
// the maphack teleport that is converted from the episode final trigger_changelevel sets mh
// IMP: decide what to do with DM here
	if (mh)
	{
		WriteByte (MSG_ALL, SVC_CUTSCENE);
		WriteString (MSG_ALL, string_null);
		intermission_running = 0;
		other = find (world, classname, "player");
		while (other) // != world)
		{
			other.fixangle = FALSE;
			other.view_ofs = '0 0 22';
			other.takedamage = DAMAGE_AIM;
			other.solid = SOLID_SLIDEBOX;
			other.movetype = MOVETYPE_WALK;
			other.modelindex = modelindex_player;
			centerprint(other, string_null);
//			msg_entity = other;                         // target of message
//			WriteByte (MSG_ONE, SVC_SETVIEWPORT);
//			WriteEntity (MSG_ONE, other);           // view port

			other = find (other, classname, "player");
		}
// finish teleport to start2
		other = self;
		self = other.aiment;
		teleport_touch();
		mh = world;
		return;
	}
#endifdef

// new method - pknextmap will use this or it will be set by every hub map to its own name
#ifdef code_painkeep_
	if (!theHub && cvar_string("pklevel") != string_null)
		changelevel (cvar_string("pklevel"));
	else
#endifdef

	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};

void() ExitIntermission =
{
// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

// map hack has to accomodate special seq
#ifdef opgrade__
	if (intermission_running == 2 || intermission_running == 3)
	{
		s1__ = world.model;
#ifdef has_issues
// the issue here is that after intermis exit viewport is messed up
		if (mh) s1__ = strcat("maps/", mh.netname,".bsp");
#endifdef
			if (intermission_running == 3) // the extra end message - after all 4 runes are gotten
			{
				if ( (serverflags&15) == 15) s1__ = "q1end";
			}

		s0__ = cvar_string(strcat("__fin_",ftos(intermission_running),s1__)); // hipnotic and q1 end deal
		if (strlen(s0__) < 6) s0__ = cvar_string(strcat("__fin_",s1__));
		s0__ = strreplace("&", "\n", s0__);

		if (strlen(s0__) > 6)
		{
			if (intermission_running == 2)
			{
				WriteByte (MSG_ALL, SVC_CDTRACK);
				WriteByte (MSG_ALL, 2);
				WriteByte (MSG_ALL, 3);
			}

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, s0__);
			return;
		}
	}
#else

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
#ifdef q_mapseq
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);		// qc++ dp only make these cvar_string
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}
#endifdef

#ifdef hip_mapseq
		if (world.model == "maps/hip1m4.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 6);
			WriteByte (MSG_ALL, 3);
			WriteByte (MSG_ALL, SVC_FINALE);
/*
			**************************************
			Deep within the bowels of the
			Research Facility, you discover the
			passage that the followers of Quake
			have used to enter our world.
			The bastards used some type of
			gigantic teleporter to overload
			one of our own slipgates!  As long as
			this portal exists, Earth will never
			be safe from Quake's cruel minions.

			If you can find the source of the
			portal's power, you can shut it
			down--possibly forever!  With only a
			moment's consideration for your own
			safety, you re-enter the dark domain,
			knowing Hell would be a better fate
			than experiencing the reign of Quake.
*/
			WriteString (MSG_ALL, "Deep within the bowels of the\nResearch Facility, you discover the\npassage that the followers of Quake\nhave used to enter our world.\nThe bastards used some type of\ngigantic teleporter to overload\none of our own slipgates!  As long as\nthis portal exists, Earth will never\nbe safe from Quake's cruel minions." );
			//WriteString (MSG_ALL, "If you can find the source of the\nportal's power, you can shut it\ndown--possibly forever!  With only a\nmoment's consideration for your own\nsafety, you re-enter the dark domain,\nknowing Hell would be a better fate\nthan experiencing the reign of Quake." );
			return;
		}
		else if (world.model == "maps/hip2m5.bsp")
		{
/*
			**************************************
			After destroying the power generator,
			you pass beyond the gate of Mortum's
			Keep.  A wave of nausea suddenly flows
			over you and you find yourself cast
			out into a liquid void.  You float
			lifelessly, yet aware, in a lavender
			sea of energy.

			After what seems like an eternity,
			you feel the presence of a diabolical
			intelligence.  You are held helpless
			for a moment as your mind is open to
			that of Armagon--Quake's General and
			master of this realm.  Recognizing
			you as the one who foiled his
			attempt to conquer Earth, a hellish
			howl fills your mind and blots out
			all consciousness.  When you awake,
			you find yourself on the shores of
			reality, but in a time and place
			unknown to you.
*/
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 6);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "After destroying the power generator,\nyou pass beyond the gate of Mortum's\nKeep.  A wave of nausea suddenly flows\nover you and you find yourself cast\nout into a liquid void.  You float\nlifelessly, yet aware, in a lavender\nsea of energy." );
			//WriteString (MSG_ALL, "After what seems like an eternity,\nyou feel the presence of a diabolical\nintelligence.  You are held helpless\nfor a moment as your mind is open to\nthat of Armagon--Quake's General and\nmaster of this realm.  Recognizing\nyou as the one who foiled his\nattempts to conquer Earth, a hellish\nhowl fills your mind and blots out\nall consciousness.  When you awake,\nyou find yourself on the shores of\nreality, but in a time and place\nunknown to you." );
			return;
		}
		else if (world.model == "maps/hipend.bsp")
		{
/*
			**************************************
			After the last echoes of Armagon's
			death yell fade away, you breathe a
			heavy sigh of relief.  With the loss
			of his magic, Armagon's fortress
			begins to collapse.  The rift he
			created to send his grisly troops
			through time slowly closes and seals
			itself forever.  In the chaos that
			ensues, a wall collapses, revealing
			one remaining time portal.  With your
			chances to escape rapidly growing
			slim, you race for the portal,
			mindless of your destination.  In a
			flash of light, you find yourself
			back at Command HQ, safe and sound.

			Congratulations!  You are victorious!
			The minions of Quake have once again
			fallen before your mighty hand.
			Is this the last you will see of
			Quake's hellions?

			Only time will tell...
*/
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "After the last echoes of Armagon's\ndeath yell fade away, you breathe a\nheavy sigh of relief.  With the loss\nof his magic, Armagon's fortress\nbegins to collapse.  The rift he\ncreated to send his grisly troops\nthrough time slowly closes and seals\nitself forever.  In the chaos that\nensues, a wall collapses, revealing\none remaining time portal.  With your\nchances to escape rapidly growing\nslim, you race for the portal,\nmindless of your destination.  In a\nflash of light, you find yourself\nback at Command HQ, safe and sound." );
			//WriteString (MSG_ALL, "Congratulations!  You are victorious!\nThe minions of Quake have once again\nfallen before your mighty hand.\nIs this the last you will see of\nQuake's hellions?\n\nOnly time will tell..." );
			//intermission_exittime = time + 10000000;  // never allow exit
			return;
		}
#endifdef

		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
#ifdef q_mapseq
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
#endifdef

#ifdef hip_mapseq
		if (world.model == "maps/hip1m4.bsp")
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "If you can find the source of the\nportal's power, you can shut it\ndown--possibly forever!  With only a\nmoment's consideration for your own\nsafety, you re-enter the dark domain,\nknowing Hell would be a better fate\nthan experiencing the reign of Quake." );
			return;
		}
		else if (world.model == "maps/hip2m5.bsp")
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "After what seems like an eternity,\nyou feel the presence of a diabolical\nintelligence.  You are held helpless\nfor a moment as your mind is open to\nthat of Armagon--Quake's General and\nmaster of this realm.  Recognizing\nyou as the one who foiled his\nattempt to conquer Earth, a hellish\nhowl fills your mind and blots out\nall consciousness.  When you awake,\nyou find yourself on the shores of\nreality, but in a time and place\nunknown to you." );
			return;
		}
		else if (world.model == "maps/hipend.bsp")
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Congratulations!  You are victorious!\nThe minions of Quake have once again\nfallen before your mighty hand.\nIs this the last you will see of\nQuake's hellions?\n\nOnly time will tell..." );
			intermission_exittime = time + 10000000;  // never allow exit
			return;
		}
#endifdef

	}
// else from opgrade in map_hack level code
#endifdef

	GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
// there is one + bot(s) - make sure they do a level reload, may not be any humans
// --- is this only a server test deal?

#ifdef code_bots
	if (!bot_lr)
	if (find(world, class_select, "class_bot"))
	{
		bot_lr = spawn();
#ifdef warning_no
		bot_lr.classname = "bot_lr";
#endifdef
		bot_lr.think = GotoNextMap;
		bot_lr.nextthink = time + 60 + (random() * 20);
	}
#endifdef

	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);

#ifdef HIPNOTIC
	WriteByte (MSG_ALL, 9);
#else
	WriteByte (MSG_ALL, 3);
#endifdef

	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other) // != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

#ifdef code_pkbots
	if (find(world,group,"pk*bot")) bot_changelevel(); // *bot - reload bots on next level, handle intermission
#endifdef

#ifdef map_hack
	if (mh) ExitIntermission();
	else
#endifdef
	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
//	local entity	pos;	// fx_warning

	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	if (coop || deathmatch)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	
	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (! deathmatch) ) // == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
#ifdef noobjerr
	{
		self.map = "start"; // DM or SP - we default here if a mapper forgot a map link

	#ifdef xvars1
		#ifndef nondp
// future add cvar_string("svx_rndmap") - random map selected from list
		if (cvar_string("svx_defmap")) self.map = cvar_string("svx_defmap");
		#endifdef
	#endifdef
	}
#else
		objerror ("changelevel trigger doesn't have map");					//opgrade protected
#endifdef
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
//TDO:		if (self.model != null_model) // Cataboligne - 8.14.9 - dead cam etc
		CopyToBodyQue (self);

#ifdef code_morph
		morph_clearparms(self, TRUE);
#endifdef

		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
//TDO:		if (self.model != null_model) // Cataboligne - 8.14.9 - dead cam etc
		CopyToBodyQue (self);
#ifdef code_morph
		morph_clearparms(self, TRUE);
#endifdef
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}
	else
	{	// restart the entire server
#ifdef code_morph
// died in SP hack to restart
// TDO: check vs qone / mh sp-coop tweak
		cvar_set("scratch3",ftos(0 - self.morphy)); // Cataboligne - 9.28.3
#endifdef

		localcmd ("restart\n");
	}
};

/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
#ifdef opgrade
	if ((intermission_running) && ((coop) || (deathmatch)))  // not allowed during intermission
		return;
#endifdef

#ifdef code_runes
// Cataboligne - 10.7.11 - drop runes+
// update - was: dead_drop(self); 
		if (self.rune_flag) dead_runes(self);
#endifdef


	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	respawn ();
};

#ifdef unused
float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

#endifdef

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local	entity thing;
	local	float  pcount;

#ifdef map_hack
	if (self.movetarget.oh)
	if (self.movetarget.classname == "trigger_respawn")
	{
		spot = self.movetarget; // if cloned from info_player_start, we are good...if put in a map via editor, set origin, angle
		return(spot);
	}
#endifdef


// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
#ifdef opgrade
// if this exists anywhere, is not blocked 2048 "not in dm", and the map is run DM, there is only one spawn
	if ((!deathmatch && !coop) || cvar("saved1") == 666) // if a developer wanted this in dm | coop they need to set saved1
#endifdef
	if (spot)
		return spot;

// code was not in pk 1 - left in so pk items can be used in coop
// choose a info_player_deathmatch point
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (! lastspawn)// == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn) // != world)
			return lastspawn;
	}
	else if (!deathmatch)
	{
		if (serverflags & 15)
		{	// return with a rune to start
			spot = find (world,classname,"info_player_start2");
			if (spot)
				return spot;
		}

		spot = find (world,classname,"info_player_start");
		if (spot) return(spot);
#ifdef noobjerr
#ifdef warning
			bprint ("*** Warning: no info_player_start on level - using dm start");
#endifdef
#else
		error ("PutClientInServer: no info_player_start on level");					//opgrade protected
#endifdef
	}

//	else if (deathmatch)
	spot = find(world, classname, "info_player_deathmatch");
	if (spot)		// make sure we have one before endless loop is run
	{
		if (cvar("PK") < 1)
		{
			spot = lastspawn;
			while (1)
			{
				spot = find(spot, classname, "info_player_deathmatch");
				if (spot) // != world)
				{
					if (spot == lastspawn)
						return lastspawn;
					pcount = 0;
					thing = findradius(spot.origin, 32);
					while(thing)
					{
						if (thing.classname == "player")
							pcount = pcount + 1;
						thing = thing.chain;
					}
					if (! pcount) // == 0)
					{
						lastspawn = spot;
						return spot;
					}
				}
			}
		}
// pk 1 - 3 spawn picker
		if (cvar("PK") < 4)	// dont task non dm starts until 4
		{
			f1__ = cnt_ent(self, classname,  "info_player_deathmatch");
			spot = find_tselect(f1__, self.chain);
		}
		else
		spot = find_tdest(0);

		lastspawn = spot;
		while (spot)
		{
			pcount = 0;
			thing = findradius(spot.origin, 256);
			while(thing)
			{
				if (thing.classname == "player")
					pcount = pcount + 1;
				thing = thing.chain;
			}
			if (! pcount) return spot;
			spot = spot.chain;		// test next spot till end
		}
		spot = lastspawn; // just use this
	}
	else		// no dm spawns
	{
		spot = find_tdest(0);
	}


/*
	{
// later use our uber random find dest
		spot = find (world, classname, "info_player_deathmatch");
		if (!spot) spot = find (world, classname, "info_teleport_destination");
		if (!spot) spot = find (world, classname, "info_intermission");

	}
*/
	if (!spot)
	{
		spot = spawn(); // bounce player in at 0, 0, 0 - might be a bad move, maybe create temp plat & message trigger
		spot.classname =  "info_player_start"; // save for DM / coop spawns
	}

	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
	local	entity spot;

#ifdef code_pkbots
	set_initBL(); // *bot
	self.button16 = 0; // bot fixer
#endifdef

	spot = SelectSpawnPoint ();
#ifdef code_painkeep_
	ClearSpawnPoint(spot);
#endifdef

#ifdef code_morph
	f = cvar("scratch3");
	if (f < 0 && !deathmatch && !coop) // morphic single player - because the server is reloaded every restart
	{
		parm15 = self.morphy = fabs(f);
		cvar_set("scratch3","0");
	}

// TDO: move to cfg for new morph ops
	self._stand = SUB_Null; // make sure these are safe & detectable
	self._pain = SUB_Null;
	self._run = SUB_Null;
	self._impulse = SUB_Null;
	self._attack = SUB_Null;
	self._jump = SUB_Null;
	self._jump2 = SUB_Null;
	self._die = SUB_Null;
	self._summon = SUB_Null;
	self._alt_fire = SUB_Null;
//	self._killmsg = SUB_Null; change to cdm
//	self._killmsg2 = SUB_Null;
#endifdef

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
#ifdef code_xents
	if (self.max_health < 100) // Cataboligne - 11.1.12 - adrenaline in level add
		self.max_health = 100;
#else
	self.max_health = 100;
#endifdef
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
#ifdef code_runes
// also morphs - update
	self.health_modifier = 1; // TDO: morph code
	self.rune_flag = 0;
#endifdef

#ifdef hip_items
	//JIM
	self.wetsuit_finished = 0;
	//MED
	self.empathy_finished = 0;
	//MED
	self.items2 = 0;
#endifdef

#ifdef HIPNOTIC
	self.gravity = 1.0;
	//JIM
#endifdef
	// Clear out velocity so you're not launched into the air
	// when you respawn.
// PAINKEEP Fix the velocity on respawn bug
#ifndef opgrade
	self.velocity = '0 0 0';
#endifdef

// oh, this is a hack!
#ifdef hip_weapons
#ifndef code_xents
	setmodel (self, "progs/playham.mdl");
	modelindex_hammer = self.modelindex;
#endifdef
#endifdef

#ifdef code_painkeep_
	self.pk_currentInventory = 
	self.pk_currentitem = 
	self.pkprevweapon = PK_IT_AXE;

//TDO:	self.pkplus_actortype = 0;
	self.beartrap_time = 0;
	self.bt_immune_time = time + BT_BUFFER;
	self.voteIntermission = 0;

	self.skin = 0; // damage skins, etc - needs to be before morphy

	grap_releaseHarpoon();
	self.grap_owner = world;

// bolt stuff
	self.bolt_target = world;
	self.bolt_targetNext = world;
	self.bolt_targetTimeout = 0;
	self.bolt_targetNextTimeout = 0;
	if (self.bolt_targetTimeoutEntity)
	{
		remove(self.bolt_targetTimeoutEntity);
	}
	self.bolt_targetTimeoutEntity = world;
	self.bolt_conduitTimeout = 0;
//	self.bolt_changeModelTimeout = 0;
	if (self.bolt_lightningFire)
	{
		remove(self.bolt_lightningFire);
	}
	self.bolt_lightningFire = world;

#ifdef code_painkeep_fs
	self.pkplus_actortype = 0;
#endifdef

#ifdef painkeep_splash
	AddToSplashBig(self);
#endifdef
#endifdef

	DecodeLevelParms ();
	
#ifdef code_painkeep_
// here because decode bonks items

	if (inHubMap)
	{ // give the respawn guy a fighting chance...
		self.items = self.items | IT_INVULNERABILITY;
		self.invincible_time = 1;
		self.invincible_finished = time + 15;
	}
#endifdef

	W_SetCurrentAmmo ();

#ifdef code_xents
// vw
	self.lastweapon = self.weapon;

	ominous_hum(string_null, 1); // clear any stray hum
#endifdef

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
//	spot = SelectSpawnPoint ();

#ifdef opgrade
	self.oldorigin = 
#endifdef
	self.origin = spot.origin + '0 0 1';	// 1998-07-21 Respawning where player died fix by Robert Field
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

#ifdef code_viswep
	#ifdef xvars2
// control var - turns off viswep - note: NOT a live change, server has to restart or players have to respawn
	setmodel (self, cvar_string("svx_player.mdl"));
	#else
	setmodel (self, "progs/vw_player.mdl");
	#endifdef
#else
	setmodel (self, "progs/player.mdl");
#endifdef
	modelindex_player = self.modelindex;
#ifdef code_morph
	self.modelindex_morph = self.modelindex;
#endifdef

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

#ifdef opgrade
	self.velocity = '0 0 0';	// 1998-07-21 Player moves after respawn fix by Xian
#endifdef
	
	player_stand1 ();
	
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);

// Cataboligne - 9.13.11 - x_item giveaway for doors - only set by doors in dm
#ifdef code_xents
		self.x_items = self.x_items | x_item_dm_giveaway; // we could have set defaults
#endifdef
	}

	spawn_tdeath (self.origin, self);

// per map things that need to happen for a client (fog, r_ambient, other cvar settings)
// map supplied cfg file in .group field - code has .script
// note: map is already loaded at this point
	if (world.script)
	{
		stuffcmd(self, "exec ");
		stuffcmd(self, world.script);
		stuffcmd(self, "\n");
	}
// try {mapname}.cfg file
	stuffcmd(self, "exec cfg/map/");
	stuffcmd(self, mapname);
	stuffcmd(self, ".cfg\n");

// respawn - if spot has an owner hack, make triggers
#ifdef map_hack
	if (spot.oh)
	if (! (spot.oh.spawnflags & 16)) // NOTRIG flag
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 1, 0,  spot.oh.origin, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.05, maphack_trigger, SUB_Null, spot.oh, world);
#endifdef

#ifndef code_bots
	self.ishuman = TRUE; // if not bot code compiled, always indicate human
#endifdef

#ifdef painkeep_splash
	AddToSplashBig(self); // *pk - splash tossed items
#endifdef

};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
#ifdef map_hack
	self.mangle = self.angles;
#endifdef
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
#ifdef map_hack
	self.mangle = self.angles;
#endifdef
};


/*
saved out by quaked in region mode
*/
#ifdef debug
// CHECK: search map source - find out if regioned mode is ever used REMOVE this check
void() testplayerstart =
{
};
#endifdef

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

//HIPNOTIC
//Commented out so that timelimit and fraglimit work on start map
/// Six - it makes zero sense to comment this block out - it is simply how the next map is chosen on the start map - nothing to do with limits being hit

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
// TDO: def map svx_
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
#ifdef opgrade
	if (deathmatch)	// 1998-07-27 Timelimit/Fraglimit fix by Maddes
#endifdef
	if (timelimit && time >= timelimit)
	{
		NextLevel();
//		return;
	}
	
#ifdef opgrade
	if (deathmatch)	// 1998-07-27 Timelimit/Fraglimit fix by Maddes
#endifdef
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel();
//		return;
	}	
};

//============================================================================

void() PlayerDeathThink =
{
//	local entity	old_self;	// fx_warning
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
//	local vector start, end;	// fx_warning
	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	
	self.button2 = 0;
// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);

// escher gravity code
#ifdef escher

/// FIX: make this the appr 270 value here instead of factored
	if (self.vgravity_x)
		self.velocity_x = self.velocity_x + self.vgravity_x * 1.35;
	else
	if (self.vgravity_y)
		self.velocity_y = self.velocity_y + self.vgravity_y * 1.35;
	else
	self.velocity_z = self.velocity_z + self.vgravity_z * 1.35;
#else
// normal jump
	self.velocity_z = self.velocity_z + 270;
#endifdef
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
// PK armor fix
#ifdef code_xents
			self.ignorearmor = IGN_ARM;
			T_Damage (self, world, world, self.dmg);
			self.ignorearmor = 0;
#else
			T_Damage (self, world, world, self.dmg);
#endifdef
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{	

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;

#ifdef hip_items
	//JIM
	//WETSUIT
	if (self.wetsuit_finished > time)
	{
		if (self.waterlevel==2)
		{
			self.velocity = self.velocity * 1.25;
		}
		if (self.waterlevel==3)
		{
			self.velocity = self.velocity * 1.5;
		}
		if (self.waterlevel >= 2)
		{
			// play scuba sound
			if (self.swim_flag < time)
			{
				self.swim_flag = time + 7;
				sound (self, CHAN_BODY, "misc/wetsuit.wav", 1, ATTN_NORM);
			}
			//MED 01/17/97
			else
			{
				if (fabs(self.swim_flag - time - 6)<0.04)
				{
					DeathBubbles(1);
				}
				else if (fabs(self.swim_flag - time - 5.5)<0.04)
				{
					DeathBubbles(1);
				}
				else if (fabs(self.swim_flag - time - 5)<0.04)
				{
					DeathBubbles(1);
				}
			}
		}
	  }
#endifdef
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
//			return;
		}
	}
};


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
//	local	float	mspeed, aspeed;	// fx_warning
//	local	float	r;	// fx_warning
#ifdef code_frikbots
	if (BotPreFrame ()) return ;
#endifdef

	if (intermission_running)
	{
#ifdef code_archon
// if an archon (any player / bot) has a vessel, restore pts
		if (self.arcvess)
		{
			self.pk_explode_ammo = 0;
			remove_vessel();
		}
#endifdef

#ifdef hip_mapent
      earthquake_prethink();
#endifdef
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (!self.view_ofs) // == '0 0 0')
		return;		// intermission or finale

// escher gravity code
#ifdef escher
	if (!self.vgravity) self.vgravity_z = cvar("sv_gravity") / 4;

	if ( !( self.flags & FL_ONGROUND ) )
	{
// this seems to work fine during jumps
		self.velocity = self.velocity - self.vgravity * frametime;
	}
	else
	{
// this is a mere hack to enforce a non _z positive gravity, it only works when player has velocity
/// FIX: its possible to "stall" in midair if velo is '0 0 0' and we dont want run state when on "ground"
		f0__ = 0; // grav factor - if moving cause a "fall" towards "ground"
		if (self.vgravity_x)
			if (self.velocity_x) f0__ = 5;

		if (self.vgravity_y)
			if (self.velocity_y) f0__ = 5;

		self.velocity = self.velocity - self.vgravity * frametime * f0__;
	}
#endifdef

#ifdef hip_traps
//JIM
// Kill player on Edge of Oblivion
/// Six - this should be done with a trigger & not here!
	if ( ( self.origin_z < -1300 ) && (world.model == "maps/hipdm1.bsp") &&
		( self.health > 0 ) )
	{
		self.deathtype = "falling";

		if (self.invincible_finished >= time)
		{
			self.invincible_finished = 0;
			self.items = self.items - (self.items & IT_INVULNERABILITY);
			self.invincible_time = 0;
			self.invincible_finished = 0;
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
		}
		T_Damage( self, self, world, self.health + 1000 );
	}
#endifdef

#ifdef hip_mapent
//JIM
//	if (!deathmatch)
//	{
		earthquake_prethink();
//	}
#endifdef

	makevectors (self.v_angle);		// is this still used

	CheckRules ();
/*
Archon has:
	if (self.movetype != MOVETYPE_NOCLIP)
	if (self.health > 0)
	if (self.classname == "player") // || self.group == "pk*bot")
down to waterjump
*/
	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if (self.button2)
	{
#ifdef code_morph
		if (self._jump != SUB_Null) // Should be after these checks? (in client.qc under playerjump)
			self._jump();
		else
#endifdef
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

#ifdef code_morph
// note: covers morph flyers, jetpack

	if ((framecount & 3) == 2)
	if ((!self.flags & FL_ONGROUND) || (self.v_angle_x < -45))
	if (self.movetype == MOVETYPE_FLY) // NOTE: horn, grap set this
		flyer_move(); // Cataboligne - 7.26.10 - flyer mouse-fly right code from chaos mod flight
#endifdef

// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if(time > self.attack_finished && ! self.currentammo /* == 0 */ && self.weapon != IT_AXE
#ifdef hip_weapons
#ifndef code_xents
			&& self.weapon != IT_MJOLNIR
#endifdef
#endifdef
		)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}

#ifdef code_painkeep_
// GRAPPLING
	if (self.grap_cornerchainNext) // if harpoon out
		grap_maintainHarpoon();
	else
		self.grap_firetest = 0;
	self.oldorigin = self.origin;

	updateStatusDisplay(); // PK status

	pk_DmgSkin();
#endifdef
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)		// Archon has: obeserver check
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_INVISIBILITY);
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
// this was screwing framer when invisible - player_shot1 was never ending and muzzleflash loop
// whats more this does nothing for eyes, since they only have one frame
// this fix will work until eyes have more frames
//		self.frame = 0; 

// Archon has:
// if (self.mask_x & CB_HUMAN)
		self.modelindex = modelindex_eyes;
//		else
//			self.modelindex = 0;
	}
#ifdef hip_weapons
#ifndef code_xents
//MED 12/04/96 added mjolnir stuff
   else if (self.weapon == IT_MJOLNIR)
      self.modelindex = modelindex_hammer;   // don't use eyes
#endifdef
#endifdef
	else
		self.modelindex = modelindex_player;	// don't use eyes

//	if (!self.invisible_finished)
//		self.modelindex = self.modelindex_morph;	// don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
#ifdef code_painkeep_fs
				if (self.pkplus_actortype == PKPLUS_ACTORPENT)
					sprint (self,"Get ready to leave the RED stage - Good Performance!\n");
				else
#endifdef
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_INVULNERABILITY);
			self.invincible_time = 0;
			self.invincible_finished = 0;
#ifdef code_painkeep_fs
			if (self.pkplus_actortype == PKPLUS_ACTORPENT)
				self.pkplus_actortype = 0;
#endifdef
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
#ifdef code_painkeep_fs
				if (self.pkplus_actortype == PKPLUS_ACTORQUAD)
					sprint (self,"The BLUE Curtain is dropping - You really frightened them!\n");
				else
#endifdef
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_QUAD);
			self.super_damage_finished = 0;
			self.super_time = 0;
#ifdef code_painkeep_fs
			if (self.pkplus_actortype == PKPLUS_ACTORQUAD)
				self.pkplus_actortype = 0;
#endifdef
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}	

// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
/*
	Archon has:
				if (self.noise3 != null_string)
					sound (self, CHAN_AUTO, self.noise3, 1, ATTN_NORM);
				else
*/
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_SUIT);
			self.rad_time = 0;
			self.radsuit_finished = 0;
/*
	Archon has:
// turn off suit skins
			if (self.mask_x & CB_HUMAN)
			if (self.skin > 4)
			{
				self.skin = 0;
			}
*/
		}
	}

#ifdef hip_items
//JIM
//WETSUIT
	if (self.wetsuit_finished > time)
	{
		if (self.waterlevel==2)
		{
			self.velocity = self.velocity * 0.8;
		}
		if (self.waterlevel==3)
		{
			self.velocity = self.velocity * 0.66;
		}
	}

//JIM
// wetsuit
	if (self.wetsuit_finished)
	{
	self.air_finished = time + 12;		// don't drown

	// sound and screen flash when items starts to run out
	if (self.wetsuit_finished < time + 3)
		{
			if (self.wetsuit_time == 1)
			{
				sprint (self, "Air supply in Wetsuit is running out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.wetsuit_time = time + 1;
			}

			if (self.wetsuit_time < time)
			{
				self.wetsuit_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.wetsuit_finished < time)
		{	// just stopped
//MED
			self.items2 = self.items2 - HIP_IT_WETSUIT;
			self.wetsuit_time = 0;
			self.wetsuit_finished = 0;
		}
	}

//MED
// empathy shields
	if (self.empathy_finished)
	{
		// sound and screen flash when items starts to run out
		if (self.empathy_finished < time + 3)
		{
			if (self.empathy_time == 1)
			{
				sprint (self, "Empathy Shields are running out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.empathy_time = time + 1;
			}

			if (self.empathy_time < time)
			{
				self.empathy_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.empathy_finished < time)
		{	// just stopped
//MED
			self.items2 = self.items2 - HIP_IT_EMPATHY_SHIELDS;
			self.empathy_time = 0;
			self.empathy_finished = 0;
		}
//MED
		if (self.empathy_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}
#endifdef

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
//	local	float	mspeed, aspeed;	// fx_warning
//	local	float	r;	// fx_warning


#ifdef warning_no
global float wfs;
													if (WARNING)
													if (wfs != self.weaponframe)
													{
																				bprint(" *** wf: ");
																				bprint(ftos(self.weaponframe));
																				bprint(", was: ");
																				bprint(ftos(wfs));
																				bprint("\n");
																	wfs = self.weaponframe;
													}
#endifdef

#ifdef code_pkbots
	if (vw_bot_frame != framecount)  // run these things once this frame
	{
		viswep_pkbot();

#ifdef code_archon
		if ((framecount & 31) == 17)
		if (find(world, classname, LOOPSOUND)) loop_play(); // play on looped sounds

// sphere of annihilation controls
		if (sphere_a) sphere_annihilation_phys_move();
#endifdef
	}
#endifdef

#ifdef code_frikbots
	if (BotPostFrame ())
		return ;
#endifdef

#ifdef code_pkbots
	if (find(world,classname,"pk*bot"))
  {
		if ((self.view_ofs != '0 0 0') && !self.deadflag)
		if (CheckDropPath ()) // *bot
		{
			DropBotPath ();
		}

/*
NOTE: was used in alias to load hub level - see if we still need

		if (!(DARKPLACES || chaos)) // handle other engines
		if (cvar("botlevel")) // hack so alias can load new map & keep pk*bots - set by console command aliases for map & changelevel - bmap & blvl
		{
			bot_changelevel(); // map change MUST happen - this clears bots from map!
			cvar_set("botlevel", "0");
		}
*/
  }
#endifdef

#ifdef hip_mapent
	earthquake_postthink();
#endifdef

#ifdef code_viswep
	if (self.vw_frame != framecount)
	{
		viswep_post(); // Cataboligne - 9.26.9 - viswep code link - always have to run this for 1 player + pk*bots deal
/*
Archon has:
		if ((framecount & 31) == 17)
		if (find(world, classname, LOOPSOUND)) loop_play(); // play on looped sounds

// sphere of annihilation controls
		if (sphere_a) sphere_annihilation_phys_move();
*/
}
#endifdef

#ifdef code_runes
	if (self.rune_flag & RUNE_FLG_RG || self.rune_flag & TECH_ADOC) rune_regen();
	if (self.rune_flag & RUNE_VAMPIRE) rune_vamp();
#endifdef


	if (!self.view_ofs) // == '0 0 0')
		return;		// intermission or finale
	if (self.deadflag)
#ifdef code_painkeep_
	// BOLT_START
	{
		if (self.deadflag == DEAD_DYING && self.bolt_conduitTimeout > time) // it's the conduit time for this player...
		{
			// make sure the player think is set correctly
			self.think = player_conduitJerk;
		}
		return;	 // dying, so do nothing
	}
#else
		return;
#endifdef

// TDO: coop with quantum tunnel device
// faell out of level - use beacon impulse to recover player / frikbot
#ifdef code_xents
	if (self.velocity_z < FALLOUT_VELOCITY)			// note: ever falling corridor level / poss. wind tunnels
		self.impulse = IMP_TELEBEAC;
#endifdef

// do weapon stuff

	W_WeaponFrame ();

#ifdef code_archon
// archon spell targeting
	if (self.mask_x & MORPH_ARCHON)
	if (self.weapon != IT_AXE) // need to timeout when we select fire mode
	{
		if (self.bolt_targetTimeout > time) // reticles & targeting
		{
			archon_target();
		}
		else
		{
			clear_spell();
		}
	}

	if (self.bolt_target) // clear power point protection when timed out
	{
		if (self.bolt_target.classname == "archon_power_act")
		if (self.bolt_targetTimeout < time)
			self.bolt_target = world;
	}
// end spell targeting
#endifdef

#ifdef hooks
	if (!(self.hook & HOOK_ON)) // Cataboligne 9.11.3 purify
	{
#endifdef

// check to see if player landed and play landing sound	
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
#ifdef code_morph
			else if (self.map == "demon_jump") // demon jumping - clear indicator
				self.map = null_string;
#endifdef
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5); 

#ifdef code_runes
			// chance to knock a rune loose
			rune_pull(self, FALL_PULL);
#endifdef

#ifdef code_morph
				if (self.mask_x == CB_HUMAN)
#endifdef
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
#ifdef code_morph
			if (self.mask_x == CB_HUMAN)
#endifdef
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}
#ifdef hooks
// Archon has:
//		if (!(self.flags & FL_ONGROUND))
//			self.jump_flag = self.velocity_z;
	}
	else // Cataboligne 9.11.3 purify - this is damage from your own hook activities - i.e. skullcrack
	{
		hook_dmg_check(); // IDEA: server flag?
		self.finaldest = self.velocity;
	}
#endifdef

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

#ifdef code_painkeep_
#ifdef code_morph
	if (!self.mask_x & MORPH_ARCHON)
	if (self.bolt_target.classname != "gfx/reticle.spr")
#endifdef
	if (self.bolt_target || self.bolt_targetNext || self.weaponmodel == "progs/v_cl_off.mdl" )
		bolt_checkTargets();
#endifdef

	CheckPowerups ();
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
#ifdef code_frikbots
	ClientInRankings();
#endifdef

#ifdef code_pkbots
	bot_con(TRUE); // *bot - doesnt depend on active bots, must always happen
#endifdef

	bprint("\n");
	bprint (self.netname);
#ifdef code_painkeep_
// from 1.1: Let's put some variety in the joining game msgs - qc 2.0 style
	f0__ = rint(random() * 7);
	bprint(cvar_string(strcat("hi",ftos(f0__))));
	bprint("\n");
	bprint("\n");
#else
	bprint (" entered the game\n\n");
#endifdef
	
// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
#ifdef code_frikbots
	ClientDisconnected();
#endifdef

#ifdef code_pkbots
	bot_con(FALSE); // *bot
#endifdef

	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving


#ifdef code_runes
// Cataboligne - 10.7.11 - drop runes+
// update - was: dead_drop(self); 
		if (self.rune_flag) dead_runes(self);
#endifdef


#ifdef code_painkeep_
// PK - set flag so that we know that it's a disconnected entity.
	self.classname = string_null;		// same difference
	self.deadflag = 6; // really dead
	
	grap_releaseHarpoon();
	self.beartrap_time = 0;
	self.voteIntermission = 0;

// TDO: check this - gen fn in bolt.qc
// BOLT_START
	self.bolt_target = world;
	self.bolt_targetNext = world;
	self.bolt_targetTimeout = 0;
	self.bolt_targetNextTimeout = 0;
  if(self.bolt_targetTimeoutEntity)
  {
  	remove(self.bolt_targetTimeoutEntity);
  }
	self.bolt_targetTimeoutEntity = world;
	self.bolt_conduitTimeout = 0;
//	self.bolt_changeModelTimeout = 0;
  if(self.bolt_lightningFire)
  {
  	remove(self.bolt_lightningFire);
  }
  self.bolt_lightningFire = world;
// BOLT_END
#endifdef

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

/*
===========
ClientObituary

called when a player dies
============
*/

// TDO: scripted obits

void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

#ifdef code_bots
	if (attacker.classname == "bot_fix") return;
#endifdef

#ifdef warning
									if (warnings == "obit")
									{
										bprint ("  *** Cobit att c: ");
										bprint (attacker.classname);
										bprint (" n: ");
										bprint (attacker.netname);
										bprint (" targ c: ");
										bprint (targ.classname);
										bprint (" n: ");
										bprint (targ.netname);
										bprint (" inf c: ");
										bprint (damage_inflictor.classname);
										bprint (" n: ");
										bprint (damage_inflictor.netname);
										bprint ("\n");
									}
#endifdef

	if (targ.classname == "player")
	{
//#ifdef code_xents
// __c{deathtypestr} is a custom death message set
		s0__ = strcat("__","c",damage_inflictor.deathtype);
		if (!cvar(s0__)) s0__ = strcat("__","c",damage_inflictor.classname);		// x weps  - check classname of an inflictor
		if (!cvar(s0__)) s0__ = strcat("__","c",attacker.eweapon.deathtype);	// x weps set this for CDM
		if (!cvar(s0__)) s0__ = strcat("__","c",attacker.deathtype);							// x monster CDM
		if (!cvar(s0__)) s0__ = strcat("__","c",targ.deathtype);									// targ killed by CDM

		if (cvar(s0__)) 
		{
			bprint (targ.netname);
			f0__ = 1;
// __c{deathtypestr}c if a valid function, it will be called
// code could be called to adjust f0__ track for alternate messages
// TDO: gibbed messages - maybe @ 81
			s1__ = cvar_string(strcat(s0__,"c"));
			if (strlen(s1__) > 1)
			if (isfunction(s1__))
			{
				e0__ = targ;
				e1__ = attacker;
				callfunction(s1__);
			}

			if (targ == attacker) f0__ = f0__+ 39;		// suicide starts at 40
// TDO: spec fn call - re: waterlevel test for lg

			while (f0__)
			{
				s1__ = strcat(s0__,ftos(f0__));
				f0__ = f0__ + 1;
				s2__ = strcat(s0__,ftos(f0__));
				if (!(cvar_type(s2__) & CVAR_TYPEFLAG_EXISTS) || random() < 0.5) f0__ = 0;
			}
			bprint (cvar_string(s1__));
			if (targ == attacker) 
			{
				targ.frags = (targ.frags - 1);	// - frag_minus());
				bprint ("\n");
				return;	// self kill is now done
			}
			attacker.frags = (attacker.frags + 1); //  + frag_plus(attacker));
//			attacker.xp = (attacker.xp + ARCHON_FRAG);

			f0__ = f0__ + 20; // 2nd part starts at 20
			s1__ = strcat(s0__,ftos(f0__));
			if (cvar_string(s1__) != "noexit") // noexit message - no print option on 2nd text for monsters, env hazards
			{
				bprint (attacker.netname);		// could be a mosnter or player
				bprint (cvar_string(s1__));
			}
			bprint ("\n");
			return;
		}
//#endifdef

#ifdef code_morph
//		if (targ.watertype != CONTENT_LAVA && (targ.flags & FL_DEMONBOOM || targ.deathtype == "rage") ) // because a dying demon in a rage still explodes...
		if (targ.watertype != CONTENT_LAVA && (targ.deathtype == "rage") ) // because a dying demon in a rage still explodes...
		{
			targ.deathtype = string_null;
			bprint (targ.netname);
			bprint (" went to pieces in a fit of rage!\n");
			return;
		}
#endifdef

		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER)
					bprint (" tries to put the pin back in\n");
#ifdef HIPNOTIC
//JIM
            else if (rnum <= 0.4 )
					bprint (" checks if his weapon is loaded\n");
#endifdef
				else
					bprint (" becomes bored with life\n");
				return;
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (deathstring);
				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				attacker.frags = attacker.frags + 1;

#ifdef code_xents
// TDO: move this to some other player location
// Cataboligne - 017.1.20 - scores deal
#ifdef code_highscore
// TDO: high score
				if (attacker.frags > high_score)
				{
					high_score = attacker.frags; // secretly for bot morph decision making
					high_score_nn = attacker.netname;
					
// the "high score" in frags
					if (high_score > autocvar_master_high_score)
					{
						localcmd("seta master_high_score \"");
						localcmd(ftos(high_score));
						localcmd("\"\n");
//						cvar_set("master_high_score", ftos(high_score));
						localcmd("seta master_high_nick \"");
						localcmd(high_score_nn);
						localcmd("\"\n");
					}
				}
#endifdef

				if (attacker.ishuman)		//class_select == "class_player")	// note: bots cant get these !
				{
					if (attacker.frags > cvar("score_rel1"))
					{
						serverflags = serverflags | FL_SCORE1;
						m_score_rel1 = 1;
					}
					if (attacker.frags > cvar("score_rel2"))
					{
						serverflags = serverflags | FL_SCORE2;
						m_score_rel2 = 1;
					}
				}
#endifdef

#ifdef hip_items
//MED 01/19/97
				if (empathy_dmg == 1)
				{
					bprint (targ.netname);
					if (random()<0.5)
						bprint (" shares ");
					else
						bprint (" feels ");
					bprint (attacker.netname);
					bprint ("'s pain\n");
					return;
				}
#endifdef


#ifndef code_xents
#ifdef hip_weapons
//MED 11/18/96
				if (targ.dmg_inflictor.classname == "proximity_grenade")
				{
					bprint (targ.netname);
#ifdef code_morph
					if (damage_inflictor.morphy == IMP_MSCOURGE)
					{
						if (rnum < 0.5)
							bprint (" was bombed by ");
						else
							bprint (" tried to disarm a bomb set by ");
						bprint (attacker.netname);
						bprint ("\n");
						return;
					}
#endifdef
					if (random()<0.5)
						bprint (" got too friendly with ");
					else
						bprint (" did the rhumba with ");
					bprint (attacker.netname);
					bprint ("'s bomb\n");
					return;
				}
#endifdef
#endifdef

				rnum = attacker.weapon;
				if (rnum == IT_AXE)
				{
					deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				if (rnum == IT_NAILGUN)
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_SUPER_NAILGUN)
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_GRENADE_LAUNCHER)
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				if (rnum == IT_ROCKET_LAUNCHER)
				{
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if (targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				if (rnum == IT_LIGHTNING)
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
#ifdef hip_weapons
//MED
#ifndef code_xents
            if (rnum == IT_LASER_CANNON)
				{
               if (random()<0.5)
                  {
                  deathstring = " was toasted by ";
                  }
               else
                  {
                  deathstring = " was radiated by ";
                  }
               deathstring2 = "'s laser\n";
				}
#endifdef
//MED
// x_ents FIX:
            if (rnum == IT_MJOLNIR)
				{
               deathstring = " was slammed by ";
               deathstring2 = "'s hammer\n";
				}
#endifdef
				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;
			bprint (targ.netname);

#ifdef HIPNOTIC
//JIM
			if ( attacker.deathtype )
			{
				bprint(" ");
				bprint (attacker.deathtype);
				bprint("\n");
				return;
			}
#endifdef

			// killed by a montser?
			if (attacker.flags & FL_MONSTER)
			{
/// qc++: replace with strcat + cvar_string deal
#ifdef quakemonsters
				if (attacker.classname == "monster_army")
					bprint (" was shot by a Grunt\n");
				if (attacker.classname == "monster_demon1")
					bprint (" was eviscerated by a Fiend\n");
				if (attacker.classname == "monster_dog")
					bprint (" was mauled by a Rottweiler\n");
				if (attacker.classname == "monster_enforcer")
					bprint (" was blasted by an Enforcer\n");
				if (attacker.classname == "monster_fish")
					bprint (" was fed to the Rotfish\n");
				if (attacker.classname == "monster_hell_knight")
					bprint (" was slain by a Death Knight\n");
				if (attacker.classname == "monster_knight")
					bprint (" was slashed by a Knight\n");
				if (attacker.classname == "monster_ogre")
					bprint (" was destroyed by an Ogre\n");
				if (attacker.classname == "monster_oldone")
					bprint (" became one with Shub-Niggurath\n");
				if (attacker.classname == "monster_shalrath")
					bprint (" was exploded by a Vore\n");
				if (attacker.classname == "monster_shambler")
					bprint (" was smashed by a Shambler\n");
				if (attacker.classname == "monster_tarbaby")
					bprint (" was slimed by a Spawn\n");
				if (attacker.classname == "monster_wizard")
					bprint (" was scragged by a Scrag\n");
				if (attacker.classname == "monster_zombie")
					bprint (" joins the Zombies\n");
#endifdef
// TDO: test monster obit
#ifndef code_xents
#ifdef xmonsters
// are extra monsters
				if (attacker.classname == "monster_dragon")
					bprint (" was fried by a Dragon\n");
				if (attacker.classname == "monster_vomit")
					bprint (" was vomited on by a Vomitus\n");
#endifdef
#ifdef hip_monsters
//MED
            if (attacker.classname == "monster_gremlin")
               bprint (" was outsmarted by a Gremlin\n");
//MED
            if (attacker.classname == "monster_scourge")
               bprint (" was stung by a Centroid\n");
//MED
            if (attacker.classname == "monster_armagon")
               bprint (" was outgunned by Armagon\n");
#endifdef
#endifdef
				return;
			}

			// tricks and traps
			if (attacker.classname == "explo_box")
			{
				bprint (" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker) // != world)
			{	
				bprint (" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint (" was spiked\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint (" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}

			// in-water deaths
			rnum = targ.watertype;
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");
				else
					bprint (" sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");
				else
					bprint (" can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
#ifdef code_xents
				if (MAP_MODE == "Q3" || MAP_MODE == "Q2")
				{
					bprint (" does a back flip into the lava.\n");
					return;
				}
#endifdef

				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling")
			{
				targ.deathtype = string_null;
				bprint (" fell to his death\n");
				return;
			}
			// its worse than that - he's dead Jim
			bprint (" died\n");
		}
	}
};
