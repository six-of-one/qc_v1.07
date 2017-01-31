/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botroute.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


void () t_botpath =
{
	if (other.classname != "pk*bot")
	{
		return ;
	}
	if (other.movetarget == self)
	{
		return ;
	}
	bot_toucheditem ();
	addTarget (other.movetarget.movetarget,self);
	other.movetarget.movetarget = self;
};

entity () botpath =
{
	local entity targ;
	targ = spawn ();
	targ.classname = "BotPath";
	targ.flags = 0;
	targ.solid = SOLID_TRIGGER;
	targ.movetarget = world;
	targ.touch = t_botpath;
	setsize (targ,'-4 -4 -4','4 4 4');
	return(targ);
};

float (entity a, entity b) IsUpstream =
{
	if (b.movetarget == a)
	{
		return (1);
	}
	if (b.movetarget2 == a)
	{
		return (1);
	}
	if (b.movetarget3 == a)
	{
		return (1);
	}
	if (b.movetarget4 == a)
	{
		return (1);
	}
	if (b.movetarget5 == a)
	{
		return (1);
	}
	if (b.movetarget6 == a)
	{
		return (1);
	}
	return (0);
};

float sf_cacheRoute;

void (entity node, entity targ, float len, entity item) cacheRouteTarget;
void (entity a, entity b, float recurse) updateRouteCache =
{
	RECURSEDEPTH = recurse;
	if (b.rocketlen > 0)
	{
		cacheRouteTarget (b,a,b.rocketlen,b.rocketcache);
	}
	if (b.lightninglen > 0)
	{
		cacheRouteTarget (b,a,b.lightninglen,b.lightningcache);
	}
	if (b.armorlen > 0)
	{
		cacheRouteTarget (b,a,b.armorlen,b.armorcache);
	}
	if (b.poweruplen > 0)
	{
		cacheRouteTarget (b,a,b.poweruplen,b.powerupcache);
	}
	if (b.naillen > 0)
	{
		cacheRouteTarget (b,a,b.naillen,b.nailcache);
	}
	if (b.grenadelen > 0)
	{
		cacheRouteTarget (b,a,b.grenadelen,b.grenadecache);
	}
};

void (entity a, entity b) addTarget =
{
	sf_cacheRoute = 5000; // Cataboligne - 5.11.10 - prevent infinite loop in recursive calls

	if (a == b)
	{
		return ;
	}
	if (b.movetarget == a)
	{
		return ;
	}
	if (!a)
	{
		return ;
	}
	else
	{
		if (b.movetarget2 == a)
		{
			updateRouteCache (a,b,16);
			return ;
		}
		else
		{
			if (b.movetarget3 == a)
			{
				updateRouteCache (a,b,16);
				return ;
			}
			else
			{
				if (b.movetarget4 == a)
				{
					updateRouteCache (a,b,16);
					return ;
				}
				else
				{
					if (b.movetarget5 == a)
					{
						updateRouteCache (a,b,16);
						return ;
					}
					else
					{
						if (b.movetarget6 == a)
						{
							updateRouteCache (a,b,16);
							return ;
						}
					}
				}
			}
		}
	}
	if (!b.movetarget)
	{
		b.movetarget = a;
	}
	else
	{
		if (!b.movetarget2)
		{
			b.movetarget2 = a;
		}
		else
		{
			if (!b.movetarget3)
			{
				b.movetarget3 = a;
			}
			else
			{
				if (!b.movetarget4)
				{
					b.movetarget4 = a;
				}
				else
				{
					if (!b.movetarget5)
					{
						b.movetarget5 = a;
					}
					else
					{
						if (!b.movetarget6)
						{
							b.movetarget6 = a;
						}
					}
				}
			}
		}
	}
	updateRouteCache (a,b,10);
};

float () FindAPath;
float () FindAltPath =
{
	local entity e;
	local entity carriedPath;
	local entity bestPath;
	local float dropPath;
	local float bestrng;
	local float rng;
	if (self.lefty & NODROP)
	{
		self.lefty = (self.lefty - NODROP);
		return(FindAPath ());
	}
	e = findradius (self.origin,SEARCH_RADIUS);
	bestrng = 1000;
	dropPath = 1;
	carriedPath = self.movetarget;
	bestPath = carriedPath.movetarget;
	while (e)
	{
		if (e.pathtype == DROPPED)
		{
			rng = vlen (e.origin - self.origin);
			if (rng < bestrng)
			{
				if (BotReachable (e,self))
				{
					if (BotReachable (carriedPath.movetarget,e))
					{
						addTarget (carriedPath.movetarget,e);
						bestPath = e;
						bestrng = rng;
						dropPath = 0;
					}
				}
			}
		}
		e = e.chain;
	}
	carriedPath.movetarget = bestPath;
	return(dropPath);
};

