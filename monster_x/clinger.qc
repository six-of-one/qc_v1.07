/* ::-::
 *
 * Cataboligne
 *
 * file: clinger.qc
 *
 * date: 10/13/11
 *
 * qc - support alien infestation by LordHavoc
 *
 */

// let compile process know - since this is an #include in this code set

#messagecompiling clinger.qc 

// include in random extra monsters

#undef INCL_CLINGER
#define INCL_CLINGER			256

/*
		+---------------------------------------+
		|  Frame code                           | SEC-HEAD
		+---------------------------------------+
*/


$frame base
$frame idle1
$frame shake1 shake2 shake3 shake4 shake5 shake6 shake7 shake8
$frame fall1
$frame hit1 hit2 hit3
$frame explode1 explode2

void() clinger_fall1;
void() clinger_idle1 =[ $idle1, clinger_idle1 ]
{
	local entity targ, e;
	local vector targposition, v;
	local float f, k;

// all children still alive?  don't fall yet
	if (self.cnt < 1)
		return;

	k = 0;
	e = findradius(self.origin, 1600);
	while (e)
	{
		if (e != self)
		if (e.classname != "monster_young")
		if (!e.deadflag)
		if (e.classname != OBSERVER)
		if (e.flags & FL_CLIENT) // || e.flags & FL_MONSTER)
		{
			v = e.origin - self.origin;
			v_z = 0;
			f = vlen(v);
			if (f < 160)
			if (f < k || !k) // == 0) // find closest targ
			{
				k = f;
				targ = e;
			}
		}
		e = e.chain;
	}

	if (!targ)
#ifdef enhanced
	{
// new timer burst mode
		if (self.rad_time)
		{
			if (self.rad_time <= time) clinger_fall1();
		}
		return;
	}
#else
	return;
#endifdef

#ifdef enhanced
//	if (ENHANCED)
   if (targ.invisible_finished) // mostly cant see invisible
	if (random() < 0.96) return;
#endifdef

	targposition = targ.origin + targ.velocity * 0.3;
	targposition_z = targ.origin_z;

	if (self.angles_x == 180) // on floor spawn - try diff logic
	{
		v = targposition - self.origin;
		v_z = 0;
		if (vlen(v) <= 128)
		{
			self.enemy = targ;
			clinger_fall1();
		}
	}

// if target is not below clinger, return
	if (targposition_z + targ.maxs_z > self.origin_z + self.mins_z)
		return;
// if target is not in a cylindrical area below the clinger, return
	v = targposition - self.origin;
	v_z = 0;
	if (vlen(v) > 128)
		return;

	// if a fall trace can't see the target, return
	v = self.origin + self.mins_z * '0 0 1';

	traceline(v, v - '0 0 1000', FALSE, self);
	v = trace_endpos + self.size_z * '0 0 2';
	if (v_z > self.origin_z + self.maxs_z)
		v_z = self.origin_z + self.maxs_z;

	traceline(v, targposition, TRUE, self);
	if (trace_fraction < 1)
		return;
	// looks good, let go
	self.enemy = targ;
	clinger_fall1();
};

/*
CHECK: find out why frames dont advance here

void() clinger_shake1 =[ $shake1, clinger_shake2 ] {};
void() clinger_shake2 =[ $shake1, clinger_shake3 ] {};
void() clinger_shake3 =[ $shake1, clinger_shake4 ] {};
void() clinger_shake4 =[ $shake1, clinger_shake2 ] {};
void() clinger_shake5 =[ $shake1, clinger_shake6 ] {};
void() clinger_shake6 =[ $shake1, clinger_shake7 ] {};
void() clinger_shake7 =[ $shake1, clinger_shake8 ] {};
void() clinger_shake8 =[ $shake1, clinger_idle1 ] {};
*/

framer($shake1, $shake8, clinger_shake1, clinger_idle1, 0.1,SUB_Null());

void(entity attacker, float damage) clinger_pain =
{
	if (damage < 5)
		return;
	if (time < self.pain_finished)
		return;
	self.pain_finished = time + 0.5;
	clinger_shake1();
};

/*
void() clinger_die1  =[ $hit1    , clinger_die2  ]
{
	self.touch = SUB_Null;
	self._die =
	self.th_die = SUB_Null;
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
};
void() clinger_die2  =[ $hit2    , clinger_die3  ] {};
void() clinger_die3  =[ $hit3    , clinger_die4  ] {};
void() clinger_die4  =[ $explode1, clinger_die5  ] {};
void() clinger_die5  =[ $explode2, clinger_die6  ] {};
*/

