/*
==============================================================================

Vomitus  -=¤ by Dark Mage ¤=-

==============================================================================
*/

// let compile process know - since this is an #include in this code set

#messagecompiling vomitus.qc 

// include in random extra monsters

#undef INCL_VOMITUS
#define INCL_VOMITUS		1

$cd /raid/quake/id1/models/vomitus
$origin 0 0 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14 walk15 walk16

$frame paina1 paina2 paina3 paina4 

$frame painb1 painb2 painb3 painb4

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13

$frame painc1 painc2 painc3

$frame die1 die2 die3 die4 die5 die6 die7 die8
$frame die9 die10 die11 die12 die13 die14 die15

void() vom_run1;
void() vom_idle_sound;

  
//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤



// Tarbaby Making Code, Dang this took a long time to figure out, 
// ao I searched around and used tmbot to get the idea then I changed 
// and modified it to make it my own 
//(in other words I learned how it worked)    

//note on code:Is called Make_Tarbaby to allow for greater flexability

void (vector org) spawn_tarbaby =
{  

	newmis = spawn();
// note: archon create fn
//	item_call_save(newmis, "monster_tarbaby"); - can prob just call monster_tarbaby after mod for A_MONSTER
	setorigin(newmis, org);
/*
	monster.solid = SOLID_SLIDEBOX;
	monster.movetype = MOVETYPE_STEP;
	monster.angles_y = self.angles_y;
	monster.classname = "tarbaby";
	monster.MakeMonster = self;
	self.MakeMonster = monster;	
	monster.health = 80;
	monster.goalentity = self;
	monster.movetarget = self;

	//new monsters specifics
	monster.th_stand = tbaby_stand1;
	monster.th_walk = tbaby_walk1;
	monster.th_run = tbaby_run1;
	monster.th_missile = tbaby_jump1;
	monster.th_melee = tbaby_jump1;
	monster.th_die = tbaby_die1;

	//monster.nextthink = monster.nextthink + random()*0.5; //spread out the the think times
	monster.nextthink = monster.nextthink + 0.5; //don't spread out think times 
	monster.think = walkmonster_start;

	setorigin(monster, '0 0 0');
	setmodel (monster, "progs/tarbaby.mdl");
	setsize (monster, '-16 -16 -24', '16 16 40');
*/	
};

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
// note: when we have the hot vomit & hot touch, we want to explode as a large lava ball, or puddle or shot fire balls & such

void() T_Vomistouch =
{
	local float f;

	if (other == self) return;
	if (other.classname == "vomis") return;
	if (other.classname == "vomisss") return;
	if (other.classname == "vomisexplod") return;

	if (other.classname == "monster_vomit") f = TRUE;
	if (other.classname == "monster_tarbaby") f = TRUE;
// note: morph module with archon
//	if (other.morphy == IMP_MCTHON) f = TRUE;
//	if (other.morphy == IMP_MVOMIS) f = TRUE;

	if (f) // hit a friendly, remove & return
	{
		remove(self);
		return;
	}

	if (self.classname == "vomisexplod") T_MissileTouch(); // idea: tweak damage
	if (self.classname == "vomisss")
#ifdef enhanced
		{
			self.dmg = 18;
			spike_touch();
		}
#else
		superspike_touch();
#endifdef
	else
		spike_touch();

};