float () FindAPath =
{
	local float dropPath;
	local float bestrng;
	local float rng;
	local entity e;
	local entity carriedPath;
	local entity bestPath;
	carriedPath = self.movetarget;
	dropPath = 1;
	e = findradius (self.origin,SEARCH_RADIUS);
	bestrng = 1000;
	bestPath = carriedPath.movetarget;
	while (e)
	{
		if (e.pathtype == DROPPED)
		{
			rng = vlen (e.origin - self.origin);
			if (rng < bestrng)
			{
				if (BotReachable (e,self))
				{
					addTarget (carriedPath.movetarget,e);
					bestPath = e;
					bestrng = rng;
					dropPath = 0;
				}
			}
		}
		e = e.chain;
	}
	carriedPath.movetarget = bestPath;
	return(dropPath);
};

float () CheckDropPath =
{
	local entity carriedPath;
	local entity upstreamPath;
	local float rng;
	local float lnd;
//	local float OK_HIGH;
//	local string tmp;
// this is a fix point if overflow occurs with waypoints - fix by reducing 160
	if (NUMPATHS > 160)
	{
		return (0);
	}
	if (self.classname == OBSERVER)
	{
		return (0);
	}

// dont answer TRUE to path drop that will be out of bounds
	if (noway_below)
	if (self.origin_z < noway_below) return (0);
	if (noway_above)
	if (self.origin_z > noway_above) return (0);

	carriedPath = self.movetarget;
	upstreamPath = carriedPath.movetarget;
	lnd = pointcontents (carriedPath.origin);
	if (lnd == CONTENT_EMPTY)
	{
		rng = dropline (carriedPath.origin);
		if (rng < (carriedPath.origin_z - SVC_FOUNDSECRET))
		{
			if (!(carriedPath.flags & (FL_ONGROUND + 16)))
			{
				return (0);
			}
		}
		lnd = pointcontents ((carriedPath.origin + self.mins) + '0 0 1');
		if (lnd != CONTENT_EMPTY)
		{
			if (lnd != CONTENT_WATER)
			{
				self.lefty = (self.lefty | NODROP);
				return (0);
			}
		}
	}
	else
	{
		if (lnd != CONTENT_WATER)
		{
			self.lefty = (self.lefty | NODROP);
			return (0);
		}
	}
	if ((trace_ent.classname == "plat") || (trace_ent.classname == "train"))
	{
		if (trace_ent.think)
		{
			self.lefty = (self.lefty | NODROP);
			return (0);
		}
	}
	if (self.teleport_time > time)
	{
		self.lefty = (self.lefty | NODROP);
		if (self.teleport_time > (time + 0.5))
		{
			return (0);
		}
		if (self.lefty & NODROP)
		{
			self.lefty = (self.lefty - NODROP);
		}
		return(FindAPath ());
	}
	if (!upstreamPath)
	{
		return(FindAPath ());
	}
	if (!BotReachable (upstreamPath,self))
	{
		if (upstreamPath.origin_z > (self.origin_z + MAXJUMP))
		{
			return(FindAPath ());
		}
		return(FindAltPath ());
	}
	return (0);
};

void () NewCarriedPath =
{

// dont make paths out of bounds
	if (noway_below)
	if (self.origin_z < noway_below) return;
	if (noway_above)
	if (self.origin_z > noway_above) return;

	self.movetarget = botpath ();
	self.movetarget.pathtype = CARRIED;
	setorigin (self.movetarget,self.origin);
};

void () DropBotPath =
{
//	local string tmp;
	local entity oldpath;
	local float drop;
	if (self.classname == OBSERVER)
	{
		return;
	}

	if (noway_below)
	if (self.origin_z < noway_below) return;
	if (noway_above)
	if (self.origin_z > noway_above) return;

	oldpath = self.movetarget;
	if (oldpath.movetarget)
	{
		if (oldpath.origin_z > ((oldpath.movetarget.origin_z + (MAXJUMP * 0.6)) - 1))
		{
			drop = (((oldpath.movetarget.origin_z - oldpath.origin_z) + (MAXJUMP * 0.6)) - 1);
			if (drop < (self.mins_z + 2))
			{
				drop = (self.mins_z + 2);
			}
			oldpath.origin_z = (oldpath.origin_z + drop);
		}
	}
	NewCarriedPath ();
	oldpath.pathtype = DROPPED;
	self.movetarget.movetarget = oldpath;
	NUMPATHS = (NUMPATHS + 1);
};

