/* ::-::
 *
 * Cataboligne
 *
 * file: monster_defs.qc 
 *
 * date: 017.1.11
 *
 * qc - monsters module - defines
 *
 */


// archon monster speed module - some monsters move differently

//#define mon_speed
#ifdef mon_speed
// speed divsors:
//		< 1 - slow down
//		> 1 - speed up

#define	speed_div		lip

// cvar ?
#define	MON_SPEED_DIV		1

#endifdef


#ifdef quakemonsters

	#ifdef message_top
	#messagecompiling monster_x/monster_defs.qc 
//	#message         			-- compile: monster defs 
	#define mdef_hdr
	#endifdef

#endifdef

#ifdef xmonsters

	#ifdef message_top
	#ifndef mdef_hdr
	#messagecompiling monster_x/monster_defs.qc 
	#endifdef
	#endifdef

#endifdef
