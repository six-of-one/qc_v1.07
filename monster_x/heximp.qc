/* ::-::
 *
 * Cataboligne
 *
 * file: heximp.qc
 *
 * date: 11/29/12 - inserted
 *
 * qc - hexen 2 imp monster for quake
 *
 * original by: Claus Kruuskopf AKA WiCKeD
 *
 */

// let compile process know - since this is an #include in this code set

#messagecompiling heximp.qc 

// include in random extra monsters

#undef INCL_HEXIMP
#define INCL_HEXIMP		64

 
 /*
==============================================================================

Hexen 2 IMP

==============================================================================
*/
$cd wicked/models/imp
$origin 0 0 0
$base base		
$skin flesh stone

$frame death1 death2 death3 death4 death5 death6 death7 
$frame death8 death9 death10 death11 death12 death13 death14 

$frame heximpfir1 heximpfir2 heximpfir3 heximpfir4 heximpfir5 
$frame heximpfir6 heximpfir7 heximpfir8 heximpfir9 heximpfir10 
$frame heximpfir11 heximpfir12 heximpfir13 heximpfir14 heximpfir15 
$frame heximpfir16 heximpfir17 heximpfir18 heximpfir19 heximpfir20 heximpfir21

$frame heximpfly1 heximpfly2 heximpfly3 heximpfly4 heximpfly5 
$frame heximpfly6 heximpfly7 heximpfly8 heximpfly9 heximpfly10 
$frame heximpfly11 heximpfly12 heximpfly13 heximpfly14 heximpfly15 
$frame heximpfly16 heximpfly17 heximpfly18 heximpfly19 heximpfly20

$frame heximpup1 heximpup2 heximpup3 heximpup4 heximpup5 heximpup6 
$frame heximpup7 heximpup8 heximpup9 heximpup10 heximpup11 heximpup12 
$frame heximpup13 heximpup14 heximpup15 heximpup16 heximpup17 heximpup18
$frame heximpup19 heximpup20 heximpup21 heximpup22 heximpup23

$frame heximpwat1 heximpwat2 heximpwat3 heximpwat4 heximpwat5 heximpwat6 
$frame heximpwat7 heximpwat8 heximpwat9 heximpwat10 heximpwat11 heximpwat12 
$frame heximpwat13 heximpwat14 heximpwat15 heximpwat16 heximpwat17 heximpwat18
$frame heximpwat19 heximpwat20 heximpwat21 heximpwat22 heximpwat23 heximpwat24

#define SPAWN_STONE		1
#define SPAWN_SITTING	2
#define SPAWN_AMBUSH	3

/*
void() heximp_sit1 = [	$heximpwat1, heximp_sit1 ]
{
	if ((self.duration < $heximpwat1) || (self.duration > $heximpwat23))
	{
		self.duration = $heximpwat1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	if (self.frame == $heximpwat1)
	if (random() < 0.5) sound (self, CHAN_VOICE, "heximp/up.wav", 1, ATTN_IDLE);

	ai_stand();
};

void() heximp_sit2 =[	$heximpwat2, heximp_sit3 ] {ai_stand();};
void() heximp_sit3 =[	$heximpwat3, heximp_sit4 ] {ai_stand();};
void() heximp_sit4 =[	$heximpwat4, heximp_sit5 ] {ai_stand();};
void() heximp_sit5 =[	$heximpwat5, heximp_sit6 ] {ai_stand();};
void() heximp_sit6 =[	$heximpwat6, heximp_sit7 ] {ai_stand();};
void() heximp_sit7 =[	$heximpwat7, heximp_sit8 ] {ai_stand();};
void() heximp_sit8 =[	$heximpwat8, heximp_sit9 ] {ai_stand();};
void() heximp_sit9 =[	$heximpwat9, heximp_sit10 ] {ai_stand();};
void() heximp_sit10 =[	$heximpwat10, heximp_sit11 ] {ai_stand();};
void() heximp_sit11 =[	$heximpwat11, heximp_sit12 ] {ai_stand();};
void() heximp_sit12 =[	$heximpwat12, heximp_sit13 ] {ai_stand();};
void() heximp_sit13 =[	$heximpwat13, heximp_sit14 ] {ai_stand();};
void() heximp_sit14 =[	$heximpwat14, heximp_sit15 ] {ai_stand();};
void() heximp_sit15 =[	$heximpwat15, heximp_sit16 ] {ai_stand();};
void() heximp_sit16 =[	$heximpwat16, heximp_sit17 ] {ai_stand();};
void() heximp_sit17 =[	$heximpwat17, heximp_sit18 ] {ai_stand();};
void() heximp_sit18 =[	$heximpwat18, heximp_sit19 ] {ai_stand();};
void() heximp_sit19 =[	$heximpwat19, heximp_sit20 ] {ai_stand();};
void() heximp_sit20 =[	$heximpwat20, heximp_sit21 ] {ai_stand();};
void() heximp_sit21 =[	$heximpwat21, heximp_sit22 ] {ai_stand();};
void() heximp_sit22 =[	$heximpwat22, heximp_sit23 ] {ai_stand();};
void() heximp_sit23 =[	$heximpwat23, heximp_sit24 ] {ai_stand();};
void() heximp_sit24 =[	$heximpwat24, heximp_sit1 ] {ai_stand();};
*/

