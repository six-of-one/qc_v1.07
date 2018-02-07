/*
==============================================================================

BLOB

==============================================================================
*/

$cd id1/models/tarbaby
$origin 0 0 24
$base base		

$skin skin

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp
/*
	monster enhance - what to do with all this ?

// larger spawn
$frame lgwalk1 lgwalk2 lgwalk3 lgwalk4 lgwalk5 lgwalk6 lgwalk7 lgwalk8 lgwalk9 lgwalk10
$frame lgwalk11 lgwalk12 lgwalk13 lgwalk14 lgwalk15 lgwalk16 lgwalk17 lgwalk18 lgwalk19
$frame lgwalk20 lgwalk21 lgwalk22 lgwalk23 lgwalk24 lgwalk25

$frame lgrun1 lgrun2 lgrun3 lgrun4 lgrun5 lgrun6 lgrun7 lgrun8 lgrun9 lgrun10 lgrun11 lgrun12 lgrun13
$frame lgrun14 lgrun15 lgrun16 lgrun17 lgrun18 lgrun19 lgrun20 lgrun21 lgrun22 lgrun23
$frame lgrun24 lgrun25

$frame lgjump1 lgjump2 lgjump3 lgjump4 lgjump5 lgjump6

$frame lgfly1 lgfly2 lgfly3 lgfly4

$frame lgexp

*/
// super tarbaby - just because
#define TB_SUPER	MFL_SUPER

#define SUPER_SPAWN_CHANCE	0.1
// how much a super spawn could heal in a pain frame
#define super_spawn_emheal	mon_xmad_heal
// chance to heal
#define super_spawn_emheal_chn		mon_super_emheal_chn


void()	tbaby_stand1	=[	$walk1,		tbaby_stand1	] {ai_stand();};

#ifdef unused
void()	tbaby_hang1		=[	$walk1,		tbaby_hang1	] {ai_stand();};
#endifdef

/*
void()	tbaby_walk1	=[	$walk1,		tbaby_walk2	] {ai_turn();};
void()	tbaby_walk2	=[	$walk2,		tbaby_walk3	] {ai_turn();};
void()	tbaby_walk3	=[	$walk3,		tbaby_walk4	] {ai_turn();};
void()	tbaby_walk4	=[	$walk4,		tbaby_walk5	] {ai_turn();};
void()	tbaby_walk5	=[	$walk5,		tbaby_walk6	] {ai_turn();};
void()	tbaby_walk6	=[	$walk6,		tbaby_walk7	] {ai_turn();};
void()	tbaby_walk7	=[	$walk7,		tbaby_walk8	] {ai_turn();};
void()	tbaby_walk8	=[	$walk8,		tbaby_walk9	] {ai_turn();};
void()	tbaby_walk9	=[	$walk9,		tbaby_walk10	] {ai_turn();};
void()	tbaby_walk10	=[	$walk10,		tbaby_walk11	] {ai_turn();};
void()	tbaby_walk11	=[	$walk11,		tbaby_walk12	] {ai_walk(2);};
void()	tbaby_walk12	=[	$walk12,		tbaby_walk13	] {ai_walk(2);};
void()	tbaby_walk13	=[	$walk13,		tbaby_walk14	] {ai_walk(2);};
void()	tbaby_walk14	=[	$walk14,		tbaby_walk15	] {ai_walk(2);};
void()	tbaby_walk15	=[	$walk15,		tbaby_walk16	] {ai_walk(2);};
void()	tbaby_walk16	=[	$walk16,		tbaby_walk17	] {ai_walk(2);};
void()	tbaby_walk17	=[	$walk17,		tbaby_walk18	] {ai_walk(2);};
void()	tbaby_walk18	=[	$walk18,		tbaby_walk19	] {ai_walk(2);};
void()	tbaby_walk19	=[	$walk19,		tbaby_walk20	] {ai_walk(2);};
void()	tbaby_walk20	=[	$walk20,		tbaby_walk21	] {ai_walk(2);};
void()	tbaby_walk21	=[	$walk21,		tbaby_walk22	] {ai_walk(2);};
void()	tbaby_walk22	=[	$walk22,		tbaby_walk23	] {ai_walk(2);};
void()	tbaby_walk23	=[	$walk23,		tbaby_walk24	] {ai_walk(2);};
void()	tbaby_walk24	=[	$walk24,		tbaby_walk25	] {ai_walk(2);};
void()	tbaby_walk25	=[	$walk25,		tbaby_walk1	] {ai_walk(2);};
*/

