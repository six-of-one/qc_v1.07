/*
==============================================================================

OGRE

==============================================================================
*/

$cd id1/models/ogre_c
$origin 0 0 24
$base base		
$skin base

$frame	stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7
$frame walk8 walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame swing1 swing2 swing3 swing4 swing5 swing6 swing7
$frame swing8 swing9 swing10 swing11 swing12 swing13 swing14

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7
$frame smash8 smash9 smash10 smash11 smash12 smash13 smash14

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6

$frame pain1 pain2 pain3 pain4 pain5

$frame painb1 painb2 painb3

$frame painc1 painc2 painc3 painc4 painc5 painc6

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8 paind9 paind10
$frame paind11 paind12 paind13 paind14 paind15 paind16

$frame paine1 paine2 paine3 paine4 paine5 paine6 paine7 paine8 paine9 paine10
$frame paine11 paine12 paine13 paine14 paine15

$frame death1 death2 death3 death4 death5 death6
$frame death7 death8 death9 death10 death11 death12
$frame death13 death14

$frame bdeath1 bdeath2 bdeath3 bdeath4 bdeath5 bdeath6
$frame bdeath7 bdeath8 bdeath9 bdeath10

$frame pull1 pull2 pull3 pull4 pull5 pull6 pull7 pull8 pull9 pull10 pull11

/*
// super (boss) ogre frames

$frame	sostand1 sostand2 sostand3 sostand4 sostand5 sostand6 sostand7 sostand8 sostand9

$frame sowalk1 sowalk2 sowalk3 sowalk4 sowalk5 sowalk6 sowalk7
$frame sowalk8 sowalk9 sowalk10 sowalk11 sowalk12 sowalk13 sowalk14 sowalk15 sowalk16

$frame sorun1 sorun2 sorun3 sorun4 sorun5 sorun6 sorun7 sorun8

$frame soswing1 soswing2 soswing3 soswing4 soswing5 soswing6 soswing7
$frame soswing8 soswing9 soswing10 soswing11 soswing12 soswing13 soswing14

$frame sosmash1 sosmash2 sosmash3 sosmash4 sosmash5 sosmash6 sosmash7
$frame sosmash8 sosmash9 sosmash10 sosmash11 sosmash12 sosmash13 sosmash14

$frame soshoot1 soshoot2 soshoot3 soshoot4 soshoot5 soshoot6

$frame sopain1 sopain2 sopain3 sopain4 sopain5

$frame sopainb1 sopainb2 sopainb3

$frame sopainc1 sopainc2 sopainc3 sopainc4 sopainc5 sopainc6

$frame sopaind1 sopaind2 sopaind3 sopaind4 sopaind5 sopaind6 sopaind7 sopaind8 sopaind9 sopaind10
$frame sopaind11 sopaind12 sopaind13 sopaind14 sopaind15 sopaind16

$frame sopaine1 sopaine2 sopaine3 sopaine4 sopaine5 sopaine6 sopaine7 sopaine8 sopaine9 sopaine10
$frame sopaine11 sopaine12 sopaine13 sopaine14 sopaine15

$frame sodeath1 sodeath2 sodeath3 sodeath4 sodeath5 sodeath6
$frame sodeath7 sodeath8 sodeath9 sodeath10 sodeath11 sodeath12
$frame sodeath13 sodeath14

$frame sobdeath1 sobdeath2 sobdeath3 sobdeath4 sobdeath5 sobdeath6
$frame sobdeath7 sobdeath8 sobdeath9 sobdeath10

$frame sopull1 sopull2 sopull3 sopull4 sopull5 sopull6 sopull7 sopull8 sopull9 sopull10 sopull11

// super ogre - extra mad

$frame	soemsstand1 soemsstand2 soemsstand3 soemsstand4 soemsstand5 soemsstand6 soemsstand7 soemsstand8 soemsstand9

$frame soemwalk1 soemwalk2 soemwalk3 soemwalk4 soemwalk5 soemwalk6 soemwalk7
$frame soemwalk8 soemwalk9 soemwalk10 soemwalk11 soemwalk12 soemwalk13 soemwalk14 soemwalk15 soemwalk16

$frame soemrun1 soemrun2 soemrun3 soemrun4 soemrun5 soemrun6 soemrun7 soemrun8

$frame soemsswing1 soemsswing2 soemsswing3 soemsswing4 soemsswing5 soemsswing6 soemsswing7
$frame soemsswing8 soemsswing9 soemsswing10 soemsswing11 soemsswing12 soemsswing13 soemsswing14

$frame soemsmash1 soemsmash2 soemsmash3 soemsmash4 soemsmash5 soemsmash6 soemsmash7
$frame soemsmash8 soemsmash9 soemsmash10 soemsmash11 soemsmash12 soemsmash13 soemsmash14

$frame soemdeath1 soemdeath2 soemdeath3 soemdeath4 soemdeath5 soemdeath6
$frame soemdeath7 soemdeath8 soemdeath9 soemdeath10 soemdeath11 soemdeath12
$frame soemdeath13 soemdeath14
*
//=============================================================================

#define	OGRE_SUPER	8
#define	OGRE_SUPER_MAD	16 // got extra mad

#define super_ogre_chance 0.1
#define super_ogre_emheal 80 // how much a super ogre thats extra mad could heal in a pain frame
#define super_ogre_emheal_chn 0.4 // chance to heal

/*
void() OgreGrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 40, world);
//	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion (self);
};

void() OgreGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		OgreGrenadeExplode();
		return;
	}
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};
*/
/*
================
OgreFireGrenade
================

now calling W_FireGrenade

void() OgreFireGrenade =
{
	local	entity missile;//, mpuff;	// fx_warning
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
		
// set missile speed	

	makevectors (self.angles);

	missile.velocity = normalize(self.enemy.origin - self.origin);
	missile.velocity = missile.velocity * 600;
	missile.velocity_z = 200;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
//	missile.touch = OgreGrenadeTouch;
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);

// qc++
	missile.dmg = 40;

};
*/

