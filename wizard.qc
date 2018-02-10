/*
==============================================================================

WIZARD

==============================================================================
*/

$cd id1/models/a_wizard
$origin 0 0 24
$base wizbase	
$skin wizbase

$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8
$frame hover9 hover10 hover11 hover12 hover13 hover14 hover15

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10
$frame fly11 fly12 fly13 fly14

$frame magatt1 magatt2 magatt3 magatt4 magatt5 magatt6 magatt7
$frame magatt8 magatt9 magatt10 magatt11 magatt12 magatt13

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7 death8


/*
==============================================================================

WIZARD

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/

#define W_LAVA 2 // lava wixard
#define W_POISON 4 // poison wixard
#define W_2HEAD 8 // 2 heads
#define W_SPIKE 32 // xtra spikes
// super is now an extra bit
//#define W_LGSPIKE 32 // large with xtra spikes
#define W_3SPIKE 64 // 3 heads xtra spikes
//#define W_SUP3SPIKE 128 // super size 3 heads xtra spikes
#define W_UPG 110 // any upgrade bit
#define W_UPGM 96 // all mega upgrade bits - no 2 head, no lava, and no poison

#define wl_track 0.6 // chance a shot will be tracker
#define wl_track_dmg 20  // damage done by tracker explode

/*
=============
LaunchMissile

Sets the given entities velocity and angles so that it will hit self.enemy
if self.enemy maintains it's current velocity
0.1 is moderately accurate, 0.0 is totally accurate
=============
*/

#ifdef unused

void(entity missile, float mspeed, float accuracy) LaunchMissile =
{
	local	vector	vec, move;
	local	float	fly;

	makevectors (self.angles);
		
// set missile speed
	vec = self.enemy.origin + self.enemy.mins + self.enemy.size * 0.7 - missile.origin;

// calc aproximate time for missile to reach vec
	fly = vlen (vec) / mspeed;
	
// get the entities xy velocity
	move = self.enemy.velocity;
	move_z = 0;

// project the target forward in time
	vec = vec + move * fly;
	
	vec = normalize(vec);
	vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5);
	
	missile.velocity = vec * mspeed;

	missile.angles = '0 0 0';
	missile.angles_y = vectoyaw(missile.velocity);

// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;	
};

#endifdef

void() wiz_run1;
void() wiz_side1;

/*
=================
WizardCheckAttack
=================
*/
float()	WizardCheckAttack =
{
//	local vector	spot1, spot2;	
//	local entity	targ;
//	local float		chance;

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_vis)
		return FALSE;

	if (enemy_range == RANGE_FAR)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}
		
//	targ = self.enemy;
	
// see if any entities are in the way of the shot
//	spot1 = self.origin + self.view_ofs;
//	spot2 = targ.origin + targ.view_ofs;

	traceline ((self.origin + self.view_ofs), (self.enemy.origin + self.enemy.view_ofs), FALSE, self);

	if (trace_ent != self.enemy)
	{	// don't have a clear shot, so move to a side
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
		return FALSE;
	}
			
	if (enemy_range == RANGE_MELEE)
	{
#ifdef monsters_plus__
		if (self.spawnflags & W_LAVA) // lava wizards can "flame ON" with an enemy in melee range
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
#endifdef
		self.rnd_ = 0.9;
	}
	else if (enemy_range == RANGE_NEAR)
		self.rnd_ = 0.6;
	else if (enemy_range == RANGE_MID)
		self.rnd_ = 0.2;
	else
		self.rnd_ = 0;

	if (random () < self.rnd_)
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	if (enemy_range == RANGE_MID)
	{
		if (self.attack_state != AS_STRAIGHT)
		{
			self.attack_state = AS_STRAIGHT;
			wiz_run1 ();
		}
	}
	else
	{
		if (self.attack_state != AS_SLIDING)
		{
			self.attack_state = AS_SLIDING;
			wiz_side1 ();
		}
	}

#ifdef pointless_warning
	return FALSE;
#endifdef
};

