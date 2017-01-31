/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: bot_ai.qc
 *
 * date: Fri Apr  4 04:40:01 UTC 2008
 *
 * final qc
 *
 */

// * bots can collect & use painkeep stuff - YAY (no gir, thats bad...aww. I wanted to explode.)

void() use_pkitem =
{
	local float drp;

	drp = 0;

	if (self.health < 30) drp = 1;		// hurt - always use item - try most beneficial first

	else if (self.health < 66)
	{
		if (self.health < 40) drp = 1;
		else drp = random();
		if (drp < 0.1) drp = 0.9;
		else if (drp < 0.2) drp = 0.8;
	}
	else if (random() < 0.3)
	{
		drp = random();
		if (drp < 0.1) drp = 0.9;
		else if (drp < 0.2) drp = 0.8;
	}

	if (drp)
	{
		if (self.pk_canpabammo > 0 && drp > 0.9) // heal or escape when health low
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_CANPAB;
			PK_Attack();
		}
		else if (self.pkplus_phoneammo > 0 && drp > 0.9)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PKPLUS_IT_PHONE;
			PK_Attack();
		}
		else if (self.pk_gravitywellammo != 0 && drp > 0.8)
		{
			if (coop)
			{
				local entity pl;
				pl = find(world, classname, "player");
				while (pl != world)
				{
					if (pl.class_select == "class_player" && (vlen(self.origin - pl.origin) < 2000)) return; // dont fire one of these when real player is close by
					pl = find(pl, classname, "player");
				}
			}
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_GRAVITYWELL;
			PK_Attack();
		}
		else if (self.pk_turretammo > 0 && drp > 0.7)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_TURRET;
			PK_Attack();
		}
		else if (self.pk_beartrapammo > 0 && drp > 0.6)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_BEARTRAP;
			PK_Attack();
		}
		else if (self.pkplus_egoammo > 0 && drp > 0.4) // Cataboligne - 5.8.10 - bots use pkplus artefacts items now - YAY!  (no Gir, thats bad...)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PKPLUS_IT_EGO;
			PK_Attack();
		}
		else if (self.pkplus_tombammo > 0)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PKPLUS_IT_TOMB;
			PK_Attack();
		}
	}
};

void () endEnemy =
{
	local entity olden;
	olden = self.enemy;
	if (self.lefty & GETGOODY)
	{
		self.lefty = (self.lefty - GETGOODY);
	}
	if (self.lefty & MULTIENEMY)
	{
		self.lefty = (self.lefty - MULTIENEMY);
	}
	self.enemy = world;
	self.think = self.th_walk;
	self.nextthink = (time + 0.1);
	self.search_time = (time - 1);
	self.enemyrun = 0;
	self.goalentity.goalentity = self.goalentity;
	if (olden.classname == "player")
	{
		if (olden.enemy == self)
		{
			olden.enemy = world;
		}
	}
};

void () CallForHelp =
{
	local entity e;
	local entity p;
	local entity tmp;
//	local float d;
	HELPING = 1;
	e = find (world,classname,"pk*bot");
	while (e)
	{
		if (e != self)
		{
			if (e.team == self.team)
			{
				if (e.enemy == world)
				{
					if (e.health > 80)
					{
						if (e.items & ((((IT_ROCKET_LAUNCHER + IT_LIGHTNING) + IT_SUPER_NAILGUN) + IT_SUPER_SHOTGUN) + IT_GRENADE_LAUNCHER))
						{
							p = BestChaseRoute (e,self.enemy);
							traceline (e.origin,self.enemy.origin,TRUE,e);
							if ((trace_fraction == 1) || (p.enemycache == self.enemy))
							{
								if (VERBOSEBOT)
								{
									dprint (e.teamname);
									dprint (e.netname);
									dprint (" coming to help!\n");
								}
								e.enemy = self.enemy;
								tmp = self;
								self = e;
								BotFoundTarget ();
								if (self.goalentity.classname != "BotTarget")
								{
#ifdef warning
									if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 1
#endifdef
									ai_botstand();
									return;
								}
								setorigin (self.goalentity,p.origin);
								self = tmp;
							}
						}
					}
				}
			}
		}
		e = find (e,classname,"pk*bot");
	}
	HELPING = 0;
};