#define	OGRE_BAWSE	2
// rogue qc has a flag for map specced force to be normal ogres (not avail for OGRE_BOSS upgrade)
#define	OGRE_NORMAL	4

#define	OGRE_SUPER	MFL_SUPER
#define	OGRE_SUPER_MAD	MFL_SXMAD
//=============================================================================

/*
================
chainsaw

FIXME
================
*/
void(float side) chainsaw =
{
//local vector	delta;
//local float 	ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ai_charge(10);

//	delta = self.enemy.origin - self.origin;

	if (vlen(self.enemy.origin - self.origin) > 100)
		return;
		
	self.ldmg_ = (random() + random() + random()) * 4;

#ifdef monsters_plus__
// one of those "BIG" ogres - bump damage by model scale factor
	if (self.spawnflags & MFL_BSUP) self.ldmg_ = self.ldmg_ * self.scale;

	if ((side) && (side < 2))
	if (self.spawnflags & OGRE_SUPER)
		sound (self, CHAN_VOICE, "zombie/z_hit.wav", 1, ATTN_IDLE); // 10.13.13
#endifdef

	T_Damage (self.enemy, self, self, self.ldmg_);
	
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
void() ogre_stand1	=[	$stand1,	ogre_stand2	] {ai_stand();};
void() ogre_stand2	=[	$stand2,	ogre_stand3	] {ai_stand();};
void() ogre_stand3	=[	$stand3,	ogre_stand4	] {ai_stand();};
void() ogre_stand4	=[	$stand4,	ogre_stand5	] {ai_stand();};
void() ogre_stand5	=[	$stand5,	ogre_stand6	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
ai_stand();
};
void() ogre_stand6	=[	$stand6,	ogre_stand7	] {ai_stand();};
void() ogre_stand7	=[	$stand7,	ogre_stand8	] {ai_stand();};
void() ogre_stand8	=[	$stand8,	ogre_stand9	] {ai_stand();};
void() ogre_stand9	=[	$stand9,	ogre_stand1	] {ai_stand();};
*/

//framer($stand1, $stand9, ogre_stand1, frd1, 0.1,
//framerloop($stand1, $stand9, ogre_stand1, 0.1,ai_stand();	frame_arb($stand5,if (random() < 0.2) sound(self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE)); );

#ifdef monsters_plus__
// Modified by Dave Weiden (Weiden@Trenton.EDU) 9/20/96
/*
void() ogre_pull1       =[      $pull1,         ogre_pull2      ] {ai_frame(self.walkframe);};
void() ogre_pull2       =[      $pull2,         ogre_pull3      ] {ai_frame(self.walkframe);};
void() ogre_pull3       =[      $pull3,         ogre_pull4      ] {ai_frame(self.walkframe);};
void() ogre_pull4       =[      $pull4,         ogre_pull5      ] {ai_frame(self.walkframe);};
void() ogre_pull5       =[      $pull5,         ogre_pull6      ] {
	ai_frame(self.walkframe);
	sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};
void() ogre_pull6       =[      $pull6,         ogre_pull7      ] {ai_frame(self.walkframe);};
void() ogre_pull7       =[      $pull7,         ogre_pull8      ] {ai_frame(self.walkframe);};
void() ogre_pull8       =[      $pull8,         ogre_pull9      ] {ai_frame(self.walkframe);};
void() ogre_pull9       =[      $pull9,         ogre_pull10     ] {ai_frame(self.walkframe);};
void() ogre_pull10      =[      $pull10,        ogre_pull11     ] {ai_frame(self.walkframe);};
void() ogre_pull11      =[      $pull11,        ogre_pull12     ] {ai_frame(self.walkframe);};
*/
void() ogre_run1;

framer($walk13, $walk16, ogre_walk13, ogre_run1, 0.1,SUB_Null());

void() ogre_pull12      =[      $pull10,        ogre_pull13     ] {ai_walk(0);};
void() ogre_pull13      =[      $pull9,         ogre_pull14     ] {ai_walk(0);};
void() ogre_pull14      =[      $pull8,         ogre_pull15     ] {ai_walk(0);};
void() ogre_pull15      =[      $pull6,         ogre_pull16     ] {ai_walk(0);};
void() ogre_pull16      =[      $pull4,         ogre_walk13     ] {ai_walk(0);};


framer($pull1, $pull11, ogre_pull1, ogre_pull12, 0.1,

	frame_arb($pull5,sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE));
);

