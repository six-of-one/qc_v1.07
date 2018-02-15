 /* ::-::
 *
 * Cataboligne
 *
 * file: pulse_nail.qc 
 *
 * date: 016.3.2
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
	self.nextthink = self.dmgtime;

	// we want to hurt the owner now...
	self.owner = world;
};

// fire a pulse spike - recoded with fire_missile

void(float ox) W_FirePulseSpikes =
{

	v1__ = self.origin + '0 0 16' + v_right*ox;

#ifdef vwlaunch

	if (self.vwlaunch)
		v1__ = self.origin + v_up * VWZ_PNAILG + v_right * (ox / 2.5) + v_right * VWY_PNAILG + v_forward * VWX_PNAILG;

#endifdef

#ifdef code_xents

	fire_missile(SPIKE_VEL, MOVETYPE_FLYMISSILE, FL_MSL | FL_PUNCH | FL_USEAMMO

#ifdef code_runes
										 | FL_RUNEHST 
#endifdef
//																					RM_SKY | PF_LAVA
													, 0	, v1__, '0 0 0', "pulse_spike", "progs/spike.mdl", "weapons/pulse/pulse_1.wav", spike_touch, cvar("pulse_spike"),  SUB_Remove, SUB_Null);

#else
	makevectors(self.v_angle);
	launch_spike(v1__, v_forward);
	setmodel(newmis, "progs/spike.mdl");
	newmis.classname="pulse_spike";
	newmis.touch = spike_touch;
	newmis.think = SUB_Remove;
	newmis.nextthink = time + cvar(newmis.classname);
	sound (newmis, CHAN_WEAPON, "weapons/pulse/pulse_1.wav", 1, ATTN_NORM);

#endifdef

	newmis.dmgtime = newmis.nextthink;		// master live time - touch changes nt
	newmis.dmg = 27;
//	newmis.theowner = self;  done in launch spike
	newmis.skin = 3;
	newmis.weapon = IT_NAILGUN; // Cataboligne - 2.19.11 - correct obit in pk_clientobit
	newmis.wad = "spike";		// change class to this after hit a bleeder
	if (EWEAP) newmis.wad = EWEAP.deathtype;
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
#ifdef code_runes
	if (rune_haste(0.3))
#endifdef
	self.attack_finished = time + 0.6;

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe >= 5)
		self.weaponframe = 1;
	SuperDamageSound();

	z2__ = W_FirePulseSpikes;
	if (EWEAP.fire_code && (EWEAP.fire_code != SUB_Null)) z2__ = EWEAP.fire_code;			// check for eweapon override on firing pulsed nail guns
	if (!(self.weaponframe & 1))
	{
		self.frame = $nailatt2;
		z2__(-4);
	}
	else
		z2__(4);
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