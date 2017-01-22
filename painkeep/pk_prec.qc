/* ::-::
 *
 * Cataboligne
 *
 * file: pk_prec.qc 
 *
 * date: 017.1.22
 *
 * qc - painkeep module - precache
 *
 */
 
// included to be complete - 3.0 does not use this
 
void() pk_precache =
{
	// PAINKEEP New teleport sounds
	precache_sound ("misc/teleport/tele_1.wav");
	precache_sound ("misc/teleport/tele_2.wav");
	precache_sound ("misc/teleport/tele_3.wav");
	precache_sound ("misc/teleport/tele_4.wav");
	precache_sound ("misc/teleport/tele_1a.wav");
	precache_sound ("misc/teleport/tele_2a.wav");
	precache_sound ("misc/teleport/tele_3a.wav");
	precache_sound ("misc/teleport/tele_4a.wav");

	// SPLASH
	precache_model ("progs/s_splash.spr");
	precache_model ("progs/s_splava.spr");

// GIBS_START
	// extra gibs ...
	precache_model ("progs/g_arm.mdl");
	precache_model ("progs/g_boot.mdl");
	precache_model ("progs/g_eye.mdl");
	precache_model ("progs/g_fore.mdl");
	precache_model ("progs/g_leg.mdl");

  // Gib1 alternative
	precache_model ("progs/qtgib1.mdl");

  // Gib2 alternatives
	precache_model ("progs/qtgib2.mdl");

  // h_player alternative
	precache_model ("progs/qtgib3.mdl");
// GIBS_END

// MARK_SOUNDS_START
	/*
// extra player pain sounds

	precache_sound ("player/pain_1.wav");
	precache_sound ("player/pain_2.wav");
	precache_sound ("player/pain_3.wav");
	precache_sound ("player/pain_4.wav");
	precache_sound ("player/pain_5.wav");
	precache_sound ("player/pain_6.wav");
	precache_sound ("player/pain_7.wav");

// extra player death sounds
	precache_sound ("player/death_1.wav");
	precache_sound ("player/death_2.wav");
	precache_sound ("player/death_3.wav");
	precache_sound ("player/death_4.wav");
	precache_sound ("player/death_5.wav");
	precache_sound ("player/death_6.wav");
	precache_sound ("player/death_7.wav");
	precache_sound ("player/death_8.wav");

	precache_sound ("player/death_9.wav");

	precache_sound ("player/death_10.wav");

	precache_sound ("player/death_11.wav");


// misc sounds that mark has replaced.

	precache_sound ("player/suck_1.wav");
	precache_sound ("player/suck_2.wav");
	precache_sound ("player/suck_3.wav");
	precache_sound ("player/suck_4.wav");
	precache_sound ("player/suck_5.wav");
	precache_sound ("player/suck_6.wav");
	precache_sound ("player/suck_7.wav");
	precache_sound ("player/suck_8.wav");

	precache_sound ("player/burn_1.wav");
	precache_sound ("player/burn_2.wav");
	precache_sound ("player/burn_3.wav");
	precache_sound ("player/burn_4.wav");
	precache_sound ("player/burn_5.wav");

 	precache_sound ("player/drown_1.wav");
 	precache_sound ("player/drown_2.wav");
 	precache_sound ("player/drown_3.wav");
 	precache_sound ("player/drown_4.wav");


 	precache_sound ("player/jump_1.wav");
 	precache_sound ("player/jump_2.wav");
 	precache_sound ("player/jump_3.wav");
 	precache_sound ("player/jump_4.wav");


 	precache_sound ("player/gasp_1.wav");
 	precache_sound ("player/gasp_2.wav");
 	precache_sound ("player/gasp_3.wav");
 	precache_sound ("player/gasp_4.wav");
 	precache_sound ("player/gasp_5.wav");


 	precache_sound ("player/fall_1.wav");
 	precache_sound ("player/fall_2.wav");


 	precache_sound ("player/gib_1.wav");
 	precache_sound ("player/gib_2.wav");

 	precache_sound ("player/gib_3.wav");
	*/


// MARK_SOUNDS_END

	// Painkeep item pickup sound
	precache_sound("misc/pickup/tone2.wav");

  // PAINKEEP_START view models
  precache_model ("progs/v_bear.mdl");
  precache_model ("progs/v_turret.mdl");
  precache_model ("progs/v_harp.mdl");
  precache_model ("progs/v_cube.mdl");
  precache_model ("progs/v_beans.mdl");
  // PAINKEEP_END

// AIRG_MAIN_START
  // Precache the files used in the AirFist.

	precache_model ("progs/v_airgun.mdl");  // Player view of airgun
	precache_model ("progs/s_ablast.spr");	// Air Gun Fire sprite
// AIRG_MAIN_END
};