// end weiden mod
#endifdef

/*
void() ogre_walk1	=[	$walk1,		ogre_walk2	] {ai_walk(3);};
void() ogre_walk2	=[	$walk2,		ogre_walk3	] {ai_walk(2);};
void() ogre_walk3	=[	$walk3,		ogre_walk4	] {
ai_walk(2);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
};
void() ogre_walk4	=[	$walk4,		ogre_walk5	] {ai_walk(2);};
void() ogre_walk5	=[	$walk5,		ogre_walk6	] {ai_walk(2);};
void() ogre_walk6	=[	$walk6,		ogre_walk7	] {
ai_walk(5);
if (random() < 0.1)
	sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
};
void() ogre_walk7	=[	$walk7,		ogre_walk8	] {ai_walk(3);};
void() ogre_walk8	=[	$walk8,		ogre_walk9	] {ai_walk(2);};
void() ogre_walk9	=[	$walk9,		ogre_walk10	] {ai_walk(3);};
void() ogre_walk10	=[	$walk10,	ogre_walk11	] {ai_walk(1);};
void() ogre_walk11	=[	$walk11,	ogre_walk12	] {ai_walk(2);};
void() ogre_walk12	=[	$walk12,	ogre_walk13	] {ai_walk(3);};
void() ogre_walk13	=[	$walk13,	ogre_walk14	] {ai_walk(3);};
void() ogre_walk14	=[	$walk14,	ogre_walk15	] {ai_walk(3);};
void() ogre_walk15	=[	$walk15,	ogre_walk16	] {ai_walk(3);};
void() ogre_walk16	=[	$walk16,	ogre_walk1	] {ai_walk(4);};
*/