framerloop($heximpwat1, $heximpwat24, heximp_sit1, 0.1,

	frame_arb($heximpwat1,if (random() < 0.5) sound (self, CHAN_VOICE, "heximp/up.wav", 1, ATTN_IDLE));
	ai_stand();
);

/*
void() heximp_stand1 = [	$heximpfly1, heximp_stand1 ]
{
	if ((self.duration < $heximpfly1) || (self.duration > $heximpfly19))
	{
		self.duration = $heximpfly1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	ai_stand();
};


void() heximp_stand1 =[	$heximpfly1, heximp_stand2 ] {ai_stand();};
void() heximp_stand2 =[	$heximpfly2, heximp_stand3 ] {ai_stand();};
void() heximp_stand3 =[	$heximpfly3, heximp_stand4 ] {ai_stand();};
void() heximp_stand4 =[	$heximpfly4, heximp_stand5 ] {ai_stand();};
void() heximp_stand5 =[	$heximpfly5, heximp_stand6 ] {ai_stand();};
void() heximp_stand6 =[	$heximpfly6, heximp_stand7 ] {ai_stand();};
void() heximp_stand7 =[	$heximpfly7, heximp_stand8 ] {ai_stand();};
void() heximp_stand8 =[	$heximpfly8, heximp_stand9 ] {ai_stand();};
void() heximp_stand9 =[	$heximpfly9, heximp_stand10 ] {ai_stand();};
void() heximp_stand10 =[	$heximpfly10, heximp_stand11 ] {ai_stand();};
void() heximp_stand11 =[	$heximpfly11, heximp_stand12 ] {ai_stand();};
void() heximp_stand12 =[	$heximpfly12, heximp_stand13 ] {ai_stand();};
void() heximp_stand13 =[	$heximpfly13, heximp_stand14 ] {ai_stand();};
void() heximp_stand14 =[	$heximpfly14, heximp_stand15 ] {ai_stand();};
void() heximp_stand15 =[	$heximpfly15, heximp_stand16 ] {ai_stand();};
void() heximp_stand16 =[	$heximpfly16, heximp_stand17 ] {ai_stand();};
void() heximp_stand17 =[	$heximpfly17, heximp_stand18 ] {ai_stand();};
void() heximp_stand18 =[	$heximpfly18, heximp_stand19 ] {ai_stand();};
void() heximp_stand19 =[	$heximpfly19, heximp_stand20 ] {ai_stand();};
void() heximp_stand20 =[	$heximpfly20, heximp_stand1 ] {ai_stand();};
*/

framerloop($heximpfly1, $heximpfly20, heximp_stand1, 0.1,ai_stand());

