 /* ::-::
 *
 * Cataboligne
 *
 * file: pulse_nail.qc 
 *
 * date: 016.2.29
 *
 * qc - painkeep module - pulse nailgun qc
 *
 */


//	rebound the pulse spike

void() pulse_rebound =
{
	self.velocity = normalize(self.velocity) * 1000;
	self.movetype = MOVETYPE_FLYMISSILE;
	self.angles = vectoangles(self.velocity);
	self.think = SUB_Remove;
	self.nextthink = self.ltime;

	// we want to hurt the owner now...
	self.owner = world;
};

// fire a pulse spike - recoded with fire_missile

void(float ox) W_FirePulseSpikes =
{
//	local vector	dir;  v0__

//	makevectors(self.v_angle);
//	sound (self, CHAN_WEAPON, "weapons/pulse/pulse_1.wav", 1, ATTN_NORM);
	//self.attack_finished = time + 0.4;
//	self.currentammo = self.ammo_nails = self.ammo_nails - ammo_con(1, self, string_null);
#ifdef code_pkbots__removethis
	if (self.class_select == "class_pk*bot")
		v0__ = botaim ();
	else
#endifdef
//	v0__ = aim (self, 1000);
	v1__ = self.origin + '0 0 16' + v_right*ox;

/*
	if (autocvar_sv_centerwep)
		v1__ = self.origin + '0 0 16' + v_right*ox;
	else
		v1__ = self.origin + v_up * VWZ_PNAILG + v_right * (ox / 2.5) + v_right * VWY_PNAILG + v_forward * VWX_PNAILG;

	if (autocvar_sv_centerwep)
		launch_spike (self.origin + '0 0 16' + v_right*ox, v0__);
	else
		launch_spike (self.origin + v_up * VWZ_PNAILG + v_right * (ox / 2.5) + v_right * VWY_PNAILG + v_forward * VWX_PNAILG, v0__);
*/

	fire_missile(SPIKE_VEL, MOVETYPE_FLYMISSILE, FL_MSL | FL_PUNCH | FL_USEAMMO

#ifndef noautoaim
																								 | FL_AIM1K
#endifdef

#ifdef code_runes
										 | FL_RUNEHST 
#endifdef
//																					RM_SKY | PF_LAVA
													, 0	, v1__, '0 0 0', "pulse_spike", "progs/spike.mdl", "weapons/pulse/pulse_1.wav", spike_touch, 2.0,  SUB_Remove, SUB_Null);


//	newmis.touch = spike_touch;
	newmis.dmg = 27;
	newmis.theowner = self;
//	newmis.classname = "pulse_spike";
//	setmodel (newmis, "progs/p-nail.mdl");
//	setmodel (newmis, "progs/spike.mdl");
	newmis.skin = 3;
//	newmis.angles = vectoangles(v0__);
	newmis.weapon = IT_NAILGUN; // Cataboligne - 2.19.11 - correct obit in pk_clientobit

//	setsize (newmis, '0 0 0', '0 0 0');
//	self.punchangle_x = -2;
//	cam_punch(); // Cataboligne - 5.13.10 - cam purify - nullify fire punchangle if in cam view

	// time limit
//	newmis.think = SUB_Remove;
//	newmis.nextthink = time + 2.0;
};

// pulse nailgun frames

void() player_pnail1	 =[$nailatt1, player_pnail2]
//void(float ox) pulse_fire =
{
	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0)
	{
		player_run ();
		return;
	}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	if (!(self.weaponframe & 1))
	{
		self.frame = $nailatt2;
		W_FirePulseSpikes (-4);
	}
	else
	W_FirePulseSpikes (4);
#ifdef code_runes
	if (rune_haste(0.3))
#endifdef
	self.attack_finished = time + 0.6;
};

void() player_pnail2	 =[$nailatt2, player_pnail1]
//void() pulse_idle =
{
	if (!self.button0)
	{
		player_run();
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;

	self.nextthink = time + 0.2;
};