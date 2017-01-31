/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: bot_tally.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


// tally up things bots might want


float (entity e) doorweight =
{
	local float weight;
	weight = KINDA_WANT;
	if (e.owner.targetname)
	{
		weight = DONT_WANT;
	}
	else if (e.touch == secret_touch)
	{
		weight = KINDA_WANT;
	}
	else if (e.state == STATE_TOP)
	{
		weight = DONT_WANT;
	}
	else if (e.state == STATE_UP)
	{
		weight = KINDA_WANT;
	}
	if (!Spotvisible (e))
	{
		weight = DONT_WANT;
	}
	return(weight);
};

float (entity e) buttonweight =
{
	local float weight;
	weight = DONT_WANT;
	if (e.state == STATE_BOTTOM)
	if (Spotvisible (e))
	{
		weight = (KINDA_WANT + 1);
	}
	return(weight);
};

float (entity e) platweight =
{
	local float weight;
	weight = KINDA_WANT;
	if (!Platvisible (e))
	if (!Spotvisible (e))
	{
		weight = DONT_WANT;
	}
	return(weight);
};

float (entity e) trigpushweight =
{
	local float weight;
	local vector spot;
	local vector org;
	weight = DONT_WANT;
	org = ((e.absmin + e.absmax) * 0.5);
	org_z = (e.absmin_z + 1);
	spot = org;
	spot_z = self.origin_z;
	traceline (self.origin,spot,TRUE,self);
	if (trace_fraction == 1)
	{
		traceline (spot,org,TRUE,self);
		if (trace_fraction == 1)
		{
			spot_z = dropline (org);
			if (self.absmin_z > spot_z)
			{
				spot_z = self.absmin_z;
			}
			if (org_z < (((self.maxs_z - self.mins_z) + spot_z) + MAXJUMP))
			{
				weight = KINDA_WANT;
			}
		}
	}
	return(weight);
};

float (entity e) triggerweight =
{
	local float weight;
	local float rnd;
	weight = (KINDA_WANT - 2);
	rnd = random ();
//	if (PK)
	if (e.classname == "hub_teleport")
	if (world.message == "hub") // *pk - bots need to see hub portals when on hub
	if (self.map == null_string)
	{
//		return(WANT * 2);
		return(MUST_HAVE);
	}
	if (rnd < 0.250)
	{
		weight = WANT;
	}
	if (!Spotvisible (e))
	{
		weight = DONT_WANT;
	}
	return(weight);
};

float (entity e) backpackweight =
{
	local float lnd;
	local float weight;
	weight = WANT;
	lnd = pointcontents (e.absmin + '0 0 1');
	if (e.items & (IT_ROCKET_LAUNCHER + IT_LIGHTNING))
	{
		weight = (MUST_HAVE - 1);
	}
	if ((lnd == CONTENT_LAVA) || (lnd == CONTENT_SLIME))
	{
		weight = DONT_WANT;
	}
	return(weight);
};

float (entity e) healthweight =
{
	local float weight;
	weight = WANT;
	if (self.health < 60)
	{
		weight = (MUST_HAVE - 1);
	}
	else if (e.healtype == HEAL_MEGA || e.healtype == HEAL_SOUL)
	{
		weight = MUST_HAVE;
	}
	else if (self.health > 99)
	{
		weight = DONT_WANT;
	}
	return(weight);
};

float () nailweight =
//float (entity e) nailweight =
{
	local float weight;
	weight = (WANT - 1);
	if (self.ammo_nails > 199)
	{
		weight = DONT_WANT;
	}
	else
	{
		if (self.ammo_nails > 120)
		{
			weight = (KINDA_WANT - 2);
		}
	}
	return(weight);
};

//float (entity e) shellweight =
float () shellweight =
{
	local float weight;
	weight = (WANT - 1);
	if (self.ammo_shells > 99)
	{
		weight = DONT_WANT;
	}
	else
	{
		if (self.ammo_shells > 50)
		{
			weight = (KINDA_WANT - 2);
		}
	}
	return(weight);
};

//float (entity e) cellweight =
float () cellweight =
{
	local float weight;
	weight = WANT;
	if (self.ammo_cells > 99)
	{
		weight = DONT_WANT;
	}
	return(weight);
};