/*
=================
WizardAttackFinished
=================
*/
//float()	WizardAttackFinished =	// fx_warning
void()	WizardAttackFinished =
{
	if (enemy_range >= RANGE_MID || !enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		self.think = wiz_run1;
	}
	else
	{
		self.attack_state = AS_SLIDING;
		self.think = wiz_side1;
	}
};

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void() Wiz_FastFire =
{
//	local vector		vec;
//	local vector		dst;

	if (self.owner.health > 0)
	{
		self.owner.effects = self.owner.effects | EF_MUZZLEFLASH;

		makevectors (self.enemy.angles);	
//		dst = self.enemy.origin - 13*self.movedir;
	
//		vec = normalize(dst - self.origin);
		self.v__ = normalize((self.enemy.origin - 13*self.movedir) - self.origin);
		sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.v__);
		newmis.velocity = self.v__ * 600;
		newmis.owner = self.owner;
		newmis.classname = "wizspike";
		setmodel (newmis, "progs/w_spike.mdl");
#ifdef monsters_plus__
		newmis.wad = self.wad;
		if (self.spawnflags & W_LAVA)
		{
			setmodel (newmis, "progs/lavaball.mdl");
			newmis.classname = "fireballwep";					// FIX: not coded

			if (self.spawnflags & MFL_SUPER) // BOOM!
			{
				sound (self, CHAN_WEAPON, "chaos/incoming.wav", 1, ATTN_NORM);
//				newmis.velocity = vec*600;
				newmis.frame = 20;
				newmis.dmg = 85;
				newmis.touch = T_MissileTouch; // rocket explosion
			}
			else
			{
				sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);
				newmis.velocity = self.v__ * (700 + (ceil(3 * random()) * 100));
				newmis.frame = 22 + floor(random() * 1.4);
				newmis.touch = fire_touch;				// fire_fly_touch; FIX: not impl
				newmis.dmg = 20;
			}
		}
		else
		if (self.spawnflags & MFL_SUPER) // BOOM!
		{
			newmis.velocity = self.v__ * 400;
			newmis.frame = 1;
			newmis.dmg = 40 + random() * 10;
			newmis.touch = T_MissileTouch; // rocket explosion
		}
#endifdef

		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	}

	remove (self);
};

#ifdef monsters_plus__
// Wiz fire repeating - some scragg get a lot more attacks

void(float wf_fwd, float wf_rt, vector wf_v, float wf_tm) Wiz_Firerep =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.spawnflags = self.spawnflags;
	newmis.nextthink = time + 1;
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin (newmis, self.origin + wf_v + v_forward * wf_fwd + v_right * wf_rt);
	newmis.enemy = self.enemy;
	newmis.nextthink = time + wf_tm;
	newmis.think = Wiz_FastFire;
	if (wf_rt <= 0)
		newmis.movedir = '0 0 0' - v_right;
	else
		newmis.movedir = v_right;
};
#endifdef

void() Wiz_StartFast =
{
//	local	entity	missile;
	
	sound (self, CHAN_WEAPON, "wizard/wattack.wav", 1, ATTN_NORM);
	self.v_angle = self.angles;
	makevectors (self.angles);

	newmis = spawn ();
	newmis.owner = self;
	newmis.nextthink = time + 0.6;
//	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin + '0 0 30' + v_forward*14 + v_right*14);
	newmis.enemy = self.enemy;
	newmis.nextthink = time + 0.8;
	newmis.think = Wiz_FastFire;
	newmis.movedir = v_right;

	newmis = spawn ();
	newmis.owner = self;
	newmis.nextthink = time + 1;
//	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin + '0 0 30' + v_forward*14 + v_right* -14);
	newmis.enemy = self.enemy;
	newmis.nextthink = time + 0.3;
	newmis.think = Wiz_FastFire;
	newmis.movedir = VEC_ORIGIN - v_right;
};



void() Wiz_idlesound =
{
//local float wr;
	self.rnd_ = random() * 5;

	if (self.waitmin < time)
	{
	 	self.waitmin = time + 2;
	 	if (self.rnd_ > 4.5) 
	 		sound (self, CHAN_VOICE, "wizard/widle1.wav", 1,  ATTN_IDLE);
	 	if (self.rnd_ < 1.5)
	 		sound (self, CHAN_VOICE, "wizard/widle2.wav", 1, ATTN_IDLE);
	}
//	return;
};


/*
void()	wiz_stand1	=[	$hover1,		wiz_stand2	] {ai_stand();};
void()	wiz_stand2	=[	$hover2,		wiz_stand3	] {ai_stand();};
void()	wiz_stand3	=[	$hover3,		wiz_stand4	] {ai_stand();};
void()	wiz_stand4	=[	$hover4,		wiz_stand5	] {ai_stand();};
void()	wiz_stand5	=[	$hover5,		wiz_stand6	] {ai_stand();};
void()	wiz_stand6	=[	$hover6,		wiz_stand7	] {ai_stand();};
void()	wiz_stand7	=[	$hover7,		wiz_stand8	] {ai_stand();};
void()	wiz_stand8	=[	$hover8,		wiz_stand1	] {ai_stand();};
*/

