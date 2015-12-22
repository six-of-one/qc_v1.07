/* ::-::
 *
 * Cataboligne
 *
 * file: young.qc
 *
 * date: 10/13/11
 * date: 11/16/12 - enhanced for evolving young - get larger as time goes by
 *
 * qc - support alien infestation by LordHavoc
 *
 */

// let compile process know - since this is an #include in this code set

#messagecompiling young.qc 

// include in random extra monsters

#undef INCL_YOUNG
#define INCL_YOUNG			128

/*
		+---------------------------------------+
		|  Frame code                           | SEC-HEAD
		+---------------------------------------+
*/


$frame base
$frame stand1
$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame runatt1 runatt2 runatt3 runatt4 runatt5 runatt6 runatt7 runatt8

// young "evolve" now - after a certain time passes they get bigger
// the final stage - Aliens!

$frame mdstand1
$frame mdrun1 mdrun2 mdrun3 mdrun4 mdrun5 mdrun6 mdrun7 mdrun8
$frame mdrunatt1 mdrunatt2 mdrunatt3 mdrunatt4 mdrunatt5 mdrunatt6 mdrunatt7 mdrunatt8

$frame lgstand1
$frame lgrun1 lgrun2 lgrun3 lgrun4 lgrun5 lgrun6 lgrun7 lgrun8
$frame lgrunatt1 lgrunatt2 lgrunatt3 lgrunatt4 lgrunatt5 lgrunatt6 lgrunatt7 lgrunatt8

//============================================================================

#ifdef testset
float YOUNG_LIFE_SM = 10; // rels for a small youngling
float YOUNG_LIFE_MD = 20; // rels for a med youngling
#else
float YOUNG_LIFE_SM = 30; // rels for a small youngling
float YOUNG_LIFE_MD = 65; // rels for a med youngling
#endifdef

float YOUNG_LIFE_LG = 125; // rels for a large youngling


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

void() young_med;
void() young_lg;

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

	if (!now)
	if (self.a__)
	if (self.rad_time < time)
	{
		self.a__ = self.a__ + 1;
		if (self.a__ == 2) // becomes med
			young_med();
		if (self.a__ == 3) // becomes lg
			young_lg();
	}

};

void()	young_stand1	=[	$stand1,	young_stand1	] {ai_stand();young_slimedamage();};

//void()	young_mdstand1	=[	$mdstand1,	young_mdstand1	] {ai_stand();young_slimedamage();};
//void()	young_lgstand1	=[	$lgstand1,	young_lgstand1	] {ai_stand();young_slimedamage();};

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

// so we can enhance and have a walk slower than a run
float YOUNG_WALK;

// walk sets