// Normal shot
void(float offset) vom_shot =
{
	local	vector	offang;
	local	vector	org, vec;
	
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y + offset * 6;
	
	makevectors (offang);

	org = self.origin + self.mins + self.size*0.5 + v_forward * 20;


// set missile speed
	vec = normalize (v_forward);
	vec_z = 0 - vec_z + (random() - 0.5)*0.1;
	
	launch_spike (org, vec);
	newmis.classname = "vomis";
	setmodel (newmis, "progs/vomis.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.frame = 0;
	newmis.skin = 0;
	newmis.velocity = vec*300;
	newmis.touch = T_Vomistouch;

};

// Exploding Missiles
void(float offset) vom_shot2 =
{
/*
	local	vector	offang;
	local	vector	org, vec;
	
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y + offset * 6;
	
	makevectors (offang);

	org = self.origin + self.mins + self.size*0.5 + v_forward * 20;


// set missile speed
	vec = normalize (v_forward);
	vec_z = 0 - vec_z + (random() - 0.5)*0.1;
	
	launch_spike (org, vec);
*/
	vom_shot(offset);
	newmis.classname = "vomisexplod";
//	setmodel (newmis, "progs/vomis.mdl");
//	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.frame = 2;
	newmis.skin = 1;
//	newmis.velocity = vec*300;
//	newmis.touch = T_Vomistouch;
};

// Creture spawners
void(float offset) vom_shot3 =
{
	local	vector	offang;
	local	vector	org, vec;
	
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y + offset * 6;
	
	makevectors (offang);

	org = self.origin + self.mins + self.size*0.5 + v_forward * 20;
      
// set missile speed
	vec = normalize (v_forward);
	vec_z = 0 - vec_z + (random() - 0.5)*0.1;
	
	spawn_tarbaby(self.origin + '0 0 6' + v_forward * 10);
	newmis.velocity = vec*3;
};

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

/*
previous cm-mk 2 loop code - depricated

void()	vom_stand1	=[	$stand1,	vom_stand1	]
{
	if ((self.duration < $stand1) || (self.duration > $stand8))
	{
		self.duration = $stand1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

// idle sound - heh heh - this was so obvious in retrospect
	if (random() < 0.5) copb_checkFart();
	self.copb_nextFartTimeout = time + 30 + rint(random() * 200);

	ai_stand();
};
*/

/*
void()	vom_stand1	=[	$stand1,	vom_stand2	] {ai_stand();};
void()	vom_stand2	=[	$stand2,	vom_stand3	] {ai_stand();};
void()	vom_stand3	=[	$stand3,	vom_stand4	] {ai_stand();};
void()	vom_stand4	=[	$stand4,	vom_stand5	] {ai_stand();};
void()	vom_stand5	=[	$stand5,	vom_stand6	] {ai_stand();};
void()	vom_stand6	=[	$stand6,	vom_stand7	] {ai_stand();};
void()	vom_stand7	=[	$stand7,	vom_stand8	] {ai_stand();};
void()	vom_stand8	=[	$stand8,	vom_stand9	] {ai_stand();};
void()	vom_stand9	=[	$stand9,	vom_stand1	] {ai_stand();};

// restore below, once we have pk module - have an option to include if pk module is out
	frame_arb($stand3,

		if (random() < 0.5) copb_checkFart();
		self.copb_nextFartTimeout = time + 30 + rint(random() * 200);
	);


*/

framerloop($stand1, $stand9, vom_stand1, 0.1,

	ai_stand()

);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

/*
void()	vom_walk1	=[	$walk1,	vom_walk2	] {vom_idle_sound(); ai_walk(2);};
void()	vom_walk2	=[	$walk2,	vom_walk3	] {ai_walk(5);};
void()	vom_walk3	=[	$walk3,	vom_walk4	] {ai_walk(5);};
void()	vom_walk4	=[	$walk4,	vom_walk5	] {ai_walk(4);};
void()	vom_walk5	=[	$walk5,	vom_walk6	] {ai_walk(4);};
void()	vom_walk6	=[	$walk6,	vom_walk7	] {ai_walk(2);};
void()	vom_walk7	=[	$walk7,	vom_walk8	] {ai_walk(2);};
void()	vom_walk8	=[	$walk8,	vom_walk9	] {ai_walk(3);};
void()	vom_walk9	=[	$walk9,	vom_walk10	] {ai_walk(3);};
void()	vom_walk10	=[	$walk10,	vom_walk11	] {ai_walk(4);};
void()	vom_walk11	=[	$walk11,	vom_walk12	] {ai_walk(3);};
void()	vom_walk12	=[	$walk12,	vom_walk13	] {ai_walk(4);};
void()	vom_walk13	=[	$walk13,	vom_walk1	] {ai_walk(6);};
*/

framerloop($walk1, $walk13, vom_walk1, 0.1,

	frame_arb($walk1,vom_idle_sound());

	if (self.frame < $walk9)
		ai_rep($walk1, ai_walk, 2, 5, 5, 4, 4, 2, 2, 3);
	else
		ai_rep($walk9, ai_walk, 3, 4, 3, 4, 6, -6, -6, -6);
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

/*
void()	vom_run1	=[	$walk1,	vom_run2	] { vom_idle_sound(); ai_run (20);};
void()	vom_run2	=[	$walk2,     vom_run3	] {ai_run(25);};
void()	vom_run3	=[	$walk3,	vom_run4	] {ai_run(18);};
void()	vom_run4	=[	$walk4,	vom_run5	] {ai_run(16);};
void()	vom_run5	=[	$walk5,	vom_run6	] {ai_run(14);};
void()	vom_run6	=[	$walk6,	vom_run7	] {ai_run(25);};
void()	vom_run7	=[	$walk7,	vom_run8	] {ai_run(21);};
void()	vom_run8	=[	$walk8,	vom_run1	] {ai_run(13);};
*/

framerloop($walk1, $walk8, vom_run1, 0.1,

	frame_arb($walk1,vom_idle_sound());

	ai_rep($walk1, ai_run, 20, 25, 18, 16, 14, 25, 21, 13);
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
// all 2 pain need check for frame sequence and appearance - consolidate this to 1 set with rnd sound

/*
void()	vom_paina1	=[	$paina1,		vom_paina2	] {sound (self, CHAN_VOICE, "vomitus/paina.wav", 1, ATTN_NORM);};
void()	vom_paina2	=[	$paina2,		vom_paina3	] {};
void()	vom_paina3	=[	$paina3,		vom_paina4	] {};
void()	vom_paina4	=[	$paina4,		vom_paina5	] {};
*/

void()	vom_pain_exit	= [	$paina1,		vom_run1	] {};

framer($paina1, $paina4, vom_paina1, vom_pain_exit, 0.1,

	frame_arb($paina1,sound(self, CHAN_VOICE, "vomitus/paina.wav", 1, ATTN_NORM));
);
	
//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_painb1	=[	$painb1,		vom_painb2	] {sound (self, CHAN_VOICE, "vomitus/painb.wav", 1, ATTN_NORM);};
void()	vom_painb2	=[	$painb2,		vom_painb3	] {};
void()	vom_painb3	=[	$painb3,		vom_painb4	] {};
void()	vom_painb4	=[	$painb4,		vom_painb5	] {};
void()	vom_painb5	=[	$painb1,		vom_run1	] {};
*/

framer($painb1, $painb4, vom_painb1, vom_pain_exit, 0.1,

	frame_arb($painb1,sound(self, CHAN_VOICE, "vomitus/painb.wav", 1, ATTN_NORM));
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_painc1	=[	$painc1,		vom_painc2	] {sound (self, CHAN_VOICE, "vomitus/painc.wav", 1, ATTN_NORM);};
void()	vom_painc2	=[	$painc2,		vom_painc3	] {};
void()	vom_painc3	=[	$painc3,		vom_painc4	] {};
void()	vom_painc4	=[	$painc2,		vom_painc5	] {};
void()	vom_painc5	=[	$painc1,		vom_run1	] {};
*/

framer($painc1, $painc3, vom_painc1, vom_pain_exit, 0.1,

	frame_arb($painc1,sound(self, CHAN_VOICE, "vomitus/painc.wav", 1, ATTN_NORM));
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_die1	=[	$die1,	vom_die2	] {ai_forward(10);};
void()	vom_die2	=[	$die2,	vom_die3	] {ai_forward(8);};
void()	vom_die3	=[	$die3,	vom_die4	] {self.solid = SOLID_NOT; ai_forward(7);};
void()	vom_die4	=[	$die4,	vom_die5	] {};
void()	vom_die5	=[	$die5,	vom_die6	] {};
void()	vom_die6	=[	$die6,	vom_die7	] {};
void()	vom_die7	=[	$die7,	vom_die8	] {};
void()	vom_die8	=[	$die8,	vom_die9	] {ai_forward(10);};
void()	vom_die9	=[	$die9,	vom_die10	] {ai_forward(11);};
void()	vom_die10	=[	$die10,	vom_die11	] {};
void()	vom_die11	=[	$die11,	vom_die12	] {};
void()	vom_die12	=[	$die12,	vom_die13	] {};
void()	vom_die13	=[	$die13,	vom_die14	] {};
void()	vom_die14	=[	$die14,	vom_die15	] {};
void()      vom_die15   =[    $die15,     vom_die15   ] {};
*/

framer($die1, $die15, vom_die1, SUB_Null, 0.1,

	frame_arb($die3,self.solid = SOLID_NOT);

	ai_rep($die1, ai_forward, 10,-8, 7, -6, -6, -6, -6, 10);
	frame_arb($die9,ai_forward(11));
);
//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

void()	vom_dieb1	=[	$die1,	vom_dieb2	] {self.takedamage = DAMAGE_NO;};
void()	vom_dieb2	=[	$die2,	vom_run1	] 
{
	local float f;
	local vector v;

	T_RadiusDamage (self, self, 120, world);

	f = rint(random() * 2);
	while (f > 0)
	{
		if (random() < 0.6)
		{
			makevectors(self.v_angle);
			v_y = crandom() * 60;
			spawn_tarbaby(self.origin + v + (v_forward * (24 + 20 * f)));
			newmis.velocity_z = 50 + random() * 100;
		}
		f = f - 1;
	}

	sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.think = BecomeExplosion;
	self.nextthink = time + 0.2;
//	BecomeExplosion ();
};

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

void() vom_die =
{
// check for explosion (hey it's tarbabys big brother)
	if (self.health < -60)
	{
		vom_dieb1();
		return; 
	}
// regular death
	if (random() < 0.13)
	{
		makevectors(self.v_angle);
		spawn_tarbaby(self.origin + (v_forward * 44));
		newmis.velocity_z = 50 + random() * 100;
	}

	sound (self, CHAN_VOICE, "vomitus/die.wav", 1, ATTN_NORM);
	vom_die1 ();

};


//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_attacka1 =[	$attack1,	vom_attacka2 ] {ai_face(); sound (self, CHAN_VOICE, "vomitus/attack1.wav", 1, ATTN_NORM);};
void()	vom_attacka2 =[	$attack2,	vom_attacka3 ] {ai_face();};
void()	vom_attacka3 =[	$attack3,	vom_attacka4 ] {ai_face();};
void()	vom_attacka4 =[	$attack4,	vom_attacka5 ] {ai_face();};
void()	vom_attacka5 =[	$attack5,	vom_attacka6 ] {ai_face();};
void()	vom_attacka6 =[	$attack6,	vom_attacka7 ] {ai_face();};
void()	vom_attacka7 =[	$attack7,	vom_attacka8 ] {vom_shot(-2);};
void()	vom_attacka8 =[	$attack8,	vom_attacka9 ] {vom_shot(-1);};
void()	vom_attacka9 =[	$attack9,	vom_attacka10 ] {vom_shot(0);};
void()	vom_attacka10 =[	$attack10,	vom_attacka11 ] {vom_shot(1);};
void()	vom_attacka11 =[	$attack11,	vom_attacka12 ] {vom_shot(2);};
void()	vom_attacka12 =[	$attack12,	vom_attacka13 ] {ai_face();};//{vom_shot(3);};
void()	vom_attacka13 =[	$attack13,	vom_run1    ] {ai_face();};
*/

framer($attack1, $attack13, vom_attacka1, vom_run1, 0.1,

	frame_arb($attack1,sound (self, CHAN_VOICE, "vomitus/attack1.wav", 1, ATTN_NORM));
	ai_rep($attack7, vom_shot, -2, -1, 0, 1, 2, -6, -6, -6);
	ai_face();
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_attacke1 =[	$attack1,	vom_attacke2 ] {ai_face(); sound (self, CHAN_VOICE, "vomitus/attack2.wav", 1, ATTN_NORM);};
void()	vom_attacke2 =[	$attack2,	vom_attacke3 ] {ai_face();};
void()	vom_attacke3 =[	$attack3,	vom_attacke4 ] {ai_face();};
void()	vom_attacke4 =[	$attack4,	vom_attacke5 ] {ai_face();};
void()	vom_attacke5 =[	$attack5,	vom_attacke6 ] {ai_face();};
void()	vom_attacke6 =[	$attack6,	vom_attacke7 ] {ai_face();}; //{vom_shot3(-1);};
void()	vom_attacke7 =[	$attack7,	vom_attacke8 ] {vom_shot(-2);};
void()	vom_attacke8 =[	$attack8,	vom_attacke9 ] {ai_face();};//{vom_shot(0);};
void()	vom_attacke9 =[	$attack9,	vom_attacke10 ] {vom_shot(0);};
void()	vom_attacke10 =[	$attack10,	vom_attacke11 ] {ai_face();}; //{vom_shot(0);};
void()	vom_attacke11 =[	$attack11,	vom_attacke12 ] {vom_shot(2);};
void()	vom_attacke12 =[	$attack12,	vom_attacke13 ] {vom_shot3(-1);};
void()	vom_attacke13 =[	$attack13,	vom_run1     ] {ai_face();};
*/

framer($attack1, $attack13, vom_attacke1, vom_run1, 0.1,

	frame_arb($attack1,sound (self, CHAN_VOICE, "vomitus/attack2.wav", 1, ATTN_NORM));
	ai_rep($attack7, vom_shot, -2, -6, 0, -6, 2, -6, -6, -6);
	frame_arb($attack12,vom_shot3(-1));
	ai_face();
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_attackb1 =[	$attack1,	vom_attackb2 ] {ai_face(); sound (self, CHAN_VOICE, "vomitus/attack2.wav", 1, ATTN_NORM);};
void()	vom_attackb2 =[	$attack2,	vom_attackb3 ] {ai_face();};
void()	vom_attackb3 =[	$attack3,	vom_attackb4 ] {ai_face();};
void()	vom_attackb4 =[	$attack4,	vom_attackb5 ] {ai_face();};
void()	vom_attackb5 =[	$attack5,	vom_attackb6 ] {ai_face();};
void()	vom_attackb6 =[	$attack6,	vom_attackb7 ] {if (random() < 0.12) vom_shot(-3);};
void()	vom_attackb7 =[	$attack7,	vom_attackb8 ] {if (random() < 0.06) vom_shot(-2);};
void()	vom_attackb8 =[	$attack8,	vom_attackb9 ] {if (random() < 0.1) vom_shot(-1);};
void()	vom_attackb9 =[	$attack9,	vom_attackb10 ] {vom_shot2(0);};
void()	vom_attackb10 =[	$attack10,	vom_attackb11 ] {if (random() < 0.08) vom_shot(1);};
void()	vom_attackb11 =[	$attack11,	vom_attackb12 ] {if (random() < 0.2) vom_shot(2);};
void()	vom_attackb12 =[	$attack12,	vom_attackb13 ] {if (random() < 0.1) vom_shot(3);};
void()	vom_attackb13 =[	$attack13,	vom_run1     ] {ai_face();};
*/

framer($attack1, $attack13, vom_attackb1, vom_run1, 0.1,

	frame_arb($attack1,sound (self, CHAN_VOICE, "vomitus/attack2.wav", 1, ATTN_NORM));
	frame_arb($attack6,if (random() < 0.12) vom_shot(-3));
	frame_arb($attack7,if (random() < 0.06) vom_shot(-2));
	frame_arb($attack8,if (random() < 0.1) vom_shot(-1));
	frame_arb($attack9,vom_shot2(0));
	frame_arb($attack10,if (random() < 0.08) vom_shot(1));
	frame_arb($attack11,if (random() < 0.2) vom_shot(2));
	frame_arb($attack12,if (random() < 0.1) vom_shot(3));
	ai_face();
);

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
/*
void()	vom_attackc1 =[	$attack1,	vom_attackc2 ] {ai_face(); sound (self, CHAN_VOICE, "vomitus/attack1.wav", 1, ATTN_NORM);};
void()	vom_attackc2 =[	$attack2,	vom_attackc3 ] {ai_face();};
void()	vom_attackc3 =[	$attack3,	vom_attackc4 ] {ai_face();};
void()	vom_attackc4 =[	$attack4,	vom_attackc5 ] {ai_face();};
void()	vom_attackc5 =[	$attack5,	vom_attackc6 ] {ai_face();};
void()	vom_attackc6 =[	$attack6,	vom_attackc7 ] {if (random() < 0.08) vom_shot(-3); newmis.classname = "vomisss"; };
void()	vom_attackc7 =[	$attack7,	vom_attackc8 ] {ai_face();}; //{vom_shot(-2);};
void()	vom_attackc8 =[	$attack8,	vom_attackc9 ] {vom_shot(-1);};
void()	vom_attackc9 =[	$attack9,	vom_attackc10 ] {if (random() < 0.1) vom_shot(0); newmis.classname = "vomisss"; };
void()	vom_attackc10 =[	$attack10,	vom_attackc11 ] {ai_face();}; //{vom_shot(1);};
void()	vom_attackc11 =[	$attack11,	vom_attackc12 ] {vom_shot(2);};
void()      vom_attackc12 =[  $attack12,  vom_attackc13 ] {if (random() < 0.06) vom_shot(3); newmis.classname = "vomisss"; };
void()	vom_attackc13 =[	$attack13,	vom_run1     ] {ai_face();};
*/

framer($attack1, $attack13, vom_attackc1, vom_run1, 0.1,

	frame_arb($attack1,sound (self, CHAN_VOICE, "vomitus/attack1.wav", 1, ATTN_NORM));
	frame_arb($attack6,if (random() < 0.08) {vom_shot(-3); newmis.classname = "vomisss")};
	frame_arb($attack8,vom_shot(-1));
	frame_arb($attack9,if (random() < 0.1) {vom_shot(0); newmis.classname = "vomisss")};
	frame_arb($attack11,vom_shot(2));
	frame_arb($attack12,if (random() < 0.06) {vom_shot(3); newmis.classname = "vomisss")};
	ai_face();
);
//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
// 2 attacks, not used
/*
void()	vom_attackd1 =[	$attack1,	vom_attackd2 ] {ai_face(); sound (self, CHAN_VOICE, "vomitus/attack1.wav", 1, ATTN_NORM);};
void()	vom_attackd2 =[	$attack2,	vom_attackd3 ] {ai_face();};
void()	vom_attackd3 =[	$attack3,	vom_attackd4 ] {ai_face();};
void()	vom_attackd4 =[	$attack4,	vom_attackd5 ] {ai_face();};
void()	vom_attackd5 =[	$attack5,	vom_attackd6 ] {ai_face();};
void()	vom_attackd6 =[	$attack6,	vom_attackd7 ] {vom_shot(-3);};
void()	vom_attackd7 =[	$attack7,	vom_attackd8 ] {vom_shot2(-2);};
void()	vom_attackd8 =[	$attack8,	vom_attackd9 ] {vom_shot3(-1);};
void()	vom_attackd9 =[	$attack9,	vom_attackd10 ] {vom_shot3(0);};
void()	vom_attackd10 =[	$attack10,	vom_attackd11 ] {vom_shot3(1);};
void()	vom_attackd11 =[	$attack11,	vom_attackd12 ] {vom_shot2(2);};
void()	vom_attackd12 =[	$attack12,	vom_attackd13 ] {vom_shot(3);};
void()	vom_attackd13 =[	$attack13,	vom_run1     ] {ai_face();};

//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

void()	vom_attackf1 =[	$attack1,	vom_attackf2 ] {ai_face(); sound (self, CHAN_VOICE, "vomitus/attack2.wav", 1, ATTN_NORM);};
void()	vom_attackf2 =[	$attack2,	vom_attackf3 ] {ai_face();};
void()	vom_attackf3 =[	$attack3,	vom_attackf4 ] {ai_face();};
void()	vom_attackf4 =[	$attack4,	vom_attackf5 ] {ai_face();};
void()	vom_attackf5 =[	$attack5,	vom_attackf6 ] {ai_face();};
void()	vom_attackf6 =[	$attack6,	vom_attackf7 ] {vom_shot2(-3);};
void()	vom_attackf7 =[	$attack7,	vom_attackf8 ] {vom_shot2(-1);};
void()	vom_attackf8 =[	$attack8,	vom_attackf9 ] {vom_shot(0);};
void()	vom_attackf9 =[	$attack9,	vom_attackf10 ] {vom_shot(0);};
void()	vom_attackf10 =[	$attack10,	vom_attackf11 ] {vom_shot(0);};
void()	vom_attackf11 =[	$attack11,	vom_attackf12 ] {vom_shot2(1);};
void()	vom_attackf12 =[	$attack12,	vom_attackf13 ] {vom_shot2(3);};
void()	vom_attackf13 =[	$attack13,	vom_run1     ] {ai_face();};
*/
//¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤


void() vom_attack =
{
  
   local float r;
  
   r = random (); 

	if (random() < 0.16)
	if (self.attack_finished > time + 1.2)
	{
      vom_attackc1(); // long attack time - chance of rnd spikes
		self.attack_finished = 1.2;
	}

   if (time < self.attack_finished) return;

	self.attack_finished = 1.2 + random();
   
   if (r < 0.62)
     {
      vom_attacka1(); // shot 5 normal
     }
   else if (r < 0.7) 
     {
      vom_attacke1(); // 3 spikes, 1 tarbaby
		self.attack_finished = 3 + random();
     }
   else if (r < 0.9) 
     { 
      vom_attackb1(); // exploder, random spikes
		self.attack_finished = 1.4 + random();
     }
   else 
     {
      vom_attackc1(); // 2 + rand super spikes
		self.attack_finished = 0.8 + random();
     } 
};


// note: need close range attack

void() vom_melee =
{
	if (time < self.attack_finished)
	return;	

	if (random() > 0.6)
		vom_attackc1(); // chance of rnd spikes
};



void() vom_idle_sound =
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "vomitus/idle1.wav", 1, ATTN_NORM);
};

void(entity attacker, float damage)	vom_pain =
{	
  local float r;

	if (self.pain_finished > time)
		return;

	r = random ();

//pain c
	if (r < 0.2)
	{
		self.noise2 = "vomitus/painc.wav";
		self.call__ = vom_painc1;

/*
		sound (self, CHAN_VOICE, "vomitus/painc.wav", 1, ATTN_NORM);

		if (time - self.pain_finished < 5)
		if ((random() * 30) > damage)
			return;		// didn't flinch

		vom_painc1 ();
*/
	}

//pain b
	else if (r < 0.4)
	{
		self.noise2 = "vomitus/painb.wav";
		self.call__ = vom_painb1;

/*
		sound (self, CHAN_VOICE, "vomitus/painb.wav", 1, ATTN_NORM);

		if (time - self.pain_finished > 5)
		{	// allways go into pain frame if it has been a while
				vom_painb1 ();
			self.pain_finished = time + 1;
			return;
		}
		
		if ((random()*30 > damage) )
			return;		// didn't flinch

		vom_painb1 ();
*/
	}

//pain a
	else

	{
		self.noise2 = "vomitus/paina.wav";
		self.call__ = vom_paina1;
/*
		sound (self, CHAN_VOICE, "vomitus/paina.wav", 1, ATTN_NORM);

		if (time - self.pain_finished > 5)
		{	// allways go into pain frame if it has been a while
				vom_paina1 ();
			self.pain_finished = time + 1;
			return;
		}
		
		if ((random()*30 > damage) )
			return;		// didn't flinch

		vom_paina1 ();
*/
	}

	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);

	if (time - self.pain_finished < 5)
	if ((random() * 30) > damage)
		return;		// didn't flinch

	self.call__();

	self.pain_finished = time + 1;

};

//float	vom_type;

/*QUAKED monster_vomit (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_vomit =
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
	
	if (!M_MONSTER & CB_M_VOMIT)
	if (deathmatch)
	{
		if (R_MONSTER)
			remove(self);
		return;
	}	
*/

	precache_model ("progs/vomitus.mdl");
	precache_model ("progs/vomis.mdl");
	precache_model ("progs/h_hellkn.mdl");

	
	precache_sound ("vomitus/attack1.wav");
	precache_sound ("vomitus/attack2.wav");
	precache_sound ("vomitus/die.wav");
	precache_sound ("vomitus/paina.wav");
	precache_sound ("vomitus/painb.wav");
	precache_sound ("vomitus/painc.wav");
	precache_sound ("hknight/sight1.wav");
	precache_sound ("hknight/hit.wav");
	precache_sound ("vomitus/idle1.wav");
//tarbaby stuff
	precache_model ("progs/tarbaby.mdl");

	precache_sound ("blob/death1.wav");
	precache_sound ("blob/hit1.wav");
	precache_sound ("blob/land1.wav");
	precache_sound ("blob/sight1.wav");
//}

/*
// Cataboligne - 11.14.12 - fast / slow code
	if (self.speed <= 0) self.speed = MON_NORM;
	self.lip = 1; // local speed divisor
// map specced
	if (self.netname == CFAST) self.speed = MON_FAST;
	else if (self.netname == CSLOW) self.speed = MON_SLOW;
*/

	self.netname = "Vomitus";

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/vomitus.mdl");

	setsize (self, '-24 -24 -24', '24 24 24');

	self.skin = rint(random() * 1.4);
	if (random() < 0.6) self.skin = 3; // original skin 1

	self.health = 250;

	self.th_stand = vom_stand1;
	self.th_walk = vom_walk1;
	self.th_run = vom_run1;
	self.th_melee = vom_melee;
	self.th_missile = vom_attack;
	self.th_pain = vom_pain;
	self.th_die = vom_die;
	
	walkmonster_start;
};
