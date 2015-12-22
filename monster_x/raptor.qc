/*
==============================================================================

RAPTOR
  qc by gopal nener
  gopal@networx.net.au

==============================================================================
*/

// let compile process know - since this is an #include in this code set

#messagecompiling raptor.qc 

// include in random extra monsters

#undef INCL_RAPTOR
#define INCL_RAPTOR		8


void(entity attacker, float damage)     raptor1_pain;
void(entity attacker, float damage)     raptor1_stumble;
void() raptor_die;
void() raptor_limp;
void(float side, float damg)        raptor_Melee;

$scale  0.8
$origin 0 100 24
$base base
$skin base


$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10
$frame death11 death12 death13

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12 leap13

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

$frame limp1 limp2 limp3 limp4 limp5 limp6 limp7 limp8 limp9 limp10
$frame limp11 limp12

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8 deathb9 deathb10
$frame deathb11 deathb12 deathb13 deathb14

$frame attackb1 attackb2 attackb3 attackb4 attackb5 attackb6 attackb7 attackb8
$frame attackb9 attackb10 attackb11 attackb12 attackb13 attackb14 attackb15
//============================================================================


/*

deprecated - see *_die code

void(string gibname, float dm) ThrowNewHead =
{
	local entity newhead;
	newhead = spawn();
	setmodel (newhead, gibname);
	newhead.frame = 0;
	newhead.nextthink = -1;
	newhead.movetype = MOVETYPE_BOUNCE;
	newhead.takedamage = DAMAGE_NO;
	newhead.solid = SOLID_NOT;
	newhead.view_ofs = '0 0 8';
	setsize (newhead, '-16 -16 0', '16 16 56');
	newhead.velocity = VelocityForDamage (dm);
	newhead.origin_z = newhead.origin_z - 24;
	newhead.flags = newhead.flags - (newhead.flags & FL_ONGROUND);
	newhead.avelocity = crandom() * '0 600 0';
};

*/

void(float r) raptor_sound =
{
	self.th_pain = raptor1_pain;
	self.th_die = raptor_die;
	self.rnd_ = rint(random() * r);
	if (!self.impulse) // == 0)
	{
		if (self.rnd_ == 1)
		{
			sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
			self.impulse = 1;
		}
		if (r != 15)
		{
			if (self.rnd_ == 2) sound(self, CHAN_VOICE, "mon_II/raptor/ridle2.wav", 1, ATTN_IDLE);
			if (self.rnd_ == 3) sound(self, CHAN_VOICE, "mon_II/raptor/ridle3.wav", 1, ATTN_IDLE);
			if (self.rnd_ == 4) sound(self, CHAN_VOICE, "mon_II/raptor/ridle4.wav", 1, ATTN_IDLE);
		}
	}
	if ((self.impulse == 1) && (self.rnd_ < 5))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 2;
	}
	if ((self.impulse == 2) && (self.rnd_ < 2))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 0;
	}
};