/*
void() heximp_hover1 =[	$heximpfly1, heximp_hover1 ]
{
	if ((self.duration < $heximpfly1) || (self.duration > $heximpfly19))
	{
		self.duration = $heximpfly1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	ai_walk(14);
};

void() heximp_hover1 =[	$heximpfly1, heximp_hover2 ] {ai_walk(14);};
void() heximp_hover2 =[	$heximpfly2, heximp_hover3 ] {ai_walk(14);};
void() heximp_hover3 =[	$heximpfly3, heximp_hover4 ] {ai_walk(14);};
void() heximp_hover4 =[	$heximpfly4, heximp_hover5 ] {ai_walk(14);};
void() heximp_hover5 =[	$heximpfly5, heximp_hover6 ] {ai_walk(14);};
void() heximp_hover6 =[	$heximpfly6, heximp_hover7 ] {ai_walk(14);};
void() heximp_hover7 =[	$heximpfly7, heximp_hover8 ] {ai_walk(14);};
void() heximp_hover8 =[	$heximpfly8, heximp_hover9 ] {ai_walk(14);};
void() heximp_hover9 =[	$heximpfly9, heximp_hover10 ] {ai_walk(14);};
void() heximp_hover10 =[	$heximpfly10, heximp_hover11 ] {ai_walk(14);};
void() heximp_hover11 =[	$heximpfly11, heximp_hover12 ] {ai_walk(14);};
void() heximp_hover12 =[	$heximpfly12, heximp_hover13 ] {ai_walk(14);};
void() heximp_hover13 =[	$heximpfly13, heximp_hover14 ] {ai_walk(14);};
void() heximp_hover14 =[	$heximpfly14, heximp_hover15 ] {ai_walk(14);};
void() heximp_hover15 =[	$heximpfly15, heximp_hover16 ] {ai_walk(14);};
void() heximp_hover16 =[	$heximpfly16, heximp_hover17 ] {ai_walk(14);};
void() heximp_hover17 =[	$heximpfly17, heximp_hover18 ] {ai_walk(14);};
void() heximp_hover18 =[	$heximpfly18, heximp_hover19 ] {ai_walk(14);};
void() heximp_hover19 =[	$heximpfly19, heximp_hover20 ] {ai_walk(14);};
void() heximp_hover20 =[	$heximpfly20, heximp_hover1 ] {ai_walk(14);};
*/

framerloop($heximpfly1, $heximpfly20, heximp_hover1, 0.1,ai_walk(14));

/*
void() heximp_fly1 =[	$heximpfly1, heximp_fly1 ]
{
	if ((self.duration < $heximpfly1) || (self.duration > $heximpfly19))
	{
		self.duration = $heximpfly1;
	}
	else self.duration = self.duration + 1;

	self.frame = self.duration;

	ai_run(24);
};


void() heximp_fly1 =[	$heximpfly1, heximp_fly2 ] {ai_run(24);};
void() heximp_fly2 =[	$heximpfly2, heximp_fly3 ] {ai_run(24);};
void() heximp_fly3 =[	$heximpfly3, heximp_fly4 ] {ai_run(24);};
void() heximp_fly4 =[	$heximpfly4, heximp_fly5 ] {ai_run(24);};
void() heximp_fly5 =[	$heximpfly5, heximp_fly6 ] {ai_run(24);};
void() heximp_fly6 =[	$heximpfly6, heximp_fly7 ] {ai_run(24);};
void() heximp_fly7 =[	$heximpfly7, heximp_fly8 ] {ai_run(24);};
void() heximp_fly8 =[	$heximpfly8, heximp_fly9 ] {ai_run(24);};
void() heximp_fly9 =[	$heximpfly9, heximp_fly10 ] {ai_run(24);};
void() heximp_fly10 =[	$heximpfly10, heximp_fly11 ] {ai_run(24);};
void() heximp_fly11 =[	$heximpfly11, heximp_fly12 ] {ai_run(24);};
void() heximp_fly12 =[	$heximpfly12, heximp_fly13 ] {ai_run(24);};
void() heximp_fly13 =[	$heximpfly13, heximp_fly14 ] {ai_run(24);};
void() heximp_fly14 =[	$heximpfly14, heximp_fly15 ] {ai_run(24);};
void() heximp_fly15 =[	$heximpfly15, heximp_fly16 ] {ai_run(24);};
void() heximp_fly16 =[	$heximpfly16, heximp_fly17 ] {ai_run(24);};
void() heximp_fly17 =[	$heximpfly17, heximp_fly18 ] {ai_run(24);};
void() heximp_fly18 =[	$heximpfly18, heximp_fly19 ] {ai_run(24);};
void() heximp_fly19 =[	$heximpfly19, heximp_fly20 ] {ai_run(24);};
void() heximp_fly20 =[	$heximpfly20, heximp_fly1 ] {ai_run(24);};
*/

