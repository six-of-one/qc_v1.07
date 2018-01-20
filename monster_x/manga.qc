/*
==============================================================================
Ludovic Texier - Nov 2, 96

MANGA BABE, based on
OGRE code....

==============================================================================
*/

// let compile process know - since this is an #include in this code set

#messagecompiling manga.qc 

// include in random extra monsters

#undef INCL_MANGA
#define INCL_MANGA		16


$cd /quake/test/progs/manga3.mdl
$origin 0 0 -100

$base base		
$skin skin10

$frame base

$frame	st1 st2 st3 st4 st5 st6 st7 st8

$frame wa1 wa2 wa3 wa4 wa5 wa6 wa7 wa8 wa9 
$frame wa10 wa11 wa12 wa13 wa14 wa15 wa16 wa17 wa18

$frame ki1 ki2 ki3 ki4 ki5 ki6 ki7
$frame ki8 ki9 ki10 ki11 ki12 ki13 ki14 ki15


$frame at1 at2 at3 at4 at5 at6 at7 at8 at9 at10 at11


$frame pa1 pa2 pa3 pa4 pa5 pa6



$frame die1 die2 die3 die4 die5 die6
$frame die7 die8 die9 die10 die11 die12
$frame die13 die14 die15 die16 

//add these to fix a frame problem but there's really only 16 frames ...???
$frame die17 die18 


//=============================================================================

/*
deprecated - just duplicate ogre code !!

void() mangaGrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 40, world);
//	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion (self);
};

void() mangaGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		mangaGrenadeExplode();
		return;
	}
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};
*/

/*
================
mangaFireGrenade
================
*/
/*
deprecated for ogre fire code

void() mangaFireGrenade =
{
	local	entity missile;
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;

// fix obit message for these girls
	missile.classname = "grenade";
	newmis.weapon = IT_GRENADE_LAUNCHER; // Cataboligne - 2.19.11 - correct obit in pk_clientobit

// set missile speed	

	makevectors (self.angles);

	missile.velocity = normalize(self.enemy.origin - self.origin);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = mangaGrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = mangaGrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
};
*/

//=============================================================================

