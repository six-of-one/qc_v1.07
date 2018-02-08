/*
==============================================================================

SHAL-RATH

==============================================================================
*/
$cd id1/models/shalrath
$origin 0 0 24
$base base
$skin skin
$scale 0.7

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11

$frame pain1 pain2 pain3 pain4 pain5 

$frame death1 death2 death3 death4 death5 death6 death7

$frame	walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame	walk11 walk12
// NOTE: how does this impach supes
$frame walkeoc

// super shalrath!
$frame lgattack1 lgattack2 lgattack3 lgattack4 lgattack5 lgattack6 lgattack7 lgattack8
$frame lgattack9 lgattack10 lgattack11

$frame lgpain1 lgpain2 lgpain3 lgpain4 lgpain5

$frame lgdeath1 lgdeath2 lgdeath3 lgdeath4 lgdeath5 lgdeath6 lgdeath7

$frame	lgwalk1 lgwalk2 lgwalk3 lgwalk4 lgwalk5 lgwalk6 lgwalk7 lgwalk8 lgwalk9 lgwalk10
$frame	lgwalk11 lgwalk12

$frame lgattackb1 lgattackb2 lgattackb3 lgattackb4

#define		SUPER_VORE		MFL_SUPER

void() shalrath_pain;
void() ShalMissile;
void() shal_stand     =[      $walk1,       shal_stand    ] 
{
#ifdef monsters_plus__
	self.count = self.count + 1;

	if (self.spawnflags & SUPER_VORE)
	{
		if (SV_MINEALLOW & CB_M_SVORE)
		if ((time & SV_CKTIME) == SV_CKTIME)
		if (self.count > 5)
		if (random() < 0.35)
		{
			SummonMonster(string_null);
			self.count = 0;
		}

// charge him up - note buku XP if killed while he has this
		if (self.archon < 100) self.archon = self.health + random() * (self.health / 2);
	}
#endifdef

	ai_stand();
};

/*
void() shal_walk1     =[      $walk2,       shal_walk2    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_walk(6);};
void() shal_walk2     =[      $walk3,       shal_walk3    ] {ai_walk(4);};
void() shal_walk3     =[      $walk4,       shal_walk4    ] {ai_walk(0);};
void() shal_walk4     =[      $walk5,       shal_walk5    ] {ai_walk(0);};
void() shal_walk5     =[      $walk6,       shal_walk6    ] {ai_walk(0);};
void() shal_walk6     =[      $walk7,       shal_walk7    ] {ai_walk(0);};
void() shal_walk7     =[      $walk8,       shal_walk8    ] {ai_walk(5);};
void() shal_walk8     =[      $walk9,       shal_walk9    ] {ai_walk(6);};
void() shal_walk9     =[      $walk10,       shal_walk10    ] {ai_walk(5);};
void() shal_walk10    =[      $walk11,       shal_walk11    ] {ai_walk(0);};
void() shal_walk11    =[      $walk12,       shal_walk12    ] {ai_walk(4);};
void() shal_walk12    =[      $walk1,       shal_walk1    ] {ai_walk(5);};
*/

//framer($walk2, $walkeoc, shal_walk1, frd1, 0.1,

/* this is a cheat - it saves 1 frame_arb
#ifdef opgrade
// note: simpler code but it runs a slightly different frame sequence on entry, starting with walk1 instead of walk2
framerloop($walk1, $walk12, shal_walk1, 0.1,

	frame_arb($walk2,if (random() < 0.2) sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE));

	ai_rep($walk1, ai_walk, 5, 6, 4, 0, 0, 0, 0, 5);
	ai_rep($walk9, ai_walk, 6, 5, 0, 4, -6, -6, -6, -6);
);

#else
*/
framerloop($walk2, $walkeoc, shal_walk1, 0.1,

	frame_arb($walk2,if (random() < 0.2) sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE));
#ifdef monsters_plus__
	frame_arb($walk7,

		if (self.spawnflags & SUPER_VORE)
		{
			if (SV_MINEALLOW & CB_M_SVORE)
			if ((time & SV_CKTIME) == SV_CKTIME) SummonMonster(string_null);

			if (self.archon < 100) self.archon = self.health + random() * (self.health / 2);
		}
	);
#endifdef

	ai_rep($walk2, ai_walk, 6, 4, 0, 0, 0, 0, 5, 6);
	ai_rep($walk10, ai_walk, 5, 0, 4, 5, -6, -6, -6, -6);
	frame_arb($walkeoc,self.frame = $walk1);
);
//#endifdef