framerloop($heximpfly1, $heximpfly20, heximp_fly1, 0.1,ai_run(24));

/*
===============
Imp Attack Code
===============
*/

void() ImpClaw =
{
	if (!self.enemy) return;
	if (!CanDamage (self.enemy, self)) return;

	ai_charge(10);

	self.v__ = self.enemy.origin - self.origin;

	if (vlen(self.v__) > 64) return;

	self.dmg = (random() + random() + random()) * 4;
	T_Damage (self.enemy, self, self, self.dmg);
};

/*
void() heximp_ball14;

void() heximp_hit1 =[	$heximpfir1, heximp_hitball2 ] {ai_charge(1);self.a__ = 1;};
void() heximp_hitball2 =[	$heximpfir2, heximp_hitball3 ] {ai_charge(1);};
void() heximp_hitball3 =[	$heximpfir3, heximp_hitball4 ] {ai_charge(2);};
void() heximp_hitball4 =[	$heximpfir4, heximp_hitball5 ] {ai_charge(2);};
void() heximp_hitball5 =[	$heximpfir5, heximp_hitball6 ] {ai_charge(3);};
void() heximp_hitball6 =[	$heximpfir6, heximp_hitball7 ] {ai_charge(3);};
void() heximp_hitball7 =[	$heximpfir7, heximp_hitball8 ] {ai_charge(4);};
void() heximp_hitball8 =[	$heximpfir8, heximp_hitball9 ] {ai_charge(4);};
void() heximp_hitball9 =[	$heximpfir9, heximp_hitball10 ] {ai_charge(5);};
void() heximp_hitball10 =[	$heximpfir10, heximp_hitball11 ] {ai_charge(5);};
void() heximp_hitball11 =[	$heximpfir11, heximp_hitball12 ] {ai_charge(6);};
void() heximp_hitball12 =[	$heximpfir12, heximp_hitball13 ] {ai_charge(6);};
void() heximp_hitball13 =[	$heximpfir13, heximp_hit14 ]
{
	ai_charge(7);
	if (self.a__ == 2) self.think = heximp_ball14;	
};

void() heximp_hit14 =[	$heximpfir14, heximp_hit15 ] {ai_charge(7);};
void() heximp_hit15 =[	$heximpfir15, heximp_hit16 ]
{
sound(self, CHAN_VOICE, "heximp/fist.wav", 1, ATTN_NORM);
ImpClaw();
};
void() heximp_hit16 =[	$heximpfir16, heximp_hit17 ] {ImpClaw();};
void() heximp_hit17 =[	$heximpfir17, heximp_hit18 ] {ImpClaw();};
void() heximp_hit18 =[	$heximpfir18, heximp_hit19 ] {ImpClaw();};
void() heximp_hit19 =[	$heximpfir19, heximp_hit20 ] {ImpClaw();};
void() heximp_hit20 =[	$heximpfir20, heximp_hit21 ] {ai_charge(-1);};
void() heximp_hit21 =[	$heximpfir21, heximp_fly1 ] {ai_charge(-4);};
*/

framer($heximpfir1, $heximpfir21, heximp_hit1, heximp_fly1, 0.1,

	frame_arb($heximpfir15,sound(self, CHAN_VOICE, "heximp/fist.wav", 1, ATTN_NORM));

	ai_rep($heximpfir1, ai_charge, 1, 1, 2, 2, 3, 3, 4, 4);
	ai_rep($heximpfir9, ai_charge, 5, 5, 6, 6, 7, 7, -6, -6);
	frame_arb($heximpfir20,ai_charge(-1));
	frame_arb($heximpfir21,ai_charge(-4));
	framerange_arb($heximpfir15, $heximpfir19, ImpClaw());
);