framerloop($walk1, $walk16, ogre_walk1, 0.1,

	frame_arb($walk3,if (random() < 0.2) sound(self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE));
	frame_arb($walk12,if ((self.spawnflags & MFL_ENHANCE)  && (random() <0.25) && ! (self.spawnflags & MFL_BSUP))  ogre_pull1());
	frame_arb($walk6,

		if (random() < 0.1) 
		{
#ifdef monsters_plus__
			if (self.spawnflags & OGRE_SUPER)
				sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
			else
#endifdef
			sound(self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
		}
	);

	ai_rep($walk1, ai_walk, 3, 2, 2, 2, 2, 5, 3, 2);
	ai_rep($walk9, ai_walk, 3, 1, 2, 3, 3, 3, 3, 4);
);


/*
void() ogre_run1	=[	$run1,		ogre_run2	] {ai_run(9);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};
void() ogre_run2	=[	$run2,		ogre_run3	] {ai_run(12);};
void() ogre_run3	=[	$run3,		ogre_run4	] {ai_run(8);};
void() ogre_run4	=[	$run4,		ogre_run5	] {ai_run(22);};
void() ogre_run5	=[	$run5,		ogre_run6	] {ai_run(16);};
void() ogre_run6	=[	$run6,		ogre_run7	] {ai_run(4);};
void() ogre_run7	=[	$run7,		ogre_run8	] {ai_run(13);};
void() ogre_run8	=[	$run8,		ogre_run1	] {ai_run(24);};
*/

framerloop($run1, $run8, ogre_run1, 0.1,

	frame_arb($run1,if (random() < 0.2) sound(self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE));
#ifdef monsters_plus__
	frame_arb($run5,
	if (self.spawnflags & OGRE_SUPER)
	if ((time & SV_CKTIME) == SV_CKTIME)
	{
		s7__ = "owner";
		self.count = cnt_ent(world, class_select, "class_monster");
		if (self.count < 4 + skill)
		{
			self.rnd_ = random();
			if (self.rnd_ < 0.35) SummonMonster("monster_ogre");
			else if (self.rnd_ < 0.5) SummonMonster("monster_dog");
			else if (self.rnd_ < 0.6) SummonMonster("monster_spider");
		}
// charge him up - note buku XP if killed while he has this
//		if (self.archon < 100) self.archon = self.health + random() * (self.health / 2);
	}
	);
#endifdef
	ai_rep($run1, ai_run, 9, 12, 8, 22, 16, 4, 13, 24);
);


/*
void() ogre_swing1	=[	$swing1,		ogre_swing2	] {ai_charge(11);
sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);
};
void() ogre_swing2	=[	$swing2,		ogre_swing3	] {ai_charge(1);};
void() ogre_swing3	=[	$swing3,		ogre_swing4	] {ai_charge(4);};
void() ogre_swing4	=[	$swing4,		ogre_swing5	] {ai_charge(13);};
void() ogre_swing5	=[	$swing5,		ogre_swing6	] {ai_charge(9); chainsaw(0);self.angles_y = self.angles_y + random()*25;};
void() ogre_swing6	=[	$swing6,		ogre_swing7	] {chainsaw(200);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing7	=[	$swing7,		ogre_swing8	] {chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing8	=[	$swing8,		ogre_swing9	] {chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing9	=[	$swing9,		ogre_swing10 ] {chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing10	=[	$swing10,		ogre_swing11 ] {chainsaw(-200);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing11	=[	$swing11,		ogre_swing12 ] {chainsaw(0);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing12	=[	$swing12,		ogre_swing13 ] {ai_charge(3);};
void() ogre_swing13	=[	$swing13,		ogre_swing14 ] {ai_charge(8);};
void() ogre_swing14	=[	$swing14,		ogre_run1	] {ai_charge(9);};
*/

framer($swing1, $swing14, ogre_swing1, ogre_run1, 0.1,

	ai_rep($swing1, ai_charge, 11, 1, 4, 13, 9, -6, -6, -6);
	ai_rep($swing9, ai_charge, -6, -6, -6, 3, 8, 9, -6, -6);
	ai_rep($swing5, chainsaw, 0, 200, 0, 0, 0, -200, 0, -6);
	framerange_arb($swing5,$swing11,self.angles_y = self.angles_y + random()* 25);

#ifdef monsters_plus__
	frame_arb($swing1,
	if (self.spawnflags & OGRE_SUPER)
	{
		if (random() < 0.5)
			sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	}
	else
		sound(self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM)
	);
#else
	frame_arb($swing1,sound(self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM));
#endifdef
);

/*
void() ogre_smash1	=[	$smash1,		ogre_smash2	] {ai_charge(6);
sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);
};
void() ogre_smash2	=[	$smash2,		ogre_smash3	] {ai_charge(0);};
void() ogre_smash3	=[	$smash3,		ogre_smash4	] {ai_charge(0);};
void() ogre_smash4	=[	$smash4,		ogre_smash5	] {ai_charge(1);};
void() ogre_smash5	=[	$smash5,		ogre_smash6	] {ai_charge(4);};
void() ogre_smash6	=[	$smash6,		ogre_smash7	] {ai_charge(4); chainsaw(0);};
void() ogre_smash7	=[	$smash7,		ogre_smash8	] {ai_charge(4); chainsaw(0);};
void() ogre_smash8	=[	$smash8,		ogre_smash9	] {ai_charge(10); chainsaw(0);};
void() ogre_smash9	=[	$smash9,		ogre_smash10 ] {ai_charge(13); chainsaw(0);};
void() ogre_smash10	=[	$smash10,		ogre_smash11 ] {chainsaw(1);};
void() ogre_smash11	=[	$smash11,		ogre_smash12 ] {ai_charge(2); chainsaw(0);
self.nextthink = self.nextthink + random()*0.2;};	// slight variation

#ifdef codefix
void() ogre_smash12 =[$smash12, ogre_smash13] {ai_charge(0);};
#else 
// there is no difference in code ops - as this code calls ai_charge with 0.000000
void() ogre_smash12 =[$smash12, ogre_smash13] {ai_charge();};
#endifdef

void() ogre_smash13	=[	$smash13,		ogre_smash14 ] {ai_charge(4);};
void() ogre_smash14	=[	$smash14,		ogre_run1	] {ai_charge(12);};
*/

framer($smash1, $smash14, ogre_smash1, ogre_run1, 0.1,

	frame_arb($smash11,self.nextthink = self.nextthink + random()*0.2);

	ai_rep($smash1, ai_charge, 6, 0, 0, 1, 4, 4, 4, 10);
	ai_rep($smash9, ai_charge, 13, -6, 2, 0, 4, 12, -6, -6);
	ai_rep($smash6, chainsaw, 0, 0, 0, 0, 1, 0, -6, -6);

#ifdef monsters_plus__
	frame_arb($smash1,

		if (self.spawnflags & OGRE_SUPER)
			sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM)
	);
#else
	frame_arb($smash1,sound(self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM));
#endifdef
);

