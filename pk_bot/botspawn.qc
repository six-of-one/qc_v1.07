/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botspawn.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */

// darkplaces / chaos only
// thinking - because if we call it straight up (in some cases) it missed the bots

void(float tm) th_bot_changeParms =
{
	e0__ = world;
	if (self.classname != "bot_chPrm")
	{
		if (!find(world, classname, "bot_chPrm"))
		{
			e0__ = spawn();
			e0__.classname = "bot_chPrm";
			e0__.think = th_bot_changeParms;
			e0__.nextthink = time + tm;
		}
	}
	else
	{
		bot_saveData();
		remove(self);
	}
};

float NOSAVE; // init bots on level change - dont re-save old data, only admin & script control of bots should do that

void () initBL =
{
	local float num;
	local float offset;
	local float i, f;
	local entity e;
//	local string tmp;

// always remove this ent
	if (self.classname == "initBL")
	{
		self.think = SUB_Remove;
		self.nextthink = time + 1;
	}

	NOISEQUEUE = noisetarget ();
	num = ((serverflags & BOTS) / 16);

	serverflags = serverflags - (serverflags & BOTS) - (serverflags & INITLEVEL);
	NUMBOTS = 0;
	NUMPATHS = 0;
	NUMPATHERS = 0;
	offset = 1;
	NOSAVE = TRUE;
	if (self.cnt > 0 && !num) // start bots with skill levels set in .cnt (parm12 or sv_bot_pk) when num is 0
	{
		i = BOT_SAVE_SKILL; // no more than this many
	}

	while (num > 0 || i > 0)
	{
		c_skill = skill;
		f = 0;
		if ((NUMBOTS < (BOT_SAVE_SKILL - 1)) && !(serverflags & DEDICATED))
		{
//			c_skill = ((0.1 * (parm12 & (offset * 31))) / offset);
			f = c_skill = ((self.cnt & (offset * 3)) / offset);
		}

		offset = (offset * 4);
		if (num || (i && f > 0))
			AddAnotherBot(c_skill);
		if (num > 0) num = (num - 1);
		if (i > 0) i = (i - 1);
	}
	if (serverflags & TEAMFLAG)
	{
		if (!teamplay)
		{
			serverflags = (serverflags - TEAMFLAG);
			serverflags = (serverflags - (serverflags & TEAMBOTS));
			NOSAVE = FALSE;
			return ;
		}
	}
	else
	{
		if (teamplay)
		{
			serverflags = (serverflags + TEAMFLAG);
			serverflags = (serverflags - (serverflags & TEAMBOTS));
			NOSAVE = FALSE;
			return ;
		}
	}
	if (!teamplay)
	{
		NOSAVE = FALSE;
		return ;
	}
	num = ((serverflags & TEAMBOTS) / 256);
	if (num == 0)
	{
		NOSAVE = FALSE;
		return ;
	}
	e = find (world,classname,"player");
	while (e)
	{
		i = 0;
		offset = 1;
		while (i < num)
		{
			i = (i + 1);
			c_skill = skill;
			if ((i < BOT_SAVE_SKILL ) && !(serverflags & DEDICATED))
			{
//				skill = ((0.1 * (parm13 & (offset * 31))) / offset);
				c_skill = ((self.count & (offset * 3)) / offset);
			}
			offset = (offset * 4);
			addTeamBots (e,TRUE);
		}
		e = find (e,classname,"player");
	}
	if (serverflags & DEDICATED)
	{
		serverflags = (serverflags - DEDICATED);
	}
	NOSAVE = FALSE;
};