void() clinger_die6  =[ $explode2, clinger_respawn  ]
{
	local float c, ma;
	local vector v, vel;

	ma = self.lefty;
	self.lefty = 0;
	

	sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	// take into account the clipping hull size used by young and spawn them
	// either at the top of the box, or the bottom if spawning them at the top
	// of the box would put them in the floor
	if (self.angles_x != 180)
	{
		v = self.origin + self.maxs_z * '0 0 1';
		traceline(v, v - '0 0 56', FALSE, self);
		v = trace_endpos + '0 0 24';
	}
	else
		v = self.origin + '0 0 30';

	while (self.cnt > 0)
	{
		self.cnt = self.cnt - 1;
		spawnmonster_young(self, v);
	}
	c = 4;
	while (c > 0)
	{
		c = c - 1;
		vel_x = crandom() * 100;
		vel_y = crandom() * 100;
		vel_z = 200;
		SpawnMeatSpray(v, vel);
		ThrowGib ("progs/gib1.mdl", self.health);
	}
	self.model = string_null;
	self.nextthink = time + 30;
	if (!deathmatch) // original ops
		remove(self);

	if (self.event == "dyn_sp") // Cat note: dont create a load of respawners when making random monsters
	{
		self.health = 1; // hide from random monster corpse removal
		self.nextthink = time + self.wait;

		if ((!C_MONSTER_CNT) || ((monster_rnd_cnt + ma) < C_MONSTER_CNT)) // respawn until monsters are not maxed out & making more - add self back in too
			self.count = self.count - 1;

		if (self.count < 0)
		{
			if (!ma) monster_rnd_cnt = monster_rnd_cnt - 1; // decr if not coming from killed

			remove(self);
			return;
		}
		else
			self.nextthink = time + 25 + random() * 10;

		monster_rnd_cnt = monster_rnd_cnt + ma; // add back in - got subbed off when dead
	}
};

framer($hit1, $explode2, clinger_die1, clinger_die6, 0.1,

	frame_arb($hit1,

		self.touch = SUB_Null;
		self.th_die = SUB_Null;
		self.solid = SOLID_NOT;
		self.takedamage = DAMAGE_NO;
	);
);

void() clinger_falltouch =
{
	self._die();
};

void() clinger_fall1 =[ $fall1, clinger_fall2 ]
{
	self.th_pain = SUB_Null;
	self.touch = clinger_falltouch;
	if (self.angles_x != 180)
	{
		self.movetype = MOVETYPE_TOSS;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		self.velocity = '0 0 -400';
	}
};

void() clinger_fall2 =[ $fall1, clinger_fall2 ]
{
	if (self.flags & FL_ONGROUND) self._die();
	if (self.angles_x == 180) self._die(); // already there
};


void() cligner_killed =
{
	self.lefty = 1;
	clinger_die1();
};

// note: macro sets .think

void() clinger_respawn = [ $idle1, clinger_idle1 ]
{
	local float respawning;
	respawning = self.a__;
	self.a__ = TRUE; // always respawning after first spawn
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_NONE; // note: protected from noway rules
	self.model = self.mdl;

	self.health = 80;
	self.takedamage = DAMAGE_AIM;
	self.deadflag = DEAD_NO;
	self.th_pain = clinger_pain;
	self.th_die = cligner_killed; // via killed - restore monster count
	self._die = clinger_die1; // all internal calls
	self.enemy = world;

// occasionally make one that bursts w/o a target - 11.6.13
	self.rad_time = 0;
	if (random() < 0.06) self.rad_time = time + 30 + random() * 60;

	// count all the young that will drop as monsters - not needed with item_call
//	total_monsters = total_monsters + self.cnt;

	if (respawning)
		sound(self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);

// why were the braces here ??
//	{
	if (self.event == "dyn_sp" && self.angles_x == 180)
	{
		if (!respawning)
		{
			setsize (self, '-16 -16 0', '16 16 40');
			self.origin = self.origin + '0 0 20';
			self.velocity = '0 0 -20';
			self.movetype = MOVETYPE_TOSS;
		}
	}
	else
	{
		setsize (self, '-16 -16 -40', '16 16 0');
		setorigin (self, self.dest1);
	}
//	}
};


/*QUAKED monster_clinger (1 0 0) (-16 -16 -56) (16 16 0) Ambush

*/
void() monster_clinger
{
// override test
	if (! dm_over)			// __monster_clinger_button0		"1"
//	if (!M_MONSTER_II & CB_M_CLING)
 	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/clinger2.mdl");
	precache_model ("progs/young.mdl");

	self.netname = "Alien pod";
	setmodel (self, "progs/clinger2.mdl");
	self.mdl = self.model;

	self.class_select = "class_monster";
// how many young this pod makes
	self.cnt = 2 + cvar("skill") * 2
#ifdef enhanced
		+ rint(random())
#endifdef
		;

	if (self.map	== "dyn_sp") // Cat note: dont create a load of respawners when making random monsters
	{
//		self.stack1 = "no_monster_wakey";

		if (!self.count)  self.count = 2 + ceil( random() * 4); // loop respawn a few times, then out
		if (!self.wait) self.wait = C_MONSTER_WAIT / self.count; // try to be done by next random up
		if (self.wait < 15) self.wait = 15 + random();
#ifdef enhanced
//		if (ENHANCED)
		if (random() < 0.5) self.cnt = 3 + random() * 10; // 50% random spawns get rnd cnts
#endifdef

		traceline(self.origin + '0 0 6', self.origin + '0 0 1005', TRUE, self);
		if (sky_touch(trace_endpos + '0 0 1', world)) trace_fraction = 1; // hit sky brush or surface - we dont want them "on" skys
		if (trace_fraction >= 1 || (random() < 0.16)) // no ceiling ? - or occasionally make a floor model
		{
			self.angles_x = 180; // try flipping over
		}
		else
		{
			self.origin = trace_endpos;
		}
	}

// what does this note really mean ??
// *** Cat note: probably doesnt mix well with admin respawnable monsters - monster_II dont respawn yet

// for respawning in deathmatch
	self.dest1 = self.origin - '0 0 0.125';
	clinger_respawn();
};
