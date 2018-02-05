/*
==============================================================================

DEMON

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

/*
	Archon: wwe do with this?
// dbl demon / black orange beast w/ skin + tail

$frame dblstand1 dblstand2 dblstand3 dblstand4 dblstand5 dblstand6 dblstand7 dblstand8 dblstand9
$frame dblstand10 dblstand11 dblstand12 dblstand13

$frame dblwalk1 dblwalk2 dblwalk3 dblwalk4 dblwalk5 dblwalk6 dblwalk7 dblwalk8

$frame dblrun1 dblrun2 dblrun3 dblrun4 dblrun5 dblrun6

$frame dblleap1 dblleap2 dblleap3 dblleap4 dblleap5 dblleap6 dblleap7 dblleap8 dblleap9 dblleap10
$frame dblleap11 dblleap12

$frame dblpain1 dblpain2 dblpain3 dblpain4 dblpain5 dblpain6

$frame dbldeath1 dbldeath2 dbldeath3 dbldeath4 dbldeath5 dbldeath6 dbldeath7 dbldeath8 dbldeath9

$frame dblattacka1 dblattacka2 dblattacka3 dblattacka4 dblattacka5 dblattacka6 dblattacka7 dblattacka8
$frame dblattacka9 dblattacka10 dblattacka11 dblattacka12 dblattacka13 dblattacka14 dblattacka15

// super demon
$frame superstand1 superstand2 superstand3 superstand4 superstand5 superstand6 superstand7 superstand8 superstand9
$frame superstand10 superstand11 superstand12 superstand13

$frame superwalk1 superwalk2 superwalk3 superwalk4 superwalk5 superwalk6 superwalk7 superwalk8

$frame superrun1 superrun2 superrun3 superrun4 superrun5 superrun6

$frame superleap1 superleap2 superleap3 superleap4 superleap5 superleap6 superleap7 superleap8 superleap9 superleap10
$frame superleap11 superleap12

$frame superpain1 superpain2 superpain3 superpain4 superpain5 superpain6

$frame superdeath1 superdeath2 superdeath3 superdeath4 superdeath5 superdeath6 superdeath7 superdeath8 superdeath9

$frame superattacka1 superattacka2 superattacka3 superattacka4 superattacka5 superattacka6 superattacka7 superattacka8
$frame superattacka9 superattacka10 superattacka11 superattacka12 superattacka13 superattacka14 superattacka15

// extra mad

$frame semstand1 semstand2 semstand3 semstand4 semstand5 semstand6 semstand7 semstand8 semstand9
$frame semstand10 semstand11 semstand12 semstand13

$frame semwalk1 semwalk2 semwalk3 semwalk4 semwalk5 semwalk6 semwalk7 semwalk8

$frame semrun1 semrun2 semrun3 semrun4 semrun5 semrun6

$frame semleap1 semleap2 semleap3 semleap4 semleap5 semleap6 semleap7 semleap8 semleap9 semleap10
$frame semleap11 semleap12

$frame sempain1 sempain2 sempain3 sempain4 sempain5 sempain6

$frame semdeath1 semdeath2 semdeath3 semdeath4 semdeath5 semdeath6 semdeath7 semdeath8 semdeath9

$frame semattacka1 semattacka2 semattacka3 semattacka4 semattacka5 semattacka6 semattacka7 semattacka8
$frame semattacka9 semattacka10 semattacka11 semattacka12 semattacka13 semattacka14 semattacka15

*/
//============================================================================

#define	DEMON_DBL		2
#define	DEMON_SUPER		MFL_SUPER
#define	DEMON_BOB		8
#define	DEMON_SUPER_MAD		MFL_SXMAD		// got extra mad
#define	DEMON_BOOM		32		// raged and exploding

#define	super_demon_chance		0.08
#define	dbl_demon_chance		0.25
#define	super_demon_emheal		100		// how much a super demon thats extra mad could heal in a pain frame
#define	super_demon_emheal_chn		0.33		// chance to heal

