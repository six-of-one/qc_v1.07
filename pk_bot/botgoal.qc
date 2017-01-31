/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botgoal.qc
 *
 * date: Fri Apr  4 04:40:01 UTC 2008
 *
 * final qc
 *
 */


void (float dist) ai_botrun;
void () bot_chase;
void () bot_trigger1;
void () aibot_chooseGoal;
float () BotFindTarget;
void () shoottarget =
{
	local vector dir;
	local entity botTarget;
	botTarget = self.goalentity;
	bot_trigger1 ();
	sound (self,CHAN_WEAPON,"weapons/guncock.wav",TRUE,ATTN_NORM);
	dir = ((botTarget.goalentity.absmin + botTarget.goalentity.absmax) * 0.5);
	dir = normalize (dir - self.origin);
	FireBullets (MOVETYPE_TOSS,dir,'0.040 0.040 0');
	self.attack_finished = (time + 0.5);
	self.enemy = world;
	if (botTarget.goalentity.classname == "door")
	{
		self.search_time = (time + 8);
	}
};

void (float dist) ai_botseek =
{
	local entity botTarget;
	local vector dir;
	local float rng;
	local float oldrng;
	if (self.enemy)
	{
		aibot_setupchase ();
	}
	if (BotFindTarget ())
	{
		self.lefty = (self.lefty | FAR_SEEK);
		return ;
	}
	botTarget = self.goalentity;
	if (time < self.search_time)
	{
		if (botTarget.goalentity.classname == "train")
		{
			dir = ((botTarget.goalentity.absmin + botTarget.goalentity.absmax) * 0.5);
			dir_z = (botTarget.goalentity.absmax_z + 1);
			setorigin (botTarget,dir);
		}
		if (botTarget.goalentity.solid != SOLID_NOT)
		{
			oldrng = vlen (botTarget.origin - self.origin);
			Botmovetogoal (dist);
			rng = vlen (botTarget.origin - self.origin);
			if (rng >= oldrng)
			{
				self.search_time = (self.search_time - 0.4);
				if (botTarget.goalentity == botTarget)
				{
					self.search_time = time;
				}
			}
			return ;
		}
	}
	aibot_chooseGoal ();
	if (botTarget.goalentity.takedamage == DAMAGE_YES)
	{
		shoottarget ();
	}
	Botmovetogoal (dist);
};

float (entity e) thingweight =
{
	local float weight;
	local float OK_HIGH;
	local float recent;
	local float waittime;
	weight = DONT_WANT;
	OK_HIGH = 0;
	if (self.flags & FL_SWIM)
	{
		OK_HIGH = Swimto (e);
	}
	if (e.lastbot == self)
	{
		recent = (e.lasttime > (time - 8));
		if (!recent)
		{
			waittime = (time - (20* random ()));
			recent = (e.lasttime > waittime);
		}
		if (recent)
		{
			return(DONT_WANT);
		}
	}
	if (e.th_weight)
	{
		weight = e.th_weight (e);
	}
	else
	{
		e.pathtype = NEVERTARGET;
	}
	if (weight > DONT_WANT)
	{
		if (!OK_HIGH)
		{
			if (e.absmin_z > (self.origin_z + MAXJUMP))
			{
				weight = DONT_WANT;
			}
		}
	}
	return(weight);
};

float (entity e) trigweight =
{
	local float weight;
	weight = DONT_WANT;
	if (e.lastbot == self)
	{
		if (e.lasttime > (time - 8))
		{
			return(DONT_WANT);
		}
	}
	if (e.th_weight)
	{
		weight = e.th_weight (e);
	}
	else
	{
		e.pathtype = NEVERTARGET;
	}
	return(weight);
};

float (entity e) itemweight =
{
	local float weight;
	local float OK_HIGH;
	weight = DONT_WANT;
	OK_HIGH = 0;
	if (self.flags & FL_SWIM)
	{
		OK_HIGH = Swimto (e);
	}
	if (e.lastbot == self)
	{
		if (e.lasttime > (time - 5))
		{
			return(DONT_WANT);
		}
	}
	if (e.th_weight)
	{
		weight = e.th_weight (e);
	}
	else
	{
		e.pathtype = NEVERTARGET;
	}
	if (weight > DONT_WANT)
	{
		if (!OK_HIGH)
		{
			if (e.absmin_z > (self.origin_z + MAXJUMP))
			{
				weight = DONT_WANT;
			}
		}
	}
	if (weight > DONT_WANT)
	{
		if (!TrueReachable (e))
		{
			weight = DONT_WANT;
		}
	}
	return(weight);
};

