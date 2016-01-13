/* ::-::
 *
 * Cataboligne
 *
 * file: hip_code.qc 
 *
 * date: 5.10.15
 *
 * qc - hipnotic module - 3.12.97_update
 *
 */


/// this is the hipnotic code file loaded by progs.src



// HIPNOTIC is defined or not defined in compiler.qc, the master control file
//						  module options are set in hipnotic/hip_control.qc

#ifdef HIPNOTIC

	#ifdef message_top
	#message         			-- compile: hipnotic version 3.12.97_update 
	#endifdef




	#ifdef xvars0

// server controls section - enables options to allow server console control
// note: these are controlled by xvars - if that system is disabled, these will be too



	#endifdef



// main hip modules

// moved to defs.qc
//#messagecompiling hipnotic/hipdefs.qc 
//#include </hipdefs.qc>


	#messagecompiling hipnotic/hipsubs.qc 
	#include </hipsubs.qc>

// extruded code
	#messagecompiling hipnotic/hip_ai.qc 
	#include </hip_ai.qc>

// we still need to compile this for wallsprite code

	#messagecompiling hipnotic/hipholes.qc 
	#include </hipholes.qc>

// Six - this is wrapped with debug as it produces a weird result
	#messagecompiling hipnotic/hipspike.qc 
	#include </hipspike.qc>


	#messagecompiling hipnotic/hipdecoy.qc 
	#include </hipdecoy.qc>

#endifdef

// --------------------------------------------------------------------------------------------------------------------------

// this is sub-ifdef'd among 3 units

#messagecompiling hipnotic/hipmisc.qc 
#include </hipmisc.qc>


// --------------------------------------------------------------------------------------------------------------------------
#ifdef hip_mapent

// the next 7 can be individually excluded by commenting out
	#messagecompiling hipnotic/hip_brk.qc 
	#include </hip_brk.qc>

	#messagecompiling hipnotic/hip_expl.qc 
	#include </hip_expl.qc>

	#messagecompiling hipnotic/hipquake.qc 
	#include </hipquake.qc>

	#messagecompiling hipnotic/hiprubbl.qc 
	#include </hiprubbl.qc>

	#messagecompiling hipnotic/hip_push.qc 
	#include </hip_push.qc>

	#messagecompiling hipnotic/hip_part.qc 
	#include </hip_part.qc>

	#messagecompiling hipnotic/hipwater.qc 
	#include </hipwater.qc>
// end exclude set

	#messagecompiling hipnotic/hiptrain.qc 
	#include </hiptrain.qc>

	#messagecompiling hipnotic/hipcount.qc 
	#include </hipcount.qc>

	#messagecompiling hipnotic/hiptrig.qc 
	#include </hiptrig.qc>

#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hip_rotate

	#messagecompiling hipnotic/hiprot.qc 
	#include </hiprot.qc>

	#messagecompiling hipnotic/hipclock.qc 
	#include </hipclock.qc>

#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hip_items
// there is no specific items files - but we need to remove this
	#undef hipitem_xlate_item
#endifdef

// this is sub-ifdef'd among * units

#messagecompiling hipnotic/hipitems.qc 
#include </hipitems.qc>



// --------------------------------------------------------------------------------------------------------------------------
#ifdef hip_spawn

	#messagecompiling hipnotic/hipspawn.qc 
	#include </hipspawn.qc>

#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef hip_weapons

	#undef hipitem_xlate_weapon

	// extruded code
	#messagecompiling hipnotic/hip_weapon.qc 
	#include </hip_weapon.qc>

#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef hip_monsters

	#undef hipitem_xlate_monster

	#messagecompiling hipnotic/hipscrge.qc 
	#include </hipscrge.qc>

	#messagecompiling hipnotic/hipgrem.qc 
	#include </hipgrem.qc>

	#messagecompiling hipnotic/hiparma.qc 
	#include </hiparma.qc>

#else

	#ifdef HIPNOTIC
		#ifdef message_top
		#message         			-- exclude: hipnotic monsters NOT compiled 
		#endifdef
	#endifdef

#endifdef




/*

estimated cost of hipnotic package
compiled on 5.12.15 with fteqcc 1.0 --- NOT completed

 66680 strofs (of 1000000)
 29097 numstatements (of 524288)
   987 numfunctions (of 16384)
  3177 numglobaldefs (of 32768)
   321 numfielddefs (291 unique) (of 2048)
  3592 numpr_globals (of 65536)
Writing ./progs.dat
377470 TOTAL SIZE
Writing ./progs.lno
 81 unique precache_models

vs.

no hipnotic code

 47856 strofs (of 1000000)
 20301 numstatements (of 524288)
   637 numfunctions (of 16384)
  2271 numglobaldefs (of 32768)
   270 numfielddefs (245 unique) (of 2048)
  2638 numpr_globals (of 65536)
Writing ./progs.dat
264206 TOTAL SIZE
Writing ./progs.lno
 69 unique precache_models


the hipnotic code base used (at compile date indicated):

 statements
 functions
 global defs
 field defs
 numpr globals
 bytes in progs.dat
*/


// --------------------------------------------------------------------------------------------------------------------------

// code affecting monsters, weapons and items
// translate hipnotic to id1 selections
// note - if you enable a module - its xlate will turn off

#ifdef hipitem_xlate

//#messagecompiling hipnotic/hip_xlate.qc 
#include </hip_xlate.qc>

	#ifdef message_all

		#ifdef hipitem_xlate_item
		#message         			-- compile: hipnotic items translated to quake 1 
		#endifdef

		#ifdef hipitem_xlate_weapon
		#message         			-- compile: hipnotic weapons translated to quake 1 
		#endifdef

		#ifdef hipitem_xlate_monster
		#message         			-- compile: hipnotic monsters translated to quake 1 
		#endifdef

	#endifdef

#endifdef

#ifdef hipitem_null

//#messagecompiling hipnotic/hip_xnull.qc 
#include </hip_xnull.qc>

	#ifdef message_all

		#ifdef hipitem_xlate_item
		#message         			-- compile: hipnotic items nullified 
		#endifdef

		#ifdef hipitem_xlate_weapon
		#message         			-- compile: hipnotic weapons nullified 
		#endifdef

		#ifdef hipitem_xlate_monster
		#message         			-- compile: hipnotic monsters nullified 
		#endifdef

	#endifdef

#endifdef