/*
void() shal_run1     =[      $walk2,       shal_run2    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_run(6);};
void() shal_run2     =[      $walk3,       shal_run3    ] {ai_run(4);};
void() shal_run3     =[      $walk4,       shal_run4    ] {ai_run(0);};
void() shal_run4     =[      $walk5,       shal_run5    ] {ai_run(0);};
void() shal_run5     =[      $walk6,       shal_run6    ] {ai_run(0);};
void() shal_run6     =[      $walk7,       shal_run7    ] {ai_run(0);};
void() shal_run7     =[      $walk8,       shal_run8    ] {ai_run(5);};
void() shal_run8     =[      $walk9,       shal_run9    ] {ai_run(6);};
void() shal_run9     =[      $walk10,       shal_run10    ] {ai_run(5);};
void() shal_run10    =[      $walk11,       shal_run11    ] {ai_run(0);};
void() shal_run11    =[      $walk12,       shal_run12    ] {ai_run(4);};
void() shal_run12    =[      $walk1,       shal_run1    ] {ai_run(5);};
*/

//framer($walk2, $walkeoc, shal_run1, frd1, 0.1,

/* this is a cheat - it saves 1 frame_arb
#ifdef opgrade
// note: simpler code but it runs a slightly different frame sequence on entry, starting with walk1 instead of walk2
framerloop($walk1, $walk12, shal_run1, 0.1,

	frame_arb($walk2,if (random() < 0.2) sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE));

	ai_rep($walk1, ai_run, 5, 6, 4, 0, 0, 0, 0, 5);
	ai_rep($walk9, ai_run, 6, 5, 0, 4, -6, -6, -6, -6);
);

#else
*/
#ifdef monsters_plus__
// some bizzare ass compiler failure when this is in frame_arb - even tho code DOES NOT COMPILE!
void() fukee1 =
{
		if (self.spawnflags & SUPER_VORE)
#ifdef code_archon
		if (sphere_a.owner != self) // dont summon while we have the sphere
#endifdef
		if ((time & SV_CKTIME) == SV_CKTIME)
		{
			s7__ = "owner";
			self.count = cnt_ent(world, class_select, "class_monster");
			if (self.count < 4 + skill)
			{
				self.rnd_ = random();
				if (self.rnd_ < 0.15) SummonMonster("monster_shalrath");
				else if (self.rnd_ < 0.3) SummonMonster("monster_wizard");
				else if (self.rnd_ < 0.4) SummonMonster("monster_spider");
				else if (self.rnd_ < 0.6) SummonMonster("monster_vomit");
			}
		}
};

void() fukee2 =
{
		if (self.spawnflags & SUPER_VORE)
		{
			self.rnd_ = random();
			if (self.rnd_ < 0.05) self.weapon = 0; // got back to explody balls
			else 
			if (self.rnd_ < 0.12) // change weps
			{
				self.rnd_ = random();
				if (self.rnd_ < 0.3) self.weapon = IT_LIGHTNING;
				else if (self.rnd_ < 0.4) self.weapon = 2;
				else self.weapon = IT_SUPER_NAILGUN;
			}
#ifdef local_test
	// REMOVE
//		self.weapon = IT_LIGHTNING;
#endifdef
		}
};
#endifdef

framerloop($walk2, $walkeoc, shal_run1, 0.1,

	frame_arb($walk2,if (random() < 0.2) sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE));
#ifdef monsters_plus__
	frame_arb($walk5,fukee1());
#endifdef

	ai_rep($walk2, ai_run, 6, 4, 0, 0, 0, 0, 5, 6);
	ai_rep($walk10, ai_run, 5, 0, 4, 5, -6, -6, -6, -6);
	frame_arb($walkeoc,self.frame = $walk1);
);
//#endifdef

// super shal-rath - Vorerel - Vaareziel

// 2nd attack - lightning, summon sphere, portal, other magics
/*

deprecated - using player vore 2nd attack frames :TDO:

void() s_shal_attackb1     =[      $lgattackb1,       s_shal_attackb2    ] 
{
	sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM); // IMP: new sounds for super
	ai_frame(self.walkframe);
	ai_face();
};
void() s_shal_attackb2     =[      $lgattackb2,       s_shal_attackb3    ] {ai_face();ai_frame(self.walkframe);};
void() s_shal_attackb3     =[      $lgattackb3,       s_shal_attackb4    ] {ai_face();ai_frame(self.walkframe);};
void() s_shal_attackb4     =[      $lgattackb4,       s_shal_attackb5    ]
{
	ShalMissile(); // IMP: attack 2 - new att
	ai_frame(self.walkframe);
};
void() s_shal_attackb5    =[      $lgattackb3,      s_shal_attackb6   ] {ai_face();ai_frame(self.walkframe);};
void() s_shal_attackb6    =[      $lgattackb2,      shal_run1   ] {ai_frame(self.walkframe);};

*/

