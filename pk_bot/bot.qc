/* ::-::
 *
 * Cataboligne
 *
 * file: bot.qc
 *
 * date: Sun Apr 6
 *
 * moved various bot fn() here for adaptive code
 *
 */



void (entity e) Update_Frags =
{
	WriteByte (MSG_ALL,MSG_UPDATEFRAGS);
	WriteByte (MSG_ALL,e.id);
	WriteShort (MSG_ALL,e.frags);
};


float () getrandombotskin =
{
	local float botskin;
	botskin = random ();
	if (botskin <= 0.066)
	{
		return(0);
	}
	if ((botskin > 0.066) && (botskin <= 0.132))
	{
		return (1);
	}
	if ((botskin > 0.132) && (botskin <= 0.198))
	{
		return (2);
	}
	if ((botskin > 0.198) && (botskin <= 0.264))
	{
		return (3);
	}
	if ((botskin > 0.264) && (botskin <= 0.330))
	{
		return (4);
	}
	if ((botskin > 0.330) && (botskin <= 0.396))
	{
		return(5);
	}
	if ((botskin > 0.396) && (botskin <= 0.462))
	{
		return (6);
	}
	if ((botskin > 0.462) && (botskin <= 0.528))
	{
		return (7);
	}
	if ((botskin > 0.528) && (botskin <= 0.594))
	{
		return (8);
	}
	if ((botskin > 0.594) && (botskin <= 0.660))
	{
		return (9);
	}
	if ((botskin > 0.660) && (botskin <= 0.726))
	{
		return (10);
	}
	if ((botskin > 0.726) && (botskin <= 0.792))
	{
		return (11);
	}
	if ((botskin > 0.792) && (botskin <= 0.858))
	{
		return(12);
	}
	if ((botskin > 0.858) && (botskin <= 0.924))
	{
		return (13);
	}
	if ((botskin > 0.924) && (botskin <= 1))
	{
		return(15);
	}
	else
	{
		return(15);
	}
};

// *bot - admin control over bots only for darkplaces & chaos - called by bot code on a think when pk*bots are added or removed

void() bot_saveData =
{
	local float offset, toffset, team1;
	local float nb, nt, pk12, pk13;
	local entity e;

	e = find(world,group,"pk*bot");
	offset = toffset = 1;
	pk12 = pk13 = 0;
	team1 = 100;
	nb = nt = 0;
	while (e)
	{
		if (e.team == 99)
		{
			nb = (nb + 1);
			if (nb < BOT_SAVE_SKILL)
			{
				pk12 = (pk12 + ((offset * e.skil) & (offset * 3)));

				offset = (offset * 4);
			}
		}
		else
		{
			if (team1 == 100)
			{
				team1 = e.team;
			}
			if (e.team == team1)
			{
				nt = (nt + 1);
				if (nt < BOT_SAVE_SKILL)
				{
				pk13 = (pk13 + ((toffset * e.skil) & (toffset * 3)));
				toffset = (toffset * 4);
				}
			}
		}
		e = find (e,group,"pk*bot");
	}

	cvar_set("sv_bot_pk", ftos(pk12));
	cvar_set("sv_bot_pktm", ftos(pk13));
};

//	*bot skin code - not sure to include - requiers parm mod
#ifdef code_pkbots_notused
void() bot_skinParms =
{
	if (SKINSMODE)
	{
		parm4 = ((parm4 + (self.skin * 512)) + (16384* SKINSMODE));
	}
};

void() bot_skinDecode =
{
	local float skinno;

	if (parm4 > 511)
	{
		SKINSMODE = ((parm4 & 49152) / 16384);
		skinno = (parm4 & 7680);
		parm4 = (parm4 & 511);
		skinChange (self,skinno);
	}
};
#endifdef

// initialize bots on level