void () setBotGravity =
{
	local float newmax;
	local float vel;
//	local float sk;

	GRAVITY = (cvar ("sv_gravity") * 0.1);
	bprint ("Gravity accel: ");
	bprint (ftos (GRAVITY));
	bprint ("\n");
	newmax = 0;
	vel = 270;
	MAXJUMP = -1;
	while (newmax > MAXJUMP)
	{
		vel = (vel - GRAVITY);
		MAXJUMP = newmax;
		newmax = (newmax + (vel * 0.1));
	}
	MAXJUMP = (MAXJUMP - 1);
	bprint ("Max jump height: ");
	bprint (ftos (MAXJUMP));
	bprint ("\n");
	LEVELJUMPTIME = 0;
	vel = 270;
	newmax = 0;
	while (newmax > -1)
	{
		LEVELJUMPTIME = (LEVELJUMPTIME + 0.1);
		vel = (vel - GRAVITY);
		newmax = (newmax + (vel * 0.1));
	}
	LEVELJUMPTIME = (LEVELJUMPTIME - (newmax / vel));
	bprint ("Level jump time: ");
	bprint (ftos (LEVELJUMPTIME));
	bprint ("\n");
	newmax = 0;
	vel = 200;
	GRENADEMAXHEIGHT = -1;
	while (newmax > GRENADEMAXHEIGHT)
	{
		vel = (vel - GRAVITY);
		GRENADEMAXHEIGHT = newmax;
		newmax = (newmax + (vel * 0.1));
	}
	bprint ("Max grenade height: ");
	bprint (ftos (GRENADEMAXHEIGHT));
	bprint ("\n");
	INVGRENLD = (((0.1 * 2) * (200 - GRAVITY)) / GRAVITY);
	INVGRENLD = (1/ (INVGRENLD * SEARCH_RADIUS));
	bprint ("inverse grenade level distance: ");
	bprint (ftos (INVGRENLD));
	bprint ("\n");
	BOTSPEED = (cvar ("sv_maxspeed") / 10);
};

void () PutBotInServer;
float () numplayers;
//float (entity e) totalscore;
void () respawnBot =
{
	local string m;
	local float n;
	local float o;
	local entity e;
	CopyToBodyQue (self);
	if (!teamplay)
	{
		if (serverflags & TEAMBOTS)
		{
			n = (NUMBOTS + numplayers ());
			o = ((serverflags & TEAMBOTS) / 256);
			if ((o < n) || (self.team != 99))
			{
				self.nextthink = (time + 1);
				if (self.team == 99)
				{
					NUMBOTS = (NUMBOTS - 1);
				}
				remove (self.movetarget);
				remove (self.goalentity);
				self.think = SUB_Remove;
				if (self.pather)
				{
					NUMPATHERS = (NUMPATHERS - 1);
				}
				if (self.team != 99)
				{
					m = ": I'm going to find a team server.\n";
				}
				else if (self.frags < -20) //totalscore (self) < 0)
				{
					m = ": I'm tired of getting fragged.  I'm off\n";
				}
				else if (self.frags > 100) //totalscore (self) > 100)
				{
					m = ": I'm going to find some real competition\n";
				}
				else
				{
						m = ": This server's too crowded.  I'm off\n";
				}
				bprint (self.teamname);
				bprint (self.netname);
				bprint (m);
				bprint (self.teamname);
				bprint (self.netname);
				bprint (" left the game with ");
				bprint (ftos (self.frags));
				bprint (" frags\n");
				return ;
			}
		}
	}
	else
	{
		if (self.team != 99)
		{
			e = find (world,classname,"player");
			while (e)
			{
				if (e.team == self.team)
				{
					PutBotInServer ();
					return ;
				}
				e = find (e,classname,"player");
			}
			bprint (self.teamname);
			bprint (self.netname);
			bprint (": Going off to join my team\n");
			bprint (self.teamname);
			bprint (self.netname);
			bprint (" left the game with ");
			bprint (ftos (self.frags));
			bprint (" frags\n");
			return ;
/*
		}
		else
		{
			if (SKINSMODE == 2)
			{
// CHECK: painkeep damage skins
//				skinChange (self,randombotskin);
			}
*/
		}
	}
	PutBotInServer ();
};

