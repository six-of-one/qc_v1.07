/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: pkbot.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */

// Cataboligne - 9.26.9 - visible weapons model (player has no gun!)

// running
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

// standing
$frame stand1 stand2 stand3 stand4 stand5

// pain
$frame pain1 pain2 pain3 pain4 pain5 pain6

//
// fire wep attacks
//
// light fire frames
$frame lightfatt1 lightfatt2 lightfatt3 lightfatt4

// *** duplicate of player.mdl frames above - not really necc... in fact dont use, some vw_ were not animated here
$frame dont_use1 dont_use2 dont_use3 dont_use4

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

// crouching & prone frames

$frame crouchdown1 crouchdown2 crouchdown3
$frame crouch1 crouch2 crouch3 crouch4 crouch5
$frame prone1 prone2 prone3 prone4 prone5 prone6 prone7

// weapon access

$frame dropull1 dropull2 dropull3 dropull4 dropull5 dropull6 dropull7

// axe animation

$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6
$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

// axe attacks

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6

//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

// viswep stuff - not found in player mdl - should not go past frame deathe9

$frame dthrow1 dthrow2 dthrow3 dthrow4 dthrow5
//$frame firerun1 firerun2 firerun3 firerun4 firerun5 firerun6 /



void () bot_start = [ $stand1, bot_walk ]
{
//	local string tmp;
	BotPostThink ();
	droptofloor(0, 0);
	self.nextthink = ((time + 0.2) + (0.2 * random ()));
	if (self.skil < 3)
	{
		self.nextthink = (self.nextthink + (0.1 * (3- self.skil)));
	}
};

void () bot_stand1 = [ $stand1, bot_walk ] 
{
 	ai_botstand ();
	BotPostThink ();
};

void () bot_walk = [ $rockrun1, bot_walk ]
{
 	self.weaponframe = 0;
	if (self.weapon == IT_AXE)
	{
		if (self.walkframe == 6)
		{
			self.walkframe = 0;
		}
		self.frame = ($axrun1 + self.walkframe);
	}
	else
	{
		if (self.walkframe == 6)
		{
			self.walkframe = 0;
		}
		self.frame = (self.frame + self.walkframe);
	}
	self.walkframe = (self.walkframe + 1);
	ai_botseek (BOTSPEED);
	BotPostThink ();
};

void () bot_run = [ $rockrun1, bot_run ]
{
 	self.weaponframe = 0;
	if (self.weapon == IT_AXE)
	{
		if (self.walkframe == 6)
		{
			self.walkframe = 0;
		}
		self.frame = ($axrun1 + self.walkframe);
	}
	else
	{
		if (self.walkframe == 6)
		{
			self.walkframe = 0;
		}
		self.frame = (self.frame + self.walkframe);
	}
	self.walkframe = (self.walkframe + 1);
	ai_botrun (BOTSPEED);
	BotPostThink ();
};

void () bot_chase = [ $rockrun1, bot_chase ]
{
 	self.weaponframe = 0;
	if (self.weapon == IT_AXE)
	{
		if (self.walkframe == 6)
		{
			self.walkframe = 0;
		}
		self.frame = ($axrun1 + self.walkframe);
	}
	else
	{
		if (self.walkframe == 6)
		{
			self.walkframe = 0;
		}
		self.frame = (self.frame + self.walkframe);
	}
	self.walkframe = (self.walkframe + 1);
	aibot_chase (BOTSPEED);
	BotPostThink ();
};

void () bot_shot1 = [ $shotatt1, bot_shot2 ]
{
 	self.weaponframe = 1;
	self.effects = (self.effects | EF_MUZZLEFLASH);
};

