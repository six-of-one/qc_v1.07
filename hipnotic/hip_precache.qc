/* ::-::
 *
 * Cataboligne
 *
 * file: hip_precache.qc
 *
 * date: 5.14.15
 *
 * qc - hipnotic extruded precache module
 *
 */

#ifdef id_include_always
#messageinclude   hipnotic/hip_precache.qc 
#endifdef
 
#ifdef nondp

#ifndef use_hip_precache

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   hipnotic/hip_precache.qc 
	#endifdef
	#endifdef

#define use_hip_precache

/// Six - no longer using calling fn of some sub modules to save globals - this now compiles directly into the fn() that used to call it

//void() Hip_precache =
//{
// from world.qc - main

/*
	precache_file("maps/hip1m1.bsp");
	precache_file("maps/hip1m2.bsp");
	precache_file("maps/hip1m3.bsp");
	precache_file("maps/hip1m4.bsp");
	precache_file("maps/hip1m5.bsp");
	precache_file("maps/hip2m1.bsp");
	precache_file("maps/hip2m2.bsp");
	precache_file("maps/hip2m3.bsp");
	precache_file("maps/hip2m4.bsp");
	precache_file("maps/hip2m5.bsp");
	precache_file("maps/hip2m6.bsp");
	precache_file("maps/hip3m1.bsp");
	precache_file("maps/hip3m2.bsp");
	precache_file("maps/hip3m3.bsp");
	precache_file("maps/hip3m4.bsp");
	precache_file("maps/hipdm1.bsp");
	precache_file("maps/hipend.bsp");
	precache_file("maps/zoo.bsp");
	precache_file("maps/mark.bsp");
*/

// worldspawn

//MED 10/21/96 added flies sound
	precache_sound("misc/flys.wav");
//MED 01/13/97 added explosion sounds
	precache_sound("misc/shortexp.wav");
	precache_sound("misc/longexpl.wav");

	#ifdef hip_footsteps
	precache_sound("misc/foot1.wav");
	precache_sound("misc/foot2.wav");
	precache_sound("misc/foot3.wav");
	precache_sound("misc/foot4.wav");
	precache_sound("misc/foot5.wav");
	precache_sound("misc/foot6.wav");
	precache_sound("misc/foot7.wav");
	#endifdef

	precache_model("progs/player.mdl");
	precache_model("progs/eyes.mdl");
	precache_model("progs/h_player.mdl");
	#ifdef hip_weapons
//MED 12/03/96 added player with hammer
	precache_model("progs/playham.mdl");
//MED 10/31/96 added precache for hip view models
	precache_model("progs/v_laserg.mdl");
	precache_model("progs/v_hammer.mdl");
	precache_model("progs/v_prox.mdl");
	precache_model("progs/proxbomb.mdl");
//MED 11/19/96
	precache_sound("hipweap/mjolhit.wav");	// mjolnir
	precache_sound("hipweap/mjolslap.wav");	// mjolnir
	precache_sound("hipweap/mjoltink.wav");	// mjolnir
	precache_sound("hipweap/proxwarn.wav");	// proximity bomb
	precache_sound("hipweap/proxbomb.wav");	// proximity bomb
	#endifdef

//MED 10/18/96 added precache for laser cannon
	precache_model("progs/lasrspik.mdl");

// from weapons.qc
//MED
	precache_sound("enforcer/enfstop.wav");	// laser cannon
//MED 11/06/96
	precache_sound("knight/sword1.wav");	// laser cannon
	precache_sound("hipweap/laserg.wav");	// laser cannon
	precache_sound("hipweap/laserric.wav");	// laser cannon ricochet
//};

// nondp
#endifdef

// use_hip_precache
#endifdef