void() ImpBallExplode =
{
	T_RadiusDamage (self, self.owner, 20, world);
//	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	BecomeExplosion(self);
};

/*
================
ImpThrowBall
================
*/


void() ImpThrowBall =
{
//	local	entity missile;

	self.effects = self.effects | EF_MUZZLEFLASH;

//	missile = spawn ();
//	missile.owner = self;
//	missile.movetype = MOVETYPE_FLY;
//	missile.solid = SOLID_BBOX;

	// set missile speed	

	makevectors (self.angles);

//	self.v__ = normalize(self.enemy.origin - self.origin);

	launch_spike (self.origin, normalize(self.enemy.origin - self.origin));

	newmis.velocity = v_up * 32 + newmis.velocity * 600;

//	missile.angles = vectoangles(missile.velocity);

	newmis.touch = ImpBallExplode;

	// set missile duration
//	missile.nextthink = time + 5.0;
//	missile.think = SUB_Remove;

	setmodel (newmis, "progs/heximp_ball.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
//	setorigin (missile, self.origin);
};

/*
void() heximp_ball1 =[	$heximpfir1, heximp_hitball2 ] {ai_charge(1);self.a__ = 2;};

multiplex with *_hitball2 above

void() heximp_ball2 =[	$heximpfir2, heximp_ball3 ] {ai_charge(1);};
void() heximp_ball3 =[	$heximpfir3, heximp_ball4 ] {ai_charge(2);};
void() heximp_ball4 =[	$heximpfir4, heximp_ball5 ] {ai_charge(2);};
void() heximp_ball5 =[	$heximpfir5, heximp_ball6 ] {ai_charge(3);};
void() heximp_ball6 =[	$heximpfir6, heximp_ball7 ] {ai_charge(3);};
void() heximp_ball7 =[	$heximpfir7, heximp_ball8 ] {ai_charge(4);};
void() heximp_ball8 =[	$heximpfir8, heximp_ball9 ] {ai_charge(4);};
void() heximp_ball9 =[	$heximpfir9, heximp_ball10 ] {ai_charge(5);};
void() heximp_ball10 =[	$heximpfir10, heximp_ball11 ] {ai_charge(5);};
void() heximp_ball11 =[	$heximpfir11, heximp_ball12 ] {ai_charge(6);};
void() heximp_ball12 =[	$heximpfir12, heximp_ball13 ] {ai_charge(6);};
void() heximp_ball13 =[	$heximpfir13, heximp_ball14 ] {ai_charge(7);};

void() heximp_ball14 =[	$heximpfir14, heximp_ball15 ] {ai_charge(4);};
void() heximp_ball15 =[	$heximpfir15, heximp_ball16 ]
{
	sound (self, CHAN_VOICE, "heximp/fist.wav", 1, ATTN_NORM);
	ImpThrowBall();
};
void() heximp_ball16 =[	$heximpfir16, heximp_ball17 ] {ai_charge(-2);};
void() heximp_ball17 =[	$heximpfir17, heximp_ball18 ] {ai_charge(-2);};
void() heximp_ball18 =[	$heximpfir18, heximp_ball19 ] {ai_charge(-4);};
void() heximp_ball19 =[	$heximpfir19, heximp_ball20 ] {ai_charge(-4);};
void() heximp_ball20 =[	$heximpfir20, heximp_ball21 ] {ai_charge(-8);};
void() heximp_ball21 =[	$heximpfir21, heximp_fly1 ] {ai_charge(-16);};
*/

framer($heximpfir1, $heximpfir21, heximp_ball1, heximp_fly1, 0.1,

	frame_arb($heximpfir15,

		sound(self, CHAN_VOICE, "heximp/fist.wav", 1, ATTN_NORM);
		ImpThrowBall();
	);

	ai_rep($heximpfir1, ai_charge, 1, 1, 2, 2, 3, 3, 4, 4);
	ai_rep($heximpfir9, ai_charge, 5, 5, 6, 6, 7, 4, -6, -2);
	ai_rep($heximpfir17, ai_charge, -2, -4, -4, -8, -16, -6, -6, -6);
);


/*
void() heximp_death1 =[	$death1, heximp_death2 ]
{
	self.velocity_x = -200 + 400*random();
	self.velocity_y = -200 + 400*random();
	self.velocity_z = 100 + 100*random();
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	sound (self, CHAN_VOICE, "heximp/death.wav", 1, ATTN_NORM);
};
void() heximp_death2 =[	$death2, heximp_death3 ] {};
void() heximp_death3 =[	$death3, heximp_death4 ] {};
void() heximp_death4 =[	$death4, heximp_death5 ] {};
void() heximp_death5 =[	$death5, heximp_death6 ] {};
void() heximp_death6 =[	$death6, heximp_death7 ] {};
void() heximp_death7 =[	$death7, heximp_death8 ] {};
void() heximp_death8 =[	$death8, heximp_death9 ] {};
void() heximp_death9 =[	$death9, heximp_death10 ] {};
void() heximp_death10 =[	$death10, heximp_death11 ] {};
void() heximp_death11 =[	$death11, heximp_death12 ] {};
void() heximp_death12 =[	$death12, heximp_death13 ] {self.solid = SOLID_NOT;};
void() heximp_death13 =[	$death13, heximp_death14 ] {};
void() heximp_death14 =[	$death14, heximp_death14 ] {};
*/

framer($death1, $death14, heximp_death1, SUB_Null, 0.1,

	frame_arb($death12,self.solid = SOLID_NOT);
);

// trim ?

void() heximp_death =
{
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		ThrowGib ("progs/h_heximp.mdl", self.health);
//		remove (self); // this would remove the head
		return;
	}

	self.velocity_x = -200 + 400*random();
	self.velocity_y = -200 + 400*random();
	self.velocity_z = 100 + 100*random();
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	sound (self, CHAN_VOICE, "heximp/death.wav", 1, ATTN_NORM);

	heximp_death1();
};