/*
void() shal_attack1     =[      $attack1,       shal_attack2    ] {
sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
ai_face();
};
void() shal_attack2     =[      $attack2,       shal_attack3    ] {ai_face();};
void() shal_attack3     =[      $attack3,       shal_attack4    ] {ai_face();};
void() shal_attack4     =[      $attack4,       shal_attack5    ] {ai_face();};
void() shal_attack5     =[      $attack5,       shal_attack6    ] {ai_face();};
void() shal_attack6     =[      $attack6,       shal_attack7    ] {ai_face();};
void() shal_attack7     =[      $attack7,       shal_attack8    ] {ai_face();};
void() shal_attack8     =[      $attack8,       shal_attack9    ] {ai_face();};
void() shal_attack9     =[      $attack9,       shal_attack10   ] {ShalMissile();};
void() shal_attack10    =[      $attack10,      shal_attack11   ] {ai_face();};
void() shal_attack11    =[      $attack11,      shal_run1   ] {};
*/

framer($attack1, $attack11, shal_attack1, shal_run1, 0.1,
	
	frame_arb($attack1,

#ifdef monsters_plus__
		fukee2();
#endifdef

#ifdef code_archon
		if ((sphere_a.owner == self) && self.weapon != 2) shal_run1();
		else
#endifdef
#ifdef code_morph
		if (self.weapon) player_shalrath_lightning1(); //s_shal_attackb1();
		else
#endifdef
		sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM)
	);

#ifdef monsters_plus__
	frame_arb($attack1,

		if (self.spawnflags & SUPER_VORE)
		if (random() < 0.8) ShalMissile();
	);
#endifdef

	if (self.frame == $attack9) ShalMissile();
	else ai_face();
);

/*
void() shal_pain1       =[      $pain1, shal_pain2      ] {};
void() shal_pain2       =[      $pain2, shal_pain3      ] {};
void() shal_pain3       =[      $pain3, shal_pain4      ] {};
void() shal_pain4       =[      $pain4, shal_pain5      ] {};
void() shal_pain5       =[      $pain5, shal_run1      ] {};
*/

framer($pain1, $pain5, shal_pain1, shal_run1, 0.1,SUB_Null());

/*
void() shal_death1      =[      $death1,        shal_death2     ] {};
void() shal_death2      =[      $death2,        shal_death3     ] {};
void() shal_death3      =[      $death3,        shal_death4     ] {};
void() shal_death4      =[      $death4,        shal_death5     ] {};
void() shal_death5      =[      $death5,        shal_death6     ] {};
void() shal_death6      =[      $death6,        shal_death7     ] {};
void() shal_death7      =[      $death7,        shal_death7    ] {};
*/

framer($death1, $death7, shal_death1, SUB_Null, 0.1,SUB_Null());


void() shalrath_pain =
{
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
	shal_pain1();
	self.pain_finished = time + 3;
#ifdef monsters_plus__
	if (self.spawnflags & SUPER_VORE) self.pain_finished = time + 5;
#endifdef
};

void() shalrath_die =
{
// check for gib
	self.dmg = -90;
#ifdef monsters_plus__
	if (mon_gibdmg < self.dmg) self.dmg = mon_gibdmg;
#endifdef

	if (self.health < self.dmg)
	{
/*
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_shal.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
*/
		gibbs("progs/h_shal.mdl");
		return;
	}

	sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	shal_death1();
	self.solid = SOLID_NOT;
	// insert death sounds here
};

/*
================
ShalMissile
================
*/
void() ShalMissileTouch;
void() ShalHome;
void() ShalMissile =
{
//	local	entity 	missile;
//	local	vector	dir;
//	local	float	dist, flytime;
#define flytime self.frags

	self.v__ = normalize((self.enemy.origin + '0 0 10') - self.origin);
//	dist = vlen(self.enemy.origin - self.origin);
	flytime = vlen(self.enemy.origin - self.origin) * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);


// commented out lines all in launch_spike
	launch_spike(self.origin + '0 0 10', self.v__);
//	newmis = spawn();
//	newmis.owner = self;

//	newmis.solid = SOLID_BBOX;
//	newmis.movetype = MOVETYPE_FLYMISSILE;
	setmodel (newmis, "progs/v_spike.mdl");

	setsize (newmis, '0 0 0', '0 0 0');		

//	newmis.origin = self.origin + '0 0 10';
	newmis.velocity = self.v__ * 400;
	newmis.avelocity = '300 300 300';
	newmis.nextthink = flytime + time;
	newmis.think = ShalHome;
	newmis.enemy = self.enemy;
	newmis.touch = ShalMissileTouch;

#undef flytime
};