framerloop($walk1, $walk25, tbaby_walk1, 0.1,

	if (self.frame < $walk11) ai_turn();
	else ai_walk(2);
);

/*
void()	tbaby_run1	=[	$run1,		tbaby_run2	] {ai_face();};
void()	tbaby_run2	=[	$run2,		tbaby_run3	] {ai_face();};
void()	tbaby_run3	=[	$run3,		tbaby_run4	] {ai_face();};
void()	tbaby_run4	=[	$run4,		tbaby_run5	] {ai_face();};
void()	tbaby_run5	=[	$run5,		tbaby_run6	] {ai_face();};
void()	tbaby_run6	=[	$run6,		tbaby_run7	] {ai_face();};
void()	tbaby_run7	=[	$run7,		tbaby_run8	] {ai_face();};
void()	tbaby_run8	=[	$run8,		tbaby_run9	] {ai_face();};
void()	tbaby_run9	=[	$run9,		tbaby_run10	] {ai_face();};
void()	tbaby_run10	=[	$run10,		tbaby_run11	] {ai_face();};
void()	tbaby_run11	=[	$run11,		tbaby_run12	] {ai_run(2);};
void()	tbaby_run12	=[	$run12,		tbaby_run13	] {ai_run(2);};
void()	tbaby_run13	=[	$run13,		tbaby_run14	] {ai_run(2);};
void()	tbaby_run14	=[	$run14,		tbaby_run15	] {ai_run(2);};
void()	tbaby_run15	=[	$run15,		tbaby_run16	] {ai_run(2);};
void()	tbaby_run16	=[	$run16,		tbaby_run17	] {ai_run(2);};
void()	tbaby_run17	=[	$run17,		tbaby_run18	] {ai_run(2);};
void()	tbaby_run18	=[	$run18,		tbaby_run19	] {ai_run(2);};
void()	tbaby_run19	=[	$run19,		tbaby_run20	] {ai_run(2);};
void()	tbaby_run20	=[	$run20,		tbaby_run21	] {ai_run(2);};
void()	tbaby_run21	=[	$run21,		tbaby_run22	] {ai_run(2);};
void()	tbaby_run22	=[	$run22,		tbaby_run23	] {ai_run(2);};
void()	tbaby_run23	=[	$run23,		tbaby_run24	] {ai_run(2);};
void()	tbaby_run24	=[	$run24,		tbaby_run25	] {ai_run(2);};
void()	tbaby_run25	=[	$run25,		tbaby_run1	] {ai_run(2);};
*/

framerloop($run1, $run25, tbaby_run1, 0.1,

	if (self.frame < $run11) ai_face();
	else ai_run(2);
	frame_arb($run1,self.movetype = MOVETYPE_STEP;);
);

//============================================================================


void()	tbaby_jump1;

void()	Tar_JumpTouch =
{
//	local	float	ldmg;

#ifdef monsters_plus__
	if (other.takedamage)// && other.classname != self.classname)
	if (other.classname != "monster_tarbaby")
//	if (other.classname != "monster_lavabomb") // use tarbaby class now
	if (other.classname != "monster_vomit")
#ifdef code_morph
	if (other.morphy !=  IMP_MCTHON)
#endifdef
	{
		self.duration = time + 5;
#else
	if (other.takedamage && other.classname != self.classname)
	{
#endifdef
		if ( vlen(self.velocity) > 400 )
		{
			self.ldmg_ = 10 + 10*random();
#ifdef monsters_plus__
			if (self.spawnflags & TB_SUPER) self.ldmg_ = self.ldmg_ * self.scale;
#endifdef
			T_Damage (other, self, self, self.ldmg_);	
			sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
		}
	}
	else
		sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);

	self.touch = SUB_Null;
	self.nextthink = time + 0.1;

	jumptouch_rep(monster_tarbaby, tbaby_run1, tbaby_jump1);

/*
	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = tbaby_run1;
	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = tbaby_jump1;
	self.nextthink = time + 0.1;
*/
};