void() heximp_pain =
{
	sound (self, CHAN_VOICE, "heximp/pain.wav", 1, ATTN_NORM);
	ai_pain(6);
};

/*
void() heximp_up1 = [	$heximpup1, heximp_up2 ] {sound (self, CHAN_VOICE, "heximp/up.wav", 1, ATTN_IDLE);};

void() heximp_up2 = [	$heximpup2, heximp_up2 ]
{
	if ((self.duration < $heximpup2) || (self.duration > $heximpup23))
	{
		self.duration = $heximpup2;
	}
	else self.duration = self.duration + 1;

	if (self.duration > $heximpup23)
	{
		self.duration = $heximpup1;
		heximp_fly1();
	}
	else
	self.frame = self.duration;
};
/*
void() heximp_up2 =[	$heximpup2, heximp_up3 ] {};
void() heximp_up3 =[	$heximpup3, heximp_up4 ] {};
void() heximp_up4 =[	$heximpup4, heximp_up5 ] {};
void() heximp_up5 =[	$heximpup5, heximp_up6 ] {};
void() heximp_up6 =[	$heximpup6, heximp_up7 ] {};
void() heximp_up7 =[	$heximpup7, heximp_up8 ] {};
void() heximp_up8 =[	$heximpup8, heximp_up9 ] {};
void() heximp_up9 =[	$heximpup9, heximp_up10 ] {};
void() heximp_up10 =[	$heximpup10, heximp_up11 ] {};
void() heximp_up11 =[	$heximpup11, heximp_up12 ] {};
void() heximp_up12 =[	$heximpup12, heximp_up13 ] {};
void() heximp_up13 =[	$heximpup13, heximp_up14 ] {};
void() heximp_up14 =[	$heximpup14, heximp_up15 ] {};
void() heximp_up15 =[	$heximpup15, heximp_up16 ] {};
void() heximp_up16 =[	$heximpup16, heximp_up17 ] {};
void() heximp_up17 =[	$heximpup17, heximp_up18 ] {};
void() heximp_up18 =[	$heximpup18, heximp_up19 ] {};
void() heximp_up19 =[	$heximpup19, heximp_up20 ] {};
void() heximp_up20 =[	$heximpup20, heximp_up21 ] {};
void() heximp_up21 =[	$heximpup21, heximp_up22 ] {};
void() heximp_up22 =[	$heximpup22, heximp_up23 ] {};
void() heximp_up23 =[	$heximpup23, heximp_fly1 ] {};
*/