void () bot_shot2 = [ $shotatt2, bot_shot3 ]
{
 	self.weaponframe = 2;
	if (self.skil > 0.9)
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_shot3 = [ $shotatt3, bot_shot4 ]
{
 	self.weaponframe = 3;
	if (self.skil > 0)
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_shot4 = [ $shotatt4, bot_shot5 ]
{
 	self.weaponframe = 4;
	if (self.skil > 0)
	{
		ai_botcharge (BOTSPEED);
	}
	else
	{
		ai_botcharge (BOTSPEED * 0.5);
	}
	BotPostThink ();
};

void () bot_shot5 = [ $shotatt5, bot_shot6 ]
{
 	self.weaponframe = 5;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_shot6 = [ $shotatt6, bot_run ]
{
 	self.weaponframe = 6;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_trigger1 = [ $shotatt1, bot_trigger2 ]
{
 	self.weaponframe = 1;
	self.effects = (self.effects | EF_MUZZLEFLASH);
};

void () bot_trigger2 = [ $shotatt2, bot_trigger3 ]
{
 	self.weaponframe = 2;
	ai_botseek (BOTSPEED);
	BotPostThink ();
};

void () bot_trigger3 = [ $shotatt3, bot_trigger4 ]
{
 	self.weaponframe = 3;
	ai_botseek (BOTSPEED);
	BotPostThink ();
};

void () bot_trigger4 = [ $shotatt4, bot_trigger5 ]
{
 	self.weaponframe = 4;
	ai_botseek (BOTSPEED);
	BotPostThink ();
};

void () bot_trigger5 = [ $shotatt5, bot_trigger6 ]
{
 	self.weaponframe = 5;
	ai_botseek (BOTSPEED);
	BotPostThink ();
};

void () bot_trigger6 = [ $shotatt6, bot_walk ]
{
 	self.weaponframe = 6;
	ai_botseek (BOTSPEED);
	BotPostThink ();
};

void () bot_axe1 = [ $axatt1, bot_axe2 ]
{
 	self.weaponframe = 1;
};

void () bot_axe2 = [ $axatt2, bot_axe3 ]
{
 	self.weaponframe = 2;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axe3 = [ $axatt3, bot_axe4 ]
{
 	self.weaponframe = 3;
	W_FireAxe ();
	BotPostThink ();
};

void () bot_axe4 = [ $axatt4, bot_run ]
{
 	self.weaponframe = 4;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axeb1 = [ $axattb1, bot_axeb2 ]
{
 	self.weaponframe = 5;
};

void () bot_axeb2 = [ $axattb2, bot_axeb3 ]
{
 	self.weaponframe = 6;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axeb3 = [ $axattb3, bot_axeb4 ]
{
 	self.weaponframe = 7;
	W_FireAxe ();
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axeb4 = [ $axattb4, bot_run ]
{
 	self.weaponframe = 8;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axec1 = [ $axattc1, bot_axec2 ]
{
 	self.weaponframe = 1;
};

void () bot_axec2 = [ $axattc2, bot_axec3 ]
{
 	self.weaponframe = 2;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axec3 = [ $axattc3, bot_axec4 ]
{
 	self.weaponframe = 3;
	W_FireAxe ();
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axec4 = [ $axattc4, bot_run ]
{
 	self.weaponframe = 4;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axed1 = [ $axattd1, bot_axed2 ]
{
 	self.weaponframe = 5;
};

void () bot_axed2 = [ $axattd2, bot_axed3 ]
{
 	self.weaponframe = 6;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axed3 = [ $axattd3, bot_axed4 ]
{
 	self.weaponframe = 7;
	W_FireAxe ();
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axed4 = [ $axattd4, bot_run ]
{
 	self.weaponframe = 8;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () pkbot_melee =
{
	self.weapon = W_BestBotWeapon ();
	xw_parm(self); // Cataboligne - 9.2.11 - is needed ???
	W_BotAttack ();
};

// NOTE: hardcoded stuff like this means this bot CAN NOT use morphs - he will try to run these frames and fire weps - looks way weird

void () bot_nail1 = [ $lightfatt1, bot_nail2 ]
{
 	self.effects = (self.effects | EF_MUZZLEFLASH);
	self.weaponframe = (self.weaponframe + 1);
	if (self.weaponframe == 9)
	{
		self.weaponframe = 1;
	}
	SuperDamageSound ();
	W_FireSpikes (4);
	ai_botnailcharge (BOTSPEED);
//	self.attack_finished = (time + 0.2);
	BotPostThink ();
};

void () bot_nail2 = [ $lightfatt2, bot_nail1 ]
{
 	self.effects = (self.effects | EF_MUZZLEFLASH);
	self.weaponframe = (self.weaponframe + 1);
	if (self.weaponframe == 9)
	{
		self.weaponframe = 1;
	}
	SuperDamageSound ();
	W_FireSpikes (-4);
	ai_botnailcharge (BOTSPEED);
//	self.attack_finished = (time + 0.2);
	BotPostThink ();
};

void () bot_light1 = [ $lightfatt1, bot_light2 ]
{
 	self.effects = (self.effects | EF_MUZZLEFLASH);
	self.weaponframe = (self.weaponframe + 1);
	if (self.weaponframe == 5)
	{
		self.weaponframe = 1;
	}
	SuperDamageSound ();
	W_FireLightning ();
	ai_botnailcharge (BOTSPEED);
	self.attack_finished = (time + 0.2);
	BotPostThink ();
};

void () bot_light2 = [ $lightfatt2, bot_light1 ]
{
 	self.effects = (self.effects | EF_MUZZLEFLASH);
	self.weaponframe = (self.weaponframe + 1);
	if (self.weaponframe == 5)
	{
		self.weaponframe = 1;
	}
	SuperDamageSound ();
	W_FireLightning ();
	ai_botnailcharge (BOTSPEED);
	self.attack_finished = (time + 0.2);
	BotPostThink ();
};

void () bot_rocket1 = [ $rockatt1, bot_rocket2 ]
{
 	self.weaponframe = 1;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	BotPostThink ();
};

void () bot_rocket2 = [ $rockatt2, bot_rocket3 ]
{
 	self.weaponframe = 2;
	if (self.skil > 2)
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_rocket3 = [ $rockatt3, bot_rocket4 ]
{
 	self.weaponframe = 3;
	if (self.skil > 1)
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_rocket4 = [ $rockatt4, bot_rocket5 ]
{
 	self.weaponframe = 4;
	if (self.skil > 1)
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_rocket5 = [ $rockatt5, bot_rocket6 ]
{
 	self.weaponframe = 5;
	if (self.skil > 0)
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_rocket6 = [ $rockatt6, bot_run ]
{
 	self.weaponframe = 6;
	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_rebound1 = [ $rockatt1, bot_rebound2 ]
{
 	self.weaponframe = 1;
	self.effects = (self.effects | EF_MUZZLEFLASH);
	BotPostThink ();
};

void () bot_rebound2 = [ $rockatt2, bot_rebound3 ]
{
 	self.weaponframe = 2;
	BotPostThink ();
};

void () bot_rebound3 = [ $rockatt3, bot_rebound4 ]
{
 	self.weaponframe = 3;
	BotPostThink ();
};

void () bot_rebound4 = [ $rockatt4, bot_rebound5 ]
{
 	self.weaponframe = 4;
	aibot_chase (BOTSPEED);
	BotPostThink ();
};

void () bot_rebound5 = [ $rockatt5, bot_rebound6 ]
{
 	self.weaponframe = 5;
	aibot_chase (BOTSPEED);
	BotPostThink ();
};

void () bot_rebound6 = [ $rockatt6, bot_chase ]
{
 	self.weaponframe = 6;
	aibot_chase (BOTSPEED);
	BotPostThink ();
};

void () bot_pain1 = [ $pain1, bot_pain2 ]
{
 	PainSound ();
	self.weaponframe = 0;
};

void () bot_pain2 = [ $pain2, bot_pain3 ]
{
 	
	local float r;
	r = ((4* random ()) + self.skil);
	if (r > 2)
	{
		ai_botrun (BOTSPEED);
	}
	else
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_pain3 = [ $pain3, bot_pain4 ]
{
 	if (self.skil >= TRUE)
	{
		ai_botrun (BOTSPEED);
	}
	else
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_pain4 = [ $pain4, bot_pain5 ]
{
 	if (self.skil > 0)
	{
		ai_botrun (BOTSPEED);
	}
	else
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_pain5 = [ $pain5, bot_pain6 ]
{
 	if (self.skil > 2)
	{
		ai_botrun (BOTSPEED);
	}
	else
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_pain6 = [ $pain6, bot_run ]
{
 	ai_botrun (BOTSPEED);
	BotPostThink ();
};

void () bot_axpain1 = [ $axpain1, bot_axpain2 ]
{
 	PainSound ();
	self.weaponframe = 0;
	BotPostThink ();
};

void () bot_axpain2 = [ $axpain2, bot_axpain3 ]
{
 	
	local float r;
	r = ((4* random ()) + self.skil);
	if (r > 2)
	{
		ai_botrun (BOTSPEED);
	}
	else
	{
		ai_botcharge (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_axpain3 = [ $axpain3, bot_axpain4 ]
{
 	if (self.skil >= TRUE)
	{
		ai_botrun (BOTSPEED);
	}
	BotPostThink ();
};

void () bot_axpain4 = [ $axpain4, bot_axpain5 ]
{
 	ai_botcharge (BOTSPEED);
	BotPostThink ();
};

void () bot_axpain5 = [ $axpain5, bot_axpain6 ]
{
 	ai_botrun (BOTSPEED);
	BotPostThink ();
};

void () bot_axpain6 = [ $axpain6, bot_run ]
{
 	ai_botrun (BOTSPEED);
	BotPostThink ();
};

void () bot_pain =
{
	if (self.weaponframe)
	{
		return ;
	}
	if (self.invisible_finished > time)
	{
		return ;
	}
	if (self.weapon == IT_AXE)
	{
		bot_axpain1 ();
	}
	else
	{
		bot_pain1 ();
	}
};

void () bot_diea1;
void () bot_dieb1;
void () bot_diec1;
void () bot_died1;
void () bot_diee1;
void () bot_die_ax1;
void () BotDead =
{
	self.deadflag = DEAD_DEAD;

	if (inHubMap)
	if (bot_vote(0.7))
	{
		return;
	}

	self.nextthink = ((time + 0.3) + ((random () * (NUMBOTS + 3)) * 0.1));
	if (teamplay)
	{
		self.nextthink = (self.nextthink + random ());
	}
	if (TELEFRAGFLAG)
	{
		self.nextthink = (self.nextthink + (5* random ()));
		TELEFRAGFLAG = 0;
	}
	self.think = respawnBot;
};

void () BotDie =
{
	local float i;
	if (self.deadflag != DEAD_NO)
	{
		return ;
	}
	dead_drop(self);

	self.items = (self.items - (self.items & IT_INVISIBILITY));
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = self.modelindex_morph;
	DropBackpack ();
	self.weaponmodel = null_string;
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = (self.flags - (self.flags & FL_ONGROUND));
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
	{
		self.velocity_z = (self.velocity_z + (random () * 300));
	}
	if (self.health < -40)
	{
		GibPlayer ();
		BotDead ();
		return ;
	}
	DeathSound ();
	self.angles_x = 0;
	self.angles_z = 0;
	if (self.weapon == IT_AXE)
	{
		bot_die_ax1 ();
		return ;
	}
	i = cvar ("temp2");
	if (!i)
	{
		i = (1+ floor (random () * 6));
	}
	if (i == 1)
	{
		bot_diea1 ();
	}
	else if (i == 2)
	{
		bot_dieb1 ();
	}
	else if (i == 3)
	{
		bot_diec1 ();
	}
	else if (i == 4)
	{
		bot_died1 ();
	}
	else
	{
		bot_diee1 ();
	}
};

void () bot_diea1 = [ $deatha1, bot_diea2 ] { };
void () bot_diea2 = [ $deatha2, bot_diea3 ] { };
void () bot_diea3 = [ $deatha3, bot_diea4 ] { };
void () bot_diea4 = [ $deatha4, bot_diea5 ] { };
void () bot_diea5 = [ $deatha5, bot_diea6 ] { };
void () bot_diea6 = [ $deatha6, bot_diea7 ] { };
void () bot_diea7 = [ $deatha7, bot_diea8 ] { };
void () bot_diea8 = [ $deatha8, bot_diea9 ] { };
void () bot_diea9 = [ $deatha9, bot_diea10 ] { };
void () bot_diea10 = [ $deatha10, bot_diea11 ] { };
void () bot_diea11 = [ $deatha11, bot_diea11 ] { 	BotDead ();
};

void () bot_dieb1 = [ $deathb1, bot_dieb2 ] { };
void () bot_dieb2 = [ $deathb2, bot_dieb3 ] { };
void () bot_dieb3 = [ $deathb3, bot_dieb4 ] { };
void () bot_dieb4 = [ $deathb4, bot_dieb5 ] { };
void () bot_dieb5 = [ $deathb5, bot_dieb6 ] { };
void () bot_dieb6 = [ $deathb6, bot_dieb7 ] { };
void () bot_dieb7 = [ $deathb7, bot_dieb8 ] { };
void () bot_dieb8 = [ $deathb8, bot_dieb9 ] { };
void () bot_dieb9 = [ $deathb9, bot_dieb9 ] { 	BotDead ();
};

void () bot_diec1 = [ $deathc1, bot_diec2 ] { };
void () bot_diec2 = [ $deathc2, bot_diec3 ] { };
void () bot_diec3 = [ $deathc3, bot_diec4 ] { };
void () bot_diec4 = [ $deathc4, bot_diec5 ] { };
void () bot_diec5 = [ $deathc5, bot_diec6 ] { };
void () bot_diec6 = [ $deathc6, bot_diec7 ] { };
void () bot_diec7 = [ $deathc7, bot_diec8 ] { };
void () bot_diec8 = [ $deathc8, bot_diec9 ] { };
void () bot_diec9 = [ $deathc9, bot_diec10 ] { };
void () bot_diec10 = [ $deathc10, bot_diec11 ] { };
void () bot_diec11 = [ $deathc11, bot_diec12 ] { };
void () bot_diec12 = [ $deathc12, bot_diec13 ] { };
void () bot_diec13 = [ $deathc13, bot_diec14 ] { };
void () bot_diec14 = [ $deathc14, bot_diec15 ] { };
void () bot_diec15 = [ $deathc15, bot_diec15 ] { 	BotDead ();
};

void () bot_died1 = [ $deathd1, bot_died2 ] { };
void () bot_died2 = [ $deathd2, bot_died3 ] { };
void () bot_died3 = [ $deathd3, bot_died4 ] { };
void () bot_died4 = [ $deathd4, bot_died5 ] { };
void () bot_died5 = [ $deathd5, bot_died6 ] { };
void () bot_died6 = [ $deathd6, bot_died7 ] { };
void () bot_died7 = [ $deathd7, bot_died8 ] { };
void () bot_died8 = [ $deathd8, bot_died9 ] { };
void () bot_died9 = [ $deathd9, bot_died9 ] { 	BotDead ();
};

void () bot_diee1 = [ $deathe1, bot_diee2 ] { };
void () bot_diee2 = [ $deathe2, bot_diee3 ] { };
void () bot_diee3 = [ $deathe3, bot_diee4 ] { };
void () bot_diee4 = [ $deathe4, bot_diee5 ] { };
void () bot_diee5 = [ $deathe5, bot_diee6 ] { };
void () bot_diee6 = [ $deathe6, bot_diee7 ] { };
void () bot_diee7 = [ $deathe7, bot_diee8 ] { };
void () bot_diee8 = [ $deathe8, bot_diee9 ] { };
void () bot_diee9 = [ $deathe9, bot_diee9 ] { 	BotDead ();
};

void () bot_die_ax1 = [ $axdeth1, bot_die_ax2 ] { };
void () bot_die_ax2 = [ $axdeth2, bot_die_ax3 ] { };
void () bot_die_ax3 = [ $axdeth3, bot_die_ax4 ] { };
void () bot_die_ax4 = [ $axdeth4, bot_die_ax5 ] { };
void () bot_die_ax5 = [ $axdeth5, bot_die_ax6 ] { };
void () bot_die_ax6 = [ $axdeth6, bot_die_ax7 ] { };
void () bot_die_ax7 = [ $axdeth7, bot_die_ax8 ] { };
void () bot_die_ax8 = [ $axdeth8, bot_die_ax9 ] { };
void () bot_die_ax9 = [ $axdeth9, bot_die_ax9 ] { 	BotDead ();
};