void()	tbaby_jump5;

/*
void()	tbaby_fly1		=[	$fly1,	tbaby_fly2	] {};
void()	tbaby_fly2		=[	$fly2,	tbaby_fly3	] {};
void()	tbaby_fly3		=[	$fly3,	tbaby_fly4	] {};
void()	tbaby_fly4		=[	$fly4,	tbaby_fly1	] {
self.cnt = self.cnt + 1;
if (self.cnt == 4)
{
//dprint ("spawn hop\n");
tbaby_jump5 ();
}
};
*/

framerloop($fly1, $fly4, tbaby_fly1, 0.1,

	frame_arb($fly4,
		self.cnt = self.cnt + 1;
		if (self.cnt == 4) tbaby_jump5 ();
	);
	
);

/*
void()	tbaby_jump1		=[	$jump1,	tbaby_jump2		] {ai_face();};
void()	tbaby_jump2		=[	$jump2,	tbaby_jump3		] {ai_face();};
void()	tbaby_jump3		=[	$jump3,	tbaby_jump4		] {ai_face();};
void()	tbaby_jump4		=[	$jump4,	tbaby_jump5		] {ai_face();};
*/
void()	tbaby_jump5		=[	$jump5,	tbaby_jump6		]
{
#ifdef monsters_plus__
	if (self.duration < time)
	{
		self.duration = MAXFL;
		self.movetype = MOVETYPE_STEP;
		self.th_run();
		return;
	}
#endifdef
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = Tar_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 200';
	self.velocity_z = self.velocity_z + random()*150;
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.cnt = 0;
};
void()	tbaby_jump6	=[	$jump6,tbaby_fly1	] {};

framer($jump1, $jump4, tbaby_jump1, tbaby_jump5, 0.1,ai_face());

#ifdef monsters_plus__
// tb fires a shot - handles super babys

void() tbaby_shot =
{
	if (!checkbottom(self)) // flew
 	if (random() < 0.65)
		return;

// ???: admin request on this - no idea why
	if (self.model != "progs/lavabomb.mdl")
	if (!(self.spawnflags & TB_SUPER))
	{
		self.th_melee();
		return;
	}

	if (self.enemy)
	if (vlen(self.enemy.origin - self.origin) < 300)
	if (random() < 0.5)
	{
		self.th_melee();
		return;
	}

	boss_missile('0 0 0');

	newmis.dmg = (20 + random() * 4) * self.scale;
	newmis.skin = 2;

	if (self.model != "progs/lavabomb.mdl")
	if (self.skin > 0)
	{
		setmodel (newmis, "progs/w_spike.mdl");
		newmis.avelocity = '0 0 0';
	}

	if (self.spawnflags & TB_SUPER) // large baby, larger shot, more dmg
	{
//		newmis.dmg = 40 + random() * 8;
		if (newmis.model == "progs/lavaball.mdl")
			newmis.frame = 13;
		else
		newmis.frame = 1;
	}

	setsize(newmis, '0 0 0', '0 0 0');
};
#endifdef

//=============================================================================


#ifdef monsters_plus__
	#define tb_mitosis
#else
#ifdef ROGUE
	#define tb_mitosis
#endifdef
#endifdef

#ifdef tb_mitosis
void(float ign) tbaby_mitosis;
#endifdef