/*
void()  raptor1_stand1   =[      $stand1,        raptor1_stand2   ]
{
//	local float rsnd;
/ *
	self.th_pain = raptor1_pain;
	self.th_die = raptor_die;
	self.rnd_ = rint(random() * 10);
	if (self.impulse == 0)
	{
		if (self.rnd_ == 1)
		{
			sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
			self.impulse = 1;
		}
		if (self.rnd_ == 2) sound(self, CHAN_VOICE, "mon_II/raptor/ridle2.wav", 1, ATTN_IDLE);
		if (self.rnd_ == 3) sound(self, CHAN_VOICE, "mon_II/raptor/ridle3.wav", 1, ATTN_IDLE);
		if (self.rnd_ == 4) sound(self, CHAN_VOICE, "mon_II/raptor/ridle4.wav", 1, ATTN_IDLE);
	}
	if ((self.impulse == 1) && (self.rnd_ < 5))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 2;
	}
	if ((self.impulse == 2) && (self.rnd_ < 2))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 0;
	}
* /
	raptor_sound(10);
	ai_stand();
};


void()  raptor1_stand2   =[      $stand2,        raptor1_stand2   ]
{
	if ((self.duration < $stand2) || (self.duration > $stand15))
	{
		self.duration = $stand2;
	}
	else self.duration = self.duration + 1;

	if (self.duration > $stand15)
	{
		self.duration = $stand1;
		raptor1_stand1();
	}
	else
	{
		self.frame = self.duration;
		ai_stand();
	}
};


void()  raptor1_stand2   =[      $stand2,        raptor1_stand3   ] {ai_stand();};
void()  raptor1_stand3   =[      $stand3,        raptor1_stand4   ] {ai_stand();};
void()  raptor1_stand4   =[      $stand4,        raptor1_stand5   ] {ai_stand();};
void()  raptor1_stand5   =[      $stand5,        raptor1_stand6   ] {ai_stand();};
void()  raptor1_stand6   =[      $stand6,        raptor1_stand7   ] {ai_stand();};
void()  raptor1_stand7   =[      $stand7,        raptor1_stand8   ] {ai_stand();};
void()  raptor1_stand8   =[      $stand8,        raptor1_stand9   ] {ai_stand();};
void()  raptor1_stand9   =[      $stand9,        raptor1_stand10  ] {ai_stand();};
void()  raptor1_stand10  =[      $stand10,       raptor1_stand11  ] {ai_stand();};
void()  raptor1_stand11  =[      $stand11,       raptor1_stand12  ] {ai_stand();};
void()  raptor1_stand12  =[      $stand12,       raptor1_stand13  ] {ai_stand();};
void()  raptor1_stand13  =[      $stand13,       raptor1_stand14  ] {ai_stand();};
void()  raptor1_stand14  =[      $stand14,       raptor1_stand15  ] {ai_stand();};
void()  raptor1_stand15  =[      $stand15,       raptor1_stand1   ] {ai_stand();};
*/

framerloop($stand1, $stand15, raptor1_stand1, 0.1,

	frame_arb($stand1, raptor_sound(10));
	ai_stand()

);

/*
void()  raptor1_walk1    =[      $walk1,         raptor1_walk2    ]
{
    local float rsnd;
    self.th_pain = raptor1_pain;
    self.th_die = raptor_die;
    rsnd = rint(random() * 15);
    if (self.impulse == 0)
    {
	if (rsnd > 10)
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 1;
	}
      //  if (rsnd == 2)
      //          sound(self, CHAN_VOICE, "ridle2.wav", 1, ATTN_IDLE);
      //  if (rsnd == 3)
      //          sound(self, CHAN_VOICE, "ridle3.wav", 1, ATTN_IDLE);
      //  if (rsnd == 4)
      //          sound(self, CHAN_VOICE, "ridle4.wav", 1, ATTN_IDLE);
    }
    if ((self.impulse == 1) && (rsnd < 5))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle2.wav", 1, ATTN_IDLE);
		self.impulse = 2;
	}
    if ((self.impulse == 2) && (rsnd < 2))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 0;
	}        
    ai_walk(2);
};

void()  raptor1_walk2    =[      $walk2,         raptor1_walk3    ] {ai_walk(2);};
void()  raptor1_walk3    =[      $walk3,         raptor1_walk4    ] {ai_walk(2);};
void()  raptor1_walk4    =[      $walk4,         raptor1_walk5    ] {ai_walk(2);};
void()  raptor1_walk5    =[      $walk5,         raptor1_walk6    ] {ai_walk(2);};
void()  raptor1_walk6    =[      $walk6,         raptor1_walk7    ] {ai_walk(2);};
void()  raptor1_walk7    =[      $walk7,         raptor1_walk8    ] {ai_walk(1);};
void()  raptor1_walk8    =[      $walk8,         raptor1_walk9    ] {ai_walk(2);};
void()  raptor1_walk9    =[      $walk9,         raptor1_walk10   ] {ai_walk(3);};
void()  raptor1_walk10   =[      $walk10,        raptor1_walk11   ] {ai_walk(3);};
void()  raptor1_walk11   =[      $walk11,        raptor1_walk12   ] {ai_walk(2.5);};
void()  raptor1_walk12   =[      $walk12,        raptor1_walk13   ] {ai_walk(2);};
void()  raptor1_walk13   =[      $walk13,        raptor1_walk14   ] {ai_walk(2);};
void()  raptor1_walk14   =[      $walk14,        raptor1_walk15   ] {ai_walk(2);};
void()  raptor1_walk15   =[      $walk15,        raptor1_walk16   ] {ai_walk(1);};
void()  raptor1_walk16   =[      $walk16,        raptor1_walk1    ] {ai_walk(2);};
*/