float () RunAway =
{
	local float runawayspeakchance;
	local float weap;
	runawayspeakchance = random ();
	if (!VERBOSEBOT)
	{
		runawayspeakchance = 1;
	}
	if (self.items & IT_INVULNERABILITY)
	{
		return (0);
	}
	if (self.enemy.items & IT_INVULNERABILITY)
	{
		if (XRP)
		if (runawayspeakchance <= 0.1)
		{
			bprint (self.netname);
			bprint (": Run for it, ");
			bprint (self.enemy.netname);
			if (random() < 0.6)
				bprint (" has got a Pentagram and is not afraid to use it!\n");
			else if (random() < 0.2)
				bprint (" is the freaking Anti-Christ!\n");
			else
				bprint (" has nasty pointy teeth!\n"); // Cat - 4.5.10 - Python mods
		}
		return (1);
	}
	if (self.enemy.health < WANT) // 35
	{
		return (0);
	}
	weap = W_BestHeldWeapon ();
	if (weap & (IT_ROCKET_LAUNCHER + IT_LIGHTNING))
	{
		return (0);
	}
	if (self.items & IT_QUAD)
	{
		if ((self.health + (self.armorvalue * self.armortype)) > 50)
		{
			return (0);
		}
	}
// xrp add
	if (XRP)
	if (self.health < 15)
	{
		if (runawayspeakchance <= 0.001)
		{
			bprint (self.netname);
			bprint (": I'm totally fucked!\n");
		}
		if ((runawayspeakchance <= 0.002) && (runawayspeakchance > 0.001))
		{
			bprint (self.netname);
			bprint (": Run Away!\n");
		}
		use_pkitem();
		return (1);
	}
	if (self.health < 45)
	{
		use_pkitem();
		return (1);
	}
	if (weap & ((IT_SHOTGUN + IT_AXE) + IT_NAILGUN))
	{
		if (self.enemy.items & IT_QUAD)
		{
// xrp add
	if (XRP)
			if (runawayspeakchance <= 0.1)
			{
				bprint (self.netname);
				bprint (": Run for it, ");
				bprint (self.enemy.netname);
				bprint (" has Quad Damage!\n");
			}
			use_pkitem();
			return (1);
		}
		if (self.enemy.weapon & ((IT_ROCKET_LAUNCHER + IT_LIGHTNING) + IT_SUPER_NAILGUN))
		{
			use_pkitem();
			return (1);
		}
	}
	if (self.lefty & MULTIENEMY)
	{
		if (self.health < 70)
		{
		if (XRP)
			if (runawayspeakchance <= 0.1)
			{
				bprint (self.netname);
				bprint (": help, tossed salads!");
			}
			use_pkitem();
			return (1);
		}
	}
	return (0);
};

void () BotHuntTarget =
{
	if (VERBOSEBOT)
	{
		dprint (self.teamname);
		dprint (self.netname);
		dprint (": Go kick ");
		dprint (self.enemy.teamname);
		dprint (self.enemy.netname);
		dprint ("'s ass!\n");
	}
	self.enemyrun = 0;
	self.strafetime = 0;
	if (self.lefty & ONTRAIN)
	{
		self.lefty = (self.lefty - ONTRAIN);
	}
	self.goalentity.goalentity = self.enemy;
	if (self.enemy.enemy == world)
	{
		self.enemy.enemy = self;
	}
	if (self.goalentity.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 2
#endifdef
		ai_botstand();
		return;
	}
	setorigin (self.goalentity,self.enemy.origin);
	self.think = self.th_run;
	self.strafeonly = 0;
	self.ideal_yaw = vectoyaw (self.enemy.origin - self.origin);
	self.lefty = ((self.lefty - (self.lefty & LOCAL_TIME)) + 6);
	self.nextthink = (time + 0.1);
	self.attack_finished = ((time + 0.7) - (0.2 * self.skil));
	self.search_time = (time + 7);
	clearCache (self);
	if (teamplay)
	{
		if (!HELPING)
		{
			CallForHelp ();
		}
	}
};