void () bot_pain;
void () BotDie;
void () bot_stand1;
void () bot_walk;
void () bot_run;
void () bot_start;
void () pkbot_melee;
entity () botmovetarget;

void () PutBotInServer =
{
//	local entity spwn;
//	local vector spot;

	SetNewParms ();

	self.group = "pk*bot";
	self.class_select = "class_bot";
	PutClientInServer(); /// Cataboligne - 6.20.10 - does all commented stuff below *** NOTE: means bots use parm*, which is wrong
	// sets FL_CLIENT - might be ok

//	self.classname = "player";		// at long last, taking the frikbot route
	self.movetype = MOVETYPE_STEP;
	self.air_finished = (time + 30);
	self.dmg = 1;

//models--------

	self.yaw_speed = (45 + (25 * self.skil));
	self.lefty = STRAFE_DIR;
	if (self.goalentity == world)
	{
		self.goalentity = botmovetarget ();
	}
	self.goalentity.goalentity = world;
	self.search_time = time;
	self.th_pain = bot_pain;
	self.th_die = BotDie;
	self.th_stand = bot_stand1;
	self.th_walk = bot_walk;
	self.th_run = bot_run;
	self.th_melee = pkbot_melee;
	self.th_cache = cacheenemy;
	self.touch = fix_thud;
	self.think = bot_start;
	self.nextthink = (time + 0.1);
	self.enemy = world;
	self.pathtype = NEVERTARGET;
	if (self.movetarget == world)
	{
		NewCarriedPath ();
	}
	else
	{
		setorigin (self.movetarget,self.origin);
	}
	self.movetarget.movetarget = world;
	clearCache (self);
	if (self.pather)
	{
		NUMPATHERS = (NUMPATHERS - 1);
		self.pather = 0;
	}
	if (NUMPATHERS < MAXPATHERS)
	{
		self.pather = 1;
		NUMPATHERS = (NUMPATHERS + 1);
	}

#ifndef nodprint
	if (BOTSPEED < 32)
	{
		dprint ("Feeling kind of slow today (SV_MAXSPEED = ");
		dprint (ftos (BOTSPEED * 10));
		dprint ("\n");
	}
#endifdef

#ifndef nodprint
	if (cvar ("sv_aim") != 0.930)
	{
		dprint ("Seems like sv_aim isn't 0.93\n");
	}
#endifdef
};

void () SpawnNewBot =
{
	local string tmp;
// xrp code - looks good, not qualifying
	if (intermission_running)
	{
		return ;
	}
	PutBotInServer ();
	bprint (self.teamname);
	bprint (self.netname);
	bprint (" | skill = ");
	bprint (ftos (self.skil));
#ifdef code_painkeep_
	f0__ = rint(random() * 7);
	bprint(cvar_string(strcat("hi",ftos(f0__))));
	bprint("\n");
	bprint("\n");
#else
	bprint (" entered the game\n\n");
#endifdef
//	bprint (") entered the game.\n");
};

entity () AddBot =
{
	e1__ = spawn ();

	e0__ = self;
	self = e1__;
	self.think = SpawnNewBot;
	self.nextthink = (time + (12 * random ()));
	self.skil = c_skill;
	if (self.skil < 0)
	{
		self.skil = 0;
	}
	else if (self.skil > 3)
	{
		self.skil = 3;
	}
//	initscore ();
	self = e0__;
	return(e1__);
};

float () numplayers =
{
	f0__ = 0;
	e0__ = find (world,classname,"player");
	while (e0__)
	{
		f0__ = (f0__ + 1);
		e0__ = find (e0__,classname,"player");
	}
	return(f0__);
};