void()	tbaby_die1	=[	$exp,		tbaby_die2	] {
self.takedamage = DAMAGE_NO;
};
void()	tbaby_die2	=[	$exp,		tbaby_run1	] 
{
	self.ldmg_ = 120 * self.scale;	// TDO: override
#ifdef monsters_plus__
	if (self.spawnflags & TB_SUPER)
	{
		if (random() < 0.2) // baby blast!
		{
			self.sup_time = MAXFL;			// so pain code doesnt run
			self.cnt = random() * 6;
			while (self.cnt > 0)
			{
				tbaby_mitosis(self.cnt);
				item_eject(newmis, GEN_BOUNCE);
				self.cnt = self.cnt - 1;
			}
			remove(self);
			return;
		}
//		self.dmg = 220;
	}
#endifdef

	T_RadiusDamage (self, self, self.ldmg_, world);

	sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	BecomeExplosion (world);	// note: this maybe makes these un-respawnable if they are upgraded map monsters
};

#ifdef tb_mitosis
//=============================================================================
// rogue - do some extra stuff

void() tbaby_checknew =
{
// note: this causes freeze frame death
	if (!walkmove(0,0))
	{
//		remove(self);
		self.model = string_null; // note - may have fade remove or crumble process later
		self.think = SUB_Remove;
		self.nextthink = time + 1;
		return;
	}
	
// CHECK: do we need all this since copyentity was used?			-- note: we do if mitosis was from a morph

//	self.enemy = self.owner.enemy;
//	if (self.owner.class_select != "class_monster") // owner is lava morph or other
//	{
		self.th_stand = tbaby_stand1;
		self.th_walk = tbaby_walk1;
		self.th_run = tbaby_run1;
		self.th_missile = tbaby_shot;
		self.th_melee = tbaby_jump1;
		self.th_die = tbaby_die1;

	self.origin_z = self.origin_z + 3;      // raise off floor a bit
	droptofloor();

	if (!walkmove(0,0))
	{
// ISSUE: what if the owner explodes after mitosing

		self.owner.th_pain = tbaby_mitosis;
//		remove(self);
		self.think = SUB_Remove;
		self.nextthink = time + 1 + random() * 2;
		return;
	}

// Cataboligne - 11.14.12 - fast / slow code
#ifdef mon_speed
	if (self.speed <= 0) self.speed = MON_NORM;
	self.lip = 1; // local speed divisor

// server controls set all monsters fast or slow if not specced - this includes random monsters
//	else 
//	if (FAST_MONSTER & CB_M_TARBABY) self.speed = MON_FAST;
//	else if (SLOW_MONSTER & CB_M_TARBABY) self.speed = MON_SLOW;
#endifdef


	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.flags = self.flags | FL_MONSTER;
	self.pausetime = 99999999;
	self.th_stand ();
	self.nextthink = self.nextthink + random()*0.5;

	if (self.model == "progs/lavabomb.mdl")
		self.th_missile = tbaby_shot;

	self.class_select = "class_monster";

	total_monsters = total_monsters + 1;
  	
	WriteByte (MSG_BROADCAST, SVC_UPDATESTAT);
	WriteByte (MSG_BROADCAST, STAT_TOTALMONSTERS);
	WriteLong (MSG_BROADCAST, total_monsters);
};

// Cataboligne - 12.6.12 - added ignore for super baby explode or sac mode burst, make babys for sure