vector (float n) chooseRoamTarget =
{
	local float len;
	local float r;
	local float d;
	local float m;
	local float lnd;
	local vector dir;
	local vector below;
	local vector bestorg;
	bestorg = self.origin;
	d = random ();
	if (d < 0.8)
	{
		r = random ();
		m = 1;
		if (r < 0.5)
		{
			m = -1;
		}
		bestorg_x = (bestorg_x + (m * ((700 * random ()) + 50)));
	}
	if (d > 0.2)
	{
		r = random ();
		m = 1;
		if (r < 0.5)
		{
			m = -1;
		}
		bestorg_y = (bestorg_y + (m * ((700 * random ()) + 50)));
	}
	bestorg_z = (((bestorg_z + ((3* MAXJUMP) * random ())) - (2* MAXJUMP)) - 1);
	traceline (self.origin,bestorg,TRUE,self);
	dir = normalize (bestorg - self.origin);
	len = vlen (bestorg - self.origin);
	bestorg = (self.origin + (dir * ((len * trace_fraction) - KINDA_WANT)));
	below = bestorg;
	below_z = (dropline (below) + 1);
	lnd = pointcontents (below);
	if (lnd != CONTENT_EMPTY)
	{
		if (lnd != CONTENT_WATER)
		{
			if (n < 7)
			{
				return(chooseRoamTarget (n + 1));
			}
		}
	}
	below = (bestorg - (30* dir));
	below_z = (dropline (below) + 1);
	lnd = pointcontents (below);
	if (lnd != CONTENT_EMPTY)
	{
		if (lnd != CONTENT_WATER)
		{
			if (n < 7)
			{
				return(chooseRoamTarget (n + 1));
			}
		}
	}
	r = (n + (random () * 3));
	if ((bestorg_z > self.origin_z) || (r > 5))
	{
		bestorg_z = (below_z - self.mins_z);
	}
	len = vlen (bestorg - self.origin);
	if (len < KINDA_WANT)
	{
		if (n < 7)
		{
			return(chooseRoamTarget (n + 1));
		}
	}
	return(bestorg);
};

float (entity e) cacheweight =
{
	local float weight;
	local float tw;
	local float dis;
	local float it;
	weight = 0;
	if (e.lastbot == self)
	{
		if (e.lasttime > (time - 2))
		{
			return(weight);
		}
	}
	dis = vlen (self.origin - e.origin);
	it = self.items;
	e.pendingcache = world;
	e.pendinglen = 0;
	if (e.rocketcache)
	{
		if ((e.rocketcache.solid == SOLID_TRIGGER) || (e.rocketcache.nextthink < (time + 4)))
		{
			if ((self.rocketcache != e.rocketcache) || (self.rocketlen > e.rocketlen))
			{
				weight = ((1000000 - e.rocketlen) - (2* dis));
				if (it & IT_ROCKET_LAUNCHER)
				{
					weight = (weight * 0.5);
				}
				e.pendingcache = e.rocketcache;
				e.pendinglen = e.rocketlen;
			}
		}
	}
	if (e.lightningcache)
	{
		if ((e.lightningcache.solid == SOLID_TRIGGER) || (e.lightningcache.nextthink < (time + 4)))
		{
			if ((self.lightningcache != e.lightningcache) || (self.lightninglen > e.lightninglen))
			{
				tw = ((1000000 - e.lightninglen) - (2* dis));
				if (it & IT_LIGHTNING)
				{
					tw = (tw * 0.5);
				}
				if (tw > weight)
				{
					weight = tw;
					e.pendingcache = e.lightningcache;
					e.pendinglen = e.lightninglen;
				}
			}
		}
	}
	if (self.armorvalue < 101)
	{
		if (e.armorcache)
		{
			if ((e.armorcache.solid == SOLID_TRIGGER) || (e.armorcache.nextthink < (time + 4)))
			{
				if ((self.armorcache != e.armorcache) || (self.armorlen > e.armorlen))
				{
					tw = ((1000000 - e.armorlen) - (2* dis));
					if (tw > weight)
					{
						weight = tw;
						e.pendingcache = e.armorcache;
						e.pendinglen = e.armorlen;
					}
				}
			}
		}
	}
	if (e.nailcache)
	{
		if ((e.nailcache.solid == SOLID_TRIGGER) || (e.nailcache.nextthink < (time + 2)))
		{
			if ((self.nailcache != e.nailcache) || (self.naillen > e.naillen))
			{
				tw = ((1000000 - e.naillen) - (2* dis));
				if (it & IT_SUPER_NAILGUN)
				{
					tw = (tw * 0.5);
				}
				if (tw > (weight + 2500))
				{
					weight = tw;
					e.pendingcache = e.nailcache;
					e.pendinglen = e.naillen;
				}
			}
		}
	}
	if (e.grenadecache)
	{
		if ((e.grenadecache.solid == SOLID_TRIGGER) || (e.grenadecache.nextthink < (time + 2)))
		{
			if ((self.grenadecache != e.grenadecache) || (self.grenadelen > e.grenadelen))
			{
				tw = ((1000000 - e.grenadelen) - (2* dis));
				if (it & IT_GRENADE_LAUNCHER)
				{
					tw = (tw * 0.5);
				}
				if (tw > (weight + 2500))
				{
					weight = tw;
					e.pendingcache = e.grenadecache;
					e.pendinglen = e.grenadelen;
				}
			}
		}
	}
	if (e.powerupcache)
	{
		if (e.powerupcache.solid == SOLID_TRIGGER)
		{
			if ((self.powerupcache != e.powerupcache) || (self.poweruplen > e.poweruplen))
			{
				tw = ((1000000 - e.poweruplen) - (2* dis));
				if (tw > weight)
				{
					weight = tw;
					e.pendingcache = e.powerupcache;
					e.pendinglen = e.poweruplen;
				}
			}
		}
	}
	return(weight);
};