/*
void()	demon1_stand1	=[	$stand1,	demon1_stand2	] {ai_stand();};
void()	demon1_stand2	=[	$stand2,	demon1_stand3	] {ai_stand();};
void()	demon1_stand3	=[	$stand3,	demon1_stand4	] {ai_stand();};
void()	demon1_stand4	=[	$stand4,	demon1_stand5	] {ai_stand();};
void()	demon1_stand5	=[	$stand5,	demon1_stand6	] {ai_stand();};
void()	demon1_stand6	=[	$stand6,	demon1_stand7	] {ai_stand();};
void()	demon1_stand7	=[	$stand7,	demon1_stand8	] {ai_stand();};
void()	demon1_stand8	=[	$stand8,	demon1_stand9	] {ai_stand();};
void()	demon1_stand9	=[	$stand9,	demon1_stand10	] {ai_stand();};
void()	demon1_stand10	=[	$stand10,	demon1_stand11	] {ai_stand();};
void()	demon1_stand11	=[	$stand11,	demon1_stand12	] {ai_stand();};
void()	demon1_stand12	=[	$stand12,	demon1_stand13	] {ai_stand();};
void()	demon1_stand13	=[	$stand13,	demon1_stand1	] {ai_stand();};
*/

framerloop($stand1, $stand13, demon1_stand1, 0.1,ai_stand());

// demon summons aid
/*

decided not too - super demon is one bad mofo, and would NOT ask for any help

	if (self.frame == $stand5)
	if (self.spawnflags & SUPER)
	if ((time & SV_CKTIME) == SV_CKTIME)
	if (random() < 0.25)
		SummonMonster("monster_dog");
*/

/*
void()	demon1_walk1	=[	$walk1,		demon1_walk2	] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_walk(8);
};
void()	demon1_walk2	=[	$walk2,		demon1_walk3	] {ai_walk(6);};
void()	demon1_walk3	=[	$walk3,		demon1_walk4	] {ai_walk(6);};
void()	demon1_walk4	=[	$walk4,		demon1_walk5	] {ai_walk(7);};
void()	demon1_walk5	=[	$walk5,		demon1_walk6	] {ai_walk(4);};
void()	demon1_walk6	=[	$walk6,		demon1_walk7	] {ai_walk(6);};
void()	demon1_walk7	=[	$walk7,		demon1_walk8	] {ai_walk(10);};
void()	demon1_walk8	=[	$walk8,		demon1_walk1	] {ai_walk(10);};
*/

framerloop($walk1, $walk8, demon1_walk1, 0.1,

	frame_arb($walk1,if (random() < 0.2) sound(self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE));

	ai_rep($walk1, ai_walk, 8, 6, 6, 7, 4, 6, 10, 10);
);

/*
void()	demon1_run1	=[	$run1,		demon1_run2	] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_run(20);};
void()	demon1_run2	=[	$run2,		demon1_run3	] {ai_run(15);};
void()	demon1_run3	=[	$run3,		demon1_run4	] {ai_run(36);};
void()	demon1_run4	=[	$run4,		demon1_run5	] {ai_run(20);};
void()	demon1_run5	=[	$run5,		demon1_run6	] {ai_run(15);};
void()	demon1_run6	=[	$run6,		demon1_run1	] {ai_run(36);};
*/

framerloop($run1, $run6, demon1_run1, 0.1,

	frame_arb($run1, if (random() < 0.2) sound(self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE));

	ai_rep($run1, ai_run, 20, 15, 36, 20, 15, 36, -6, -6);
);