void(float ign) tbaby_mitosis =
{
	newmis = world;
#ifdef monsters_plus__
	if (( random() < mon_super_emheal_chn ) || ign)
#else
	if ( random() < 0.35 )
#endifdef
	{
		newmis = spawn();
		copyentity(self, newmis);			// NOTE: may have serious issues when morph calls this !
/*
		e0__.classname = self.classname;
		e0__.netname = self.netname;
		e0__.movetype = MOVETYPE_STEP;
		setsize (e0__, '-16 -16 -24', '16 16 40');
		e0__.health = 80;
// chaos improvements - handle lava bomb
		if (self.model == "progs/lavabomb.mdl")
			e0__.health = 160;
		else if (self.skin == 1)
			e0__.health = 60;
		else if (self.skin == 2)
			e0__.health = 100;

		e0__.owner = self;
		self.th_pain = SUB_Null;
		
		setmodel (e, self.model);
		e0__.solid = SOLID_SLIDEBOX;
		e0__.skin = self.skin;
		if (self.class_select == "class_monster") 
			e0__.frame = self.frame;
		
		setorigin (e0__, self.origin);
*/
		newmis.spawnflags = newmis.spawnflags - (newmis.spawnflags & MFL_BSUP);		// dont mitosis into a super | xmad
		cvar_fields(newmis, strcat("__",newmis.classname));		// load em up - updates health & so
		newmis.think = tbaby_checknew;
		newmis.nextthink = time + 0.5;

		sound (newmis, CHAN_VOICE, "blob/mytosis.wav", 1, ATTN_NORM);
	}

	pain_sup();
/*
	if (self.spawnflags & MFL_SUPER)
	if (self.class_select == "class_monster") 
	if (self.pain_finished < time)
	{
		if (random() < mon_super_emheal_chn)
		{
			self.health = self.health + (mon_super_heal * random());
		}

		if (self.speed > mon_superspeedup_max)
		if (random() < (mon_superspeed_chn * 5))
		{
			self.speed  = self.speed - mon_superspeed_fact;
			if (self.speed < mon_superspeedup_max) self.speed = mon_superspeedup_max;
		}

		self.pain_finished = time + 2;
	}
*/
};

//=============================================================================

// detect spawn type creatures
/*

deactivated - only used in 1 place

float(entity e) IS_SPAWN =
{
	local float f;

	f = FALSE;
	if (e.model == "progs/tarbaby.mdl") f = TRUE;
	if (e.model == "progs/lavabomb.mdl") f = TRUE;
	return(f);
};
*/
#endifdef

//=============================================================================


/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush Blue Green Spots Silent Lavabomb random Super
Spawn (Tarbaby), 80 health points.

--------  CAT  -------
"Lavabomb" - the new uber spawn, Lava mode
"random" - select a rogue type at random
"Super" - larger tarbaby, all versions

-------- ROGU --------
The Spawn (and hellspawn)

The spawn type is random by default on rogue maps
If you want a specific type, select "Blue", "Green", or "Spots".
"blue"  - plain old tarbaby, 80 health
"green" - new toxic skin - 60 health
"spots" - rogue hellspawn - 100 health

"Silent" - hipnotic deal - may not work in every case
*/

#define	TB_BLUE		2
#define	TB_GREEN	4
#define	TB_HELLS	8
#define	TB_LAVA		32
#define	TB_RANDOM	64


