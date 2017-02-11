/*
==============================================================================

SPIDER

==============================================================================
*/


// let compile process know - since this is an #include in this code set

#messagecompiling spider.qc 

// include in random extra monsters

#undef INCL_SPIDER
#define INCL_SPIDER		4


$cd /raid/quake/id1/models/spider
$origin 0 0 -24
$base base
$skin skin
$scale 0.7

$frame frame1 frame2 frame3 frame4 frame5 frame6 frame7 frame8 frame9 frame10
$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8 pain9 pain10 pain11

// set if entity has been poisoned
#define   FL_POISONED					 32768

void() spider_pain;
void() spider_poison;
void(float offset) SpiderMissile;


void() spid_stand     =[      $frame1,       spid_stand    ] {ai_stand();};

/*
void() spid_walk1     =[      $frame1,       spid_walk2    ] {
if (random() < 0.2)
	sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_walk(4);};
void() spid_walk2     =[      $frame2,       spid_walk3    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_walk(4);};
void() spid_walk3     =[      $frame3,       spid_walk4    ] {ai_walk(4);};
void() spid_walk4     =[      $frame4,       spid_walk5    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_walk(4);};
void() spid_walk5     =[      $frame5,       spid_walk6    ] {ai_walk(4);};
void() spid_walk6     =[      $frame6,       spid_walk7    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_walk(4);};
void() spid_walk7     =[      $frame7,       spid_walk8    ] {ai_walk(4);};
void() spid_walk8     =[      $frame8,       spid_walk9    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_walk(4);};
void() spid_walk9     =[      $frame9,       spid_walk10    ] {ai_walk(4);};
void() spid_walk10    =[      $frame10,       spid_walk1    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_walk(4);};
*/

// tap sound only on even frames

framerloop($frame1, $frame10, spid_walk1, 0.1,

	frame_arb($frame1, if (random() < 0.2) sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_NORM));

	if (! (self.frame & 1)) sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_walk(4);

);

/*
void() spid_run1     =[      $frame1,       spid_run2    ] {
if (random() < 0.2)
	sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_run(12);};
void() spid_run2     =[      $frame3,       spid_run3    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_run(12);};
void() spid_run3     =[      $frame5,       spid_run4    ] {ai_run(12);};
void() spid_run4     =[      $frame7,       spid_run5    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_run(12);};
void() spid_run5     =[      $frame9,       spid_run6    ] {ai_run(12);};

void() spid_run6     =[      $frame1,       spid_run7    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_run(12);};
void() spid_run7     =[      $frame3,       spid_run8    ] {ai_run(12);};
void() spid_run8     =[      $frame5,       spid_run9    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_run(12);};
void() spid_run9     =[      $frame7,       spid_run10    ] {ai_run(12);};
void() spid_run10    =[      $frame9,       spid_run1    ] {
	sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	ai_run(12);};
*/


framerloop($frame1, $frame9, spid_run1, 0.1,

	if (self.frame > $frame1) self.frame = self.frame + 1;

	if (self.frame & 1) sound(self,CHAN_VOICE, "mon_II/spider/tap.wav", 1, ATTN_IDLE);
	frame_arb($frame1, if (random() < 0.2) sound(self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_NORM));

	ai_walk(12);

);

/*
void() spid_melee1      =[      $frame1,        spid_melee2     ]{
sound(self, CHAN_VOICE, "demon/dhit2.wav", 1, ATTN_NORM); 
ai_charge(12);
};
void() spid_melee2      =[      $frame3,        spid_melee3     ] {ai_charge(12);};
void() spid_melee3      =[      $frame5,        spid_melee4     ] {ai_charge(12);};
void() spid_melee4      =[      $frame7,        spid_melee5     ] {ai_charge(12);};
void() spid_melee5      =[      $frame9,        spid_melee6     ] {ai_charge(12);};
void() spid_melee6      =[      $frame1,        spid_melee7     ] {ai_charge(12);};
void() spid_melee7      =[      $frame3,        spid_melee8     ] {ai_charge(12);};
void() spid_melee8      =[      $frame5,        spid_melee9     ] {ai_charge(12);};
void() spid_melee9      =[      $frame7,        spid_melee10    ] {ai_charge(12);};
void() spid_melee10     =[      $frame9,        spid_run1       ] {ai_melee();

	if (random () < 0.2)
	{
		if (self.enemy.takedamage)
			spider_poison ();
	}
};
*/