float () BotFoundTarget =
{
// xrp add
	local float huntspeakchance;
	huntspeakchance = random ();
	if (!XRP)
	if (!VERBOSEBOT)
	{
		huntspeakchance = 1;
	}
	if (huntspeakchance <= 0.010)
	{
		bprint (self.netname);
		if (self.netname == "M*nstAr") // 5.5.10 - Monstar mob msgs
		{
			bprint (": Prepare the transformation chamber Yesman!\n");
		}
		else if (self.netname == "Hard_ware")
		{
			bprint (": Right away boss...\n");
		}
		else if (self.netname == "Yesman")
		{
			bprint (": Chamber, Yes, transform, Yes, right away, Yes...\n");
		}
//		else if (self.netname == null_string)
//		{
//			bprint ("\n");
//		}
		else
		{
		if (self.netname == "Codename: blizzard")
			{
			bprint (": is it cold enough yet ");
			bprint (self.enemy.netname);
			bprint (" ?\n");
			}
		else if (self.netname == "Kill=death+die-dead")
			{
			bprint (": gonna solve your equation with 12, ");
			bprint (self.enemy.netname);
			bprint (" - 12 gauge that is!\n");
			}
		else
			{
			bprint (": I'm gonna make you my bitch ");
			bprint (self.enemy.netname);
			bprint ("!\n");
			}
		}
	}
	else if ((huntspeakchance <= 0.020) && (huntspeakchance > 0.010))
	{
		bprint (self.netname);
		if (self.netname == "M*nstAr")
		{
			bprint (": I'll get you for this Silverhawks!\n");
		}
		else if (self.netname == "Hard_ware")
		{
			bprint (": Look boss - a super sky shadow.\n");
		}
		else if (self.netname == "Yesman")
		{
			bprint (": Ooh, Yes boss, sure thing boss.\n");
		}
		else
		{
		if (self.netname == "Ray ---=>")
			{
			bprint (": visiting the Volcano God again ");
			bprint (self.enemy.netname);
			bprint (" ?\n");
			}
		else
			{
			bprint (": Don't Fuck with Daddy ");
			bprint (self.enemy.netname);
			bprint ("!\n");
			}
		}
	}
	else if ((huntspeakchance <= 0.030) && (huntspeakchance > 0.020))
	{
		bprint (self.netname);
		if (self.netname == "M*nstAr")
		{
			bprint (": Moonstar of Limbo, give me the muscles, the might, the menace of...M*NSTAR!\n");
		}
		else if (self.netname == "Hard_ware")
		{
			bprint (": The Silverhawks dont stand a chance, boss.\n");
		}
		else if (self.netname == "Yesman")
		{
			bprint (": Boss, we gotta get outa here.\n");
		}
		else
		{
		bprint (": Come meet my lil' friend ");
		bprint (self.enemy.netname);
		bprint ("!\n");
		}
	}
	else if ((huntspeakchance <= 0.040) && (huntspeakchance > 0.030))
	{
		bprint (self.netname);
		if (self.netname == "M*nstAr")
		{
			bprint (": Stargazer, I'll get you for this - no one puts M*nstar away...\n");
		}
		else if (self.netname == "Hard_ware")
		{
			bprint (": Its a freeze ray boss.\n");
		}
		else if (self.netname == "Yesman")
		{
			bprint (": No boss, er I mean Yes boss.\n");
		}
		else
		{
		bprint (": Looks like ");
		bprint (self.enemy.netname);
		if (random() < 0.4)
			bprint (" just shat himself!\n");
		else
			if (random() < 0.5)
				bprint (" is an empty headed animal food trough wiper!\n"); // Cat - 4.5.10 - Python mods
			else
				bprint (" will have to cut down the tallest tree in the forest with...a HERRING!\n"); // Cat - 5.5.10 - more python mods
		}
	}
	else if ((huntspeakchance <= 0.050) && (huntspeakchance > 0.040))
	{
		bprint (self.netname);
		if (self.netname == "M*nstAr")
		{
			bprint (": I'll make short work of you Silverhawks...\n");
		}
		else if (self.netname == "Hard_ware")
		{
			bprint (": I got it boss!\n");
		}
		else if (self.netname == "Yesman")
		{
			bprint (": It's super Yesman...Yes.\n");
		}
		else if (self.netname == "Ray ---=>")
		{
			bprint (": run faster ");
			bprint (self.enemy.netname);
			bprint ("!\n");
		}
		else
		{
		bprint (": ");
		bprint (self.enemy.netname);
		if (random() < 0.4)
			bprint (" has 5 rels to beg for mercy, Times up!\n");
		else
			bprint (" is going to be 6 feet under!\n");
		}
	}
	else if ((huntspeakchance <= 0.060) && (huntspeakchance > 0.050)) // Cat - unk date - Python mods
	{
		bprint (self.netname);
		bprint (": ");
		bprint (self.enemy.netname);
		if (random() < 0.5)
			bprint (" - Your mother was a hamster and your father smelt of elderberries!\n");
		else
			bprint (" - you got any cheese in that cheese shop?\n");
	}
	else if ((huntspeakchance <= 0.070) && (huntspeakchance > 0.060))
	{
		bprint (self.netname);
		bprint (": ");
		bprint (self.enemy.netname);
		if (random() < 0.5)
			bprint (" has got two empty halves of coconuts and is banging them together!\n");
		else
			bprint (" is the son of a silly person!\n");
	}
	if (self.enemy == world)
	{
		return (0);
	}
	if (teamplay)
	{
		if (self.enemy.team == self.team)
		{
			self.enemy = world;
			return (0);
		}
	}
	if (self.deadflag != DEAD_NO)
	{
		self.enemy = world;
		return (0);
	}
	if (self.enemy.deadflag != DEAD_NO)
	{
		self.enemy = world;
		return (0);
	}
	if ((self.enemy.classname != "player") && (self.enemy.classname != "pk*bot"))
	{
		self.enemy = world;
		return (0);
	}
	if (self.enemy == self)
	{
		self.enemy = world;
		return (0);
	}
	BotHuntTarget ();
	return (1);
};