/*
void() ogre_nail1	=[	$shoot1,		ogre_nail2	] {ai_face();};
void() ogre_nail2	=[	$shoot2,		ogre_nail3	] {ai_face();};
void() ogre_nail3	=[	$shoot2,		ogre_nail4	] {ai_face();};
void() ogre_nail4	=[	$shoot3,		ogre_nail5	] {ai_face();OgreFireGrenade();};
void() ogre_nail5	=[	$shoot4,		ogre_nail6	] {ai_face();};
void() ogre_nail6	=[	$shoot5,		ogre_nail7	] {ai_face();};
void() ogre_nail7	=[	$shoot6,		ogre_run1	] {ai_face();};
*/

framer($shoot1, $shoot6, ogre_nail1, ogre_run1, 0.1,

	frame_arb($shoot3,

#ifdef monsters_plus__
#ifdef ROGUE
	if(self.spawnflags & OGRE_BAWSE)
		W_FireMultiGrenade();
	else
#endifdef
#endifdef
		W_FireGrenade()
	);
	ai_face();
);


/*
void()	ogre_pain1	=[	$pain1,		ogre_pain2	] {};
void()	ogre_pain2	=[	$pain2,		ogre_pain3	] {};
void()	ogre_pain3	=[	$pain3,		ogre_pain4	] {};
void()	ogre_pain4	=[	$pain4,		ogre_pain5	] {};
void()	ogre_pain5	=[	$pain5,		ogre_run1	] {};
*/

