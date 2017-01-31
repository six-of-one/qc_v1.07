/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botmove.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


void () halfwalkmove =
{
	walkmove (self.strafeyaw,self.strafedist);
	self.think = self.strafethink;
	self.nextthink = (time + 0.050);
};

float (float s_yaw, float s_dist) botwalkmove =
{
	local float halfdist;
	self.oldorigin = self.origin;
	if (self.skil > 2)
	{
		halfdist = (0.550 * s_dist);
	}
	else
	{
		halfdist = (0.5 * s_dist);
	}
	if (!walkmove (s_yaw,halfdist))
	{
		return (0);
	}
	self.strafethink = self.think;
	self.strafeyaw = s_yaw;
	self.strafedist = halfdist;
	self.think = halfwalkmove;
	self.nextthink = (time + 0.050);
	return (1);
};

float (float dist) teleptest =
{
	local vector start;
	local vector up;
	up = self.origin;
	start = self.origin;
	if (dist < 0)
	{
		up_z = ((self.absmin_z + dist) - 1);
	}
	else
	{
		up_z = ((self.absmax_z + dist) + 1);
	}
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	start_x = (start_x + 16);
	start_y = (start_y + 16);
	up_x = (up_x + 16);
	up_y = (up_y + 16);
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	start_x = (start_x - 32);
	up_x = (up_x - 32);
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	start_y = (start_y - 32);
	up_y = (up_y - 32);
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	start_x = (start_x + 32);
	up_x = (up_x + 32);
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	start = self.origin;
	start_z = up_z;
	up = start;
	start_x = (start_x + 16);
	up_x = (up_x - 16);
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	start = self.origin;
	start_z = up_z;
	up = start;
	start_y = (start_y + 16);
	up_y = (up_y - 16);
	traceline (start,up,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	return (1);
};

float (float dist) waterupz =
{
//	local vector start;
	local vector up;
	if (!teleptest (dist))
	{
		return (0);
	}
	up = self.origin;
	up_z = (up_z + dist);
	setorigin (self,up);
	return (1);
};

float (float dist) waterdownz =
{
	local vector up;
	local vector start;
	if (!teleptest ((-1* dist)))
	{
		return (0);
	}
	up = self.origin;
	up_z = (up_z - dist);
	setorigin (self,up);
	return (1);
};

float (vector jmpv) Botjump =
{
	if (self.flags & FL_ONGROUND)
	{
		self.flags = (self.flags - FL_ONGROUND);
	}
	self.velocity = jmpv;
	if (jmpv_z > 200)
	{
		sound (self, CHAN_BODY,"player/plyrjmp8.wav" ,1.0 ,ATTN_NORM);
	}
	return (1);
};

float (vector jmpv) Botwaterjump =
{
	if (self.flags & FL_ONGROUND)
	{
		self.flags = (self.flags - FL_ONGROUND);
	}
	if (!waterupz (45))
	{
		return (0);
	}
	jmpv_z = 200;
	self.velocity = jmpv;
	if (self.flags & FL_SWIM)
	{
		self.flags = (self.flags - FL_SWIM);
	}
	if (self.flags & FL_INWATER)
	{
		self.flags = (self.flags - FL_INWATER);
	}
	self.teleport_time = (time + 0.7);
	return (1);
};

float (entity targ) Swimto;
float (vector spot) CheckLavaOrLow =
{
	local float lnd;
	local float boost;
	local vector spot2;
	lnd = pointcontents (spot);
	if ((lnd == CONTENT_LAVA) || (lnd == CONTENT_SLIME))
	{
		return (1);
	}
	spot2 = spot;
	spot2_z = (spot_z + 8);
	lnd = pointcontents (spot2);
	if ((lnd == CONTENT_LAVA) || (lnd == CONTENT_SLIME))
	{
		return (1);
	}
	if (lnd != CONTENT_WATER)
	{
		boost = (MAXJUMP + 1);
		if (self.goalentity.goalentity.classname == "func_button")
		{
			boost = ((boost + self.maxs_z) - 1);
		}
		if ((spot_z + boost) < self.goalentity.origin_z)
		{
			return (1);
		}
	}
	else
	{
		traceline (spot2,self.goalentity.absmin,TRUE,self);
		if (trace_inopen)
		{
			if ((spot_z + 45) > self.goalentity.origin_z)
			{
				return (0);
			}
			return (1);
		}
		if (trace_fraction == 1)
		{
			return (0);
		}
		return (1);
	}
	return (0);
};

float (vector middle) checkLanding =
{
	local float goodcnt;
	local vector spot;
	local vector center;
	center = middle;
	spot = middle;
	spot_x = (spot_x + 6);
	if (pointcontents (spot) == CONTENT_SOLID)
	{
		center_x = (center_x - 6);
	}
	spot_x = (spot_x - 12);
	if (pointcontents (spot) == CONTENT_SOLID)
	{
		center_x = (center_x + 6);
	}
	spot = middle;
	spot_y = (spot_y + 6);
	if (pointcontents (spot) == CONTENT_SOLID)
	{
		center_y = (center_y - 6);
	}
	spot_y = (spot_y - 12);
	if (pointcontents (spot) == CONTENT_SOLID)
	{
		center_y = (center_y + 6);
	}
	spot = center;
	spot_z = dropline (spot);
	goodcnt = 5;
	if (CheckLavaOrLow (spot))
	{
		return (0);
	}
	spot = center;
	spot_x = (spot_x + 6);
	spot_z = dropline (spot);
	if (CheckLavaOrLow (spot))
	{
		goodcnt = (goodcnt - 1);
	}
	spot = center;
	spot_x = (spot_x - 6);
	spot_z = dropline (spot);
	if (CheckLavaOrLow (spot))
	{
		goodcnt = (goodcnt - 1);
	}
	spot = center;
	spot_y = (spot_y + 6);
	spot_z = dropline (spot);
	if (CheckLavaOrLow (spot))
	{
		goodcnt = (goodcnt - 1);
	}
	spot = center;
	spot_y = (spot_y - 6);
	spot_z = dropline (spot);
	if (CheckLavaOrLow (spot))
	{
		goodcnt = (goodcnt - 1);
	}
	if (goodcnt > 3)
	{
		return (1);
	}
	return (0);
};

//float (float dist) JumpUpToPush =
float () JumpUpToPush =
{
	local float len;
	local vector botxy;
	local vector goalxy;
	local vector xydir;
	local vector jumpv;
	botxy = self.origin;
	botxy_z = 0;
	goalxy = self.goalentity.origin;
	goalxy_z = 0;
	xydir = normalize (goalxy - botxy);
	len = vlen ((goalxy - botxy));
	if (len < 25)
	{
		jumpv = (xydir * 20);
		jumpv_z = 270;
		Botjump (jumpv);
		return (1);
	}
	if (len < 80)
	{
		jumpv = (xydir * (len / LEVELJUMPTIME));
		jumpv_z = 270;
		Botjump (jumpv);
		return (1);
	}
	return (0);
};

float (float vz, float dist, float imagine) Bot_tryjump =
{
	local float timetofloor;
	local float tvel;
	local float dis;
	local float diffz;
	local float diffxy;
	local float NOTLAND;
	local float lnd;
	local float len;
//	local float depth;
	local float wlevel;
	local float velz;
	local float ht;
	local float frac;
	local vector botxy;
	local vector goalxy;
	local vector xydir;
	local vector top;
	local vector bottom;
	local vector jumpv;
	local vector newtop;
	local vector newbottom;
	local vector back;
	local vector front;
	local vector dir;
	local vector start;
	local string tmp;
	local entity botTarget;
	if (!(self.flags & (FL_ONGROUND + 2)))
	{
		return (0);
	}
	wlevel = CheckWaterLevel ();
	if ( (wlevel > 2) )
	{
		return (0);
	}
	if (!FacingIdeal ())
	{
		ChangeYaw ();
		if (!FacingIdeal ())
		{
			ChangeYaw ();
			if (!FacingIdeal ())
			{
				ChangeYaw ();
			}
		}
	}
	makevectors (self.angles);
	start = (self.origin + (16* v_forward));
	botTarget = self.goalentity;
	velz = vz;
	if ( (wlevel >= 1) )
	{
		if ( (velz > 200) )
		{
			velz = 200;
		}
	}
	if (wlevel == 2)
	{
		if (botTarget.origin_z < self.origin_z)
		{
			return (0);
		}
		start_z = (start_z + 45);
	}
	botxy = self.origin;
	botxy_z = 0;
	diffz = ((start_z - botTarget.origin_z) + 1);
	if (diffz < (-1* MAXJUMP))
	{
		if (botTarget.goalentity.classname != "trigger_push")
		{
			return (0);
		}
		else
		{
			if (diffz < 0)
			{
				if (JumpUpToPush ())
				{
					return (1);
				}
			}
		}
	}
	dis = dist;
	goalxy = botTarget.origin;
	if (botTarget.goalentity.classname == "train")
	{
		goalxy = (goalxy + (LEVELJUMPTIME * botTarget.goalentity.velocity));
	}
	lnd = pointcontents (goalxy);
	if ((lnd == CONTENT_LAVA) || (lnd == CONTENT_SLIME))
	{
		return (0);
	}
	goalxy_z = 0;
	xydir = normalize (goalxy - botxy);
	diffxy = vlen (goalxy - botxy);
	if (wlevel == 2)
	{
		if (diffxy > (3* BOTSPEED))
		{
			diffxy = (3* BOTSPEED);
		}
	}
	bottom = (start + self.view_ofs);
	top = (bottom + (xydir * dis));
	top_z = (top_z + (0.1 * (velz - GRAVITY)));
	traceline (bottom,top,TRUE,self);
	if (trace_fraction != TRUE)
	{
		if (velz > (GRAVITY + 180))
		{
			return(Bot_tryjump(velz - GRAVITY,dist,imagine));
		}
		else
		{
			return (0);
		}
	}
	bottom = (start - (16* v_forward));
	bottom_z = (bottom_z + self.mins_z);
	top = (bottom + ((xydir * dis) * 2));
	top_z = ((top_z + (0.2 * (velz - GRAVITY))) - (0.1 * GRAVITY));
	traceline (bottom,top,TRUE,self);
	if (trace_fraction != TRUE)
	{
		if (diffxy > (1.9 * BOTSPEED))
		{
			diffxy = (1.9 * BOTSPEED);
		}
		top = (bottom + (xydir * dis));
		top_z = ((top_z + (0.2 * (velz - GRAVITY))) - (0.1 * GRAVITY));
		traceline (bottom,top,TRUE,self);
		if (trace_fraction != TRUE)
		{
			if (diffxy > (0.9 * BOTSPEED))
			{
				diffxy = (0.9 * BOTSPEED);
			}
			velz = 290;
		}
	}
	timetofloor = 0;
	tvel = velz;
	if (diffz < 0)
	{
		timetofloor = 0.3;
	}
	else
	{
		while (diffz > 0)
		{
			timetofloor = (timetofloor + 0.1);
			tvel = (tvel - GRAVITY);
			diffz = (diffz + (tvel * 0.1));
		}
		timetofloor = (timetofloor - (diffz / tvel));
	}
	if (diffxy < ((dis * 10) * timetofloor))
	{
		jumpv = (xydir * (diffxy / timetofloor));
	}
	else
	{
		jumpv = (xydir * (10* dis));
		if (imagine)
		{
			return (0);
		}
	}
	tvel = velz;
	bottom = start;
	bottom_z = (bottom_z + self.mins_z);
	ht = (self.view_ofs_z - self.mins_z);
	NOTLAND = 1;
	while (NOTLAND)
	{
		tvel = (tvel - GRAVITY);
		newbottom = (bottom + (jumpv * 0.1));
		newbottom_z = (newbottom_z + (tvel * 0.1));
		traceline (bottom,newbottom,TRUE,self);
		frac = trace_fraction;
		if (trace_fraction == 1)
		{
			newtop = newbottom;
			top = bottom;
			top_z = (top_z + ht);
			newtop_z = (newtop_z + ht);
			traceline (top,newtop,TRUE,self);
			if (trace_fraction == 1)
			{
				traceline (newbottom,newtop,TRUE,self);
			}
			if (trace_fraction == 1)
			{
				top = (top + (16* v_right));
				newtop = (newtop + (16* v_right));
				traceline (top,newtop,TRUE,self);
			}
			if (trace_fraction == 1)
			{
				top = (top - (32* v_right));
				newtop = (newtop - (32* v_right));
				traceline (top,newtop,TRUE,self);
			}
			if (trace_fraction != 1)
			{
				frac = 0.1;
			}
		}
		if (trace_fraction !=1)
		{
			dir = normalize (newbottom - bottom);
			len = vlen (newbottom - bottom);
			newbottom = (bottom + ((dir * len) * frac));
			newbottom_z = (newbottom_z + 20);
			if (!checkLanding ((newbottom - (16* v_forward))))
			{
				return (0);
			}
			NOTLAND = 0;
		}
		if (NOTLAND)
		{
			if (CheckLavaOrLow (newbottom))
			{
				return (0);
			}
		}
		lnd = pointcontents (newbottom);
		if (lnd == CONTENT_WATER)
		{
			NOTLAND = 0;
		}
		bottom = newbottom;
	}
	jumpv_z = velz;
	if (imagine)
	{
		if (wlevel == 2)
		{
			return(teleptest (45));
		}
		return (1);
	}
	if (wlevel == 2)
	{
		return(Botwaterjump (jumpv));
	}
	if (newbottom_z < (self.absmin_z - MAXJUMP))
	{
		clearCache (self);
	}
	return(Botjump (jumpv));
};

//float (float dist) waterupdown =
float () waterupdown =
{
	local float wlevel;
	local float dis;
//	local float rnd;
//	local float zbottom;
	dis = 20;
	wlevel = CheckWaterLevel ();
	if (wlevel < 2)
	{
		return (0);
	}
	if (self.absmin_z > self.goalentity.origin_z)
	{
		if (dis > 20)
		{
			dis = 20;
		}
		if (waterdownz (dis))
		{
			return (1);
		}
		if (waterdownz ((dis * 0.5)))
		{
			return (1);
		}
		if (waterdownz ((dis * 0.2)))
		{
			return (1);
		}
	}
	if (wlevel == 3)
	{
		if (self.absmin_z < self.goalentity.origin_z)
		{
			dis = (self.goalentity.origin_z - self.absmin_z);
			if (dis > 20)
			{
				dis = 20;
			}
			if (waterupz (dis))
			{
				return (1);
			}
			if (waterupz ((dis * 0.5)))
			{
				return (1);
			}
			if (waterupz ((dis * 0.2)))
			{
				return (1);
			}
		}
	}
	return (0);
};

void (float dist) strafemove =
{
	local float ofs;
	local float rnd;
	if (self.flags & FL_SWIM)
	{
		if (waterupdown ())
		{
			return ;
		}
	}
	ofs = 90;
	rnd = random ();
	if (self.enemy)
	{
		self.strafeonly = 5;
		if (self.lefty & STRAFE_DIR)
		{
			ofs = (-1* ofs);
		}
	}
	else
	{
		if (rnd < 0.5)
		{
			ofs = (-1* ofs);
		}
	}
	if (walkmove ((self.ideal_yaw + ofs),dist))
	{
		return ;
	}
	if (self.enemy)
	{
		return ;
	}
	ofs = (-1* ofs);
	if (walkmove ((self.ideal_yaw + ofs),dist))
	{
		return ;
	}
	if (self.flags & (16+ FL_ONGROUND))
	{
		self.search_time = (self.search_time - 0.3);
	}
};

void (float dist, float wlevel) BotUnderwaterMove =
{
	local float rng;
	local float oldrng;
	local float rnd;
	rnd = random ();
	if (rnd < 0.750)
	{
		oldrng = vlen (self.origin - self.goalentity.origin);
		movetogoal (dist);
		rng = vlen (self.origin - self.goalentity.origin);
		if (oldrng > rng)
		{
			return ;
		}
		if (wlevel == 2)
		{
			if (Bot_tryjump (200,dist,0))
			{
				return ;
			}
		}
	}
	strafemove (dist);
};

float (float dist) trysidestep =
{
	local vector dir;
	local vector start;
	dir = (self.goalentity.origin - self.origin);
	dir_z = 0;
	dir = normalize (dir);
	start = self.origin;
	start_z = (self.origin_z + (self.view_ofs_z * 0.5));
	traceline (start,(start + (BOTSPEED * dir)),0,self);
	if (trace_fraction != TRUE)
	{
		strafemove (dist * 0.6);
		return (1);
	}
	makevectors (self.angles);
	start = (start + (v_right * 15));
	traceline (start,(start + (BOTSPEED * dir)),0,self);
	if (trace_fraction != TRUE)
	{
		if (walkmove ((self.ideal_yaw - 90),(dist * 0.6)))
		{
			return (1);
		}
	}
	start = (start - (v_right * 30));
	traceline (start,(start + (BOTSPEED * dir)),0,self);
	if (trace_fraction != TRUE)
	{
		if (walkmove ((self.ideal_yaw + 90),(dist * 0.6)))
		{
			return (1);
		}
	}
	return (0);
};

float (float dist) testmove =
{
	local float rng;
	local float oldrng;
	oldrng = vlen (self.origin - self.goalentity.origin);
	movetogoal (dist);
	rng = vlen (self.origin - self.goalentity.origin);
	if (rng < oldrng)
	{
		return (1);
	}
	return (0);
};

void (float dist) BotmovetoWindTunnel =
{
	if (testmove (dist))
	{
		return ;
	}
	if (trysidestep (dist))
	{
		return ;
	}
	if (Bot_tryjump (270,dist,0))
	{
		return ;
	}
	strafemove (dist * 0.5);
	return ;
};

void (float dist) BotmovetoVisiblegoal =
{
	if (walkmove (self.ideal_yaw,8))
	{
		botwalkmove (self.ideal_yaw,(dist - 8));
		return ;
	}
	if (walkmove ((self.ideal_yaw + 45),8))
	{
		movetogoal (dist - 8);
		return ;
	}
	if (walkmove ((self.ideal_yaw - 45),8))
	{
		movetogoal (dist - 8);
		return ;
	}
	if (trysidestep (dist))
	{
		return ;
	}
	if (Bot_tryjump (270,dist,0))
	{
		return ;
	}
	strafemove (dist * 0.5);
	return ;
};

void (float dist) Botmovetogoal =
{
	local entity Botgoal;
	local float wlevel;
	self.oldorigin = self.origin;
	Botgoal = self.goalentity;
	self.ideal_yaw = vectoyaw (Botgoal.origin - self.origin);
	ChangeYaw ();
	if (self.flags & FL_INWATER)
	{
		wlevel = CheckWaterLevel ();
		if (wlevel > 1)
		{
			BotUnderwaterMove (dist * 0.8,wlevel);
			return ;
		}
	}
	if (Botgoal.goalentity.classname == "trigger_push")
	{
		BotmovetoWindTunnel (dist);
		return ;
	}
	if (Spotvisible (Botgoal))
	{
		BotmovetoVisiblegoal (dist);
		return ;
	}
	if (testmove (dist))
	{
		return ;
	}
	strafemove (dist * 0.8);
	return ;
};