framerloop($walk1, $walk16, raptor1_walk1, 0.1,

	frame_arb($walk1, raptor_sound(15));
	ai_rep($walk1, ai_walk, 2, 2, 2, 2, 2, 2, 1, 2);
	ai_rep($walk1, ai_walk, 3, 3, 2.5, 2, 2, 2, 1, -1);
);

/*
void()  raptor1_run1     =[      $run1,          raptor1_run2     ] {
    local float rsnd;
    self.th_pain = raptor1_stumble;
    self.th_die = raptor_die;
    rsnd = rint(random() * 20);
    if (self.impulse == 0)
    {
	if (rsnd == 1)
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 1;
	}
	if (rsnd == 2)
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle2.wav", 1, ATTN_IDLE);
	if (rsnd == 3)
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle3.wav", 1, ATTN_IDLE);
	if (rsnd == 4)
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle4.wav", 1, ATTN_IDLE);
    }
    if ((self.impulse == 1) && (rsnd < 5))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 2;
	}
    if ((self.impulse == 2) && (rsnd < 2))
	{
		sound(self, CHAN_VOICE, "mon_II/raptor/ridle1.wav", 1, ATTN_IDLE);
		self.impulse = 0;
	}        
ai_run(20);
};

/*
void()  raptor1_run2     =[      $run2,          raptor1_run3     ] {ai_run(35);};
void()  raptor1_run3     =[      $run3,          raptor1_run4     ] {ai_run(35);};
void()  raptor1_run4     =[      $run4,          raptor1_run5     ]
{
	local float wh_att;
	wh_att = random() * 9;
	if (wh_att > 6)
		self.th_melee = raptor_MeleeAttackb;
	else
		self.th_melee = raptor_MeleeAttack;
	ai_run(35);
};
void()  raptor1_run5     =[      $run5,          raptor1_run6     ] {ai_run(35);};
void()  raptor1_run6     =[      $run6,          raptor1_run7     ] {ai_run(35);};
void()  raptor1_run7     =[      $run7,          raptor1_run8     ] {ai_run(35);};
void()  raptor1_run8     =[      $run8,          raptor1_run1     ] {ai_run(35);};
*/

// change this frame_arb

framerloop($run1, $run8, raptor1_run1, 0.1,

	frame_arb($stand1,
	
		raptor_sound(20);
		self.th_pain = raptor1_stumble;
		ai_run(20);
	);
	frame_arb($run4,

		self.rnd_ = random() * 9;
		if (self.rnd_ > 6)
		{
			self.a__ = 12;
			self.lefty = 0;
			self.walkframe = $attacka1;
		}
		else
		{
			self.a__ = 7;
			self.lefty = 1;
			self.walkframe = $attackb1;
		}

	);
	if (self.frame > $run1) ai_run(35);

);

/*
void()  raptor1_stumble1     =[      $painb1,          raptor1_stumble2     ] {ai_run(35);};
void()  raptor1_stumble2     =[      $painb2,          raptor1_stumble3     ] {ai_run(35);};
void()  raptor1_stumble3     =[      $painb3,          raptor1_stumble4     ] {ai_run(30);};
void()  raptor1_stumble4     =[      $painb4,          raptor1_stumble5     ] {ai_run(25);};
void()  raptor1_stumble5     =[      $painb5,          raptor1_stumble6     ] {ai_run(30);};
void()  raptor1_stumble6     =[      $painb6,          raptor1_stumble7     ] {ai_run(35);};
void()  raptor1_stumble7     =[      $painb7,          raptor1_stumble8     ] {ai_run(35);};
void()  raptor1_stumble8     =[      $painb8,          raptor1_run1     ] {ai_run(35);};
*/

framer($painb1, $painb8, raptor1_stumble1, raptor1_run1, 0.1,

	ai_rep($painb1, ai_run, 35, 35, 30, 25, 30, 35, 35, 35);
);