void (entity en2) secondEnemy =
{
	if (self.enemy.classname != "player")
	{
		if (en2.classname == "player")
		{
			endEnemy ();
			self.enemy = en2;
			BotFoundTarget ();
			return ;
		}
	}
	if (!enemyvisible (self.enemy))
	{
		endEnemy ();
		self.enemy = en2;
		BotFoundTarget ();
	}
	if (en2.weapon & (IT_LIGHTNING + IT_ROCKET_LAUNCHER))
	{
		if (!(self.enemy.weapon & (IT_LIGHTNING + IT_ROCKET_LAUNCHER)))
		{
			endEnemy ();
			self.enemy = en2;
			BotFoundTarget ();
		}
	}
};

float () BotfindBot =
{
	local float n;
	local entity bots;
	if (!self.lastbot)
	{
		self.lastbot = find (world,classname,"pk*bot");
	}
	n = 4;
	while (n > 0)
	{
		n = (n - 1);
		bots = self.lastbot;
		if (!teamplay || (self.team != bots.team))
		{
			if (bots != self)
			{
				if (bots != self.enemy)
				{
					if (visible (bots))
					{
						if (bots.health > 0)
						{
							self.enemy = bots;
							return(BotFoundTarget ());
						}
					}
				}
			}
		}
		self.lastbot = find (bots,classname,"pk*bot");
		if (!self.lastbot)
		{
			self.lastbot = find (world,classname,"pk*bot");
		}
	}
	return (0);
};

float () BotFindTarget =
{
/// put hub start inv check here?
	if (inHubMap && self.invincible_finished > time)
	if (random() < 0.7) return(0);

	local entity client;
	local float len;
//	local float bw;
	client = checkclient ();
	if (!client)
	{
		return(BotfindBot ());
	}
	if (client.classname == OBSERVER)
	{
		return(BotfindBot ());
	}
	if (inHubMap && client.invincible_finished > time) // Cataboligne - 5.12.10 - on a hub and this enemy is invincible still
	if (random() < 0.9) return(0);

	if (client == self.enemy)
	{
		return (0);
	}
	if (teamplay)
	{
		if (self.team == client.team)
		{
			return(BotfindBot ());
		}
	}
	if (client.flags & FL_NOTARGET)
	{
		return(BotfindBot ());
	}
	if (!enemyvisible (client))
	{
		return(BotfindBot ());
	}
	if (!infrontofbot (client))
	{
		if (!hearnoise (client))
		{
			return(BotfindBot ());
		}
	}
	if ((self.origin_z > (client.origin_z + 120)) || ((self.origin_z + 120) < client.origin_z))
	{
		self.enemy = client;
		if (RunAway ())
		{
			self.enemy = world;
			return(BotfindBot ());
		}
	}
	if (client.items & IT_INVISIBILITY)
	{
		return(BotfindBot ());
	}
	if (self.skil < 1)
	{
		len = (random () * 100);
		if (len > 25)
		{
			return (0);
		}
	}
	self.enemy = client;
	return(BotFoundTarget ());
};

void () ai_botstand =
{
	if (BotFindTarget ())
	{
		return ;
	}
};

