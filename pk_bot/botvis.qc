/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botvis.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


float (entity targ) botrange =
{
	local vector spot1;
	local vector spot2;
	local float mel;
	local float r;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	r = vlen (spot1 - spot2);
	mel = ((180 - (self.health * 0.5)) - (self.armorvalue * self.armortype));
	if (self.items & IT_QUAD)
	{
		mel = (2* mel);
	}
	if (teamplay == 1)
	{
		mel = 60;
	}
	if (r < mel)
	{
		return(RANGE_MELEE);
	}
	else if (r < SEARCH_RADIUS)
	{
		return(RANGE_NEAR);
	}
	else if (r < 1000)
	{
		return(RANGE_MID);
	}
	return(RANGE_FAR);
};

float (entity targ) infrontofbot =
{
	local vector vec;
	local vector xydir;
	local float fov;
	local float dot;
	local float lnd;
	if (self.skil == 3)
	{
		return (1);
	}
	lnd = pointcontents (self.origin + self.view_ofs);
	if (lnd != CONTENT_WATER)
	{
		if (self.skil < 2)
		{
			xydir = (targ.origin - self.origin);
			xydir_z = 0;
			dot = vlen (xydir);
			fov = ((targ.origin_z - self.origin_z) * (2- (0.750 * self.skil)));
			if (fov < 0)
			{
				fov = (-0.8 * fov);
			}
			if ((fov > 150) && (dot < fov))
			{
				return (0);
			}
		}
	}
	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = (vec * v_forward);
	fov = (0.7 - (self.skil * 0.280));
	if (dot > fov)
	{
		return (1);
	}
	if (lnd == CONTENT_WATER)
	{
		if (dot > 0)
		{
			return (1);
		}
	}
	return (0);
};

float (entity targ) Swimto =
{
	local vector spot1;
	local vector spot2;
	local float lnd;
	spot1 = (self.origin + self.view_ofs);
	spot2 = targ.absmin;
	lnd = pointcontents (spot2);
	if (lnd != CONTENT_WATER)
	{
		if (spot2_z > (spot1_z + MAXJUMP))
		{
			return (0);
		}
	}
	traceline (spot1,spot2,TRUE,self);
	if (trace_fraction == 1)
	{
		return (1);
	}
	if (trace_ent == targ)
	{
		return (1);
	}
	return (0);
};

float (entity targ) Spotvisible =
{
	local vector spot1;
	local vector spot2;
	local string t1;
	spot1 = (self.origin + self.view_ofs);
	spot2 = ((targ.absmin + targ.absmax) * 0.5);
	traceline (spot1,spot2,TRUE,self);
	if (trace_fraction == 1)
	{
		return (1);
	}
	if (trace_ent == targ)
	{
		return (1);
	}
	return (0);
};

float (entity targ) enemyvisible =
{
	local vector spot1;
	local vector spot2;
	if (visible (targ))
	{
		return (1);
	}
	spot1 = (self.origin + self.view_ofs);
	spot2 = targ.origin;
	traceline (spot1,spot2,TRUE,self);
	if (trace_inopen && trace_inwater)
	{
		return (0);
	}
	if (trace_fraction == 1)
	{
		return (1);
	}
	return (0);
};

float (entity targ) Platvisible =
{
	local vector spot1;
	local vector spot2;
	local string t1;
	spot1 = (self.origin + self.view_ofs);
	spot2 = ((targ.absmin + targ.absmax) * 0.5);
	spot2_z = (targ.absmax_z + 3);
	traceline (spot1,spot2,TRUE,self);
	if (trace_fraction == 1)
	{
		return (1);
	}
	if (trace_ent == targ)
	{
		return (1);
	}
	return (0);
};

float (vector spot) dropline =
{
	local float drop;
	local vector spot2;
	local string tmp;
	spot2 = spot;
	spot2_z = (spot2_z - 500);
	traceline (spot,spot2,TRUE,self);
	drop = (spot_z - (trace_fraction * 500));
	return(drop);
};