/*
void()  raptor1_jump1    =[      $leap1,         raptor1_jump2    ] {ai_face();};
void()  raptor1_jump2    =[      $leap2,         raptor1_jump3    ] {ai_face();};
void()  raptor1_jump3    =[      $leap3,         raptor1_jump4    ] {ai_face();};
void()  raptor1_jump4    =[      $leap4,         raptor1_jump5    ] 
{
	sound(self, CHAN_VOICE, "mon_II/raptor/rjump.wav", 1, ATTN_NORM);
	ai_face();
	self.th_die = raptor_die;
	self.touch = Monster_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 300';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()  raptor1_jump5    =[      $leap5,         raptor1_jump6    ] {};
void()  raptor1_jump6    =[      $leap6,         raptor1_jump7    ] {};
void()  raptor1_jump7    =[      $leap7,         raptor1_jump8    ] {};
void()  raptor1_jump8    =[      $leap8,         raptor1_jump9    ] {};
void()  raptor1_jump9    =[      $leap9,         raptor1_jump10   ] {};
void()  raptor1_jump10   =[      $leap10,        raptor1_jump11   ] {
self.nextthink = time + 3;
// if three rels pass, assume raptor is stuck and jump again
};

void()  raptor1_jump11   =[      $leap11,        raptor1_jump12   ] {};
void()  raptor1_jump12   =[      $leap12,        raptor1_jump13   ] {};
void()  raptor1_jump13   =[      $leap13,        raptor1_run1     ] {};
*/

// trim jump stuff

framer($leap1, $leap13, raptor1_jump1, raptor1_run1, 0.1,

	framerange_arb($leap1,$leap3,ai_face());

	frame_arb($leap4,

		ai_face();
		sound(self, CHAN_VOICE, "mon_II/raptor/rjump.wav", 1, ATTN_NORM);
		self.th_die = raptor_die;
		self.touch = Monster_JumpTouch;
		makevectors (self.angles);
		self.origin_z = self.origin_z + 1;
		self.velocity = v_forward * 600 + '0 0 300';
		if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	);
	frame_arb($leap10,self.nextthink = time + 3);
);
	
/*
void()  raptor1_atta1    =[      $attacka1,              raptor1_atta3    ]
{
	self.th_pain = raptor1_pain;
	self.th_die = raptor_limp;
	ai_charge(2.5);
};

void()  raptor1_atta2    =[      $attacka2,              raptor1_atta3    ] {ai_charge(3);};
void()  raptor1_atta3    =[      $attacka3,              raptor1_atta4    ] {ai_charge(3.5);};
void()  raptor1_atta4    =[      $attacka4,              raptor1_atta5    ] {ai_charge(5);};
void()  raptor1_atta5    =[      $attacka5,              raptor1_atta6    ] {ai_charge(2.5); raptor_Melee(200, 12);};
void()  raptor1_atta6    =[      $attacka6,              raptor1_atta7    ] {ai_charge(2);};
void()  raptor1_atta7    =[      $attacka7,              raptor1_atta8    ] {ai_charge(2);};
void()  raptor1_atta8    =[      $attacka8,              raptor1_atta9    ] {ai_charge(2);};
void()  raptor1_atta9    =[      $attacka9,              raptor1_atta10   ] {ai_charge(3);};
void()  raptor1_atta10   =[      $attacka10,             raptor1_atta11   ] {ai_charge(4);};
void()  raptor1_atta11   =[      $attacka11,             raptor1_atta12   ] {ai_charge(5); raptor_Melee(-200, 12);};
void()  raptor1_atta12   =[      $attacka12,             raptor1_atta13   ] {ai_charge(2);};
void()  raptor1_atta13   =[      $attacka13,             raptor1_atta14   ] {ai_charge(3.5);};
void()  raptor1_atta14   =[      $attacka14,             raptor1_atta15   ] {ai_charge(3.5);};
void()  raptor1_atta15   =[      $attacka15,             raptor1_run1     ] {ai_charge(2.5);};


void()  raptor1_attb1    =[      $attackb1,              raptor1_atta3    ]
{
	self.th_pain = raptor1_pain;
	self.th_die = raptor_limp;
	ai_charge(2.5);
};

void()  raptor1_attb2    =[      $attackb2,              raptor1_attb3    ] {ai_charge(3);};
void()  raptor1_attb3    =[      $attackb3,              raptor1_attb4    ] {ai_charge(3.5);};
void()  raptor1_attb4    =[      $attackb4,              raptor1_attb5    ] {ai_charge(5);};
void()  raptor1_attb5    =[      $attackb5,              raptor1_attb6    ] {ai_charge(2.5);};
void()  raptor1_attb6    =[      $attackb6,              raptor1_attb7    ] {ai_charge(2); raptor_Melee(200, 7);};
void()  raptor1_attb7    =[      $attackb7,              raptor1_attb8    ] {ai_charge(2);};
void()  raptor1_attb8    =[      $attackb8,              raptor1_attb9    ] {ai_charge(2);};
void()  raptor1_attb9    =[      $attackb9,              raptor1_attb10   ] {ai_charge(3);};
void()  raptor1_attb10   =[      $attackb10,             raptor1_attb11   ] {ai_charge(4);};
void()  raptor1_attb11   =[      $attackb11,             raptor1_attb12   ] {ai_charge(5);};
void()  raptor1_attb12   =[      $attackb12,             raptor1_attb13   ] {ai_charge(2);};
void()  raptor1_attb13   =[      $attackb13,             raptor1_attb14   ] {ai_charge(3.5);};
void()  raptor1_attb14   =[      $attackb14,             raptor1_attb15   ] {ai_charge(3.5); raptor_Melee(-200,7);};
void()  raptor1_attb15   =[      $attackb15,             raptor1_run1     ] {ai_charge(2.5);};
*/