/*
void()	demon1_jump1	=[	$leap1,		demon1_jump2	] {ai_face();};
void()	demon1_jump2	=[	$leap2,		demon1_jump3	] {ai_face();};
void()	demon1_jump3	=[	$leap3,		demon1_jump4	] {ai_face();};
void()	demon1_jump4	=[	$leap4,		demon1_jump5	]
{
	ai_face();
	
	self.touch = Monster_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 250';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	demon1_jump5	=[	$leap5,		demon1_jump6	] {};
void()	demon1_jump6	=[	$leap6,		demon1_jump7	] {};
void()	demon1_jump7	=[	$leap7,		demon1_jump8	] {};
void()	demon1_jump8	=[ 	$leap8,		demon1_jump9	] {};
void()	demon1_jump9	=[ 	$leap9,		demon1_jump10	] {};
void()	demon1_jump10	=[ 	$leap10,	demon1_jump1	] {
self.nextthink = time + 3;
};
*/

// if three rels pass, assume demon is stuck and jump again

framerloop($leap1, $leap10, demon1_jump1, 0.1,

	framerange_arb($leap1,$leap3,ai_face());
	frame_arb($leap4,

		ai_face();
		
		self.touch = Monster_JumpTouch;
		makevectors (self.angles);
		self.origin_z = self.origin_z + 1;
		self.velocity = v_forward * 600 + '0 0 250';
		if (self.flags & FL_ONGROUND)
			self.flags = self.flags - FL_ONGROUND;
		self.dmg = 40;
		self.jump_vel = 400;

	);
	frame_arb($leap10,self.nextthink = time + 3);
);


void()	demon1_jump11	=[ 	$leap11,	demon1_jump12	] {};
void()	demon1_jump12	=[ 	$leap12,	demon1_run1	] {};


/*
void()	demon1_atta1	=[	$attacka1,		demon1_atta2	] {ai_charge(4);};
void()	demon1_atta2	=[	$attacka2,		demon1_atta3	] {ai_charge(0);};
void()	demon1_atta3	=[	$attacka3,		demon1_atta4	] {ai_charge(0);};
void()	demon1_atta4	=[	$attacka4,		demon1_atta5	] {ai_charge(1);};
void()	demon1_atta5	=[	$attacka5,		demon1_atta6	] {ai_charge(2); Demon_Melee(200);};
void()	demon1_atta6	=[	$attacka6,		demon1_atta7	] {ai_charge(1);};
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	] {ai_charge(6);};
void()	demon1_atta8	=[	$attacka8,		demon1_atta9	] {ai_charge(8);};
void()	demon1_atta9	=[	$attacka9,		demon1_atta10] {ai_charge(4);};
void()	demon1_atta10	=[	$attacka10,		demon1_atta11] {ai_charge(2);};
void()	demon1_atta11	=[	$attacka11,		demon1_atta12] {Demon_Melee(-200);};
void()	demon1_atta12	=[	$attacka12,		demon1_atta13] {ai_charge(5);};
void()	demon1_atta13	=[	$attacka13,		demon1_atta14] {ai_charge(8);};
void()	demon1_atta14	=[	$attacka14,		demon1_atta15] {ai_charge(4);};
void()	demon1_atta15	=[	$attacka15,		demon1_run1] {ai_charge(4);};
*/

framer($attacka1, $attacka15, demon1_atta1, demon1_run1, 0.1,

	frame_arb($attacka5, Demon_Melee(200)

#ifdef monsters_plus
		if (self.spawnflags & 6) Demon_Melee(200);
#endifdef
	);
	frame_arb($attacka11, Demon_Melee(-200)

#ifdef monsters_plus
		if (self.spawnflags & 6) Demon_Melee(-200);
#endifdef
	);

	ai_rep($attacka1, ai_charge, 4, 0, 0, 1, 2, 1, 6, 8);
	ai_rep($attacka9, ai_charge, 4, 2, -6, 5, 8, 4, 4, -6);
);