framerloop($hover1, $hover8, wiz_stand1, 0.1,

	ai_stand();
#ifdef monsters_plus__
	frame_arb($hover3,
		if (SV_MINEALLOW & CB_M_SCRAG)
		if (self.spawnflags & MFL_SUPER)
		if ((time & SV_CKTIME) == SV_CKTIME)
		if (random() < 0.5)
			SummonMonster(string_null);
	);
#endifdef


);

/*
void()	wiz_walk1	=[	$hover1,		wiz_walk2	] {ai_walk(8);
Wiz_idlesound();};
void()	wiz_walk2	=[	$hover2,		wiz_walk3	] {ai_walk(8);};
void()	wiz_walk3	=[	$hover3,		wiz_walk4	] {ai_walk(8);};
void()	wiz_walk4	=[	$hover4,		wiz_walk5	] {ai_walk(8);};
void()	wiz_walk5	=[	$hover5,		wiz_walk6	] {ai_walk(8);};
void()	wiz_walk6	=[	$hover6,		wiz_walk7	] {ai_walk(8);};
void()	wiz_walk7	=[	$hover7,		wiz_walk8	] {ai_walk(8);};
void()	wiz_walk8	=[	$hover8,		wiz_walk1	] {ai_walk(8);};
*/

framerloop($hover1, $hover8, wiz_walk1, 0.1,

	ai_walk(8);
	frame_arb($hover1,Wiz_idlesound());
#ifdef monsters_plus__
	frame_arb($hover3,
		if (SV_MINEALLOW & CB_M_SCRAG)
		if (self.spawnflags & MFL_SUPER)
		if ((time & SV_CKTIME) == SV_CKTIME)
			SummonMonster(string_null);
	);
#endifdef
);

/*
void()	wiz_side1	=[	$hover1,		wiz_side2	] {ai_run(8);
Wiz_idlesound();};
void()	wiz_side2	=[	$hover2,		wiz_side3	] {ai_run(8);};
void()	wiz_side3	=[	$hover3,		wiz_side4	] {ai_run(8);};
void()	wiz_side4	=[	$hover4,		wiz_side5	] {ai_run(8);};
void()	wiz_side5	=[	$hover5,		wiz_side6	] {ai_run(8);};
void()	wiz_side6	=[	$hover6,		wiz_side7	] {ai_run(8);};
void()	wiz_side7	=[	$hover7,		wiz_side8	] {ai_run(8);};
void()	wiz_side8	=[	$hover8,		wiz_side1	] {ai_run(8);};

void()	wiz_run1	=[	$fly1,		wiz_run2	] {ai_run(16);
Wiz_idlesound();
};
void()	wiz_run2	=[	$fly2,		wiz_run3	] {ai_run(16);};
void()	wiz_run3	=[	$fly3,		wiz_run4	] {ai_run(16);};
void()	wiz_run4	=[	$fly4,		wiz_run5	] {ai_run(16);};
void()	wiz_run5	=[	$fly5,		wiz_run6	] {ai_run(16);};
void()	wiz_run6	=[	$fly6,		wiz_run7	] {ai_run(16);};
void()	wiz_run7	=[	$fly7,		wiz_run8	] {ai_run(16);};
void()	wiz_run8	=[	$fly8,		wiz_run9	] {ai_run(16);};
void()	wiz_run9	=[	$fly9,		wiz_run10	] {ai_run(16);};
void()	wiz_run10	=[	$fly10,		wiz_run11	] {ai_run(16);};
void()	wiz_run11	=[	$fly11,		wiz_run12	] {ai_run(16);};
void()	wiz_run12	=[	$fly12,		wiz_run13	] {ai_run(16);};
void()	wiz_run13	=[	$fly13,		wiz_run14	] {ai_run(16);};
void()	wiz_run14	=[	$fly14,		wiz_run1	] {ai_run(16);};
*/

framerloop($hover1, $hover8, wiz_side1, 0.1,

	ai_run(8);
	frame_arb($hover1,Wiz_idlesound());
);