void() ShalHome =
{
//	local vector	dir, vtemp;
	self.v__ = self.enemy.origin + '0 0 10';

#ifdef code_morph
// fix a bug where morph fired trackers are removed instantly, or strangely track to the world ent
	if (self.morphy) // fired by a morph player
	if (!self.enemy || self.enemy.health < 1) // fired with no target or target died
	{
// look for targets near flight path - idea: forward looking radar with longer range
		other = findradius(self.origin, 480);
		while (other)
		{
			if (other.solid != SOLID_NOT) // only solids
			if (other.health > 1) // can take damage && is not dead
			if (other.takedamage)
			if (other != self)	// not the bomb
			if (other != self.owner)	// not the shotter
			if (other.owner != self.owner)	// not summoned by the owner
			if (other.charmer != self.owner)	// not summoned by horn
			{
				self.lip = vlen(other.origin - self.origin);
				traceline(self.origin, other.origin, TRUE, self);

				if (trace_fraction >= 1) // can see the ent
// note - this targets invisible pk*bots
				if (other.classname != "player" || (!(other.items & IT_INVISIBILITY) && !coop && (other.classname != OBSERVER))) // dont target players / bots in coop
				{
					if (self.lip < self.lefty) // closer thing
					{
						self.enemy = other;
						self.lefty = self.lip;
					}
// but prioritize player or monster further than the closest thing
					if (other.classname == "player") self.enemy = other;
					else if (other.class_select == "class_monster") self.enemy = other;

					if (self.enemy) self.dest1 = self.enemy.origin; // target this
				}
			}
			other = other.chain;
		}
		self.nextthink = time + 0.1;
		self.think = ShalHome;
		return;
	}
#endifdef

	if (self.enemy.health < 1)
	{
		remove(self);
		return;
	}
	self.v__ = normalize(self.v__ - self.origin);
	if (skill == 3)
		self.velocity = self.v__ * 350;
	else
		self.velocity = self.v__ * 250;
	self.nextthink = time + 0.2;
	self.think = ShalHome;	

#ifdef monsters_plus__
// for homing spikes & such
	if (self.classname != "vorespike")
		self.angles = vectoangles(self.v__);
#endifdef
};

void() ShalMissileTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

#ifdef monsters_plus__
	if (self.owner.class_select == "class_monster") // not a morphed player or bot
	{
		if (other.owner == self.owner) return; // dont blow on SV summoned monster
		if (other.classname == "monster_shalrath") return; // dont blow on other monster vore / supervore
	}
#endifdef

	if (other.classname == "monster_zombie")
		T_Damage (other, self, self, 110);	

#ifdef opgrade
// make it T_RadiusDamage like below
// for more advanced code, uncomment - will allow weapon usage with arb damage
//	if (!self.dmg)
	self.dmg = 40;
	self.classname = "grenade";
// finish the rest of the code out
	GrenadeExplode();
#else
	T_RadiusDamage (self, self.owner, 40, world);
//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion (self);
#endifdef
};

//=================================================================

/*QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush Super
*/
void() monster_shalrath =
{
// override test
	if (! dm_over)			// __monster_shalrath_button0		"1"
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/shalrath.mdl");
	precache_model2 ("progs/h_shal.mdl");
	precache_model2 ("progs/v_spike.mdl");
	
	precache_sound2 ("shalrath/attack.wav");
	precache_sound2 ("shalrath/attack2.wav");
	precache_sound2 ("shalrath/death.wav");
	precache_sound2 ("shalrath/idle.wav");
	precache_sound2 ("shalrath/pain.wav");
	precache_sound2 ("shalrath/sight.wav");
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	
	setmodel (self, "progs/shalrath.mdl");
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 400;

	self.th_stand = shal_stand;
	self.th_walk = shal_walk1;
	self.th_run = shal_run1;
	self.th_die = shalrath_die;
	self.th_pain = shalrath_pain;
	self.th_missile = shal_attack1;

#ifdef HIPNOTIC
	walkmonster_start;
#else
	self.think = /*walk*/monster_start;
#endifdef
	self.nextthink = time + 0.1 + random ()*0.1;	

};

//=================================================================
/*QUAKED monster_supervore (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/

 /*
"the Upgrade"

The larger cousin of the purple traking bomb chuckin vore - also know as the "Super-vore".

Super-vore did not join his smaller cousin in support of Shubs, Armagon, or whoever was in charge in Dissolution.

He stayed home.  Thus the player has not seen him.

Not in the original time line anyway.

But since Chaos has involved itself, he has appeared.

He got concerned about his smaller cousin when he heard stories about how easy Shubs was to poink the first time.

*/

#ifdef monsters_plus_remove
void() monster_supervore =
{
	self.spawnflags = self.spawnflags | SUPER_VORE;
	monster_shalrath();
};
#endifdef