void (entity node, float len, entity item) cacheRouteMsg;
void (entity node, entity targ, float len, entity item) cacheRouteTarget =
{
	local float rng;
	rng = vlen (node.origin - targ.origin);
	if (targ.pathtype == TELEPORT)
	{
		rng = 250;
	}
	rng = ((rng + len) + 20);
	RECURSEDEPTH = (RECURSEDEPTH + 2);
	if (RECURSEDEPTH < 24)
	{
		cacheRouteMsg (targ,rng,item);
	}
	else
	{
		node.endpoint = 1;
	}
	RECURSEDEPTH = (RECURSEDEPTH - 2);
};

void (entity node, entity targ, float len, entity item) cacheRoute =
{
	RECURSEDEPTH = 1;
	cacheRouteTarget (node,targ,len,item);
	if (other.classname == "pk*bot")
	{
		if (other.rocketcache == item)
		{
			clearCache (other);
		}
		else
		{
			if (other.lightningcache == item)
			{
				clearCache (other);
			}
			else
			{
				if (other.armorcache == item)
				{
					clearCache (other);
				}
				else
				{
					if (other.powerupcache == item)
					{
						clearCache (other);
					}
					else
					{
						if (other.nailcache == item)
						{
							clearCache (other);
						}
						else
						{
							if (other.grenadecache == item)
							{
								clearCache (other);
							}
						}
					}
				}
			}
		}
	}
};

void (entity node, float len, entity item) cacheRouteMsg =
{
	sf_cacheRoute = sf_cacheRoute - 1; // Cataboligne - 5.11.10 - prevent recursive loop
	if (sf_cacheRoute < 1)
	{
		if (sf_cacheRoute == 0) bprint("\n*** Warning: pk*bot cacheRoute recursive loop hit 5000.\n\n");
		return;
	}
	
	if (item.th_cache)
	{
		if (!item.th_cache (node,len,item))
		{
			return ;
		}
	}
	else
	{
		return ;
	}
	if (node.movetarget)
	{
		cacheRouteTarget (node,node.movetarget,len,item);
	}
	if (node.movetarget2)
	{
		cacheRouteTarget (node,node.movetarget2,len,item);
	}
	if (node.movetarget3)
	{
		cacheRouteTarget (node,node.movetarget3,len,item);
	}
	if (node.movetarget4)
	{
		cacheRouteTarget (node,node.movetarget4,len,item);
	}
	if (node.movetarget5)
	{
		cacheRouteTarget (node,node.movetarget5,len,item);
	}
	if (node.movetarget6)
	{
		cacheRouteTarget (node,node.movetarget6,len,item);
	}
};

void (entity e) clearCache =
{
	e.rocketcache = world;
	e.lightningcache = world;
	e.armorcache = world;
	e.nailcache = world;
	e.grenadecache = world;
	e.powerupcache = world;
	e.rocketlen = 0;
	e.lightninglen = 0;
	e.armorlen = 0;
	e.naillen = 0;
	e.grenadelen = 0;
	e.poweruplen = 0;
	e.endpoint = 0;
};

void (entity en) RouteToEnemy =
{
	local entity e;
	RECURSEDEPTH = 8;
	e = find (world,classname,"BotPath");
	while (e)
	{
		e.enemycache = world;
		e.endpoint = 0;
		e = find (e,classname,"BotPath");
	}
	if (en.movetarget)
	{
		if (en.movetarget.movetarget)
		{
			cacheRouteTarget (en.movetarget,en.movetarget.movetarget,0,en);
			e = find (world,classname,"BotPath");
			while (e)
			{
				if (e.endpoint)
				{
					if (e.enemycache == en)
					{
						RECURSEDEPTH = 8;
						if (e.movetarget)
						{
							cacheRouteTarget (e,e.movetarget,e.enemylen,en);
						}
						if (e.movetarget2)
						{
							cacheRouteTarget (e,e.movetarget2,e.enemylen,en);
						}
						if (e.movetarget3)
						{
							cacheRouteTarget (e,e.movetarget3,e.enemylen,en);
						}
						if (e.movetarget4)
						{
							cacheRouteTarget (e,e.movetarget4,e.enemylen,en);
						}
						if (e.movetarget5)
						{
							cacheRouteTarget (e,e.movetarget5,e.enemylen,en);
						}
						if (e.movetarget6)
						{
							cacheRouteTarget (e,e.movetarget6,e.enemylen,en);
						}
					}
				}
				e = find (e,classname,"BotPath");
			}
		}
	}
};