framerloop($fly1, $fly14, wiz_run1, 0.1,

	ai_run(16);
	frame_arb($fly1,Wiz_idlesound());

#ifdef monsters_plus__
	if (self.spawnflags & MFL_SUPER)
	if ((time & SV_CKTIME) == SV_CKTIME)
	{
		s7__ = "owner";
		self.count = cnt_ent(world, class_select, "class_monster");
		if (self.count < 4 + skill)
		{
			self.cnt = random();
			if (self.cnt < 0.45) SummonMonster("monster_wizard");
			else if (self.cnt < 0.55) SummonMonster("monster_spider");
		}
	}
#endifdef

);

/*
void()	wiz_fast1	=[	$magatt1,		wiz_fast2	] {ai_face();Wiz_StartFast();};
void()	wiz_fast2	=[	$magatt2,		wiz_fast3	] {ai_face();};
void()	wiz_fast3	=[	$magatt3,		wiz_fast4	] {ai_face();};
void()	wiz_fast4	=[	$magatt4,		wiz_fast5	] {ai_face();};
void()	wiz_fast5	=[	$magatt5,		wiz_fast6	] {ai_face();};
void()	wiz_fast6	=[	$magatt6,		wiz_fast7	] {ai_face();};
*/

void()	wiz_fast7	=[	$magatt5,		wiz_fast8	] {ai_face();};
void()	wiz_fast8	=[	$magatt4,		wiz_fast9	] {ai_face();};
void()	wiz_fast9	=[	$magatt3,		wiz_fast10	] {ai_face();};
void()	wiz_fast10	=[	$magatt2,		wiz_run1	] {ai_face();SUB_AttackFinished(2);WizardAttackFinished ();};

framer($magatt1, $magatt6, wiz_fast1, wiz_fast7, 0.1,

	ai_face();
	frame_arb($magatt1,Wiz_StartFast());
);

/*
void()	wiz_pain1	=[	$pain1,		wiz_pain2	] {};
void()	wiz_pain2	=[	$pain2,		wiz_pain3	] {};
void()	wiz_pain3	=[	$pain3,		wiz_pain4	] {};
void()	wiz_pain4	=[	$pain4,		wiz_run1	] {};
*/

framer($pain1, $pain4, wiz_pain1, wiz_run1, 0.1,SUB_Null());

void()	wiz_death1	=[	$death1,		wiz_death2	] {

self.velocity_x = -200 + 400*random();
self.velocity_y = -200 + 400*random();
self.velocity_z = 100 + 100*random();
self.flags = self.flags - (self.flags & FL_ONGROUND);
sound (self, CHAN_VOICE, "wizard/wdeath.wav", 1, ATTN_NORM);
};
/*
void()	wiz_death2	=[	$death2,		wiz_death3	] {};
void()	wiz_death3	=[	$death3,		wiz_death4	]{self.solid = SOLID_NOT;};
void()	wiz_death4	=[	$death4,		wiz_death5	] {};
void()	wiz_death5	=[	$death5,		wiz_death6	] {};
void()	wiz_death6	=[	$death6,		wiz_death7	] {};
void()	wiz_death7	=[	$death7,		wiz_death8	] {};
void()	wiz_death8	=[	$death8,		wiz_death8	] {};
*/

framer($death2, $death8, wiz_death2, SUB_Null, 0.1,frame_arb($death3,self.solid = SOLID_NOT;));


void() wiz_die =
{
	self.dmg = -40;
#ifdef monsters_plus__
	if (self.gibdmg < self.dmg) self.dmg = self.gibdmg;
#endifdef

// check for gib
	if (self.health < self.dmg)
	{
#ifdef monsters_plus__
		if (self.spawnflags & 72) // 2 & 3 head - 8, 64
		{
			ThrowGib ("progs/h_wizard.mdl", self.health);
			nspawn.scale = self.scale;
			newmis.nextthink = time + 60 + random()*60;
		}
		if (self.spawnflags & W_3SPIKE) // 3 heads
		{
			ThrowGib ("progs/h_wizard.mdl", self.health);
			nspawn.scale = self.scale;
			newmis.nextthink = time + 60 + random()*60;
		}
#endifdef

		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_wizard.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		return;
	}

	wiz_death1 ();
};


void(entity attacker, float damage) Wiz_Pain =
{
	sound (self, CHAN_VOICE, "wizard/wpain.wav", 1, ATTN_NORM);
	if (random()*70 > damage)
		return;		// didn't flinch

	wiz_pain1 ();
};