void () ai_botturn =
{
	if (BotFindTarget ())
	{
		return ;
	}
	ChangeYaw ();
};

void () aibot_run_melee =
{
	self.ideal_yaw = vectoyaw (self.enemy.origin - self.origin);
	ChangeYaw ();
	if (FacingIdeal ())
	{
		self.attack_state = AS_STRAIGHT;
		self.th_melee ();
	}
};

void (float dist, float turn) aibot_run_slide =
{
	local float ofs;
	local float rdir;
	local float rng;
	local float rnd;
	local float dis;
	local float trn;
	local float weap;
	trn = turn;
	self.ideal_yaw = vectoyaw (self.enemy.origin - self.origin);
	ChangeYaw ();
	ofs = 90;
	dis = dist;
	self.strafeonly = (self.strafeonly - 1);
	if (self.strafeonly > 0)
	{
		trn = NOTURN;
	}
	rdir = (random () * 3);
	rng = botrange (self.enemy);
	if (rng == RANGE_NEAR)
	{
		rdir = (rdir + 0.8);
	}
	else
	{
		if (rng == RANGE_MELEE)
		{
			rdir = (rdir + 1.2);
			rnd = random ();
			weap = W_BestHeldWeapon ();
			if (weap == IT_ROCKET_LAUNCHER)
			{
				rnd = 0;
			}
			else
			{
				if (weap == IT_GRENADE_LAUNCHER)
				{
					rnd = 0;
				}
				else
				{
					if (self.enemyrun > 4)
					{
						rnd = 1;
					}
					else
					{
						if (weap == IT_AXE)
						{
							rnd = 1;
						}
						else
						{
							if (self.enemy.weapon == IT_ROCKET_LAUNCHER)
							{
								rnd = 1;
							}
						}
					}
				}
			}
			if (rnd < 0.3)
			{
				if (botwalkmove ((self.ideal_yaw + 180),dis))
				{
					return ;
				}
			}
		}
		else
		{
			if (rng == RANGE_MID)
			{
				weap = W_BestHeldWeapon ();
				if (weap == IT_LIGHTNING)
				{
					rdir = (rdir - 3);
				}
				else
				{
					rdir = (rdir - 1);
				}
			}
			else
			{
				if (rng == RANGE_FAR)
				{
					rdir = (rdir - 2.5);
				}
			}
		}
	}
	if (self.weapon == IT_AXE)
	{
		rdir = 0;
	}
	else
	{
		if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			rdir = (rdir + 1.5);
		}
		else
		{
			if (self.weapon == IT_GRENADE_LAUNCHER)
			{
				rdir = (rdir + 1.5);
			}
		}
	}
	if (self.enemy.weapon == IT_ROCKET_LAUNCHER)
	{
		rdir = (rdir + 1.5);
	}
	else
	{
		if (self.enemy.weapon == IT_LIGHTNING)
		{
			rdir = (rdir + 1.5);
		}
	}
	if (self.enemyrun > 8)
	{
		rdir = (rdir - 2);
	}
	else
	{
		if (self.origin_z > (self.enemy.origin_z + 130))
		{
			rdir = ((rdir + 1.1) + random ());
			if (rdir >= 1.5)
			{
				trn = NOTURN;
			}
			if (self.weapon == IT_AXE)
			{
				trn = turn;
				rdir = 0;
			}
		}
	}
	if (rdir < 1.5)
	{
		if (trn == CANTURN)
		{
			Botmovetogoal (dis);
			return ;
		}
		if (botwalkmove (self.ideal_yaw,dis))
		{
			return ;
		}
		ofs = 90;
	}
	else
	{
		if (rdir < 2.4)
		{
			ofs = 45;
		}
	}
	if (self.skil == 0)
	{
		return ;
	}
	self.strafetime = (self.strafetime + 0.1);
	if (self.skil < 2)
	{
		if (self.skil < 1)
		{
			dis = (0.7 * dis);
		}
		if (self.strafetime == 0.1)
		{
			rnd = (random () * 4);
			if (self.skil >= TRUE)
			{
				rnd = ((rnd - self.skil) + 0.5);
			}
			if (rnd > self.skil)
			{
				self.strafetime = 0;
				return ;
			}
		}
	}
	if (self.strafetime > 0.4)
	{
		rnd = (random () * 2);
		if (rnd > 1.870)
		{
			if (self.lefty & STRAFE_DIR)
			{
				self.lefty = (self.lefty - STRAFE_DIR);
			}
			else
			{
				self.lefty = (self.lefty + STRAFE_DIR);
			}
			self.strafetime = 0;
			return ;
		}
	}
	if (self.lefty & STRAFE_DIR)
	{
		ofs = (-1* ofs);
	}
	if (botwalkmove ((self.ideal_yaw + ofs),dis))
	{
		return ;
	}
	self.strafetime = 0;
	if (self.lefty & STRAFE_DIR)
	{
		self.lefty = (self.lefty - STRAFE_DIR);
	}
	else
	{
		self.lefty = (self.lefty + STRAFE_DIR);
	}
	if ((ofs == 90) || (ofs == -90))
	{
		rnd = random ();
		if (rnd < 0.050)
		{
			if (trn == CANTURN)
			{
				Botmovetogoal (dis);
				return ;
			}
		}
		if (rnd < 0.5)
		{
			walkmove (self.ideal_yaw + 180, dis * 0.5);
		}
		return ;
	}
	botwalkmove (self.ideal_yaw,dis);
};