void() set_initBL =
{
#define	dedflags		f0__

	if (!cvar("sv_bot_pkset")) return;

  	dedflags = cvar ("temp1");
	if (dedflags & DEDICATED)
	{
		serverflags = (dedflags | INITLEVEL);
		cvar_set ("temp1","0");
	}
	if (serverflags & INITLEVEL || cvar("sv_bot_pk") || cvar("sv_bot_pktm"))
	if (!find(world,classname,"initBL"))
	{
		e0__ = spawn();
		e0__.think = initBL;
		e0__.nextthink = time + 2; // give players time to start
		e0__.classname = "initBL";
		e0__.cnt = cvar("sv_bot_pk");
		e0__.count = cvar("sv_bot_pktm");
	}
	cvar_set("sv_bot_pkset", "0");		// clear so this doesnt run every respawn / coop spawn

// from prev fn() - set_CarriedPath
	if (self.movetarget == world)
	{
		NewCarriedPath ();
	}
	setorigin (self.movetarget,self.origin);
	self.movetarget.movetarget = world;
	self.pathtype = NEVERTARGET;
	if (!self.pather)
	{
		NUMPATHERS = (NUMPATHERS + 1);
	}
	self.pather = 1;

// other init code
	self.th_cache = cacheenemy;

// init max count - merged with frikbot
/*
	local entity ent;
	
	// spawn entities for the physics
	ent = nextent(world);
	max_clients = 0;

	while(ent != world)
	{
		max_clients = max_clients + 1;
		ent = nextent(ent);
	}
	if (max_clients > 16)
		max_clients = 16;
*/
};

// client connect / disconnect handle for *bots

void(float con) bot_con =
{
// connection
	if (con)
	{
//		if (!self.id) self.id = FindGood ();
// *frikbot code already sets this!
		self.id = self.b_clientno;
//		self.impulse = 204; // printinit - does nada, code commented out
		randombotskin = getrandombotskin ();
//		initscore ();
	}
	else // disconnect
	{
		active_clients = (active_clients - (active_clients & ClientBitFlag(self.id)));
//		MakeGood (self.id);
		self.classname = string_null;
	}
};

// changelevel happened - clear bots out, set reload

void() bot_changelevel =
{
	local entity e;

	e = find (world,group,"pk*bot");
	while (e)
	{
		e.nextthink = -1;
		e.modelindex = 0;
		e = find (e,group,"pk*bot");
	}
	serverflags = (serverflags | INITLEVEL); // reload bots on next level
};

// count bot kills & deaths for scoreboard - extract from ClientObituary, called for ClientObit divert in killed

void(entity targ, entity attacker) bot_kill =
{
	ClientObituary(targ, attacker); // *pk - pk death handler

	if (attacker.group == "pk*bot")
		Update_Frags(attacker);
	if (targ.group == "pk*bot")
		Update_Frags(targ);

	if ((targ.classname == "player") || (targ.group == "pk*bot"))
	{
		if (attacker.classname == "teledeath") // note: portal frag, one day maybe
		if (attacker.owner.group == "pk*bot")
		{
			TELEFRAGFLAG = 1;
			Update_Frags(attacker.owner);
		}
	}

};


// remove item hooks & put here - code diverts here from PlaceItem

// TDO: easy ver, all x stuff - note: class_select possibilities