//float (entity e) rocketweight =
float () rocketweight =
{
	local float weight;
	weight = WANT;
	if (self.ammo_rockets > 99)
	{
		weight = DONT_WANT;
	}
	return(weight);
};

//float (entity e) rlauncherweight =
float () rlauncherweight =
{
	local float weight;
	weight = (WANT + 2);
	if (!(self.items & IT_ROCKET_LAUNCHER))
	{
		weight = MUST_HAVE;
	}
	return(weight);
};

//float (entity e) lightningweight =
float () lightningweight =
{
	local float weight;
	weight = (WANT + 2);
	if (!(self.items & IT_LIGHTNING))
	{
		weight = MUST_HAVE;
	}
	return(weight);
};

//float (entity e) glauncherweight =
float () glauncherweight =
{
	local float weight;
	weight = (WANT + 1);
	if (!(self.items & IT_GRENADE_LAUNCHER))
	{
		weight = (MUST_HAVE - 1);
	}
	return(weight);
};

//float (entity e) nailgunweight =
float () nailgunweight =
{
	return(WANT);
};

//float (entity e) supernailweight =
float () supernailweight =
{
	local float weight;
	weight = (WANT + 1);
	if (!(self.items & IT_SUPER_NAILGUN))
	{
		weight = (MUST_HAVE - 1);
	}
	return(weight);
};

//float (entity e) ssgweight =
float () ssgweight =
{
	return(WANT);
};

float (entity e) armorweight =
{
	local float weight;
	weight = (e.armorvalue - self.armorvalue);
	return(weight);
};

float (entity e) artifactweight =
{
	local float weight;
	weight = (MUST_HAVE + 2);
	if (e.classname == "item_artifact_envirosuit")
	{
		weight = WANT;
	}
	return(weight);
};

float (entity node, float len, entity item) cacherocket =
{
	if (node.rocketlen > 0)
	{
		if (len >= node.rocketlen)
		{
			return (0);
		}
	}
	node.rocketlen = len;
	node.rocketcache = item;
	return (1);
};

float (entity node, float len, entity item) cachelightning =
{
	if (node.lightninglen > 0)
	{
		if (len >= node.lightninglen)
		{
			return (0);
		}
	}
	node.lightninglen = len;
	node.lightningcache = item;
	return (1);
};

float (entity node, float len, entity item) cachearmor =
{
	if (node.armorlen > 0)
	{
		if (len >= node.armorlen)
		{
			return (0);
		}
	}
	node.armorlen = len;
	node.armorcache = item;
	return (1);
};

float (entity node, float len, entity item) cachenail =
{
	if (node.naillen > 0)
	{
		if (len >= node.naillen)
		{
			return (0);
		}
	}
	node.naillen = len;
	node.nailcache = item;
	return (1);
};

float (entity node, float len, entity item) cachegrenade =
{
	if (node.grenadelen > 0)
	{
		if (len >= node.grenadelen)
		{
			return (0);
		}
	}
	node.grenadelen = len;
	node.grenadecache = item;
	return (1);
};

float (entity node, float len, entity item) cachepowerup =
{
	if (node.poweruplen > 0)
	{
		if (len >= node.poweruplen)
		{
			return (0);
		}
	}
	node.poweruplen = len;
	node.powerupcache = item;
	return (1);
};

float (entity node, float len, entity item) cacheenemy =
{
	if (node.enemylen > 0)
	{
		if (len >= node.enemylen)
		{
			return (0);
		}
	}
	node.enemylen = len;
	node.enemycache = item;
	return (1);
};

void () updaterocket =
{
	self.rocketcache = self.pendingcache;
	self.rocketlen = self.pendinglen;
};

void () updatelightning =
{
	self.lightningcache = self.pendingcache;
	self.lightninglen = self.pendinglen;
};

void () updatearmor =
{
	self.armorcache = self.pendingcache;
	self.armorlen = self.pendinglen;
};

void () updatepowerup =
{
	self.powerupcache = self.pendingcache;
	self.poweruplen = self.pendinglen;
};

void () updatenail =
{
	self.nailcache = self.pendingcache;
	self.naillen = self.pendinglen;
};

void () updategrenade =
{
	self.grenadecache = self.pendingcache;
	self.grenadelen = self.pendinglen;
};

////float (entity e) dont_weight =
float () dont_weight =
{
	return(DONT_WANT);
};