/*
void()	demon1_pain1	=[	$pain1,		demon1_pain2	] {};
void()	demon1_pain2	=[	$pain2,		demon1_pain3	] {};
void()	demon1_pain3	=[	$pain3,		demon1_pain4	] {};
void()	demon1_pain4	=[	$pain4,		demon1_pain5	] {};
void()	demon1_pain5	=[	$pain5,		demon1_pain6	] {};
void()	demon1_pain6	=[	$pain6,		demon1_run1	] {};
*/

framer($pain1, $pain6, demon1_pain1, demon1_run1, 0.1,SUB_Null());

void(entity attacker, float damage)	demon1_pain =
{
	if (self.touch == Monster_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
    sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);

	if (random()*200 > damage)
		return;		// didn't flinch
		
	demon1_pain1 ();
};

/*
void()	demon1_die1		=[	$death1,		demon1_die2	] {
sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);};
void()	demon1_die2		=[	$death2,		demon1_die3	] {};
void()	demon1_die3		=[	$death3,		demon1_die4	] {};
void()	demon1_die4		=[	$death4,		demon1_die5	] {};
void()	demon1_die5		=[	$death5,		demon1_die6	] {};
void()	demon1_die6		=[	$death6,		demon1_die7	]
{self.solid = SOLID_NOT;};
void()	demon1_die7		=[	$death7,		demon1_die8	] {};
void()	demon1_die8		=[	$death8,		demon1_die9	] {};
void()	demon1_die9		=[	$death9,		demon1_die9 ] {};
*/

framer($death1, $death9, demon1_die1, SUB_Null, 0.1,

	frame_arb($death1,sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM));
	frame_arb($death6,self.solid = SOLID_NOT);
	
);

void() demon_die =
{
// check for gib
	self.dmg = -80;
#ifdef monsters_plus
	if (self.spawnflags & DEMON_DBL) self.dmg = -100;
	if (self.spawnflags & DEMON_SUPER) self.dmg = -350;

	if (self.flags & FL_DEMONBOOM) // heh heh - little enhancement, mostly for player morph
	{
		self.attack_finished = 0; // make sure we boom
		player_demon_explode();
		return;
	}
#endifdef

	if (self.health < self.dmg)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_demon.mdl", self.health);
#ifdef monsters_plus
		if (self.spawnflags & DEMON_SUPER) self.scale = 1.6;
#endifdef
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		return;
	}

// regular death
	demon1_die1 ();
};

/*
void() Demon_MeleeAttack =
{
	demon1_atta1 ();
};
*/



/*
==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============

this code is pointless

float()	CheckDemonMelee =
{
	if (enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};
*/

/*
==============
CheckDemonJump

==============
*/
float()	CheckDemonJump =
{
//	local	vector	dist;
//	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;
		
	self.v__ = self.enemy.origin - self.origin;
	self.v___z = 0;
	
	self.f__ = vlen(self.v__);

	if (self.f__ < self.dest2_x) // 100	// spot2_
		return FALSE;
		
	if (self.f__ > self.dest2_y) // 200	// spot2_
	{
		if ((random() < 0.9) || self.dest2_z)		// spot2_
			return FALSE;
	}

	return TRUE;
};

float()	DemonCheckAttack =
{
//	local	vector	vec;	// fx_warning

// if close enough for slashing, go for it
/* 		- pointless sub call
	if (CheckDemonMelee())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}
*/
	if (enemy_range == RANGE_MELEE)
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}

// NOTE: cm2 code set these in monster setup

	self.dest2_x = 100;		// spot2_
	self.dest2_y = 200;		// spot2_
	self.dest2_z = 0;			// spot2_

	if (self.classname == "monster_dog" || self.classname == "monster_blarg")
	{
		self.dest2_x = 80;	// spot2_
		self.dest2_y = 150;	// spot2_
		self.dest2_z = 1;		// spot2_
	}

	if (self.classname == "monster_raptor")
	{
		self.dest2_x = 200;	// spot2_
		self.dest2_y = 240;	// spot2_
		self.dest2_z = 1;		// spot2_
	}

	if (CheckDemonJump())
	{
		self.attack_state = AS_MISSILE;
		if (!self.dest2_z) sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		return TRUE;
	}
	