void (float skl) AddAnotherBot =
{
	local entity newbot;
	local float n, sf;
	local string st;
	local float top, bottom;

//	self.impulse = 0;
	if (!teamplay)
	{
		if (serverflags & TEAMBOTS)
		{
			n = (NUMBOTS + numplayers ());
			if ((serverflags & TEAMBOTS) < n)
			{
				bprint ("Can't add bot - exceeds bound\n");
				return ;
			}
		}
	}
//	if (fClientNo == 15)
//		return;

	n = ClientNextAvailable(); // *frikbot tie in
	if (n == -1)
	{
		bprint("Unable to connect a bot, server is full.\n");
		return;
	}
//	fClientNo = (fClientNo + 1);
	active_clients = (active_clients | ClientBitFlag(n));
  
	if (skl < 0)
		c_skill = skill;
	else
		c_skill = skl;
	newbot = AddBot ();
	newbot.id = n;
	newbot.colormap = (newbot.id + 1);
	newbot.team = 99;
// CHECK: painkeep damageskins
/*
	if (teamplay)
	{
		skinChange (newbot,randombotskin);
	}
	else
	{
		if (SKINSMODE == 1)
		{
			skinChange (newbot,NUMBOTS);
	 	}
		else
		{
			if (SKINSMODE == 2)
			{
				st = ftos ((newbot.skil & 3) + 1);
				dprint (st);
				dprint ("= skil skin\n");
				skinChange (newbot,((newbot.skil & 3) + 1));
			}
		}
	}
	if (NAMEBOTS)
	{
		newbot.teamname = self.netname;
	}
	else
	{
		if (newbot.skil < 1)
		{
			newbot.teamname = "[Bot0]";
		}
		else
		{
			if (newbot.skil < 2)
			{
				newbot.teamname = "[Bot1]";
			}
			else
			{
				if (newbot.skil < 3)
				{
					newbot.teamname = "[Bot2]";
				}
				else
				{
					newbot.teamname = "[Bot3]";
				}
			}
		}
	}
 // NOTE: --- disabled team names for now - irritating qbot stuff
*/
	NUMBOTS = (NUMBOTS + 1);
	if (NUMBOTS == 1)
	{
		newbot.nextthink = (time + 0.1);
	}
	if (NUMBOTS < 16)
	{
		serverflags = ((serverflags - (serverflags & BOTS)) + (16* NUMBOTS));
	}

	n = 1 + floor(random() * 14.4);
	sf = 200;

	while (sf > 0) // heh heh - select a random bot name / color set - old code was a dork and always went in order
	{
		sf = sf - 1;

		if (n == 1)
		{
			top = 1;
			bottom = 6;
			if (c_skill > 2)
			{
				top = c_skill;
				bottom = 13;
				st = "Pain [stinger]";
			}
			else
				st = "Pain [bringer]";
		}
		else if (n == 2)
		{
			top = 2;
			bottom = 13;
			if (c_skill > 2)
			{
				top = c_skill + 1 + random();
				st = "Pain [special delivery]";
			}
			else
				st = "Pain [giver]";
		}
		else if (n == 3)
		{
			top = 4;
			bottom = 13;
			if (c_skill > 2)
			{
				top = c_skill * 2;
				st = "Pain [master]";
			}
			else
				st = "Pain [disciple]";
		}
		else if (n == 4)
		{
			top = 3;
			bottom = 12;
			if (c_skill > 2)
			{
				top = c_skill * 2 * random();
				st = "Clan LOLZ [|<e |<e]";
			}
			else
				st = "Clan LOLZ [w00ps]";
		}
		else if (n == 5)
		{
			top = 13;
			bottom = 12;
			if (c_skill > 2)
			{
				top = c_skill * 3 * random();
				st = "Clan LOLZ [u-r-ded]";
			}
			else
				st = "Clan LOLZ [d(_)(_)fy]";
		}
		else if (n == 6)
		{
			st = "Codename: blizzard";
			top = 0 + random() + random();
			bottom = 4 + random() + random();
		}
		else if (n == 7)
		{
			st = "Rex Felis";
			top = 1;
			bottom = 3 * c_skill * random();
		}
		else if (n == 8)
		{
			st = "r00ST3R";
			top = 4 + random() + random() + random();
			bottom = 9 + random();
		}
		else if (n == 9)
		{
			st = "M*nstAr";
			top = 3;
			bottom = 6 + random() + random() + random() + random();
		}
		else if (n == 10)
		{
			st = "Yesman";
			top = n;
			bottom = n;
		}
		else if (n == 11)
		{
			st = "Hard_ware";
			top = 0 + random();
			bottom = 13 + random() + random();
		}
		else if (n == 12)
		{
			st = "Ray ---=>";
			top = 13;
			bottom = 11;
		}
		else if (n == 13)
		{
			st = "Kill=death+die-dead";
			top = 12 + random() + random() + random();
			bottom = 11 + random() + random() + random();
		}
		else if (n == 14)
		{
			top = 9 + random() + random();
			bottom = 13;
			if (c_skill > 2)
			{
				top = c_skill * 2.2 * random() + random() + random();
				st = "Tweedle-dweeb";
			}
				st = "Tweedle-dumb";
		}
		else if (n >= 15)
		{
			st = "Pain (*) ----";
			top = 15 * random();
			bottom = 15 * random();
		}

		if (find(world, netname, st)) // see if name is taken
		{
			if (sf == 17) n = 1;
			else
			if (sf < 17)
				n = n + 1; // random no worky - brute force
			else
				n = 1 + floor(random() * 14.4);
		}
		else
			sf = 0;
	}

// merge with frikbot - using frik vars
	newbot.netname = st;
	newbot.b_clientno = newbot.id;
	newbot.b_shirt = rint(top);
	newbot.b_pants = rint(bottom);
	newbot.ishuman = FALSE; // frik stuff - make sure - always must be false for bots
	UpdateClient(newbot);		//	NOTE: this puts bot on scoreboard
/*
	WriteByte (MSG_ALL,MSG_UPDATENAME);
	WriteByte (MSG_ALL,newbot.id);
	WriteString (MSG_ALL,newbot.netname);
	WriteByte (MSG_ALL,MSG_UPDATECOLORS);
	WriteByte (MSG_ALL,newbot.id);
	WriteByte (MSG_ALL,((top * 16) + bottom));
	WriteByte (MSG_ALL,MSG_UPDATEFRAGS);
	WriteByte (MSG_ALL,newbot.id);
	WriteShort (MSG_ALL,newbot.frags);
*/
	if (!NOSAVE)
//	if (DARKPLACES || chaos) 
		th_bot_changeParms(12.5);
};

