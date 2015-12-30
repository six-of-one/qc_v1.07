/* ::-::
 *
 * Cataboligne
 *
 * file: hip_control.qc
 *
 * date: 5.23.15
 *
 * qc - hipnotic control file
 *
 */


/// this is the hipnotic code control file - with compiler options for the various configurations

#ifdef id_include_always
#messageinclude   hipnotic/hip_control.qc 
#endifdef


// code affecting monsters, weapons and items
// translate hipnotic to id1 selections
// this can be left defined - any modules loaded will turn off  its xlate in hip_code.qc

#define hipitem_xlate

// nullify all hipnotic items / weapons / monsters
// they wont load anyway, but you can load hipnotic maps without engine warnings
// this takes up globals

//#define hipitem_null



/*
sub-modules

-	defining HIPNOTIC includes all

-	to use only selected modules, you could:
	1. leave HIPNOTIC undefined and define the modules you want - there may be lost interdependencies
	2. define HIPNOTIC and comment out all the modules you DONT want

hip_maps - controls end of level text
hip_monsters - monster code
hip_weapons - wep code
hip_items - rest of item code
hip_mapent - brush based ents - rotating, trigger, trap, etc
hip_traps - shooters, triggers, etc (part of hip_mapent)
hip_rotate - rotate code (part of hip_mapent) - includes hipclock.qc
hip_spawn - spawn* and charm code - horn of conjuring will NOT work without these
hip_bulletholes - hole code
hip_footsteps - the hipnotic player footstep sound
*/


// HIPNOTIC is defined or not defined in compiler.qc, the master control file

#ifdef HIPNOTIC


// hipnotic code options

	#define hip_monsters
	#define hip_weapons
	#define hip_items

// special spawn code - used by func_spawn, and one field in finale ( .spawnfunction - see hipmisc.qc ) 
	#define hip_spawn

// auto include charmed with spawn
	#ifdef hip_spawn
	#define hip_charmed
	#endifdef

// finale code - if you dont need the mission pack end sequence, you can comment this out
	#define hip_finale

// this is for the sequencing of hip maps - the end of episode and finale texts - ~2900 bytes
// now wrapped in opgrade - new method using cvar_string is used

#ifndef opgrade

	#define hip_mapseq

#endifdef


// map ents
// * this controls a large section of spawn fns
	#define hip_mapent

		#ifdef hip_mapent

		#define hip_rotate
		#define hip_traps

		#endifdef

// the hipnotic player footstep sound
	#define hip_footsteps


	#ifdef nondp

// Six - not using with darkplaces - it has better bullet splash damage on the world
// make bullet holes
		#define hip_bulletholes

	#endifdef

#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate

	#define hipitem_xlate_item
	#define hipitem_xlate_weapon
	#define hipitem_xlate_monster
	
#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_null

// these two are NOT compatible, and this one will take priority if defined
	#undef hipitem_xlate

// the same section headers get used the same way - if the hip code block is used these are undefined
	#define hipitem_xlate_item
	#define hipitem_xlate_weapon
	#define hipitem_xlate_monster
	
#endifdef