framer($heximpup1, $heximpup23, heximp_up1, heximp_fly1, 0.1,

	frame_arb($heximpup1,sound(self, CHAN_VOICE, "heximp/up.wav", 1, ATTN_IDLE));

);

void() heximp_wake =
{
	self.th_stand = heximp_stand1;
	self.th_walk = heximp_hover1;
	self.th_run = heximp_fly1;
	self.th_die = heximp_death;
	self.th_pain = heximp_pain;
	self.th_melee = heximp_hit1;
	self.th_missile = heximp_ball1;

	if (self.spawnflags & SPAWN_STONE)
	{
		self.takedamage = DAMAGE_AIM;
		self.use = SUB_Null;
		self.skin = 0;
	
		heximp_up1 ();
	}
};

void() heximp_stone =
{
	self.takedamage = DAMAGE_NO;
	self.use = heximp_wake;
	self.think = heximp_stone;
	self.nextthink = time + 0.1;
};

/*QUAKED monster_heximp (1 0 0) (-16 -16 2) (16 16 32) Ambush Statue Sitting

a Hexen 2 imp approximation

*/

void() monster_heximp =
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
	if (! dm_over)			// __monster_heximp_button0		"1"
//	if (!M_MONSTER_II & CB_M_HEXIMP)
	if (deathmatch)
	{
		remove(self);
		return;
	}	

 precache_model ("progs/heximp.mdl");
 precache_model ("progs/h_heximp.mdl");
 precache_model ("progs/heximp_ball.mdl");

 precache_sound ("heximp/death.wav");
 precache_sound ("heximp/fist.wav");
 precache_sound ("weapons/r_exp3.wav");
 precache_sound ("heximp/pain.wav");
 precache_sound ("heximp/up.wav");
//}
/*
// Cataboligne - 11.14.12 - fast / slow code
	if (self.speed <= 0) self.speed = MON_NORM;
	self.lip = 1; // local speed divisor
// map specced
	if (self.netname == CFAST) self.speed = MON_FAST;
	else if (self.netname == CSLOW) self.speed = MON_SLOW;
*/

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

 setmodel (self, "progs/heximp.mdl");

 setsize ( self, '-16 -16 0', '16 16 32');
 self.health = 60;

	if (self.spawnflags & SPAWN_STONE) // Stone Imp
	{
		if (!self.frame /* == 0 */) self.frame = $heximpup1;
		self.skin = 1;

		if (!self.targetname)
		{
#ifndef nodprint
			dprint ("statue not targeted\n");
			dprint (self.classname);
			dprint (" at ");
			dprint (vtos(self.origin));
			dprint ("\n");
#endifdef
			return;
		}

		self.use = heximp_wake;
		self.th_stand = heximp_stone;
		self.th_walk = heximp_stone;
		self.th_run = heximp_stone;

		droptofloor(); // Put's the statue to floor		 
	}
	else //if (self.spawnflags & SPAWN_SITTING)
	{
		heximp_wake();
/*
		self.th_stand = heximp_sit1;
		self.th_walk = heximp_hover1;
		self.th_run = heximp_fly1;
		self.th_die = heximp_death;
		self.th_pain = heximp_pain;
		self.th_melee = heximp_hit1;
		self.th_missile = heximp_ball1;
*/
		if (self.spawnflags & SPAWN_SITTING)
		{
			self.th_stand = heximp_sit1;
			droptofloor(); // Drops the sitting imp to the floor 
		}
/*
	}
	else
	{
		self.th_stand = heximp_stand1;
		self.th_walk = heximp_hover1;
		self.th_run = heximp_fly1;
		self.th_die = heximp_death;
		self.th_pain = heximp_pain;
		self.th_melee = heximp_hit1;
		self.th_missile = heximp_ball1;
*/
	}
	flymonster_start;
};