void (entity ply, float n) addTeamBots =
{
	local entity newbot;
//	local entity tmp;
	local float i;
	i = n;
	while (i > 0)
	{
//		c_skill = skill; // already set
		newbot = AddBot ();
		newbot.colormap = ply.colormap;
		newbot.team = ply.team;
		newbot.teamname = ply.netname;
		skinChange (newbot,ply.skin);
		if (newbot.skil < 1)
		{
			newbot.netname = "[Bot0]";
		}
		else if (newbot.skil < 2)
		{
			newbot.netname = "[Bot1]";
		}
		else if (newbot.skil < 3)
		{
			newbot.netname = "[Bot2]";
		}
		else
		{
			newbot.netname = "[Bot3]";
		}
		i = (i - 1);
		if (!NOSAVE)
//		if (DARKPLACES || chaos) 
			th_bot_changeParms(12.5);
	}
};

void(entity e) removeBot =
{
	local entity f;

	f = e;
	if (!f) f = find (world,group,"pk*bot");
	if (!f) return ;

	if (f.pather) NUMPATHERS = (NUMPATHERS - 1);

	if (f.b_clientno != -1)
	{
// the bot's client number is not in use by a real player so we
// must remove it's entry in the rankings
// Quake engine sets all fields to 0, can only do the most important here
		f.b_frags = f.frags = 0;
		f.netname = string_null;
		f.classname = string_null;
		f.health = 0;
		f.items = 0;
		f.armorvalue = 0;
		f.weaponmodel = string_null;
		f.b_pants = 0;
		f.b_shirt = 0;
		f.ammo_shells = f.ammo_nails = f.ammo_rockets = f.ammo_cells = 0;
#ifdef code_painkeep_
		f.pkprevweapon = /* f.pklastweapon = */ 
#endifdef
		f.prevweapon = f.lastweapon = 0; // pk
		f.weapon = f.currentammo = f.x_items = f.ammo_bullet = f.ammo_slug = f.ammo_gaspr = 0; //f.ammo_hgrenade = 0; // x stuff
		f.eweapon = world;
		UpdateClient(f);
		active_clients = active_clients - (active_clients & ClientBitFlag(f.b_clientno));
		f.id = f.b_clientno = -1;
	}

// update - was: dead_drop(f); // Cataboligne - 10.7.11 - drop runes+
	if (f.rune_flag) dead_runes(f);

	remove (f.movetarget);
	remove (f.goalentity);
	remove (f);
	NUMBOTS = NUMBOTS - 1;
//	if (DARKPLACES || chaos) 
		th_bot_changeParms(1);
};