float (entity e) pathweight =
{
//	local float OK_HIGH;
	local float weight;
	local vector org;
	weight = DONT_WANT;
	if (TrueReachable (e))
	{
		weight = cacheweight (e);
		if (weight > 0)
		{
			return(weight);
		}
		weight = vlen (self.origin - org);
		weight = ((50 * SEARCH_RADIUS) - weight);
		if (e.lastbot == self)
		{
			if (e.lasttime > (time - 6))
			{
				weight = DONT_WANT;
			}
			else
			{
				if (e.lasttime > (time - 20))
				{
					weight = ((weight - (2* SEARCH_RADIUS)) - (((45 * SEARCH_RADIUS) * ((20+ e.lasttime) - time)) / 20));
				}
			}
		}
		else
		{
			if (teamplay)
			{
				if (e.lastbot.team == self.team)
				{
					if (e.lasttime > (time - 1.2))
					{
						weight = DONT_WANT;
					}
					else
					{
						if (e.lasttime > (time - 2))
						{
							weight = (weight - SEARCH_RADIUS);
						}
					}
				}
			}
		}
	}
	return(weight);
};

void () goForAir =
{
	local vector bestorg;
	local entity botTarget;
	if (VERBOSEBOT)
	{
		dprint (self.teamname);
		dprint (self.netname);
		dprint (" needs air!\n");
	}
	bestorg = self.origin;
	bestorg_z = (bestorg_z + 800);
	traceline (self.origin,bestorg,TRUE,self);
	if (!trace_inopen)
	{
		bestorg = chooseRoamTarget (1);
		bestorg_z = (bestorg_z + 200);
	}
	botTarget = self.goalentity;
	botTarget.goalentity = botTarget;
	if (self.goalentity.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in botgoal - 1.\n\n");
#endifdef
		ai_botstand();
		return;
	}
	setorigin (botTarget,bestorg);
};