/*
	more pointless code

void() Wiz_Missile =
{
	wiz_fast1();
};
*/

#ifdef monsters_plus__
// flame ON

// notes: added 28 numglobaldefs (of 32768)

// fn(firestrike_flame) - make some fires for strike
// IDEA - fill a rectang volume


// torg - target origin
// am - amount of fires
// mds - min distance from center - flames will always be further away
// tdz - z distance var, +z < -z + (z * 60%)
// tds - distance of strike sphere

void(vector torg, float am, float mds, float tdz, float tds) firestrike_flame =
{
	local float d, c1;
	local vector v1;
	
	d = am;
	while (d > 0) // flame on!
	{
		d = d - 1;
		v1_x = mds + crandom() * (tds - (mds * 0.5));
		v1_y = mds + crandom() * (tds - (mds * 0.5));
		v1_z = crandom() * tdz + (tdz * 0.6); // 60% ratio upwards
		c1 = pointcontents(torg + v1);
#ifdef code_viswep
// requires flamer module
		if (c1 != CONTENT_WATER && c1 != CONTENT_SOLID && c1 != CONTENT_SKY) // IDEA - sky_touch?
			SpawnTouchFlame(torg + v1);
		if (random() < 0.08)
		sound (newmis, CHAN_BODY, "flm/burning.wav", 1, ATTN_NORM);
#endifdef
	}
};

framer($hover3, $hover7, wizard_firestrike3, wiz_run1, 0.1,

	frame_arb($hover3, firestrike_flame(self.origin, 2 + random() * 2, 32, 80 / 1.6, 80); ai_walk(4));
	frametwo_arb($hover5,$hover6, firestrike_flame(self.origin, 2 + random() * 2, 32, 80 / 1.6, 80); ai_walk(4));
	frametwo_arb($hover4,$hover7,ai_walk(4));

);

void () wizard_firestrike1  = [ $hover1,  wizard_firestrike2  ] { firestrike_flame(self.origin, 2 + random() * 2, 32, 80 / 1.6, 80); ai_walk(4); };
void () wizard_firestrike2  = [ $hover2,  wizard_firestrike3  ]
{
	#define MAX_EFFECT_DIST 180 // no effect at all beyond this dist

	e0__ = findradius(self.origin, MAX_EFFECT_DIST);
	while (e0__)
	{
		if (e0__ != self)
//		if (e0__.takedamage) - for when non slidebox stuff can burn
		if (e0__.solid == SOLID_SLIDEBOX)  // this is one for sure that we might want FL_CLIENT, FL_MONSTER so its more inclusive
		{
			if (e0__.takedamage)
			{
				if (e0__.waterlevel < 2)
				if (random() < 0.9)
				if (!(e0__.flags & FL_ONFIRE)) // set em on fire
				{
					e0__.flags = e0__.flags | FL_ONFIRE;
					nspawn = chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0, ' 0 0 -30000', '0 0 0', '0 0 0', '0 0 0', '0 0 0', string_null, string_null, SUB_Null, 0.1, BurnThem, SUB_Null, self, world);
					nspawn.enemy = e0__;
				}
				T_FireDamage (e0__, self, self, 5 + (random() * 5) - e0__.waterlevel * 3); // IDEA build up pyro?
			}
		}
		e0__ = e0__.chain;
	}
	 ai_walk(4);
};
/*
void () wizard_firestrike3  = [ $hover3,  wizard_firestrike4  ] { firestrike_flame(self.origin, 2 + random() * 2, 32, 80 / 1.6, 80); ai_walk(4); };
void () wizard_firestrike4  = [ $hover4,  wizard_firestrike5  ] { ai_walk(4); };
void () wizard_firestrike5  = [ $hover5,  wizard_firestrike6  ] { firestrike_flame(self.origin, 2 + random() * 2, 32, 80 / 1.6, 80); ai_walk(4); };
void () wizard_firestrike6  = [ $hover6,  wizard_firestrike7  ] { firestrike_flame(self.origin, 2 + random() * 2, 32, 80 / 1.6, 80); ai_walk(4); };
void () wizard_firestrike7  = [ $hover7,  wiz_run1           ] { ai_walk(4); };
*/

#endifdef