void (float dist) ai_botgetGoody;
void (float dist) ai_botcharge =
{
	local float rng;
	local float oldrng;
	if (self.lefty & GETGOODY)
	{
		ai_botgetGoody (dist);
		return ;
	}
	if (enemyvisible (self.enemy))
	{
		rng = vlen (self.enemy.origin - self.origin);
		oldrng = vlen (self.goalentity.origin - self.origin);
		if (self.goalentity.classname != "BotTarget")
		{
#ifdef warning
			if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 3
#endifdef
			
			ai_botstand();
			return;
		}
		setorigin (self.goalentity,self.enemy.origin);
		if (self.enemyrun > 0)
		{
			self.enemyrun = (self.enemyrun - 1);
		}
		if (rng > (oldrng + 10))
		{
			self.enemyrun = (self.enemyrun + 2);
		}
	}
	aibot_run_slide (dist,NOTURN);
};

void (float dist) ai_botnailcharge =
{
//	local float rnd;
	if (!enemyvisible (self.enemy))
	{
		self.think = self.th_run;
	}
	if (!FacingIdeal ())
	{
		self.think = self.th_run;
	}
	if (self.enemy.deadflag != DEAD_NO)
	{
		endEnemy ();
		return ;
	}
	ai_botcharge (dist);
};

float (float minweight) aibot_checkforGoodies;
void (float dist) ai_botrun =
{
//	local vector delta;
//	local float axis;
	local float rng;
	local float oldrng;
//	local float direct;
//	local float ang_rint;
//	local float ang_floor;
//	local float ang_ceil;
	if (self.enemy.deadflag != DEAD_NO)
	{
		endEnemy ();
		return ;
	}
	if (!self.enemy)
	{
		endEnemy ();
		return ;
	}
	if (self.lefty & GETGOODY)
	{
		ai_botgetGoody (dist);
		return ;
	}
	enemy_vis = enemyvisible (self.enemy);
	if (enemy_vis || Spotvisible (self.enemy))
	{
		rng = vlen (self.enemy.origin - self.origin);
		oldrng = vlen (self.goalentity.origin - self.origin);
		if (self.enemyrun > 0)
		{
			self.enemyrun = (self.enemyrun - 1);
		}
		if (rng > (oldrng + 10))
		{
			self.enemyrun = (self.enemyrun + 2);
		}
		if (self.goalentity.classname != "BotTarget")
		{
			eprint (self.goalentity);
#ifdef warning
			if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 4
#endifdef
			ai_botstand();
			return;
		}
		setorigin (self.goalentity,self.enemy.origin);
		self.search_time = (time + 7);
	}
	if (self.search_time < time)
	{
		endEnemy ();
		BotFindTarget ();
		return ;
	}
	if ((self.lefty & LOCAL_TIME) > 5)
	{
		self.lefty = (self.lefty - (self.lefty & LOCAL_TIME));
		self.lastseenpos = self.goalentity.origin;
		if (aibot_checkforGoodies (DONT_WANT))
		{
			ai_botgetGoody (dist);
			return ;
		}
	}
	self.lefty = (self.lefty + 1);
	if (RunAway ())
	{
		self.lefty = (self.lefty - (self.lefty & LOCAL_TIME));
		self.lastseenpos = self.goalentity.origin;
		if (aibot_checkforGoodies (DONT_WANT))
		{
			ai_botgetGoody (dist);
			return ;
		}
	}
	enemy_infront = infrontofbot (self.enemy);
	enemy_yaw = vectoyaw (self.enemy.origin - self.origin);
	if (!enemy_vis)
	{
		aibot_setupchase ();
		Botmovetogoal (dist);
		return ;
	}
	if (self.attack_state == AS_MELEE)
	{
		aibot_run_melee ();
	}
	CheckBotAttack ();
	aibot_run_slide (dist,CANTURN);
	return ;
};