void (entity item) ageCache =
{
	if (self.rocketcache)
	{
		self.rocketlen = (self.rocketlen + 1);
	}
	if (self.lightningcache)
	{
		self.lightninglen = (self.lightninglen + 1);
	}
	if (self.armorcache)
	{
		self.armorlen = (self.armorlen + 1);
	}
	if (self.powerupcache)
	{
		self.poweruplen = (self.poweruplen + 1);
	}
	if (self.nailcache)
	{
		self.naillen = (self.naillen + 1);
	}
	if (self.grenadecache)
	{
		self.grenadelen = (self.grenadelen + 1);
	}
	if (item.solid == SOLID_TRIGGER)
	{
		if (self.rocketcache == item)
		{
			self.rocketlen = 1;
		}
		else
		{
			if (self.lightningcache == item)
			{
				self.lightninglen = 1;
			}
			else
			{
				if (self.armorcache == item)
				{
					self.armorlen = 1;
				}
				else
				{
					if (self.powerupcache == item)
					{
						self.poweruplen = 1;
					}
					else
					{
						if (self.nailcache == item)
						{
							self.naillen = 1;
						}
						else
						{
							if (self.grenadecache == item)
							{
								self.grenadelen = 1;
							}
						}
					}
				}
			}
		}
	}
};

void () resetCache =
{
	self.pendingcache = world;
	self.pendinglen = 0;
	if (self.rocketcache)
	{
		if (self.rocketcache.solid == SOLID_NOT)
		{
			self.rocketcache = world;
			self.rocketlen = 0;
		}
	}
	if (self.lightningcache)
	{
		if (self.lightningcache.solid == SOLID_NOT)
		{
			self.lightningcache = world;
			self.lightninglen = 0;
		}
	}
	if (self.armorcache)
	{
		if (self.armorcache.solid == SOLID_NOT)
		{
			self.armorcache = world;
			self.armorlen = 0;
		}
	}
	if (self.powerupcache)
	{
		if (self.powerupcache.solid == SOLID_NOT)
		{
			self.powerupcache = world;
			self.poweruplen = 0;
		}
	}
	if (self.nailcache)
	{
		if (self.nailcache.solid == SOLID_NOT)
		{
			self.nailcache = world;
			self.naillen = 0;
		}
	}
	if (self.grenadecache)
	{
		if (self.grenadecache.solid == SOLID_NOT)
		{
			self.grenadecache = world;
			self.grenadelen = 0;
		}
	}
};

void () updateBotCache =
{
	if (self.pendingcache.th_update)
	{
		self.pendingcache.th_update ();
	}
	else
	{
		dprint ("Error - no think update for ");
		dprint (self.pendingcache.classname);
		dprint ("\n");
	}
	self.pendingcache = world;
	self.pendinglen = 0;
};