float (entity a, entity b, float bmaxjump) BotWalkable =
{
	local vector spot1;
	local vector dir;
	local vector borg;
	local float tests;
	local float okpath;
	local float flr;
	local float goalheight;
	if (b.pathtype != DROPPED)
	{
		borg = ((b.absmin + b.absmax) * 0.5);
		borg_z = (b.absmin_z + 1);
	}
	else
	{
		borg = b.origin;
	}
	spot1 = a.origin;
	dir = normalize (borg - a.origin);
	dir = (((dir * LEVELJUMPTIME) * BOTSPEED) * 6.5);
	tests = vlen (borg - a.origin);
	tests = (tests / ((LEVELJUMPTIME * BOTSPEED) * 6.5));
	if (b.pathtype == DROPPED)
	{
		goalheight = (borg_z + self.mins_z);
	}
	else
	{
		goalheight = borg_z;
	}
	while (tests > 1)
	{
		okpath = 1;
		spot1 = (spot1 + dir);
		tests = (tests - 1);
		flr = dropline (spot1);
		if ((flr + bmaxjump) < goalheight)
		{
			spot1 = (spot1 - (dir * 0.5));
			flr = dropline (spot1);
			if ((flr + bmaxjump) < goalheight)
			{
				okpath = 0;
			}
			spot1 = (spot1 + dir);
			tests = (tests - 0.5);
			flr = dropline (spot1);
			if ((flr + bmaxjump) < goalheight)
			{
				if (!okpath)
				{
					return (0);
				}
				spot1 = (spot1 + (dir * 0.5));
				tests = (tests - 0.5);
				flr = dropline (spot1);
				if ((flr + bmaxjump) < goalheight)
				{
					return (0);
				}
			}
		}
	}
	return (1);
};

float (entity a, entity b) IsUpstream;
float (entity a, entity b, float truereach) Reachable =
{
	local vector spot1;
	local vector spot2;
	local vector borg;
	local float lnd;
	local float vel;
	local float diffz;
	local float diffxy;
	local float rng;
	local float maxzd;
	local float bmaxjump;
//	local float brad;
//	local string tmp;
	if (truereach)
	{
		bmaxjump = MAXJUMP;
	}
	else
	{
		bmaxjump = (0.6 * MAXJUMP);
	}
	if (b.pathtype != DROPPED)
	{
		borg = ((b.absmin + b.absmax) * 0.5);
		borg_z = (b.absmin_z + 1);
	}
	else
	{
		if (a.pathtype == DROPPED)
		{
			if (IsUpstream (a,b))
			{
				return (1);
			}
		}
		borg = b.origin;
	}
	spot1 = a.origin;
	spot2 = borg;
	if (b.pathtype != DROPPED)
	{
		spot2_z = ((b.absmin_z + b.absmax_z) * 0.5);
	}
	rng = vlen (spot2 - spot1);
	if (truereach)
	{
		if (rng > SEARCH_RADIUS)
		{
			return (0);
		}
	}
	else
	{
		if (rng > (SEARCH_RADIUS - (2* BOTSPEED)))
		{
			return (0);
		}
	}
	lnd = pointcontents (a.origin);
	if (lnd != CONTENT_WATER)
	{
		spot1_z = ((dropline (spot1) + self.view_ofs_z) - self.mins_z);
	}
	traceline (spot1,spot2,TRUE,a);
	spot2 = borg;
	if (lnd == CONTENT_WATER)
	{
		if (!trace_inopen)
		{
			if (trace_fraction == 1)
			{
				return (1);
			}
			if (truereach)
			{
				return (1);
			}
		}
		if (truereach)
		{
			maxzd = 45;
			lnd = pointcontents (a.origin + self.view_ofs);
			if (lnd == CONTENT_WATER)
			{
				maxzd = (maxzd + self.view_ofs_z);
			}
			if (spot2_z < (a.origin_z + maxzd))
			{
				if (trace_fraction == 1)
				{
					return (1);
				}
				spot1_z = spot2_z;
				traceline (spot1,spot2,TRUE,a);
				if (trace_fraction == 1)
				{
					return (1);
				}
			}
		}
	}
	if (trace_fraction != TRUE)
	{
		return (0);
	}
	spot1 = a.origin;
	if (spot2_z > (spot1_z + bmaxjump))
	{
		return (0);
	}
	spot1 = a.origin;
	spot1_z = 0;
	spot2 = borg;
	spot2_z = 0;
	diffxy = vlen (spot2 - spot1);
	diffxy = (diffxy - ((LEVELJUMPTIME * BOTSPEED) * 10));
	if (diffxy < 0)
	{
		return (1);
	}
	vel = 0;
	diffz = (a.origin_z - borg_z);
	while (diffz > 0)
	{
		diffxy = (diffxy - BOTSPEED);
		vel = (vel - GRAVITY);
		diffz = (diffz + (0.1 * vel));
	}
	if (diffxy < 0)
	{
		return (1);
	}
	return(BotWalkable (a,b,bmaxjump));
};

float (entity a, entity b) BotReachable =
{
	return(Reachable (a,b,0));
};

float (entity b) TrueReachable =
{
	return(Reachable (self,b,TRUE));
};