void () aibot_setupchase =
{
	local entity pth;
	self.think = bot_chase;
	if (TrueReachable (self.goalentity))
	{
		return ;
	}
	if (RunAway ())
	{
		self.lefty = (self.lefty - (self.lefty & LOCAL_TIME));
		aibot_checkforGoodies (WANT - 1);
		self.lastseenpos = self.goalentity.origin;
		return ;
	}
	pth = BestChaseRoute (self,self.enemy);
	if (self.goalentity.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 1
#endifdef
		ai_botstand();
		return;
	}
	if (pth != self.enemy)
	{
		setorigin (self.goalentity,pth.origin);
	}
	self.search_time = (time + 6);
};

void (float dist) aibot_chase =
{
	local entity olden;
//	local float weap;
	local float rnd;
	if (self.enemy.deadflag != DEAD_NO)
	{
		endEnemy ();
		return ;
	}
	if (self.lefty & GETGOODY)
	{
		ai_botgetGoody (dist);
		return ;
	}
	enemy_vis = enemyvisible (self.enemy);
	rnd = random ();
	if (rnd < 0.9)
	{
		enemy_vis = enemy_vis;
	}
	if (enemy_vis)
	{
		if (self.goalentity.classname != "BotTarget")
		{
#ifdef warning
			if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 1
#endifdef
			ai_botstand();
			return;
		}
		setorigin (self.goalentity,self.enemy.origin);
		self.search_time = (time + 5);
		self.think = self.th_run;
		Botmovetogoal (dist);
		return ;
	}
	if (RunAway ())
	{
		if (self.search_time < time)
		{
			endEnemy ();
			return ;
		}
		self.lefty = (self.lefty - (self.lefty & LOCAL_TIME));
		if (aibot_checkforGoodies ((WANT - 1)))
		{
			ai_botgetGoody (dist);
			self.lastseenpos = self.goalentity.origin;
			return ;
		}
	}
	if (self.enemy.items & IT_INVISIBILITY)
	{
		if (self.skil < 3)
		{
			endEnemy ();
			return ;
		}
	}
	if ((self.lefty & LOCAL_TIME) > 5)
	{
		self.lastseenpos = self.goalentity.origin;
		self.lefty = (self.lefty - (self.lefty & LOCAL_TIME));
		if (aibot_checkforGoodies ((MUST_HAVE - 3)))
		{
			ai_botgetGoody (dist);
			return ;
		}
	}
	self.lefty = (self.lefty + 1);
	olden = self.enemy;
	if (BotFindTarget ())
	{
		if (olden.enemy == self)
		{
			olden.enemy = world;
		}
		return ;
	}
	if (self.search_time < time)
	{
		endEnemy ();
		return ;
	}
	if (CheckReboundAttack ())
	{
		return ;
	}
	Botmovetogoal (dist);
};