/*
================
highkick
================
*/
void(float side) highkick =
{
	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ai_charge(10);

	self.v__ = self.enemy.origin - self.origin;

	if (vlen(self.v__) > 100)
		return;
		
	self.dmg = (random() + random() + random()) * 4;
	T_Damage (self.enemy, self, self, self.dmg);
	
	if (side)
	{
		makevectors (self.angles);
		if (side == 1)
			SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
		else
			SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};

/*
void() manga_stand1	=[	$st1,	manga_stand1	]
{
	if ((self.duration < $st1) || (self.duration > $st7))
	{
		self.duration = $st1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $st5)
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "mon_II/manga/kungfu.wav", 1, ATTN_IDLE);

	ai_stand();
};

void() manga_stand1	=[	$st1,	manga_stand2	] {ai_stand();};
void() manga_stand2	=[	$st2,	manga_stand3	] {ai_stand();};
void() manga_stand3	=[	$st3,	manga_stand4	] {ai_stand();};
void() manga_stand4	=[	$st4,	manga_stand5	] {ai_stand();};
void() manga_stand5	=[	$st5,	manga_stand6	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "mon_II/manga/kungfu.wav", 1, ATTN_IDLE);
ai_stand();
};
void() manga_stand6	=[	$st6,	manga_stand7	] {ai_stand();};
void() manga_stand7	=[	$st7,	manga_stand8	] {ai_stand();};
void() manga_stand8	=[	$st8,	manga_stand1	] {ai_stand();};
*/

framerloop($st1, $st8, manga_stand1, 0.1,

	frame_arb($st5,if (random() < 0.2) sound (self, CHAN_VOICE, "mon_II/manga/kungfu.wav", 1, ATTN_IDLE));
	ai_stand()
);

/*
void() manga_walk1	=[	$wa1,		manga_walk1	]
{
	if ((self.duration < $wa1) || (self.duration > $wa17))
	{
		self.duration = $wa1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $wa3)
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "mon_II/manga/kungfu.wav", 1, ATTN_IDLE);

	if (self.frame == $wa6)
	if (random() < 0.1)
	{
		ai_walk(3);
		sound (self, CHAN_VOICE, "mon_II/manga/hiyaa.wav", 1, ATTN_IDLE);
	}

	ai_walk(2);
};

void() manga_walk1	=[	$wa1,		manga_walk2	] {ai_walk(2);};
void() manga_walk2	=[	$wa2,		manga_walk3	] {ai_walk(2);};
void() manga_walk3	=[	$wa3,		manga_walk4	] {
ai_walk(2);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "mon_II/manga/kungfu.wav", 1, ATTN_IDLE);
};
void() manga_walk4	=[	$wa4,		manga_walk5	] {ai_walk(2);};
void() manga_walk5	=[	$wa5,		manga_walk6	] {ai_walk(2);};
void() manga_walk6	=[	$wa6,		manga_walk7	] {
ai_walk(5);
if (random() < 0.1)
	sound (self, CHAN_VOICE, "mon_II/manga/hiyaa.wav", 1, ATTN_IDLE);
};
void() manga_walk7	=[	$wa7,		manga_walk8	] {ai_walk(2);};
void() manga_walk8	=[	$wa8,		manga_walk9	] {ai_walk(2);};
void() manga_walk9	=[	$wa9,		manga_walk10	] {ai_walk(2);};
void() manga_walk10	=[	$wa10,	manga_walk11	] {ai_walk(2);};
void() manga_walk11	=[	$wa11,	manga_walk12	] {ai_walk(2);};
void() manga_walk12	=[	$wa12,	manga_walk13	] {ai_walk(2);};
void() manga_walk13	=[	$wa13,	manga_walk14	] {ai_walk(2);};
void() manga_walk14	=[	$wa14,	manga_walk15	] {ai_walk(2);};
void() manga_walk15	=[	$wa15,	manga_walk16	] {ai_walk(2);};
void() manga_walk16	=[	$wa16,	manga_walk17	] {ai_walk(2);};
void() manga_walk17	=[	$wa17,	manga_walk18	] {ai_walk(2);};
void() manga_walk18	=[	$wa18,	manga_walk1	] {ai_walk(2);};
*/

framerloop($wa1, $wa18, manga_walk1, 0.1,

	frame_arb($wa3,if (random() < 0.2) sound (self, CHAN_VOICE, "mon_II/manga/kungfu.wav", 1, ATTN_IDLE));
	frame_arb($wa6,
	
		if (random() < 0.1) sound (self, CHAN_VOICE, "mon_II/manga/hiyaa.wav", 1, ATTN_IDLE);
		ai_walk(3);
	);
	ai_walk(2);
);

/*
void() manga_run1	=[	$wa1,		manga_run2	] {ai_run(9);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "mon_II/manga/ohdju.wav", 1, ATTN_IDLE);
};
void() manga_run2	=[	$wa3,		manga_run3	] {ai_run(12);};
void() manga_run3	=[	$wa5,		manga_run4	] {ai_run(8);};
void() manga_run4	=[	$wa7,		manga_run5	] {ai_run(22);};
void() manga_run5	=[	$wa9,		manga_run6	] {ai_run(16);};
void() manga_run6	=[	$wa11,		manga_run7	] {ai_run(4);};
void() manga_run7	=[	$wa13,		manga_run8	] {ai_run(13);};
void() manga_run8	=[	$wa15,		manga_run9	] {ai_run(24);};
void() manga_run9	=[	$wa17,		manga_run1	] {ai_run(24);};
*/

framerloop($wa1, $wa17, manga_run1, 0.1,

	frame_arb($wa1,if (random() < 0.2) sound (self, CHAN_VOICE, "mon_II/manga/ohdju.wav", 1, ATTN_IDLE));
	ai_rep($wa1, ai_run, 9, 12, -6, 8, -6, 22, -6, 16);
	ai_rep($wa10, ai_run, 4, -6, 13, -6, 24, -6, 24, -6);

	if (self.frame > $wa1) self.frame = self.frame + 1;
);

/*
void() manga_swing1	=[	$ki1,		manga_swing2	] {ai_charge(11);
sound (self, CHAN_WEAPON, "mon_II/manga/hiyaa.wav", 1, ATTN_NORM);
};
void() manga_swing2	=[	$ki2,		manga_swing3	] {ai_charge(1);};
void() manga_swing3	=[	$ki3,		manga_swing4	] {ai_charge(4);};
void() manga_swing4	=[	$ki4,		manga_swing5	] {ai_charge(13);};
void() manga_swing5	=[	$ki5,		manga_swing6	] {ai_charge(9); highkick(0);self.angles_y = self.angles_y + random()*25;};
void() manga_swing6	=[	$ki6,		manga_swing7	] {highkick(200);self.angles_y = self.angles_y + random()* 25;};
void() manga_swing7	=[	$ki7,		manga_swing8	] {highkick(0);self.angles_y = self.angles_y + random()* 25;};
void() manga_swing8	=[	$ki8,		manga_swing9	] {highkick(0);self.angles_y = self.angles_y + random()* 25;};
void() manga_swing9	=[	$ki9,		manga_swing10 ] {highkick(0);self.angles_y = self.angles_y + random()* 25;};
void() manga_swing10	=[	$ki10,		manga_swing11 ] {highkick(-200);self.angles_y = self.angles_y + random()* 25;};
void() manga_swing11	=[	$ki11,		manga_swing12 ] {highkick(0);self.angles_y = self.angles_y + random()* 25;};
void() manga_swing12	=[	$ki12,		manga_swing13 ] {ai_charge(3);};
void() manga_swing13	=[	$ki13,		manga_swing14 ] {ai_charge(8);};
void() manga_swing14	=[	$ki14,		manga_run1	] {ai_charge(9);};
*/

framer($ki1, $ki14, manga_swing1, manga_run1, 0.1,

	frame_arb($ki1,sound(self, CHAN_WEAPON, "mon_II/manga/hiyaa.wav", 1, ATTN_NORM));

	ai_rep($ki1, ai_charge, 11, 1, 4, 13, 9, -6, -6, -6);
	ai_rep($ki9, ai_charge, -6, -6, -6, 3, 8, 9, -6, -6);
	ai_rep($ki5, highkick, 0, 200, 0, 0, 0, -200, 0, -6);
	framerange_arb($ki5,$ki11,self.angles_y = self.angles_y + random()* 25);
);

/*
void() manga_smash1	=[	$ki1,		manga_smash2	] {ai_charge(6);};
void() manga_smash2	=[	$ki2,		manga_smash3	] {ai_charge(0);};
void() manga_smash3	=[	$ki3,		manga_smash4	] {ai_charge(0);};
void() manga_smash4	=[	$ki4,		manga_smash5	] {ai_charge(1);
sound (self, CHAN_WEAPON, "mon_II/manga/tchak.wav", 1, ATTN_NORM);
};
void() manga_smash5	=[	$ki5,		manga_smash6	] {ai_charge(4);};
void() manga_smash6	=[	$ki6,		manga_smash7	] {ai_charge(4); highkick(0);};
void() manga_smash7	=[	$ki7,		manga_smash8	] {ai_charge(4); highkick(0);};
void() manga_smash8	=[	$ki8,		manga_smash9	] {ai_charge(10); highkick(0);};
void() manga_smash9	=[	$ki9,		manga_smash10 ] {ai_charge(13); highkick(0);};
void() manga_smash10	=[	$ki10,		manga_smash11 ] {highkick(1);};
void() manga_smash11	=[	$ki11,		manga_smash12 ] {ai_charge(2); highkick(0);
self.nextthink = self.nextthink + random()*0.2;};	// slight variation
void() manga_smash12	=[	$ki12,		manga_smash13 ] {ai_charge(0);};
void() manga_smash13	=[	$ki13,		manga_smash14 ] {ai_charge(4);};
void() manga_smash14	=[	$ki14,		manga_run1	] {ai_charge(12);};
*/

framer($ki1, $ki14, manga_smash1, manga_run1, 0.1,

	frame_arb($ki4,sound(self, CHAN_WEAPON, "mon_II/manga/tchak.wav", 1, ATTN_NORM));
	frame_arb($ki11,self.nextthink = self.nextthink + random()*0.2);

	ai_rep($ki1, ai_charge, 6, 0, 0, 1, 4, 4, 4, 10);
	ai_rep($ki9, ai_charge, 13, -6, 2, 0, 4, 12, -6, -6);
	ai_rep($ki6, highkick, 0, 0, 0, 0, 1, 0, -6, -6);
);

/*
void() manga_nail1	=[	$at1,		manga_nail1	]
{
	if ((self.duration < $at1) || (self.duration > $at9))
	{
		self.duration = $at1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $at8)
	{
		OgreFireGrenade();

// fix obit message for these girls
		newmis.classname = "grenade";
		newmis.weapon = IT_GRENADE_LAUNCHER; // Cataboligne - 2.19.11 - correct obit in pk_clientobit
	}

	if (self.frame == $at10) self.think = manga_run1;

	ai_face();
};



deprecated for loop code

void() manga_nail2	=[	$at2,		manga_nail3	] {ai_face();};
void() manga_nail3	=[	$at3,		manga_nail4	] {ai_face();};
void() manga_nail4	=[	$at4,		manga_nail5	] {ai_face();};
void() manga_nail5	=[	$at5,		manga_nail6	] {ai_face();};
void() manga_nail6	=[	$at6,		manga_nail7	] {ai_face();};
void() manga_nail7	=[	$at7,		manga_nail8	] {ai_face();};
void() manga_nail8	=[	$at8,		manga_nail9	] {ai_face();
	OgreFireGrenade();

// fix obit message for these girls
	newmis.classname = "grenade";
	newmis.weapon = IT_GRENADE_LAUNCHER; // Cataboligne - 2.19.11 - correct obit in pk_clientobit
};
void() manga_nail9	=[	$at9,		manga_nail10	] {ai_face();};
void() manga_nail10	=[	$at10,		manga_run1	] {ai_face();};
*/

framer($at1, $at10, manga_nail1, manga_run1, 0.1,

	frame_arb($at8,W_FireGrenade());
	ai_face();
);

/*
void()	manga_pain1	=[	$pa1,		manga_pain1	]
{
	if ((self.duration < $pa1) || (self.duration > $pa5))
	{
		self.duration = $pa1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $pa6) self.think = manga_run1;
};



deprecated for loop code

void()	manga_pain2	=[	$pa2,		manga_pain3	] {};
void()	manga_pain3	=[	$pa3,		manga_pain4	] {};
void()	manga_pain4	=[	$pa4,		manga_pain5	] {};
void()	manga_pain5	=[	$pa5,		manga_pain6	] {};
void()	manga_pain6	=[	$pa6,		manga_run1	] {};
*/

framer($pa1, $pa6, manga_pain1, manga_run1, 0.1,SUB_Null());


//void(entity attacker, float damage)	manga_pain =
void()	manga_pain =
{
//	local float	r;

// don't make multiple pain sounds right after each other
	if (self.pain_finished > time)
		return;


	sound (self, CHAN_VOICE, "mon_II/manga/ha.wav", 1, ATTN_NORM);

	manga_pain1 ();
	self.pain_finished = time + 1;

};

/*
void()	manga_die1	=[	$die1,	manga_die1	]
{
	if ((self.duration < $die1) || (self.duration > $die17))
	{
		self.duration = $die1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $die3)
	{
		self.solid = SOLID_NOT;
		self.ammo_rockets = 2;
		DropBackpack();
	}

	if (self.frame == $die18) self.think = SUB_Null; // drop out
};


deprecated for loop code

void()	manga_die2	=[	$die2,	manga_die3	] {};
void()	manga_die3	=[	$die3,	manga_die4	]
{self.solid = SOLID_NOT;
self.ammo_rockets = 2;DropBackpack();};
void()	manga_die4	=[	$die4,	manga_die5	] {};
void()	manga_die5	=[	$die5,	manga_die6	] {};
void()	manga_die6	=[	$die6,	manga_die7	] {};
void()	manga_die7	=[	$die7,	manga_die8	] {};
void()	manga_die8	=[	$die8,	manga_die9	] {};
void()	manga_die9	=[	$die9,	manga_die10	] {};
void()	manga_die10	=[	$die10,	manga_die11	] {};
void()	manga_die11	=[	$die11,	manga_die12	] {};
void()	manga_die12	=[	$die12,	manga_die13	] {};
void()	manga_die13	=[	$die13,	manga_die14	] {};
void()	manga_die14	=[	$die14,	manga_die15	] {};
void()	manga_die15	=[	$die15,	manga_die16	] {};
void()	manga_die16	=[	$die16,	manga_die17	] {};
// I had to add those 2 lines, it works that way ....
void()	manga_die17	=[	$die17,	manga_die18	] {};
void()	manga_die18	=[	$die18,	manga_die18	] {};
*/

framer($die1, $die18, manga_die1, SUB_Null, 0.1,

	frame_arb($die3,

		self.solid = SOLID_NOT;
		self.ammo_rockets = 5;
		DropBackpack();
	);
);

void() manga_die =
{
// check for gib
	if (self.health < -80)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	sound (self, CHAN_VOICE, "mon_II/manga/died.wav", 1, ATTN_NORM);

	manga_die1 ();
};

void() manga_melee =
{
	if (random() > 0.5)
		manga_smash1 ();
	else
		manga_swing1 ();
};

/*
//string(entity targ, entity attacker) manga_killmsg =
string() manga_killmsg =
{
	if (random() < 0.5)
		return " felt the powerful Kung-Fu of ";
	else if (random() < 0.8)
		return " got kicked out by ";
	else
	{
		bprint(" examined Manga's boots up close, you perv.\n");
		return("return");
	}
};
*/

void() monster_manga =
{
/*
if (ign != A_MONSTER)
{
	if (M_MONSTER < 0)
	{
		self.think = remove_monster;
		self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
		return;
	}
*/
// override test
	if (! dm_over)			// __monster_manga_button0		"1"
//	if (!M_MONSTER_II & CB_M_MANGA)
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model ("progs/manga3.mdl");
	precache_model ("progs/h_ogre.mdl");
	precache_model ("progs/grenade.mdl");
	precache_sound ("mon_II/manga/hiyaa.wav");
	precache_sound ("mon_II/manga/tchak.wav");
	precache_sound ("mon_II/manga/kungfu.wav");
	precache_sound ("mon_II/manga/ohdju.wav");
	precache_sound ("mon_II/manga/ha.wav");
	precache_sound ("mon_II/manga/died.wav");
//}
/*
// Cataboligne - 11.14.12 - fast / slow code
	if (self.speed <= 0) self.speed = MON_NORM;
	self.lip = 1; // local speed divisor
// map specced
	if (self.netname == CFAST) self.speed = MON_FAST;
	else if (self.netname == CSLOW) self.speed = MON_SLOW;
*/

	if (random() < 0.3) self.spawnflags = self.spawnflags | 2; // uses ogre grenade fire & this gives her multi

	self.netname = "Manga Tai";

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/manga3.mdl");

	setsize (self, '-16 -16 -24', '16 16 32');

	self.health = 250;

	self.th_stand = manga_stand1;
	self.th_walk = manga_walk1;
	self.th_run = manga_run1;
	self.th_die = manga_die;
	self.th_melee = manga_melee;
	self.th_missile = manga_nail1;
	self.th_pain = manga_pain;
//	self._killmsg = manga_killmsg;

	walkmonster_start;
};