// note: true spread of frame tests here
//				melee fn is called on diff frames than original code

framer($attacka1, $attackb15, raptor1_atta1, raptor1_run1, 0.1,

	if (self.frame == $attacka1)
	{
		self.frame = self.walkframe;
		self.th_pain = raptor1_pain;
		self.th_die = raptor_limp;
	}

	ai_rep(self.walkframe, ai_charge, 2.5, 3, 3.5, 5, 2.5, 2, 2, 2);
	ai_rep(self.walkframe + 8, ai_charge, 3, 4, 5, 2, 3.5, 3.5, 2.5, -6);

	frame_arb(self.walkframe + 4 + self.lefty, raptor_Melee(200, self.a__));
	frame_arb(self.walkframe + 10 + self.lefty * 3, raptor_Melee(-200, self.a__));

	if (self.frame == $attacka15) self.think = raptor1_run1;
);

/*
void()  raptor1_pain1    =[      $pain1,         raptor1_pain2    ] {};
void()  raptor1_pain2    =[      $pain2,         raptor1_pain3    ] {};
void()  raptor1_pain3    =[      $pain3,         raptor1_pain4    ] {};
void()  raptor1_pain4    =[      $pain4,         raptor1_pain5    ] {};
void()  raptor1_pain5    =[      $pain5,         raptor1_pain6    ] {};
void()  raptor1_pain6    =[      $pain6,         raptor1_run1     ] {};
*/

framer($pain1, $pain6, raptor1_pain1, raptor1_run1, 0.1,SUB_Null());

/*
void()  raptor1_die1             =[      $death1,                raptor1_die2     ] {
sound(self, CHAN_VOICE, "mon_II/raptor/rdeath1.wav", 1, ATTN_NORM);};


void()  raptor1_die2             =[      $death2,                raptor1_die2     ]
{
	if ((self.duration < $death2) || (self.duration > $death12))
	{
		self.duration = $death2;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $death6) self.solid = SOLID_NOT;

	if (self.frame == $death13) self.think = SUB_Null;
};

/*

deprecated for loop code

void()  raptor1_die3             =[      $death3,                raptor1_die4     ] {};
void()  raptor1_die4             =[      $death4,                raptor1_die5     ] {};
void()  raptor1_die5             =[      $death5,                raptor1_die6     ] {};
void()  raptor1_die6             =[      $death6,                raptor1_die7     ] {
self.solid = SOLID_NOT;};
void()  raptor1_die7             =[      $death7,                raptor1_die8     ] {};
void()  raptor1_die8             =[      $death8,                raptor1_die9     ] {};
void()  raptor1_die9             =[      $death9,                raptor1_die10    ] {};
void()  raptor1_die10            =[      $death10,               raptor1_die11    ] {};
void()  raptor1_die11            =[      $death11,               raptor1_die12    ] {};
void()  raptor1_die12            =[      $death12,               raptor1_die13    ] {};
void()  raptor1_die13            =[      $death13,               raptor1_die13    ] {};
*/