void(entity e) bot_item_linx =
{

// clear state for cacheRoute calls
	e.state = 0;

// armor items

	if (e.touch == armor_touch) // || e.pk_touch == armor_touch) // do here instead of item setup - Cataboligne - 9.25.9
	{
		if (!e.skin) e.armorvalue = 100;
		else if (e.skin == 1) e.armorvalue = 150;
		else if (e.skin == 2) e.armorvalue = 200;
	}

// health items
	if (e.classname == "item_health") // || e.model == "maps/b_bh10.bsp" / "maps/b_bh25.bsp / maps/b_bh100.bsp
	{
		e.state = BOT_TOUCHED;
		e.th_weight = healthweight;
		if (e.healtype == HEAL_MEGA || e.healtype == HEAL_SOUL) // || e.model == "maps/b_bh100.bsp"
		{
			e.th_cache = cachepowerup;
			e.th_update = updatepowerup;	
			e.state = BOT_TOUCHED_CACHE_ROUTE_TOUCH;
		}
		return;
	}

// armor
	if (e.model == "progs/armor.mdl") // IDEA: how to catch armor if model can change?
	{
		e.th_weight = armorweight;
		e.th_cache = cachearmor;
		e.th_update = updatearmor;
		e.state = BOT_TOUCHED_CACHE_ROUTE_TOUCH;
		return;
	}

// weapons
	if (e.classname == "weapon_supershotgun")
	{
		e.th_weight = ssgweight;
	}
	else if (e.classname == "weapon_nailgun")
	{
		e.th_weight = nailgunweight;
	}
	else if (e.classname == "weapon_supernailgun")
	{
		e.th_weight = supernailweight;
		e.th_cache = cachenail;
		e.th_update = updatenail;
		e.state = CACHE_ROUTE_TOUCH;
	}
	else if (e.classname == "weapon_grenadelauncher")
	{
		e.th_weight = glauncherweight;
		e.th_cache = cachegrenade;
		e.th_update = updategrenade;
		e.state = CACHE_ROUTE_TOUCH;
	}
	else if (e.classname == "weapon_rocketlauncher")
	{
		e.th_weight = rlauncherweight;
		e.th_cache = cacherocket;
		e.th_update = updaterocket;
		e.state = CACHE_ROUTE_TOUCH;
	}
	else if (e.classname == "weapon_lightning")
	{
		e.th_weight = lightningweight;
		e.th_cache = cachelightning;
		e.th_update = updatelightning;
		e.state = CACHE_ROUTE_TOUCH;
	}
	if (e.touch == weapon_touch /* || e.pk_touch == weapon_touch*/) return;

// ammo
	if (e.classname == "item_shells")
	{
		e.th_weight = shellweight;
	}
	else if (e.classname == "item_spikes")
	{
		e.th_weight = nailweight;
	}
	else if (e.classname == "item_rockets")
	{
		e.th_weight = rocketweight;
	}
	else if (e.classname == "item_cells")
	{
		e.th_weight = cellweight;
	}
	if (e.touch == ammo_touch) // || e.pk_touch == ammo_touch)
	{
		e.state = BOT_TOUCHED;
		return;
	}

// artifacts
	if (e.touch == powerup_touch) // || e.pk_touch == powerup_touch)
	{
		e.th_weight = artifactweight;
		if (e.classname != "item_artifact_envirosuit")
		{
			e.th_weight = artifactweight;
			e.th_cache = cachepowerup;
			e.th_update = updatepowerup;
			e.state = CACHE_ROUTE_TOUCH;
		}
		return;
	}

// any painkeep item - seems coder didnt program bot for these
#ifdef code_painkeep_
	if (e.pk_currentitem || e.netname == "Exploding Shells") // yuk :(~
	{
	e.th_weight = dont_weight;
	return;
	}
#endifdef

};


 // Cataboligne - 6.9.10 - bots get really cold now - dev code

/*

 11.6.13 - no longer using, but keeping around for a future "freeze ray" weapon

float b_frz;
float b_ufr;

void (entity e) bot_freeze =
{
	if (e)
	if (BOTFREEZE)
	{
		e.style = e.movetype;
		e.movetype = MOVETYPE_NONE;
		e.attack_finished = MAXFL;
		if (e.think != SUB_Nop) e.think1 = e.think;
		e.think = SUB_Nop;
		b_frz = b_frz + 1;
	}
	else
	{
		e.movetype = e.style;
		e.attack_finished = 0;
		e.think = e.think1; // if this is spuriously called this is not good
		e.nextthink = time + 0.1;
		b_ufr = b_ufr + 1;
	}
};
*/

// bot stuck in dead - tyr to force a respawn

void() bot_wakey =
{
	if (self.owner.deadflag)
	if (self.owner.button16 == 66600) // make sure bot didnt respawn or change state
	if (self.owner.class_select == "class_bot")
	{
		self.owner.button16 = self.owner.frags;
		self.owner.button15 = self.owner.health;
		if (self.owner.group == "pk*bot")
		{
			self.owner.nextthink = time + random();
			self.owner.think = respawnBot;
		}
		else
		{
			self.owner.nextthink = time + random();
			self.owner.think = respawn;
			self.owner.button0 = 1;
		}
	}
	remove(self);
}