framer($pain1, $pain5, ogre_pain1, ogre_run1, 0.1,SUB_Null());

/*
void()	ogre_painb1	=[	$painb1,	ogre_painb2	] {};
void()	ogre_painb2	=[	$painb2,	ogre_painb3	] {};
void()	ogre_painb3	=[	$painb3,	ogre_run1	] {};
*/

framer($painb1, $painb3, ogre_painb1, ogre_run1, 0.1,SUB_Null());

/*
void()	ogre_painc1	=[	$painc1,	ogre_painc2	] {};
void()	ogre_painc2	=[	$painc2,	ogre_painc3	] {};
void()	ogre_painc3	=[	$painc3,	ogre_painc4	] {};
void()	ogre_painc4	=[	$painc4,	ogre_painc5	] {};
void()	ogre_painc5	=[	$painc5,	ogre_painc6	] {};
void()	ogre_painc6	=[	$painc6,	ogre_run1	] {};
*/
	
framer($painc1, $painc6, ogre_painc1, ogre_run1, 0.1,SUB_Null());
	
/*
void()	ogre_paind1	=[	$paind1,	ogre_paind2	] {};
void()	ogre_paind2	=[	$paind2,	ogre_paind3	] {ai_pain(10);};
void()	ogre_paind3	=[	$paind3,	ogre_paind4	] {ai_pain(9);};
void()	ogre_paind4	=[	$paind4,	ogre_paind5	] {ai_pain(4);};
void()	ogre_paind5	=[	$paind5,	ogre_paind6	] {};
void()	ogre_paind6	=[	$paind6,	ogre_paind7	] {};
void()	ogre_paind7	=[	$paind7,	ogre_paind8	] {};
void()	ogre_paind8	=[	$paind8,	ogre_paind9	] {};
void()	ogre_paind9	=[	$paind9,	ogre_paind10	] {};
void()	ogre_paind10=[	$paind10,	ogre_paind11	] {};
void()	ogre_paind11=[	$paind11,	ogre_paind12	] {};
void()	ogre_paind12=[	$paind12,	ogre_paind13	] {};
void()	ogre_paind13=[	$paind13,	ogre_paind14	] {};
void()	ogre_paind14=[	$paind14,	ogre_paind15	] {};
void()	ogre_paind15=[	$paind15,	ogre_paind16	] {};
void()	ogre_paind16=[	$paind16,	ogre_run1	] {};
*/

framer($paind1, $paind16, ogre_paind1, ogre_run1, 0.1,

	ai_rep($paind2, ai_pain, 10, 9, 4, -6, -6, -6, -6, -6);
);

/*
void()	ogre_paine1	=[	$paine1,	ogre_paine2	] {};
void()	ogre_paine2	=[	$paine2,	ogre_paine3	] {ai_pain(10);};
void()	ogre_paine3	=[	$paine3,	ogre_paine4	] {ai_pain(9);};
void()	ogre_paine4	=[	$paine4,	ogre_paine5	] {ai_pain(4);};
void()	ogre_paine5	=[	$paine5,	ogre_paine6	] {};
void()	ogre_paine6	=[	$paine6,	ogre_paine7	] {};
void()	ogre_paine7	=[	$paine7,	ogre_paine8	] {};
void()	ogre_paine8	=[	$paine8,	ogre_paine9	] {};
void()	ogre_paine9	=[	$paine9,	ogre_paine10	] {};
void()	ogre_paine10=[	$paine10,	ogre_paine11	] {};
void()	ogre_paine11=[	$paine11,	ogre_paine12	] {};
void()	ogre_paine12=[	$paine12,	ogre_paine13	] {};
void()	ogre_paine13=[	$paine13,	ogre_paine14	] {};
void()	ogre_paine14=[	$paine14,	ogre_paine15	] {};
void()	ogre_paine15=[	$paine15,	ogre_run1	] {};
*/

framer($paine1, $paine15, ogre_paine1, ogre_run1, 0.1,

	ai_rep($paine2, ai_pain, 10, 9, 4, -6, -6, -6, -6, -6);
);



