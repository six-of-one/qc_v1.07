/* ::-::
 *
 * Cataboligne
 *
 * file: young.qc
 *
 * date: 10/13/11
 *
 * qc - support alien infestation by LordHavoc
 *
 */

/*
		+---------------------------------------+
		|  Frame code                           | SEC-HEAD
		+---------------------------------------+
*/


$frame base
$frame stand1
$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame runatt1 runatt2 runatt3 runatt4 runatt5 runatt6 runatt7 runatt8

//============================================================================

// hrm - this should be genericed in watermove dealy

void() young_slimedamage =
{
	if (self.watertype == CONTENT_LAVA)
	{
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.2;
			T_Damage(self, world, world, 20);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 1;
			T_Damage(self, world, world, 8);
		}
	}
};

// not dyn_monster, so dont get checked there

void() young_noway =
{
	local float now;

	if (MONSTER_NOWAY) // clear monsters beyond noway bounds for a level
	if (self.health > 0)
	{
		if (noway_below)
		if (self.origin_z < noway_below) now = TRUE;
		if (noway_above)
		if (self.origin_z > noway_above) now = TRUE;
		if (now)
		{
			T_Damage (self,world,world,self.health + 10);
			remove(self);
		}
	}
};

void()	Young_JumpTouch;

void()	young_stand1	=[	$stand1,	young_stand1	] {ai_stand();young_slimedamage();};

/*
void()	young_run1	=[	$run1,		young_run2	] {ai_run(-2);young_slimedamage();};
void()	young_run2	=[	$run2,		young_run3	] {ai_face();makevectors(self.angles);self.velocity = v_forward * 400 + '0 0 240';if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;young_slimedamage();};
void()	young_run3	=[	$run3,		young_run4	] {young_slimedamage();};
void()	young_run4	=[	$run4,		young_run5	] {young_slimedamage();};
void()	young_run5	=[	$run5,		young_run6	] {young_slimedamage();};
void()	young_run6	=[	$run6,		young_run7	] {young_slimedamage();};
void()	young_run7	=[	$run7,		young_run8	] {ai_face();young_slimedamage();};
void()	young_run8	=[	$run8,		young_run1	] {ai_face();young_slimedamage();};
*/

/*
void()	young_walk1	=[	$walk1,		young_walk2	] {ai_walk(16);young_slimedamage(); young_noway();};
void()	young_walk2	=[	$walk2,		young_walk3	] {ai_walk(16);young_slimedamage();};
void()	young_walk3	=[	$walk3,		young_walk4	] {ai_walk(16);young_slimedamage();};
void()	young_walk4	=[	$walk4,		young_walk5	] {ai_walk(16);young_slimedamage();};
void()	young_walk5	=[	$walk5,		young_walk6	] {ai_walk(16);young_slimedamage();};
void()	young_walk6	=[	$walk6,		young_walk7	] {ai_walk(16);young_slimedamage();};
void()	young_walk7	=[	$walk7,		young_walk8	] {ai_walk(16);young_slimedamage();};
void()	young_walk8	=[	$walk8,		young_walk1	] {ai_walk(16);young_slimedamage();};
*/

framerloop($walk1, $walk8, young_walk1, 0.1,

	frame_arb($run1,young_noway());

	ai_walk(16);
	young_slimedamage();
);

/*
void()	young_run1	=[	$run1,		young_run2	] {ai_run(16);young_slimedamage(); young_noway();};
void()	young_run2	=[	$run2,		young_run3	] {ai_run(16);young_slimedamage();};
void()	young_run3	=[	$run3,		young_run4	] {ai_run(16);young_slimedamage();};
void()	young_run4	=[	$run4,		young_run5	] {ai_run(16);young_slimedamage();};
void()	young_run5	=[	$run5,		young_run6	] {ai_run(16);young_slimedamage();};
void()	young_run6	=[	$run6,		young_run7	] {ai_run(16);young_slimedamage();};
void()	young_run7	=[	$run7,		young_run8	] {ai_run(16);young_slimedamage();};
void()	young_run8	=[	$run8,		young_run1	] {ai_run(16);young_slimedamage();};
*/

framerloop($run1, $run8, young_run1, 0.1,

	frame_arb($run1,young_noway());

	ai_run(16);
	young_slimedamage();
);

/*
void()	young_runatt1	=[	$runatt1,		young_runatt2	] {ai_face();};
void()	young_runatt2	=[	$runatt2,	young_runatt3	]
{
	ai_face();
	
	self.touch = Young_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 400 + '0 0 200';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	young_runatt3	=[	$runatt3,	young_runatt1	] {
self.nextthink = time + 3;
// if three seconds pass, assume young is stuck and jump again
};

void()	young_runatt4	=[	$runatt4,	young_runatt5	] {ai_face();young_slimedamage();};
void()	young_runatt5	=[	$runatt5,	young_runatt6	] {ai_face();young_slimedamage();};
void()	young_runatt6	=[	$runatt6,	young_runatt7	] {ai_face();young_slimedamage();};
void()	young_runatt7	=[	$runatt7,	young_runatt8	] {ai_face();young_slimedamage();};
void()	young_runatt8	=[ 	$runatt8,	young_run1		] {ai_face();young_slimedamage();};
*/