framer($death1, $death13, raptor1_die1, SUB_Null, 0.1,

	frame_arb($death1,sound(self, CHAN_VOICE, "mon_II/raptor/rdeath1.wav", 1, ATTN_NORM));
	frame_arb($death6,self.solid = SOLID_NOT);
);

/*
void()  raptor1_keel1             =[      $deathb1,                raptor1_keel1     ]
{
	if ((self.duration < $deathb1) || (self.duration > $deathb13))
	{
		self.duration = $deathb1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $deathb6) self.solid = SOLID_NOT;

	if (self.frame == $deathb7)
	{
		self.cnt = random() * 9;
		if (self.cnt > 4)
			sound(self, CHAN_VOICE, "mon_II/raptor/rdeath2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "mon_II/raptor/rdeath1.wav", 1, ATTN_NORM);
	}

	if (self.frame == $deathb14) self.think = SUB_Null;
};

/*

deprecated for loop code

void()  raptor1_keel2             =[      $deathb2,                raptor1_keel3     ] {};
void()  raptor1_keel3             =[      $deathb3,                raptor1_keel4     ] {};
void()  raptor1_keel4             =[      $deathb4,                raptor1_keel5     ] {};
void()  raptor1_keel5             =[      $deathb5,                raptor1_keel6     ] {};
void()  raptor1_keel6             =[      $deathb6,                raptor1_keel7     ]
{self.solid = SOLID_NOT;};
void()  raptor1_keel7             =[      $deathb7,                raptor1_keel8     ]
{
	local float rsnd;
	rsnd = random() * 9;
	if (rsnd > 4)
		sound(self, CHAN_VOICE, "mon_II/raptor/rdeath2.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "mon_II/raptor/rdeath1.wav", 1, ATTN_NORM);
};
void()  raptor1_keel8             =[      $deathb8,                raptor1_keel9     ] {};
void()  raptor1_keel9             =[      $deathb9,                raptor1_keel10    ] {};
void()  raptor1_keel10            =[      $deathb10,               raptor1_keel11    ] {};
void()  raptor1_keel11            =[      $deathb11,               raptor1_keel12    ] {};
void()  raptor1_keel12            =[      $deathb12,               raptor1_keel13    ] {};
void()  raptor1_keel13            =[      $deathb13,               raptor1_keel14    ] {};
void()  raptor1_keel14            =[      $deathb14,               raptor1_keel14    ] {};
*/