#ifdef pointless_warning
	return FALSE;
#endifdef
};


//===========================================================================

void(float side)	Demon_Melee =
{
//	local	float	ldmg;
//	local vector	delta;
	
	ai_face ();
	walkmove (self.ideal_yaw, 12);	// allow a little closing

//	delta = self.enemy.origin - self.origin;

	if (vlen(self.enemy.origin - self.origin) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
	sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	self.ldmg_ = 10 + 5*random();
#ifdef monsters_plus
	if (self.spawnflags & DEMON_SUPER_MAD) self.ldmg_ = 60 + 60*random();
	else
	if (self.spawnflags & DEMON_SUPER) self.ldmg_ = 20 + 20*random();
#endifdef
	T_Damage (self.enemy, self, self, self.ldmg_);	

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};

/*
	Archon code:

// CLEAN: move to monster.qc or fight.qc

void()	Monster_JumpTouch =
{
	if (self.health <= 0)
		return;

	self.nextthink = time + 0.1;

	if (self.classname == "monster_young")
	if (other.classname == self.classname)
		return;

	if (other.takedamage)
	{
		if (vlen(self.velocity) > self.jump_vel) // 400 - demon, 300 - dog
		{
			if ((self.classname == "monster_demon1") &&
				self.spawnflags & DEMON_SUPER_MAD) self.dmg = 100 + 100*random();
			else
//			if (self.spawnflags & DEMON_SUPER) self.dmg = 80 + 40*random();
//			else
			self.dmg = self.dodmg + 10*random(); // 40 - demon, 10 - dog
			T_Damage (other, self, self, self.dmg);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = self._jump;
//	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = self._jump2;
//	self.nextthink = time + 0.1;
};
*/

//============================================================================

// run double demon - 4 claws for 4x the fun


//============================================================================

// run super demon - 4 super claws for 4x the super fun


//============================================================================

// run extra mad demon stuff - "oh shit son"


//============================================================================

/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush Double Super BOB MAD Boom 

--------  CAT  -------
"netname" - fast = fast demon, slow = slow demon
"speed" - 0.1 normal, 0.05 fast, 0.2 slow
"Double": double the demon, double the fun
"Super": mega demon - watch out, use with care
"BOB": use black orange beast

*/
void() monster_demon1 =
{
// override test
	if (! dm_over)			// __monster_demon1_button0		"1"
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/demon.mdl");
	precache_model ("progs/h_demon.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/demon.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 300;

	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = demon1_atta1;		// one of two attacks
	self.th_missile = demon1_jump1;			// jump attack
	self.th_pain = demon1_pain;

#ifdef monsters_plus
	self.netname = "Fiend";


	if (self.map == "dyn_sp")
	if (random() < super_demon_chance)
		self.spawnflags = self.spawnflags | DEMON_SUPER;
	else
	if (random() < dbl_demon_chance)
		self.spawnflags = self.spawnflags | DEMON_DBL;

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

// Cataboligne - 11.24.12 - super & double code
	if (self.spawnflags & DEMON_SUPER)
	{
		self.health = 600 + (100 * random()) + (100 * random());
		self.wad = "SUPER";

		self.walkframe = $superstand1;
		self.waitmax = 4;
// jumptouch multi
		self.dodmg = 90;
	}
	else
	if (self.spawnflags & DEMON_DBL)
	{
		self.health = 400;

		self.walkframe = $dblstand1;
		self.waitmax = 2;
// jumptouch multi
		self.dodmg = 60;
	}
	else
	{
		self.health = 300;

// jumptouch multi
		self.dodmg = 40;
	}
/*
jt stuff
// jumptouch multi /b
	self.jump_vel = 400;
	self._jump = demon1_jump1;
	self._jump2 = demon1_jump11;
*/
#endifdef

	walkmonster_start;
};