framer($runatt1, $runatt8, young_runatt1, young_run1, 0.1,

	frame_arb($runatt2,

		self.touch = Young_JumpTouch;
		makevectors (self.angles);
		self.origin_z = self.origin_z + 1;
		self.velocity = v_forward * 400 + '0 0 200';
		if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	);
	ai_face();
	young_slimedamage();
);

void()	young_pain1	=[	$run1,		young_pain1	]
{
	self.a__ = self.a__ - 1;
	if (self.a__ < 1) self.nextthink = young_run1;
	young_slimedamage();
};

/*
void()	young_pain1	=[	$run1,		young_pain2	] {};
void()	young_pain2	=[	$run1,		young_pain3	] {young_slimedamage();};
void()	young_pain3	=[	$run1,		young_pain4	] {young_slimedamage();};
void()	young_pain4	=[	$run1,		young_run1	] {young_slimedamage();};
*/

void(entity attacker, float damage)	young_pain =
{
	self.a__ = 4;
	young_pain1 ();
};

void()	young_die1		=[	$runatt4,		young_die1	]
{
	self.think = SUB_Remove;
	self.nextthink = time + 15;
	self.solid = SOLID_NOT;
};

void() young_die =
{
	// spawned by a clinger, notify parent that one has died
	if (self.owner)
		self.owner.cnt = self.owner.cnt + 1;

// check for gib
	if (self.health < -30)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		remove(self);
		return;
	}

// regular death
	young_die1 ();
};

/*
string(entity targ, entity attacker) young_killmsg =
{
		return " was overrun by ";
};

string(entity targ, entity attacker) young_killmsg2 =
{
	return ".\n";
};
*/

/*QUAKED monster_young (1 0 0) (-16 -16 -24) (16 16 32) Ambush

*/
void(float ign) monster_young =
{
/*
if (ign != A_MONSTER)
{
	if (M_MONSTER < 0)
	{
		remove(self);
		return;
	}
	
	if (!M_MONSTER_II & CB_M_CLING)
	if (deathmatch)
	{
		remove(self);
		return;
	}
*/
	precache_model ("progs/young.mdl");
//}

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/young.mdl");

	self.netname = "Alien Spawn";

	setorigin (self, self.origin - '0 0 24');
	setsize (self, '-16 -16 0', '16 16 8');
	self.health = 20;

	self.th_stand = young_stand1;
	self.th_walk = young_walk1;
	self.th_run = young_run1;
	self.th_die = young_die;
	self.th_missile = young_runatt1;			// jump attack
	self.th_pain = young_pain;
	self._killmsg = young_killmsg;

	self.class_select = "class_monster";

	if (ign)
	{
		self.takedamage = DAMAGE_AIM;
	
		self.ideal_yaw = self.angles * '0 1 0';
		self.yaw_speed = 40;
		self.view_ofs = '0 0 6';
		
		self.flags = self.flags | FL_MONSTER;
		
		self.pausetime = 99999999;
		self.th_stand ();
		
		if (self.enemy)
			FoundTarget();
		young_runatt2();
		self.velocity_x = crandom() * 200;
		self.velocity_y = crandom() * 200;
		self.velocity_z = 250;
	}
	else
		walkmonster_start();
};

void(entity o, vector v) spawnmonster_young =
{
	local entity e;
	e = spawn();
	e.owner = o;
	e.enemy = o.enemy; // pass thru - cause item_call can clear things out if not dyn_
//	e.stack1 = "no_monster_wakey";
	item_call_save(e, "monster_young");
	setorigin(e, v);
};


/*
==============================================================================

YOUNG

==============================================================================
*/

/*
==============
CheckYoungJump

==============
*/
float()	CheckYoungJump =
{
	local	vector	dist;

	if (!(self.flags & FL_ONGROUND))
		return FALSE;

	if (self.origin_z > self.enemy.origin_z + -6)
		return FALSE;
		
	if (self.origin_z < self.enemy.origin_z + -42)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	if (vlen(dist) > 200)
		return FALSE;
		
	return TRUE;
};

float()	YoungCheckAttack =
{
	if (CheckYoungJump ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================

void()	Young_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;

	// lots of jumping young often kill eachother without this check
	if (other.classname == self.classname)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 200 )
		{
			ldmg = 5 + 15*random();
			T_Damage (other, self, self, ldmg);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = young_runatt1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = young_runatt4;
	self.nextthink = time + 0.1;
};