void (entity ply, float n) removeTeamBots =
{
	local float i;
	local entity e;
	i = n;
	e = find (world,group,"pk*bot");
		if (!e)
		{
			bprint ("No team bots found.\n");
			return ;
		}
	while (i > 0)
	{
		while ((e != world) && (e.team != ply.team))
		{
			e = find (e,group,"pk*bot");
		}
		removeBot(e);
		i = (i - 1);
	}
};

void () removeAllBots =
{
	local entity e;
	e = find (world,group,"pk*bot");
	if (!e)
	{
		bprint ("No bots found.\n");
		return ;
	}
	while (e)
	{
		removeBot(e);
		e = find (e,group,"pk*bot");
	}
	NUMBOTS = 0;
	bprint ("All bots removed.\n");
};

void (float n) SetMaxBots =
{
	local float t;
	self.impulse = 0;
	if (serverflags & TEAMFLAG)
	{
		bprint ("Entering bounded deathmatch mode\n");
		serverflags = ((serverflags - TEAMFLAG) - (serverflags & TEAMBOTS));
	}
	bprint ("Max bots + players set to ");
	bprint (ftos (n));
	bprint ("\n");
	serverflags = ((serverflags - (serverflags & TEAMBOTS)) + (n * 256));
	t = numplayers ();
	while ((NUMBOTS + t) < n)
	{
		AddAnotherBot(-1);
	}
};

void (float n) SetTeamBots =
{
	local float t;
	local entity e;
	self.impulse = 0;
	if (!(serverflags & TEAMFLAG))
	{
		bprint ("Entering bot team mode\n");
		serverflags = ((serverflags + TEAMFLAG) - (serverflags & TEAMBOTS));
	}
	bprint ("Bots per player team set to ");
	bprint (ftos (n));
	bprint ("\n");
	t = ((serverflags & TEAMBOTS) / 256);
	serverflags = ((serverflags - (serverflags & TEAMBOTS)) + (n * 256));
	if (t < n)
	{
		e = find (world,class_select,"class_player");
		t = (n - t);
		c_skill = skill;
		while (e)
		{
			addTeamBots (e,t);
			e = find (e,class_select,"class_player");
		}
		return ;
	}
	if (t > n)
	{
		e = find (world,class_select,"class_player");
		while (e)
		{
			t = (t - n);
			removeTeamBots (e,t);
			e = find (e,class_select,"class_player");
		}
		return ;
	}
};

void () UpdateTeamColors =
{
	local entity e;
	e = find (world,group,"pk*bot");
	while (e)
	{
		if (e.colormap == self.colormap)
		{
			e.team = self.team;
		}
		e = find (e,group,"pk*bot");
	}
};