framer($deathb1, $deathb14, raptor1_keel1, SUB_Null, 0.1,

	frame_arb($deathb6,

		self.solid = SOLID_NOT;
		self.rnd_ = random() * 9;
		if (self.rnd_ > 4)
			sound(self, CHAN_VOICE, "mon_II/raptor/rdeath2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "mon_II/raptor/rdeath1.wav", 1, ATTN_NORM);

	);
//	frame_arb($deathb6,self.solid = SOLID_NOT);
);

// so we can use ai_rep for the frame calls of walkmove
void(float f) wmiy =
{
	walkmove (self.ideal_yaw, f);
};

/*
void()  raptor1_limp1             =[      $limp1,                raptor1_limp2     ] {
//	local float diroff;
	self.f__ = (random() * 90) - 45;
	self.ideal_yaw = self.ideal_yaw + self.f__;
	ChangeYaw();};
void()  raptor1_limp2             =[      $limp2,                raptor1_limp3     ] {};
void()  raptor1_limp3             =[      $limp3,                raptor1_limp4     ] {};
void()  raptor1_limp4             =[      $limp4,                raptor1_limp5     ] {walkmove (self.ideal_yaw, 1);};
void()  raptor1_limp5             =[      $limp5,                raptor1_limp6     ] {walkmove (self.ideal_yaw, 2);};
void()  raptor1_limp6             =[      $limp6,                raptor1_limp7     ] {walkmove (self.ideal_yaw, 4.5);};
void()  raptor1_limp7             =[      $limp7,                raptor1_limp8     ] {walkmove (self.ideal_yaw, 4);};
void()  raptor1_limp8             =[      $limp8,                raptor1_limp9     ] {walkmove (self.ideal_yaw, 2.5);};
void()  raptor1_limp9             =[      $limp9,                raptor1_limp10     ] {walkmove (self.ideal_yaw, 0.5);};
void()  raptor1_limp10             =[      $limp10,                raptor1_limp11     ] {walkmove (self.ideal_yaw, 3);};
void()  raptor1_limp11             =[      $limp11,                raptor1_limp12     ] {walkmove (self.ideal_yaw, 3);};
void()  raptor1_limp12             =[      $limp12,                raptor1_keel1     ]
{
	self.impulse = self.impulse - 1;
	if (self.impulse > 0)
		raptor1_limp1();
	else
		raptor1_keel1();
};
*/

framer($limp1, $limp12, raptor1_limp1, SUB_Null, 0.1,

	frame_arb($limp1,

		self.f__ = (random() * 90) - 45;
		self.ideal_yaw = self.ideal_yaw + self.f__;
		ChangeYaw();
	);
	frame_arb($limp12,

		self.impulse = self.impulse - 1;
		if (self.impulse > 0) raptor1_limp1();
		else raptor1_keel1();
	);
	ai_rep($limp4, wmiy, 1, 2, 4.5, 4, 2.5, 0.5, 3, 3);
);


void(entity attacker, float damage)     raptor1_pain =
{
//	local float rsnd;

	if (self.touch == Monster_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
	self.rnd_ = random() * 10;
	if (self.rnd_ < 7)
		sound(self, CHAN_VOICE, "mon_II/raptor/rpain1.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "mon_II/raptor/rpain2.wav", 1, ATTN_NORM);

	if (random()*170 > damage)
		return;         // didn't flinch
		
	raptor1_pain1();
};

void(entity attacker, float damage)     raptor1_stumble =
{
//	local float rsnd;
	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
	self.rnd_ = random() * 10;
	if (self.rnd_ < 7)
		sound(self, CHAN_VOICE, "mon_II/raptor/rpain1.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "mon_II/raptor/rpain2.wav", 1, ATTN_NORM);
	if (random()*100 > damage)
		return;         // didn't flinch
		
	raptor1_stumble1();
};

void() raptor_die = 
{
// check for gib
	if (self.health < -80)
	{
/*
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_raptor.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);

// note: adds gib2.mdl to mix
*/
		gibbs("progs/h_raptor.mdl");
//		ThrowNewHead ("progs/bodygib.mdl", self.health);
// replaces ThrowNewHead -
		self.goalentity = spawn();
		self.goalentity.health = self.health;
		self = self.goalentity;
		ThrowHead ("progs/bodygib.mdl", self.health);
		return;
	}

// regular death
	raptor1_die1();
};

void() raptor_limp = 
{
// check for gib
	if (self.health < -80)
	{
/*
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_raptor.mdl", self.health);
//		ThrowNewHead ("progs/bodygib.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		self.goalentity = spawn();
		self.goalentity.health = self.health;
		self = self.goalentity;
		ThrowHead ("progs/bodygib.mdl", self.health);
*/
		raptor_die();
		return;
	}

// regular death
	self.impulse = (random() * 2) + 1;
	raptor1_limp1();
};

/*
	deprecated for being pointless

void() raptor_MeleeAttack =
{
	raptor1_atta1 ();
};

void() raptor_MeleeAttackb =
{
	raptor1_attb1 ();
};
*/

/*
//string(entity targ, entity attacker) raptor_killmsg =
string() raptor_killmsg =
{
#ifdef enhanced
//	if (random() < 0.5 || !ENHANCED)
	if (random() < 0.5)
		return " was slashed by a ";
	else if (random() < 0.9)
		return " tried to examine the claws of a ";
	else
	{
		return(" could not wait for modern times to be an archaeologist of a ");
	}
#else
	return " was slashed by a ";
#endifdef
};
*/

/*QUAKED monster_raptor (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_raptor =
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
	
	if (!M_MONSTER_II & CB_M_RAPTOR)
	if (deathmatch)
	{
		if (R_MONSTER)
			remove(self);
		return;
	}	
*/
	precache_model ("progs/raptor.mdl");
	precache_model ("progs/h_raptor.mdl");
	precache_model ("progs/bodygib.mdl");

	precache_sound("mon_II/raptor/rdeath1.wav");
	precache_sound("mon_II/raptor/rdeath2.wav");
	precache_sound("demon/dhit2.wav");
	precache_sound("mon_II/raptor/rjump.wav");
	precache_sound("mon_II/raptor/rpain1.wav");
	precache_sound("mon_II/raptor/rpain2.wav");
	precache_sound("mon_II/raptor/ridle1.wav");
	precache_sound("mon_II/raptor/ridle2.wav");
	precache_sound("mon_II/raptor/ridle3.wav");
	precache_sound("mon_II/raptor/ridle4.wav");
	precache_sound("mon_II/raptor/rsight.wav");
//}
/*
// Cataboligne - 11.14.12 - fast / slow code
	if (self.speed <= 0) self.speed = MON_NORM;
	self.lip = 1; // local speed divisor
// map specced
	if (self.netname == CFAST) self.speed = MON_FAST;
	else if (self.netname == CSLOW) self.speed = MON_SLOW;
*/

	self.netname = "Velociraptor";

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/raptor.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 400;

	self.th_stand = raptor1_stand1;
	self.th_walk = raptor1_walk1;
	self.th_run = raptor1_run1;
	self.th_die = raptor_die;
	self.th_melee = raptor1_atta1;              // one of two attacks
	self.th_missile = raptor1_jump1;                 // jump attack
	self.th_pain = raptor1_pain;
//	self._killmsg = raptor_killmsg;

// FIX ***

// jumptouch multi
//	self._jump = raptor1_jump1;
//	self._jump2 = raptor1_jump11;

	self.jump_flag = 400;
//	self.dodmg = 40;

	walkmonster_start;
};


/*
==============================================================================

raptor

==============================================================================
*/

/*
==============
CheckraptorMelee

Returns TRUE if a melee attack would hit right now
==============
*
float() CheckraptorMelee =
{
	if (enemy_range == RANGE_MELEE)
	{       // FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};
*/

/*
==============
CheckraptorJump

==============
*/
float() CheckraptorJump =
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
	if ((d < 200) || (d > 240))
		return FALSE;
		
	if (random() < 0.7)
		return FALSE;
	else
		return TRUE;
};

float() raptorCheckAttack =
{
//	local   vector  vec;
/*	
// if close enough for slashing, go for it
	if (CheckraptorMelee ())
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

	if (CheckraptorJump ())
	{
		self.attack_state = AS_MISSILE;
		// sound(self, CHAN_VOICE, "rjump.wav", 1, ATTN_NORM);
		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================

void(float side, float damg)        raptor_Melee =
{	
	ai_face ();
	walkmove (self.ideal_yaw, 6);  // allow a little closing

	self.v__ = self.enemy.origin - self.origin;

	if (vlen(self.v__) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	sound(self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	self.dmg = damg + 5*random();
	T_Damage (self.enemy, self, self, self.dmg);        

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, ((side / damg * 6 ) * v_right) + (v_up * 2));
};



/*
deprecated to Monster_JumpTouch

void()  raptor_JumpTouch =
{
	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			self.dmg = 40 + 10*random();
			T_Damage (other, self, self, self.dmg);     
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{       // jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = raptor1_jump1;
	self.nextthink = time + 0.1;

//                      self.velocity_x = (random() - 0.5) * 600;
//                      self.velocity_y = (random() - 0.5) * 600;
//                      self.velocity_z = 200;
//                      self.flags = self.flags - FL_ONGROUND;
		}
		return; // not on ground yet
	}

	self.touch = SUB_Null;
	self.think = raptor1_jump11;
	self.nextthink = time + 0.1;
};

*/