void(entity attacker, float damage)	ogre_pain =
{
//	local float	r;

// don't make multiple pain sounds right after each other
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);		

	self.rnd_ = random();

#ifdef monsters_plus__
	self.cnt = 1;

	if (self.spawnflags & OGRE_SUPER)
	{
// check to see if super ogre gets EXTRA mad
		if (!(self.spawnflags & OGRE_SUPER_MAD))
		{
			if (self.health < 250)
			if (random() < 0.5)
				self.spawnflags = self.spawnflags | OGRE_SUPER_MAD;

			if (self.health < 50)
				self.spawnflags = self.spawnflags | OGRE_SUPER_MAD;

// just like the hulk - super ogre gets bigger & a health boost when going to extra mad
			if (self.spawnflags & OGRE_SUPER_MAD)
			{
//				self.waitmax = 2.25; // multiplier in this case
				if ((random() < 0.25) || (self.health < 20))
					self.health = 800 + (200 * random()) + (200 * random());
				else
					self.health = self.health + 200 + (100 * random());
				self.max_health = self.health;

				self.th_missile = ogre_smash1; // XMAD ogre has forgotten grenades, maybe he could throw boulders
//				self.th_run(); // set new frames
			}
		}
// could make this one dangerous brute
		else
		if (random() < mon_super_emheal_chn)
			self.health = self.health + (mon_xmad_heal * random());

		if (self.speed > mon_superspeedup_max)
		if (random() < mon_superspeed_chn)
		{
			self.speed  = self.speed - mon_superspeed_fact;
			if (self.speed < mon_superspeedup_max) self.speed = mon_superspeedup_max;
		}

		self.cnt = 2;
		self.pain_finished = time + 3.5; // set a default

		if (self.rnd_ > 0.75) return;

	}
#endifdef

	self.pain_finished = time + self.cnt;
	if (self.rnd_ < 0.25)
	{
		ogre_pain1 ();
	}
	else if (self.rnd_ < 0.5)
	{
		ogre_painb1 ();
	}
	else if (self.rnd_ < 0.75)
	{
		ogre_painc1 ();
	}
	else if (self.rnd_ < 0.87)
	{
		ogre_paind1 ();
		self.pain_finished = time + self.cnt + 1;
	}
	else
	{
		ogre_paine1 ();
		self.pain_finished = time + self.cnt + 1;
	}
};

/*
void()	ogre_die1	=[	$death1,	ogre_die2	] {};
void()	ogre_die2	=[	$death2,	ogre_die3	] {};
void()	ogre_die3	=[	$death3,	ogre_die4	]
{self.solid = SOLID_NOT;
self.ammo_rockets = 2;DropBackpack();};
void()	ogre_die4	=[	$death4,	ogre_die5	] {};
void()	ogre_die5	=[	$death5,	ogre_die6	] {};
void()	ogre_die6	=[	$death6,	ogre_die7	] {};
void()	ogre_die7	=[	$death7,	ogre_die8	] {};
void()	ogre_die8	=[	$death8,	ogre_die9	] {};
void()	ogre_die9	=[	$death9,	ogre_die10	] {};
void()	ogre_die10	=[	$death10,	ogre_die11	] {};
void()	ogre_die11	=[	$death11,	ogre_die12	] {};
void()	ogre_die12	=[	$death12,	ogre_die13	] {};
void()	ogre_die13	=[	$death13,	ogre_die14	] {};
void()	ogre_die14	=[	$death14,	ogre_die14	] {};
*/

framer($death1, $death14, ogre_die1, SUB_Null, 0.1,

	frame_arb($death3,

		self.solid = SOLID_NOT;
#ifdef monsters_plus__
//		if (self.spawnflags & OGRE_BOSS)
//			self.ammo_multi_rockets = 2;			FIX:
//		else
		if (!( self.spawnflags & OGRE_SUPER))
//			self.ammo_rockets = 6 + random() * 4;
//		else
#endifdef
		{
		self.ammo_rockets = 5;
		DropBackpack();
		}
	);
);