void () aibot_chooseGoal =
{
	local vector org;
	local vector bestorg;
	local float best;
	local float weight;
	local float d1;
	local float d2;
	local float OK_NOTVIS;
	local entity e;
	local entity current;
	local entity botTarget;
//	local string tmp;
	botTarget = self.goalentity;
	if (self.lefty & FAR_SEEK)
	{
		self.lefty = ((self.lefty - (self.lefty & LOCAL_TIME)) - FAR_SEEK);
	}
	if (self.lefty & ONTRAIN)
	{
		self.lefty = (self.lefty - ONTRAIN);
	}
	self.lefty = (self.lefty + 1);
	current = botTarget.goalentity;
	self.search_time = (time + 4);
	best = DONT_WANT;
	OK_NOTVIS = 0;
	if (self.air_finished < (time + 9))
	{
		goForAir ();
		return ;
	}
	if ((self.lefty & LOCAL_TIME) < 5)
	{
		e = findradius (self.origin,SEARCH_RADIUS);
		while (e)
		{
			weight = DONT_WANT;
			if (e == current)
			{
				weight = DONT_WANT;
			}
			else
			{
				if (e.pathtype)
				{
					weight = DONT_WANT;
				}
				else
				{
					if (e.solid == SOLID_NOT)
					{
						weight = DONT_WANT;
					}
					else
					{
						if (e.solid == SOLID_TRIGGER)
						{
							if (e.istrigger)
							{
								weight = trigweight (e);
							}
							else
							{
								weight = itemweight (e);
							}
						}
						else
						{
							weight = thingweight (e);
						}
					}
				}
			}
			if (weight > (KINDA_WANT - 5))
			{
				if (weight < (WANT + 2))
				{
					if ((e.absmin_z + MAXJUMP) < self.absmin_z)
					{
						weight = (KINDA_WANT - 5);
					}
				}
			}
			if (weight > DONT_WANT)
			{
				org = ((e.absmin + e.absmax) * 0.5);
				org_z = (e.absmin_z + 1);
				if (((e.classname == "plat") || (e.classname == "func_plat")) || (e.classname == "train"))
				{
					org_z = (e.absmax_z + 1);
				}
				if (weight == best)
				{
					d1 = vlen (self.origin - bestorg);
					d2 = vlen (self.origin - org);
					weight = ((weight + (random () * 5)) - 2);
					if (d1 < d2)
					{
						weight = (weight - 1);
					}
					if (weight > best)
					{
						weight = best;
						best = (best - 1);
					}
				}
				if (weight > best)
				{
					botTarget.goalentity = e;
					best = weight;
					bestorg = org;
				}
			}
			e = e.chain;
		}
	}
	resetCache ();
	if (best < (KINDA_WANT - 3))
	{
		if (best > DONT_WANT)
		{
			best = (1000000 - 900);
		}
		e = findradius (self.origin,SEARCH_RADIUS);
		best = DONT_WANT;
		while (e)
		{
			if ((e.pathtype == DROPPED) || (e.pathtype == TELEPORT))
			{
				if (e == current)
				{
					weight = DONT_WANT;
				}
				else
				{
					weight = pathweight (e);
				}
				if (weight > best)
				{
					best = weight;
					botTarget.goalentity = e;
					self.pendingcache = e.pendingcache;
					self.pendinglen = e.pendinglen;
					bestorg = e.origin;
					if (!bestorg)
					{
						bestorg = ((e.absmin + e.absmax) * 0.5);
						bestorg_z = (e.absmin_z + 1);
					}
					self.lefty = (self.lefty | FAR_SEEK);
				}
			}
			e = e.chain;
		}
	}
	if (best > DONT_WANT)
	{
		if (self.pendingcache)
		{
			updateBotCache ();
		}
		else
		{
			if (botTarget.goalentity.classname != "BotPath")
			{
				ageCache (botTarget.goalentity);
			}
		}
	}
	if (best <= DONT_WANT)
	{
		botTarget.goalentity = botTarget;
		bestorg = chooseRoamTarget (0);
		self.lefty = (self.lefty | FAR_SEEK);
		self.search_time = (time + 2);
	}
	if (VERBOSEBOT)
	{
		dprint (self.teamname);
		dprint (self.netname);
		dprint (" going after ");
		dprint (botTarget.goalentity.classname);
		dprint ("\n");
	}
	if (botTarget.goalentity)
	{
		if (botTarget.goalentity != botTarget)
		{
			botTarget.goalentity.lastbot = self;
			botTarget.goalentity.lasttime = time;
		}
	}
	if (botTarget.goalentity.classname == "func_button")
	{
		bestorg = ((bestorg - botTarget.goalentity.pos2) - (32* normalize (botTarget.goalentity.pos2)));
	}
	if (botTarget.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in botgoal - 2.\n\n");
#endifdef
		ai_botstand();
		return;
	}
	setorigin (botTarget,bestorg);
};

float (entity e) RunAwayWeight =
{
	local float weight;
	if (!TrueReachable (e))
	{
		return (0);
	}
	traceline (self.enemy.origin + self.enemy.view_ofs, e. origin, TRUE, self.enemy);
	if (trace_fraction != TRUE)
	{
		weight = WANT;
	}
	if (trace_inopen && trace_inwater)
	{
		weight = (WANT - 5);
	}
	weight = (weight + (0.1 * vlen (self.enemy.origin - e.origin)));
	weight = (weight + (KINDA_WANT * random ()));
	return(weight);
};

void (entity en) RouteToEnemy;
entity (entity chaser, entity en) BestChaseRoute =
{
	local entity e;
	local entity p;
	local entity tmp;
	local float weight;
	local float best;
//	local string ts;
	RouteToEnemy (en);
	e = findradius (chaser.origin,SEARCH_RADIUS);
	best = 1000000;
	p = en;
	tmp = self;
	self = chaser;
	while (e)
	{
		if ((e.pathtype == DROPPED) || (e.pathtype == TELEPORT))
		{
			weight = 1000000;
			if (e.enemycache == en)
			{
				if (TrueReachable (e))
				{
					weight = (e.enemylen + (vlen (self.origin - e.origin)) * 0.5);
				}
			}
			if (weight < best)
			{
				best = weight;
				p = e;
			}
		}
		e = e.chain;
	}
	self = tmp;
	return(p);
};

