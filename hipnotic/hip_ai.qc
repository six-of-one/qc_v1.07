/* ::-::
 *
 * Cataboligne
 *
 * file: hip_ai.qc
 *
 * date: 5.12.15
 *
 * qc - hipnotic extruded ai module
 *
 */

//MED 01/20/97

/*
=============
t_followtarget

Something has bumped into a followtarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_followtarget =
{
	local entity	temp;
	local vector	spot1, spot2;
	local entity	targ;
	local entity	client;

	if (!(other.flags & FL_MONSTER))
		return;
	if (other.classname == "monster_decoy")
		return;
//	if (other.enemy == world)
//		return;
	if (other.wetsuit_time > time)
		return;
	targ = other.enemy;

// see if any entities are in the way of the shot
	spot1 = other.origin + other.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, other);
	if (trace_fraction == 1)
		return;

	if (other.enemy)
	{
		// make the monster tame
		other.oldenemy = other.enemy;
		other.enemy = world;
		other.think = other.th_walk;
	}

	temp = self;
	self = other;
	other = temp;

	self.goalentity = self.movetarget = find (world, targetname, other.target);
/*
	bprint("target ");
	bprint(other.target);
	bprint(" targetname ");
	bprint(self.goalentity.targetname);
	bprint(" origin ");
	bprint(vtos(self.goalentity.origin));
	bprint("\n");
*/
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.wetsuit_time = time + 2;
	if (!self.movetarget)
	{
		if (self.oldenemy != world)
		{
			self.enemy = self.oldenemy;
			FoundTarget();
			return;
		}
		else
		{
			client = checkclient ();
			if (!client)
			{
				self.enemy = client;
				FoundTarget();
				return;
			}
			self.pausetime = time + 999999;
			self.th_stand ();
		}
	}
};

void() followtarget_f =
{
//	if (!self.targetname)
//		objerror ("monster_followtarget: no targetname");

	self.solid = SOLID_TRIGGER;
	self.touch = t_followtarget;
	setmodel (self, self.model);  // set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = string_null;
//	setsize (self, '-8 -8 -8', '8 8 8');

};

/*QUAKED path_follow (0.5 0.3 0) ?
Monsters will stop what they are doing and follow to the path
*/

void() path_follow =
{
	followtarget_f ();
};

/*QUAKED path_follow2 (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will stop what they are doing and follow to the path
*/

void() path_follow2 =
{
	self.solid = SOLID_TRIGGER;
	self.touch = t_followtarget;
	setsize (self, '-8 -8 -8', '8 8 8');
};


//============================================================================

//MED 10/18/96 added charmed stuff
//============================================================================
#ifdef hip_charmed

void() UpdateCharmerGoal =
{
	local entity targ;
	local vector d;

	d = normalize(self.origin-self.charmer.origin);

	if (self.huntingcharmer == 1)
	{
		targ = spawn();
		self.trigger_field = targ;
		setorigin(targ,self.charmer.origin);
		self.huntingcharmer = 2;
		self.goalentity = targ;
	}
	if (self.huntingcharmer == 2)
	{
		targ = self.trigger_field;
		traceline(self.origin,self.charmer.origin,TRUE,self);
		if (trace_fraction == 1.0)
		{
//			dprint("can see ");
//			dprint(vtos(self.charmer.origin));
//			dprint("\n");
			setorigin(targ,self.charmer.origin);
		}
	}
	else
	{
		targ = self.trigger_field;
		setorigin(targ,self.charmer.origin + (d*300));
	}
};

//============================================================================
void() HuntCharmer =
{
	self.huntingcharmer = 1;
	UpdateCharmerGoal();
//	self.goalentity = self.charmer;
	self.think = self.th_walk;
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.nextthink = time + 0.1;
};

//============================================================================
void() FleeCharmer =
{
	self.huntingcharmer = 1;
	UpdateCharmerGoal();
	self.huntingcharmer = 3;
//	self.goalentity = self.charmer;
	self.think = self.th_walk;
//	self.ideal_yaw = vectoyaw(self.originself.goalentity.origin - self.origin);
	self.nextthink = time + 0.1;
};

//============================================================================
void() StopHuntingCharmer =
{
	self.goalentity = world;
	if (self.huntingcharmer>1)
		remove(self.trigger_field);
	self.huntingcharmer = 0;
	self.think = self.th_stand;
	self.nextthink = time + 0.1;
};
#endifdef

//============================================================================

//MED 11/10/96 added ai_turn_in_place
/*
=============
ai_turn_in_place

don't move, but turn towards ideal_yaw
=============
*/
void() ai_turn_in_place =
{
	local float delta;
// TEST - REMOVE
	#ifdef local_test
ai_id(ai_turn_in_place,0);
	return;
	#endifdef

// TEST - REMOVE
	self.nextthink = time + 0.1;
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	delta = fabs(self.angles_y - enemy_yaw);
	if (delta > MIN_ANGLE_DELTA)
	{
		self.ideal_yaw = enemy_yaw;
		ChangeYaw();
	}
	else
	{
		self.think = self.th_run;
	}
};

//============================================================================

/*
=============
ai_run_dodge

Strafe sideways, but continue moving towards the enemy
Used by the Scourge.
=============
*/
void() ai_run_dodge =
{
	local float	ofs;
	local float newyaw;

/*
// attempt to jump over missiles
	if (self.enemy.weaponframe == 1)
	{
		if (self.flags & FL_ONGROUND)
		{
			self.origin_z = self.origin_z + 1;
			self.velocity = self.velocity + '0 0 500';
			self.flags = self.flags - FL_ONGROUND;
		}
		self.ltime = self.ltime + 1.0;
	}
*/
	self.nextthink = time + 0.1;
	if (self.lefty)
		ofs = 40;
	else
		ofs = -40;

	if (time > self.ltime)
	{
		self.lefty = 1 - self.lefty;
		self.ltime = time + 0.8;
	}

	newyaw = enemy_yaw + ofs;
	self.ideal_yaw = enemy_yaw;
	if (walkmove (newyaw, movedist))
	{
		ChangeYaw ();
		return;
	}

	self.lefty = 1 - self.lefty;
	self.ltime = time + 0.8;
	newyaw = enemy_yaw - ofs;
	self.ideal_yaw = enemy_yaw;
	walkmove (newyaw, movedist);
	ChangeYaw ();
};

//============================================================================