float (float minweight) aibot_checkforGoodies =
{
	local entity e;
	local entity botTarget;
	local float AFRAID;
//	local float steps;
	local float best;
	local float weight;
//	local float goody_yaw;
//	local float lnd;
//	local float weap;
	local float minimum;
//	local vector spot;
	if (self.air_finished < (time + 9))
	{
		goForAir ();
		self.lefty = (self.lefty | GETGOODY);
		self.goody_time = (time + 3);
		return (1);
	}
	AFRAID = RunAway ();
	botTarget = self.goalentity;
	e = findradius (self.origin,SEARCH_RADIUS);
	best = DONT_WANT;
	while (e)
	{
		weight = DONT_WANT;
		if (e.origin_z > (self.origin_z + (0.7 * MAXJUMP)))
		{
			weight = DONT_WANT;
		}
		else
		{
			if ((e.pathtype == DROPPED) || (e.pathtype == TELEPORT))
			{
				weight = DONT_WANT;
				if (AFRAID)
				{
					weight = RunAwayWeight (e);
				}
			}
			else
			{
				if (e.pathtype != REGULARTARGET)
				{
					weight = DONT_WANT;
	 			}
				else
				{
					if (e.solid != SOLID_TRIGGER)
					{
						weight = DONT_WANT;
					}
					else
					{
						if (!e.istrigger)
						{
							weight = itemweight (e);
							if (weight < MUST_HAVE)
							{
								if (((e.origin_z < self.enemy.absmin_z) && (e.origin_z < self.absmin_z)) && !AFRAID)
								{
									weight = DONT_WANT;
								}
							}
						}
					}
				}
			}
		}
		if (weight > best)
		{
			botTarget.goalentity = e;
			best = weight;
		}
		e = e.chain;
	}
	minimum = minweight;
	if (self.skil < 1)
	{
		if (minimum < (WANT + 2))
		{
			minimum = (WANT + 2);
		}
	}
	if (best > DONT_WANT)
	{
		if ((best > minimum) || AFRAID)
		{
			if (botTarget.classname != "BotTarget")
			{
#ifdef warning
				if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 6
#endifdef
				ai_botstand();
				return(0);
			}
			setorigin (botTarget,botTarget.goalentity.origin);
			self.lefty = (self.lefty | GETGOODY);
			self.goody_time = (time + 3);
			return (1);
		}
	}
	botTarget.goalentity = self.enemy;
	return (0);
};

void (float dist) ai_endgetGoody =
{
	if (self.lefty & GETGOODY)
	{
		self.lefty = (self.lefty - GETGOODY);
	}
	if (self.goalentity.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 7
#endifdef
		ai_botstand();
		return;
	}
	setorigin (self.goalentity,self.lastseenpos);
	self.goalentity.goalentity = self.enemy;
	if (enemyvisible (self.enemy))
	{
		self.lastseenpos = self.enemy.origin;
		if (self.attack_finished < time)
		{
			if (self.attack_state == AS_MELEE)
			{
				aibot_run_melee ();
			}
			CheckBotAttack ();
		}
	}
	Botmovetogoal (dist);
};

void (float dist) ai_botgetGoody =
{
	local float goody_yaw;
	local float dis;
	local float weap;
	self.search_time = (self.search_time + 0.1);
	if (time > self.goody_time)
	{
		ai_endgetGoody (dist);
		return ;
	}
	if (self.goalentity.goalentity.solid == SOLID_NOT)
	{
		ai_endgetGoody (dist);
		return ;
	}
	if (!Spotvisible (self.goalentity.goalentity))
	{
		if (self.air_finished > 9)
		{
			ai_endgetGoody (dist);
			return ;
		}
	}
	goody_yaw = vectoyaw (self.goalentity.origin - self.origin);
	if (enemyvisible (self.enemy))
	{
		self.lastseenpos = self.enemy.origin;
		weap = W_BestBotWeapon ();
		if (((self.enemy.items & IT_INVULNERABILITY) || (self.skil < 1)) || (weap == IT_AXE))
		{
			self.ideal_yaw = goody_yaw;
			ChangeYaw ();
		}
		else
		{
			if (self.attack_finished < time)
			{
				self.ideal_yaw = vectoyaw (self.enemy.origin - self.origin);
				ChangeYaw ();
				if (self.attack_state == AS_MELEE)
				{
					aibot_run_melee ();
				}
				CheckBotAttack ();
			}
		}
	}
	if (self.air_finished < 6)
	{
		waterupz (SVC_TEMPENTITY);
		return ;
	}
	if (self.flags & FL_SWIM)
	{
		if (waterupdown ())
		{
			return ;
		}
	}
	dis = vlen (self.origin - self.goalentity.origin);
	if (dis > dist)
	{
		dis = dist;
	}
	else
	{
		if (self.goalentity.goalentity.pathtype == DROPPED)
		{
			ai_endgetGoody (dist);
			return ;
		}
	}
	if (botwalkmove (goody_yaw,dis))
	{
		return ;
	}
	if (Bot_tryjump (270,dist,0))
	{
		return ;
	}
	if (self.lefty & GETGOODY)
	{
		self.lefty = (self.lefty - GETGOODY);
	}
	if (self.goalentity.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_ai.\n\n"); // 8
#endifdef
		ai_botstand();
		return;
	}
	setorigin (self.goalentity,self.lastseenpos);
	self.goalentity.goalentity = self.enemy;
};