framer($frame1, $frame9, spid_att3, spid_run1, 0.1,

	if (self.frame > $frame1) self.frame = self.frame + 1;
	
	if (self.frame < $frame9) ai_charge(12);
	else
	{
		if (self.a__)
			SpiderMissile(0);
		else
		{
			ai_melee();
			if (random() < 0.2)
			if (self.enemy.takedamage)
				spider_poison ();
		}
	}
);

framer($frame2, $frame9, spid_att2, spid_att3, 0.1,

	self.frame = self.frame + 1;
	ai_charge(12);

);

void() spid_melee1      =[      $frame1,        spid_att2     ]
{
sound(self, CHAN_VOICE, "demon/dhit2.wav", 1, ATTN_NORM); 
ai_charge(12);
self.a__ = 0;
};

void() spid_attack1     =[      $frame1,       spid_att2    ]
{
sound(self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
ai_charge(12);
self.a__ = 1;
};

/*
void() spid_attack2     =[      $frame3,       spid_attack3    ] {ai_charge(12);};
void() spid_attack3     =[      $frame5,       spid_attack4    ] {ai_charge(12);};
void() spid_attack4     =[      $frame7,       spid_attack5    ] {ai_charge(12);};
void() spid_attack5     =[      $frame9,       spid_attack6    ] {ai_charge(12);};
void() spid_attack6     =[      $frame1,       spid_attack7    ] {ai_charge(12);};
void() spid_attack7     =[      $frame3,       spid_attack8    ] {ai_charge(12);};
void() spid_attack8     =[      $frame5,       spid_attack9    ] {ai_charge(12);};
void() spid_attack9     =[      $frame7,       spid_attack10   ] {ai_charge(12);};
void() spid_attack10    =[      $frame9,       spid_run1   ] {SpiderMissile(0);};
*/

/*
void() spid_pain1       =[      $pain1, spid_pain2      ] {};
void() spid_pain2       =[      $pain2, spid_pain3      ] {};
void() spid_pain3       =[      $pain3, spid_pain4      ] {};
void() spid_pain4       =[      $pain4, spid_pain5      ] {};
void() spid_pain5       =[      $pain5, spid_pain6      ] {};
void() spid_pain6       =[      $pain6, spid_pain7      ] {};
void() spid_pain7       =[      $pain7, spid_pain8      ] {};
void() spid_pain8       =[      $pain8, spid_pain9      ] {};
void() spid_pain9       =[      $pain9, spid_pain10     ] {};
void() spid_pain10      =[      $pain10, spid_pain11    ] {};
void() spid_pain11      =[      $pain11, spid_run1      ] {};
*/

framer($pain1, $pain11, spid_pain1, spid_run1, 0.1,SUB_Null());

void() spider_pain =
{
	if (self.pain_finished > time)
		return;

	sound(self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
self.velocity_x = -50 - 50 * random();
self.velocity_y = 0;
self.velocity_z = 150 + 150*random();
self.flags = self.flags - (self.flags & FL_ONGROUND);
	spid_pain1();
	self.pain_finished = time + 3;
};

/*
void() spid_death1      =[      $death1,        spid_death3     ] {};
void() spid_death2      =[      $death1,        spid_death3     ] {};
void() spid_death3      =[      $death2,        spid_death4     ] {};
void() spid_death4      =[      $death3,        spid_death5     ] {};
void() spid_death5      =[      $death4,        spid_death6     ] {};
void() spid_death6      =[      $death5,        spid_death7     ] {};
void() spid_death7      =[      $death6,        spid_death8    ] {};
void() spid_death8      =[      $death7,        spid_death9    ] {};
void() spid_death9      =[      $death8,        spid_death10    ] {};
void() spid_death10     =[      $death9,        spid_death11    ] {};
void() spid_death11     =[      $death10,       spid_death11    ] {};
*/

framer($death1, $death10, spid_death1, SUB_Null, 0.1,SUB_Null());

void() spider_die =
{
// check for gib
	if (self.health < -90)
	{
/*
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
*/
		gibbs("progs/gib2.mdl");
		return;
	}

	sound(self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_BOUNCE;
	self.velocity_x = -50 + 100*random();
	self.velocity_y = -50 + 100*random();
	self.velocity_z = 300 + 300*random();
	self.avelocity_x = -20 + 40*random();
	self.avelocity_y = -200 + 400*random();
	self.avelocity_z = 0;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	spid_death1();
	self.solid = SOLID_NOT;
};

/*
==============
CheckSpiderJump

==============
*/
float() CheckSpiderJump =
{
	local   vector  dist;
	local   float   d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 100)
		return FALSE;
		
	if (d > 200)
	{
		if (random() < 0.9)
			return FALSE;
	}
		
	return TRUE;
};


void () spider_jump =
{
	if (!FL_ONGROUND)
		return;
	ai_face();
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 150 + '0 0 600';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};


void () spider_attack =
{
	if (CheckSpiderJump)
		{
		if (random() < 0.5)
			spider_jump();                        
		}
	spid_attack1 ();
};

void () PoisonDamage =
{
/*
// heal runes, or special health boxes cure poison
	if (self.enemy.healtype > HEAL_NORM || (self.enemy.rune_flag & TECH_ADOC) || (self.enemy.rune_flag & RUNE_FLG_RG))
	{
		remove(self);
	}
	else 
*/
	if ( ! (self.enemy.flags & FL_POISONED)) // || self.enemy.classname == OBSERVER)
	{
		remove(self);   // if no longer poisoned, return
	}
	else if (self.enemy.health > 0)
	{
		T_Damage (self.enemy, self, self, 1);
		self.nextthink = time + 1;
	}
	else // if (self.enemy.health <= 0)
	{
		remove(self);
	}
};

// idea: some poisonings might expire

void () spider_poison =
{
	local entity poison;

	if (self.enemy.flags & FL_POISONED)  // already poisoned, so
		return;			     // just return

//	if (self.enemy.ishuman)
		centerprint (self.enemy, "You have been poisoned!\n");

	self.enemy.flags = self.enemy.flags | FL_POISONED;

	poison = spawn ();
	poison.owner = self;
	poison.enemy = self.enemy;
	poison.classname = "poison";
	poison.think = PoisonDamage;
	poison.nextthink = time + 1;
//	poison.solid = SOLID_NOT;
//	setmodel (poison, null_string);
//	setsize (poison, '0 0 0', '0 0 0');
};

/*
================
SpiderMissile
================
*/
void(float offset) SpiderMissile =
{
	local   vector  offang;
	local   vector  org, vec;
	
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y + offset * 6;

	makevectors (offang);

	org = self.origin + self.mins + self.size*0.5 + v_forward * 5;//was 20

// set missile speed
	vec = normalize (v_forward);
	vec_z = 0 - vec_z + (random() - 0.5)*0.1;
	
	launch_spike (org, vec);
	newmis.classname = "wizspike";
	setmodel (newmis, "progs/w_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	newmis.velocity = vec*300;
};

/*
//string(entity targ, entity attacker) spider_killmsg =
string() spider_killmsg =
{
#ifdef enhanced
//	if (random() < 0.5 || !ENHANCED)
	if (random() < 0.5)
		return " was dessicated by a ";
	else if (random() < 0.8)
		return " felt the powerful bite of a ";
	else
	{
		return(" - aww, tried to pet the pretty ");
	}
#else
	return " was dessicated by a ";
#endifdef
};
*/

//=================================================================

/*QUAKED monster_spider (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void() monster_spider =
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
	if (! dm_over)			// __monster_spider_button0		"1"
//	if (!M_MONSTER_II & CB_M_FISH)
	if (deathmatch)
	{
		remove(self);
		return;
	}	

	precache_model ("progs/spider.mdl");
	precache_model ("progs/w_spike.mdl");

	precache_sound("mon_II/spider/tap.wav");
	precache_sound("shalrath/attack.wav");
	precache_sound("shalrath/attack2.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("shalrath/death.wav");
	precache_sound("shalrath/idle.wav");
	precache_sound("shalrath/pain.wav");
	precache_sound("shalrath/sight.wav");
/*
	self.think = walkmonster_start; // ok for map monsters
	self.nextthink = time + 0.1 + random ()*0.1;    
}

// Cataboligne - 11.14.12 - fast / slow code
	if (self.speed <= 0) self.speed = MON_NORM;
	self.lip = 1; // local speed divisor
// map specced
	if (self.netname == CFAST) self.speed = MON_FAST;
	else if (self.netname == CSLOW) self.speed = MON_SLOW;
*/

	self.netname = "Phase spider";

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/spider.mdl");
	setsize (self, '-32 -32 -24', '32 32 5');
	self.health = 200;

	self.th_stand = spid_stand;
	self.th_walk = spid_walk1;
	self.th_run = spid_run1;
	self.th_die = spider_die;
	self.th_pain = spider_pain;
	self.th_missile = spider_attack;
	self.th_melee = spid_melee1;
//	self._killmsg = spider_killmsg;

//	if (ign == A_MONSTER) 
	walkmonster_start;
};