void()	young_walk1	=[	$run1,		young_walk1	]
{
	if ((self.duration < $run1) || (self.duration > $run7))
	{
		self.duration = $run1;
		young_noway();
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	ai_walk(YOUNG_WALK + self.waitmin);
	young_slimedamage();
};
/*
void()	young_mdwalk1	=[	$mdrun1,		young_mdwalk1	]
{
	if ((self.weaponframe < $mdrun1) || (self.weaponframe > $mdrun7))
	{
		self.weaponframe = $mdrun1;
		young_noway();
	}
	else self.weaponframe = self.weaponframe + 1;

	self.frame = self.weaponframe;

	ai_walk(YOUNG_WALK + 2);
	young_slimedamage();
};

void()	young_lgwalk1	=[	$lgrun1,		young_lgwalk1	]
{
	if ((self.weaponframe < $lgrun1) || (self.weaponframe > $lgrun7))
	{
		self.weaponframe = $lgrun1;
		young_noway();
	}
	else self.weaponframe = self.weaponframe + 1;

	self.frame = self.weaponframe;

	ai_walk(YOUNG_WALK + 6);
	young_slimedamage();
};
*/
/*
void()	young_walk1	=[	$run1,		young_walk2	] {ai_walk(YOUNG_WALK);young_slimedamage(); young_noway();};
void()	young_walk2	=[	$run2,		young_walk3	] {ai_walk(YOUNG_WALK);young_slimedamage();};
void()	young_walk3	=[	$run3,		young_walk4	] {ai_walk(YOUNG_WALK);young_slimedamage();};
void()	young_walk4	=[	$run4,		young_walk5	] {ai_walk(YOUNG_WALK);young_slimedamage();};
void()	young_walk5	=[	$run5,		young_walk6	] {ai_walk(YOUNG_WALK);young_slimedamage();};
void()	young_walk6	=[	$run6,		young_walk7	] {ai_walk(YOUNG_WALK);young_slimedamage();};
void()	young_walk7	=[	$run7,		young_walk8	] {ai_walk(YOUNG_WALK);young_slimedamage();};
void()	young_walk8	=[	$run8,		young_walk1	] {ai_walk(YOUNG_WALK);young_slimedamage();};

void()	young_mdwalk1	=[	$mdrun1,		young_mdwalk2	] {ai_walk(YOUNG_WALK + 2);young_slimedamage(); young_noway();};
void()	young_mdwalk2	=[	$mdrun2,		young_mdwalk3	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};
void()	young_mdwalk3	=[	$mdrun3,		young_mdwalk4	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};
void()	young_mdwalk4	=[	$mdrun4,		young_mdwalk5	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};
void()	young_mdwalk5	=[	$mdrun5,		young_mdwalk6	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};
void()	young_mdwalk6	=[	$mdrun6,		young_mdwalk7	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};
void()	young_mdwalk7	=[	$mdrun7,		young_mdwalk8	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};
void()	young_mdwalk8	=[	$mdrun8,		young_mdwalk1	] {ai_walk(YOUNG_WALK + 2);young_slimedamage();};

void()	young_lgwalk1	=[	$lgrun1,		young_lgwalk2	] {ai_walk(YOUNG_WALK + 6);young_slimedamage(); young_noway();};
void()	young_lgwalk2	=[	$lgrun2,		young_lgwalk3	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
void()	young_lgwalk3	=[	$lgrun3,		young_lgwalk4	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
void()	young_lgwalk4	=[	$lgrun4,		young_lgwalk5	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
void()	young_lgwalk5	=[	$lgrun5,		young_lgwalk6	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
void()	young_lgwalk6	=[	$lgrun6,		young_lgwalk7	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
void()	young_lgwalk7	=[	$lgrun7,		young_lgwalk8	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
void()	young_lgwalk8	=[	$lgrun8,		young_lgwalk1	] {ai_walk(YOUNG_WALK + 6);young_slimedamage();};
*/

// run sets

void()	young_run1	=[	$run1,		young_run1	]
{
	if ((self.duration < $run1) || (self.duration > $run7))
	{
		self.duration = $run1;
		young_noway();
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	ai_run(self.waitmax);
	young_slimedamage();

// trying to fix "floaty" aliens - randomly try jumping
//	if (! self.flags & FL_ONGROUND) - flag says they are on ground
//	if (random() > 0.9) droptofloor(0, 0);

	if (self.ip_orgOrigin != self.origin)
	{
		self.ip_orgOrigin = self.origin;
		self.cnt = 0;
	}
	else
	{
		self.cnt = self.cnt + 1;
		if (self.cnt > 50)
		{
			self._jump();
			self.cnt = 0;
		}
	}

};
/*
void()	young_mdrun1	=[	$mdrun1,		young_mdrun1	]
{
	if ((self.weaponframe < $mdrun1) || (self.weaponframe > $mdrun7))
	{
		self.weaponframe = $mdrun1;
		young_noway();
	}
	else self.weaponframe = self.weaponframe + 1;

	self.frame = self.weaponframe;

	ai_run(20);
	young_slimedamage();
};

void()	young_lgrun1	=[	$lgrun1,		young_lgrun1	]
{
	if ((self.weaponframe < $lgrun1) || (self.weaponframe > $lgrun7))
	{
		self.weaponframe = $lgrun1;
		young_noway();
	}
	else self.weaponframe = self.weaponframe + 1;

	self.frame = self.weaponframe;

	ai_run(24);
	young_slimedamage();
};
*/
/*
void()	young_run1	=[	$run1,		young_run2	] {ai_run(16);young_slimedamage(); young_noway();};
void()	young_run2	=[	$run2,		young_run3	] {ai_run(16);young_slimedamage();};
void()	young_run3	=[	$run3,		young_run4	] {ai_run(16);young_slimedamage();};
void()	young_run4	=[	$run4,		young_run5	] {ai_run(16);young_slimedamage();};
void()	young_run5	=[	$run5,		young_run6	] {ai_run(16);young_slimedamage();};
void()	young_run6	=[	$run6,		young_run7	] {ai_run(16);young_slimedamage();};
void()	young_run7	=[	$run7,		young_run8	] {ai_run(16);young_slimedamage();};
void()	young_run8	=[	$run8,		young_run1	] {ai_run(16);young_slimedamage();};

void()	young_mdrun1	=[	$mdrun1,		young_mdrun2	] {ai_run(20);young_slimedamage(); young_noway();};
void()	young_mdrun2	=[	$mdrun2,		young_mdrun3	] {ai_run(20);young_slimedamage();};
void()	young_mdrun3	=[	$mdrun3,		young_mdrun4	] {ai_run(20);young_slimedamage();};
void()	young_mdrun4	=[	$mdrun4,		young_mdrun5	] {ai_run(20);young_slimedamage();};
void()	young_mdrun5	=[	$mdrun5,		young_mdrun6	] {ai_run(20);young_slimedamage();};
void()	young_mdrun6	=[	$mdrun6,		young_mdrun7	] {ai_run(20);young_slimedamage();};
void()	young_mdrun7	=[	$mdrun7,		young_mdrun8	] {ai_run(20);young_slimedamage();};
void()	young_mdrun8	=[	$mdrun8,		young_mdrun1	] {ai_run(20);young_slimedamage();};

void()	young_lgrun1	=[	$lgrun1,		young_lgrun2	] {ai_run(24);young_slimedamage(); young_noway();};
void()	young_lgrun2	=[	$lgrun2,		young_lgrun3	] {ai_run(24);young_slimedamage();};
void()	young_lgrun3	=[	$lgrun3,		young_lgrun4	] {ai_run(24);young_slimedamage();};
void()	young_lgrun4	=[	$lgrun4,		young_lgrun5	] {ai_run(24);young_slimedamage();};
void()	young_lgrun5	=[	$lgrun5,		young_lgrun6	] {ai_run(24);young_slimedamage();};
void()	young_lgrun6	=[	$lgrun6,		young_lgrun7	] {ai_run(24);young_slimedamage();};
void()	young_lgrun7	=[	$lgrun7,		young_lgrun8	] {ai_run(24);young_slimedamage();};
void()	young_lgrun8	=[	$lgrun8,		young_lgrun1	] {ai_run(24);young_slimedamage();};
*/

// do an attack

void() young_attack =
{
	self.touch = Monster_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 400 + '0 0 200';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;	
}

void()	young_runatt1	=[	$runatt1,		young_runatt2	] {ai_frame(self.walkframe);ai_face();};
void()	young_runatt2	=[	$runatt2,	young_runatt3	] {	ai_frame(self.walkframe);ai_face(); young_attack(); };
void()	young_runatt3	=[	$runatt3,	young_runatt1	]
{
	ai_frame(self.walkframe);
	self.nextthink = time + 3;
// if three rels pass, assume young is stuck and jump again
};

void()	young_runatt4	=[	$runatt4,	young_runatt5	] {ai_frame(self.walkframe);ai_face();};
void()	young_runatt5	=[	$runatt5,	young_runatt6	] {ai_frame(self.walkframe);ai_face();};
void()	young_runatt6	=[	$runatt6,	young_runatt7	] {ai_frame(self.walkframe);ai_face();};
void()	young_runatt7	=[	$runatt7,	young_runatt8	] {ai_frame(self.walkframe);ai_face();};
void()	young_runatt8	=[ 	$runatt8,	young_run1		] {ai_frame(self.walkframe);ai_face();};

/*
void()	young_mdrunatt1	=[	$mdrunatt1,	young_mdrunatt2	] {ai_face();};
void()	young_mdrunatt2	=[	$mdrunatt2,	young_mdrunatt3	] {	ai_face(); young_attack(); };
void()	young_mdrunatt3	=[	$mdrunatt3,	young_mdrunatt1	] { self.nextthink = time + 3; };

void()	young_mdrunatt4	=[	$mdrunatt4,	young_mdrunatt5	] {ai_face();young_slimedamage();};
void()	young_mdrunatt5	=[	$mdrunatt5,	young_mdrunatt6	] {ai_face();young_slimedamage();};
void()	young_mdrunatt6	=[	$mdrunatt6,	young_mdrunatt7	] {ai_face();young_slimedamage();};
void()	young_mdrunatt7	=[	$mdrunatt7,	young_mdrunatt8	] {ai_face();young_slimedamage();};
void()	young_mdrunatt8	=[ 	$mdrunatt8,	young_mdrun1		] {ai_face();young_slimedamage();};


void()	young_lgrunatt1	=[	$lgrunatt1,	young_lgrunatt2	] {ai_face();};
void()	young_lgrunatt2	=[	$lgrunatt2,	young_lgrunatt3	] {	ai_face(); young_attack(); };
void()	young_lgrunatt3	=[	$lgrunatt3,	young_lgrunatt1	] { self.nextthink = time + 3; };

void()	young_lgrunatt4	=[	$lgrunatt4,	young_lgrunatt5	] {ai_face();young_slimedamage();};
void()	young_lgrunatt5	=[	$lgrunatt5,	young_lgrunatt6	] {ai_face();young_slimedamage();};
void()	young_lgrunatt6	=[	$lgrunatt6,	young_lgrunatt7	] {ai_face();young_slimedamage();};
void()	young_lgrunatt7	=[	$lgrunatt7,	young_lgrunatt8	] {ai_face();young_slimedamage();};
void()	young_lgrunatt8	=[ 	$lgrunatt8,	young_lgrun1		] {ai_face();young_slimedamage();};

*/
// pain sets
void()	young_pain1	=[	$run1,		young_pain2	] {ai_frame(self.walkframe);};
void()	young_pain2	=[	$run1,		young_pain3	] {ai_frame(self.walkframe);};
void()	young_pain3	=[	$run1,		young_pain4	] {ai_frame(self.walkframe);};
void()	young_pain4	=[	$run1,		young_run1	] {ai_frame(self.walkframe);};

/*
void()	young_mdpain1	=[	$mdrun1,		young_mdpain2	] {};
void()	young_mdpain2	=[	$mdrun1,		young_mdpain3	] {young_slimedamage();};
void()	young_mdpain3	=[	$mdrun1,		young_mdpain4	] {young_slimedamage();};
void()	young_mdpain4	=[	$mdrun1,		young_mdrun1	] {young_slimedamage();};

void()	young_lgpain1	=[	$lgrun1,		young_lgpain2	] {};
void()	young_lgpain2	=[	$lgrun1,		young_lgpain3	] {young_slimedamage();};
void()	young_lgpain3	=[	$lgrun1,		young_lgpain4	] {young_slimedamage();};
void()	young_lgpain4	=[	$lgrun1,		young_lgrun1	] {young_slimedamage();};

//void(entity attacker, float damage)	young_pain =
void()	young_pain =
{
	if (self.a__ == 2) young_mdpain1 ();
	if (self.a__ == 3) young_lgpain1 ();
	else
	young_pain1 ();
};
*/

// death of younglings
void()	young_die1		=[	$runatt4,		young_die1	]
{
	ai_frame(self.walkframe);
	self.think = SUB_Remove;
	self.nextthink = time + 15;
	self.solid = SOLID_NOT;
};
/*
void()	young_mddie1		=[	$mdrunatt4,		young_mddie1	]
{
	self.think = SUB_Remove;
	self.nextthink = time + 15;
	self.solid = SOLID_NOT;
};

void()	young_lgdie1		=[	$lgrunatt4,		young_lgdie1	]
{
	self.think = SUB_Remove;
	self.nextthink = time + 15;
	self.solid = SOLID_NOT;
};
*/
void() young_die =
{
	// spawned by a clinger, notify parent that one has died
	if (self.owner)
		self.owner.cnt = self.owner.cnt + 1;

// check for gib
	if (self.health < -30)
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		remove(self);
		return;
	}

// regular death
//	if (self.a__ == 2) young_mddie1 ();
//	if (self.a__ == 3) young_lgdie1 ();
//	else 
	young_die1 ();
};


// younglings evolve

// note: these may not need to be complete builds

void() young_med =
{
//	setsize (self, '-32 -32 0', '32 32 16');
	self.walkframe = $mdstand1;
	self.waitmin = 2; // walk speed
	self.waitmax = 20; // run speed

	self.health = 20 * self.a__;
/*
	self.th_stand = young_stand1;
	self.th_walk = young_walk1;
	self.th_run = young_run1;
	self.th_die = young_die;
	self.th_missile = young_runatt1;
	self.th_pain = young_pain1;

// jumptouch multi
	self._jump = young_runatt1;
	self._jump2 = young_runatt4;
	self.jump_flag = 200;
*/
	self.dodmg = 10 + random() * 5;

	self.rad_time = time + YOUNG_LIFE_MD + random() * 14;
//	self.dmg = 15;
	droptofloor(0, 0);
	young_walk1();
};

void() young_lg =
{
//	setsize (self, '-65 -64 0', '64 64 32');
	self.walkframe = $lgstand1;
	self.waitmin = 6; // walk speed
	self.waitmax = 24; // run speed

	self.health = 20 * self.a__ + random() * 40;
/*
	self.th_stand = young_stand1;
	self.th_walk = young_walk1;
	self.th_run = young_run1;
	self.th_die = young_die;
	self.th_missile = young_runatt1;
	self.th_pain = young_pain1;

// jumptouch multi
	self._jump = young_runatt1;
	self._jump2 = young_runatt4;
	self.jump_flag = 200;
*/
	self.dodmg = 35 + random() * 5;

//	self.rad_time = time + YOUNG_LIFE_LG + random() * 18;
	self.rad_time = MAXFL; // no more evolution for now
//	self.dmg = 40;
	self.wad = "MEGA";

	droptofloor(0, 0);
	young_walk1();
};


//string(entity targ, entity attacker) young_killmsg =
string() young_killmsg =
{
		return " was overrun by ";
};

string() young_killmsg2 =
{
	return ".\n";
};



//float YOUNG_EVOL = 1; // set to 0 to stop evolutions

/*QUAKED monster_young (1 0 0) (-16 -16 -24) (16 16 32) Ambush

*/
void(float ign) monster_young =
{
if (ign != A_MONSTER)
{
	if (M_MONSTER < 0)
	{
		self.think = remove_monster;
		self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
		return;
	}
	
	if (!M_MONSTER_II & CB_M_CLING)
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/young.mdl");
}

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.walkframe = 0;

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
	self.th_pain = young_pain1;
	self._killmsg = young_killmsg;

	self.class_select = "class_monster";

	self.waitmin = 0; // walk speed add in
	self.waitmax = 16; // run speed

// jumptouch multi
	self._jump = young_runatt1;
	self._jump2 = young_runatt4;
	self.jump_flag = 200;
	self.dodmg = 5 + random() * 5;

	self.a__ = 0;
	YOUNG_WALK = 16;

#ifdef enhanced
//	if (ENHANCED && YOUNG_EVOL)
//	{
		YOUNG_WALK = 8;
		self.rad_time = time + YOUNG_LIFE_SM + random() * 10;
		self.a__ = 1;
//	}
#endifdef

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

		droptofloor(0, 0); // since pods dont call walkmonster, these seem to end up off floor sometimes
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
	e.stack1 = "no_monster_wakey";
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
/*
deprecated to Monster_JumpTouch

void()	Young_JumpTouch =
{
	if (self.health <= 0)
		return;

	// lots of jumping young often kill eachother without this check
	if (other.classname == self.classname)
		return;
		
	if (self.dmg <= 0) self.dmg = 5;
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 200 )
		{
			self.dodmg = self.dmg + 15*random();
			T_Damage (other, self, self, self.dodmg);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	if (self.a__ == 2) self.think = young_mdrunatt1;
	if (self.a__ == 3) self.think = young_lgrunatt1;
	else
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
	if (self.a__ == 2) self.think = young_mdrunatt4;
	if (self.a__ == 3) self.think = young_lgrunatt4;
	else
	self.think = young_runatt4;
	self.nextthink = time + 0.1;
};

*/