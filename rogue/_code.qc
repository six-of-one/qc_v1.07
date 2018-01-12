/* ::-::
 *
 * Cataboligne
 *
 * file: rogue _code.qc 
 *
 * date: 1.5.017
 *
 * qc - rogue module - 3.2.97_update
 *
 */


/// this is the rogue code file loaded by progs.src



// ROGUE is defined or not defined in compiler.qc, the master control file
//						  module options are set in rogue/rogue_control.qc

#ifdef ROGUE

	#ifdef message_top
	#message         			-- compile: rogue version Mar(-ish).97
	#endifdef




	#ifdef xvars0

// server controls section - enables options to allow server console control
// note: these are controlled by xvars - if that system is disabled, these will be too



	#endifdef



// main hip modules

// moved to defs.qc
//#messagecompiling rogue/rogdefs.qc 
//#include </hipdefs.qc>


	#messagecompiling rogue/hipsubs.qc 
	#include </hipsubs.qc>

// extruded code
	#messagecompiling rogue/rogue_ai.qc 
	#include </rogue_ai.qc>


// Six - this is wrapped with debug as it produces a weird result
	#messagecompiling rogue/hipspike.qc 
	#include </hipspike.qc>



#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef rogue_mapent

// the next X can be individually excluded by commenting out


	#messagecompiling rogue/rogue_part.qc 
	#include </rogue_part.qc>


#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef rogue_items
// there is no specific items files - but we need to remove this
	#undef rogitem_xlate_item
#endifdef

// this is sub-ifdef'd among * units

#messagecompiling rogue/rogitems.qc 
#include </rogitems.qc>


// --------------------------------------------------------------------------------------------------------------------------
#ifdef rogue_weapons

	#undef rogitem_xlate_weapon

	// extruded code
	#messagecompiling rogue/rogue_weapon.qc 
	#include </rogue_weapon.qc>

#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef rogue_monsters

	#undef rogitem_xlate_monster

	#messagecompiling rogue/hipscrge.qc 
	#include </hipscrge.qc>


#else

	#ifdef rogue
		#ifdef message_top
		#message         			-- exclude: rogue monsters NOT compiled 
		#endifdef
	#endifdef

#endifdef




/*

estimated cost of rogue package
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

no rogue code

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


the rogue code base used (at compile date indicated):

 statements
 functions
 global defs
 field defs
 numpr globals
 bytes in progs.dat
*/


// --------------------------------------------------------------------------------------------------------------------------

// code affecting monsters, weapons and items
// translate rogue to id1 selections
// note - if you enable a module - its xlate will turn off

#ifdef rogitem_xlate

//#messagecompiling rogue/rogue_xlate.qc 
#include </rogue_xlate.qc>

	#ifdef message_all

		#ifdef rogitem_xlate_item
		#message         			-- compile: rogue items translated to quake 1 
		#endifdef

		#ifdef rogitem_xlate_weapon
		#message         			-- compile: rogue weapons translated to quake 1 
		#endifdef

		#ifdef rogitem_xlate_monster
		#message         			-- compile: rogue monsters translated to quake 1 
		#endifdef

	#endifdef

#endifdef

#ifdef rogitem_null

//#messagecompiling rogue/rogue_xnull.qc 
#include </rogue_xnull.qc>

	#ifdef message_all

		#ifdef rogitem_xlate_item
		#message         			-- compile: rogue items nullified 
		#endifdef

		#ifdef rogitem_xlate_weapon
		#message         			-- compile: rogue weapons nullified 
		#endifdef

		#ifdef rogitem_xlate_monster
		#message         			-- compile: rogue monsters nullified 
		#endifdef

	#endifdef

#endifdef