void() monster_tarbaby =
{
// override test
	if (! dm_over)			// __monster_tarbaby_button0		"1"
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/tarbaby.mdl");

	precache_sound2 ("blob/death1.wav");
	precache_sound2 ("blob/hit1.wav");
	precache_sound2 ("blob/land1.wav");
	precache_sound2 ("blob/sight1.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/tarbaby.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 80;

	self.th_stand = tbaby_stand1;
	self.th_walk = tbaby_walk1;
	self.th_run = tbaby_run1;
	self.th_missile = tbaby_jump1;
	self.th_melee = tbaby_jump1;
	self.th_die = tbaby_die1;

#ifdef ROGUE

#ifdef monsters_plus__
	if (!(self.spawnflags & MFL_ENHANCE))			// bypass this for enhanced mode ogres 
#endifdef
	{
// rogue - spawn upgrade - new skins, more health, mitosis
// random upgrade if not specced
		if ((MAP_MODE == "r") && !(self.spawnflags & 14))
		{
			  self.rnd_ = skill * 0.2;
			  self.rnd_ = self.rnd_ + random();
		
			if (self.rnd_ > 0.8 && skill > 1)
			{
				self.spawnflags = self.spawnflags | TB_HELLS;
			}
			else if (self.rnd_ > 0.5)
			{
				self.spawnflags = self.spawnflags | TB_GREEN;
			}
		}
		if (self.spawnflags & 14)
#ifdef monsters_plus__
			cvar_fields(self, strcat("__",self.classname));		// use our custom loader
#else
		{
			if (self.spawnflags & 8)
			{
				self.th_pain = tbaby_mitosis;
				self.skin = 2;
				self.health = 100;
			}
			else if (self.spawnflags & 4)
			{
				self.th_pain = tbaby_mitosis;
				self.skin = 1;
				self.health = 60;
			}
			else if (self.spawnflags & 2)
			{
				self.skin = 0;
			}
		}
#endifdef
	}

#endifdef

#ifdef monsters_plus_remove

if (random() < 0.25) // MAP_LAVABABY) 
		self.spawnflags = self.spawnflags | TB_LAVA;

	self.netname = "Spawn"; // check: these

	self.cnt = (self.spawnflags & TB_LAVA); // mapper | code selected | rnd map convert - lava bomb

#ifdef enhanced
//	if (ign == A_MONSTER) // checks for random monsters
	{
		if (random() < 0.1) // SUPER_SPAWN_CHANCE
			self.spawnflags = self.spawnflags | TB_SUPER;

		if (random() < 0.3) // RND_LAVABABY) 
			self.cnt = 16; //TB_LAVA; // hot tarbaby from random
	}
#endifdef


//	if (ign != A_MONSTER || self.cnt > 0)
//	if ((random() < MAP_LAVABABY) || self.cnt > 0) // hot tarbaby converted from a map spawned baby
if ((self.cnt > 0) || (self.map	== "dyn_sp"))
	{
		setmodel(self,"progs/lavabomb.mdl"); // this model has rocket trail flag set
		setsize (self, '-16 -16 -24', '16 16 40');
		if (self.map == "dyn_sp")
		if (random() < 0.2) self.skin = 2; // pk lava skin
//		self.health = 160;
		self.health = self.health + 80; // add to what we already have, could be a super
		self.th_missile = tbaby_shot;
		if (random() < 0.75) self.th_pain = tbaby_mitosis;
		self.netname = "Bomb";
		walkmonster_start ();
		return;
	}

	self.cnt = (self.spawnflags & TB_RANDOM); // mapper | code selected random

	if (self.spawnflags & TB_HELLS)
	{
		self.th_missile = tbaby_shot;
		self.th_pain = tbaby_mitosis;
		self.skin = 2;
//		self.health = 100;
		self.health = self.health + 20;
	}
	else if (self.spawnflags & TB_GREEN)
	{
		self.th_pain = tbaby_mitosis;
		self.skin = 1;
//		self.health = 60;
		self.health = self.health - 20;
	}
	else if (self.spawnflags & TB_BLUE)
	{
		self.skin = 0;
	}
	else
	if ((MAP_MODE == "r") || self.cnt)
	{
//		skill = cvar("skill");
		if (self.cnt) // TB_RANDOM - make a random selection
			self.cnt = random();
		else // rogue map tarbaby
		{
			self.cnt = skill * 0.2;
			self.cnt = self.cnt + random();
			if (self.cnt > 0.8)
			if (skill <= 1) // skill > 1 test moved here
				self.cnt = 0.7;
		}

//		if (self.cnt > 0.8 && skill > 1)
		if (self.cnt > 0.8)
		{
			self.th_missile = tbaby_shot;
			self.th_pain = tbaby_mitosis;
			self.skin = 2;
//			self.health = 100;
			self.health = self.health + 20;
		}
		else if (self.cnt > 0.5)
		{
			self.th_pain = tbaby_mitosis;
			self.skin = 1;
	//		self.health = 60;
			self.health = self.health - 20;
		}
	}

#endifdef

	walkmonster_start;
};

/*

deprecated - set spawnflag and use previous fn call

// enhanced tarbaby - the chaos mod lavabomb

void(float ign) monster_lavabomb =
*/