/*QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) Ambush Lava Poison Twohead Spike LargeSpike TripleSpike ExlTripleSpike

"Lava" - lava skin scragg, shoots lava balls, more health, faster, badder
"Poison" - Toxic Green skin scragg, shoots poison tracers, more health

Note: any of these can be lava or poison
"TwoHead" - two heads are better than one, double health, double attacks
"Spike" - extra spikes, extra health, extra attacks, more magic
"LargeSpike" - larger more badass version of spike scragg
"TripleSpike" - Three headed spike scragg - triple spike health, 6x attacks, 
"SupsTripleSpike" - Super Three headed spike scragg - monster id card says "bad-ass motherfucker"

*/

#define wl_lava 0.25 // chance of any upgrade going lava
#define wl_2head 0.85 // chance of two head upgrade - because upgrade is auto 2 head
#define wl_spike 0.6 // chance of spike upgrade
#define wl_lgspike 0.3 // chance of large spike upgrade
#define wl_3spike 0.2 // chance of 3 head spike upgrade
#define wl_sup3spike 0.05 // chance of super 3 head spike upgrade

#define wl_rnd 0.8 // total chance for a better random wixard
#define wl_imp 0.1 // total chance for a better map wixard
float rnd_super_spike3; // limited number of these will appear

/*
overall chances:
	map wizard - 10%
	rnd wizard - 80%
	go lava - 25%

upgrade breakdown:
	40%	- 2 head
	30%	- spike
	10%	- large spike
	15%	- 3 head spike
	5% 	- super 3 head spike
*/

void() monster_wizard =
{
// override test
	if (! dm_over)			// __monster_wizard_button0		"1"
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/wizard.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_model ("progs/w_spike.mdl");

	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/wizard.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 80;

	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = wiz_fast1;
	self.th_pain = Wiz_Pain;
	self.th_die = wiz_die;

#ifdef monsters_plus

	self.a__ = FALSE;

//	if (ENHANCED)
//	if (ENH_Q1_MAP_MONSTERS || (ign == A_MONSTER))
	if (self.map	== "dyn_sp")
		self.a__ = TRUE;

	if ((self.a__) || (self.spawnflags & W_UPG))
	{
		self.rnd_ = wl_imp;
		if (skill == 3) self.rnd_ = wl_imp + wl_imp;
		if (self.map == "dyn_sp") self.rnd_ = wl_rnd;

		if (!self.spawnflags & W_UPG) // not map specced - enhance him
		if (random() < self.rnd_)
		{
			self.a__ = W_2HEAD;
	
			self.rnd_ = random(); // pick an upgrade
			if ((self.rnd_ < wl_sup3spike) && (rnd_super_spike3 < (skill + 1))) self.a__ = W_SUP3SPIKE;
			else if (self.rnd_ < wl_3spike) self.a__ = W_3SPIKE;
			else if (self.rnd_ < wl_lgspike) self.a__ = W_LGSPIKE;
			else if (self.rnd_ < wl_spike) self.a__ = W_SPIKE;

			self.spawnflags = self.spawnflags | self.a__;

// any upgrade can get lava added
			if (random() < wl_lava)
				self.spawnflags = self.spawnflags | W_LAVA;
		}

// this should be replaced by a generic cvar_fields call !
		if (self.spawnflags & W_SUP3SPIKE)
		{
			self.health = 800;
			self.walkframe = $gsx3hover1;
			self.waitmax = 16;
			self.wad = "SUPER_XMAD";
			rnd_super_spike3 = rnd_super_spike3 + 1;
			setsize (self, '-24 -24 -44', '24 24 60');
		}
		else if (self.spawnflags & W_LGSPIKE)
		{
			self.health = 480;
			self.walkframe = $lsxhover1;
			self.waitmax = 16;

			setsize (self, '-24 -24 -44', '24 24 60');
		}
		else if (self.spawnflags & W_3SPIKE)
		{
			self.health = 280;
			self.walkframe = $sx3hover1;
			self.waitmax = 10;

		}
		else if (self.spawnflags & W_SPIKE)
		{
			self.health = 180;
			self.walkframe = $sxhover1;

		}
		else if (self.spawnflags & W_2HEAD)
		{
			self.health = 120;
			self.walkframe = $thhover1;
		}

		if (self.spawnflags & W_LAVA)
		{
			self.skin = 1;
			if (!self.spawnflags & 240) // W_UPGM) // normal or 2 head had lava added
			{
				self.health = 160;
				if (random() < 0.25) self.health = 200 + random() * 100;
			}

			self.th_melee = Wiz_Flame;
		}
	}
#endifdef

	flymonster_start;
};