void() bot_fixed =
{
	if (self.owner.class_select == "class_bot")
	if (self.frags == self.owner.frags) // hasnt changed
	{
		bot_fix.frags = bot_fix.frags + 1;
		self.owner.armorvalue = 0;
		self.owner.invincible_finished = 0;
		T_Damage (self.owner,world,bot_fix,self.owner.health + 10);
	}
	remove(self);
}

// take a shot at fixing 2 bot problems - bots getting stuck & doing nothing for a long time and being dead too long

// not testing health because it didnt work right

void() bot_fixer =
{
//	local entity e,f;

	e0__ = find(world,class_select,"class_bot");

	if (bot_fix && (!e0__ || intermission_running) )
	{
		remove(bot_fix);
		bot_fix = world;
		return;
	}

	if (!bot_fix && e0__)
	{
		bot_fix = spawn();
#ifdef warning_no
		bot_fix.classname = "bot_fix";
#endifdef
		bot_fix.think = bot_fixer;
		bot_fix.nextthink = time + BOT_FIX_TIME;

		while (e0__)
		{
			e0__.button16 = e0__.frags;
			e0__.button15 = e0__.health;
			e0__ = find(e0__,class_select,"class_bot");
		}

		return;
	}

	if (self.think == bot_fixer)
	{
		while (e0__)
		{
			if (e0__.button16 == e0__.frags)
//			if (e0__.button15 == e0__.health)
			{
#ifdef code_painkeep_
				if (!(inHubMap && e0__.map != string_null)) // do nothing on hub maps / once voted
#endifdef
				{
					if (e0__.deadflag)
					{
						e1__ = spawn();
#ifdef warning_no
						e1__.classname = "bot_waker";
#endifdef
						e1__.think = bot_wakey;
						e1__.nextthink = time + 2 + random() * 5;
						e1__.owner = e0__;
						e0__.button16 = 66600;
					}
// had to put this back in - bot inactivity is still happening
					else if (bot_fix.cnt == 6) // note: this only checks frags on 14 rel loop - need a longer range check for this
					{
					e1__ = spawn();
#ifdef warning_no
					e1__.classname = "bot_fixer";
#endifdef
					e1__.think = bot_fixed;
					e1__.nextthink = time + 3 + random() * 10;
					e1__.owner = e0__;
					e1__.frags = e0__.frags;
					}
				}
			}
			else
			if (e0__.button16 != 66600)
			{
				e0__.button16 = e0__.frags;
				e0__.button15 = e0__.health;
			}
			e0__ = find(e0__,class_select,"class_bot");
		}

		self.nextthink = time + BOT_FIX_TIME;
		bot_fix.cnt = bot_fix.cnt - 1;
		 if (bot_fix.cnt < 0) bot_fix.cnt = 11; // only do a dead check every 10 * cnt - about 150 rels
	}
};

// preventative for endless bot axe war - also reduce bot fixer
// or a little cheat goes along way

void() Bot_Melee =
{
//	local entity e;
//	local float f;

	if (!ax_dmg)
	if (random() < 0.8) // unknown timing - this is a guess, might be really good or really bad or really medium  
	{
		f0__ = TRUE;
		e0__ = findradius(self.origin, 80);
		while (e0__ && f0__)
		{
			if (e0__ != self)
			if (e0__.class_select == "class_bot")
			{
				if (CanDamage(e0__, self)) // hit this other bot - we dont really care about the particulars, what happens between bots, stays between bots
				{
					e0__.axhitme = 1;
					SpawnBlood (e0__, e0__.origin, '0 0 0', 20);
					T_Damage (e0__,self,self,20 + random() * 10);
					f0__ = FALSE;
				}
			}
			e0__ = e0__.chain;
		}
	}
};




