/*
void()	ogre_bdie1	=[	$bdeath1,	ogre_bdie2	] {};
void()	ogre_bdie2	=[	$bdeath2,	ogre_bdie3	] {ai_forward(5);};
void()	ogre_bdie3	=[	$bdeath3,	ogre_bdie4	]
{self.solid = SOLID_NOT;
self.ammo_rockets = 2;DropBackpack();};
void()	ogre_bdie4	=[	$bdeath4,	ogre_bdie5	] {ai_forward(1);};
void()	ogre_bdie5	=[	$bdeath5,	ogre_bdie6	] {ai_forward(3);};
void()	ogre_bdie6	=[	$bdeath6,	ogre_bdie7	] {ai_forward(7);};
void()	ogre_bdie7	=[	$bdeath7,	ogre_bdie8	] {ai_forward(25);};
void()	ogre_bdie8	=[	$bdeath8,	ogre_bdie9	] {};
void()	ogre_bdie9	=[	$bdeath9,	ogre_bdie10	] {};
void()	ogre_bdie10	=[	$bdeath10,	ogre_bdie10	] {};
*/


framer($bdeath1, $bdeath10, ogre_bdie1, SUB_Null, 0.1,

	frame_arb($bdeath3,

		self.solid = SOLID_NOT;
#ifdef monsters_plus__
		if (!( self.spawnflags & OGRE_SUPER))
#endifdef
		{
			self.ammo_rockets = 5;
			DropBackpack();
		}
	);
	ai_rep($bdeath2, ai_forward, 5, -6, 1, 3, 7, 25, -6, -6);
);


void() ogre_die =
{
	self.dmg = -80;
#ifdef monsters_plus__
	if (self.spawnflags & MFL_BSUP) self.dmg = -300;
#endifdef

// check for gib
	if (self.health < self.dmg)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_ogre.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

	sound (self, CHAN_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);

	if (random() < 0.5)
		ogre_die1 ();
	else
		ogre_bdie1 ();
};

void() ogre_melee =
{
	if (random() > 0.5)
		ogre_smash1 ();
	else
		ogre_swing1 ();
};


/*QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 64) Ambush Boss Normal Super
The Ogre

--------  CAT  -------
"netname" - fast = fast ogre, slow = slow ogre
"speed" - 0.1 normal, 0.05 fast, 0.2 slow
Super: mega ogre

-------- ROGU --------
Boss: use the modified skin and fire multigrenades.
Normal: use the original skin and fire normal grenades.
*/
void() monster_ogre =
{
// override test
	if (! dm_over)			// __monster_ogre_button0		"1"
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/ogre.mdl");
	precache_model ("progs/h_ogre.mdl");
	precache_model ("progs/grenade.mdl");

	precache_sound ("ogre/ogdrag.wav");
	precache_sound ("ogre/ogdth.wav");
	precache_sound ("ogre/ogidle.wav");
	precache_sound ("ogre/ogidle2.wav");
	precache_sound ("ogre/ogpain1.wav");
	precache_sound ("ogre/ogsawatk.wav");
	precache_sound ("ogre/ogwake.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/ogre.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 200;

	self.th_stand = fr_stand9;
	self.th_walk = ogre_walk1;
	self.th_run = ogre_run1;
	self.th_die = ogre_die;
	self.th_melee = ogre_melee;
	self.th_missile = ogre_nail1;
	self.th_pain = ogre_pain;

#ifdef ROGUE

#ifdef monsters_plus__
	if (!(self.spawnflags & MFL_ENHANCE))			// bypass this for enhanced mode ogres 
#endifdef

// rogue - multi ogre
// none specified - choose random. 25% boss on normal, hard, bloodbath
	if (MAP_MODE == "r")
	if (!(self.spawnflags & 4))	// not locked as normal ogre
	{
		if (cvar("skill") > 0)
		if ( random() <= 0.25 )
		{
			self.spawnflags = self.spawnflags | OGRE_BAWSE;
		}
	}

// TDO: the override should catch this - test
	if (self.spawnflags & OGRE_BAWSE)
	{
		self.skin = 1;
	}

#endifdef

	walkmonster_start;
};

/*
moved to cfg

void() monster_ogre_marksman =
{
	monster_ogre();
};
*/