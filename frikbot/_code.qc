/* ::-::
 *
 * Cataboligne
 *
 * file: _code.qc 
 *
 * date: 016.1.10
 *
 * qc - frikbot module - extract from archon
 *
 */


/// this is the frikbot code file loaded by progs.src



// code_frikbots is defined or not defined in compiler.qc, the master control file
//						  module options are set here

#ifdef code_frikbots

	#ifdef message_top
	#message         			-- compile: frikbot X-pk (Version 0.10.1) 
	#endifdef



	#ifdef xvars0

// server controls section - enables options to allow server console control
// note: these are controlled by xvars - if that system is disabled, these will be too



	#endifdef


// main bot modules

// call moved to defs.qc
//#messagecompiling frikbot/_defs.qc 
//#include </_defs.qc>


	#messagecompiling frikbot/bot.qc 
	#include </bot.qc>

	#messagecompiling frikbot/bot_way.qc 
	#include </bot_way.qc>

	#messagecompiling frikbot/bot_fight.qc 
	#include </bot_fight.qc>

	#messagecompiling frikbot/bot_ai.qc 
	#include </bot_ai.qc>

	#messagecompiling frikbot/bot_misc.qc 
	#include </bot_misc.qc>

	#messagecompiling frikbot/bot_phys.qc 
	#include </bot_phys.qc>

	#messagecompiling frikbot/bot_move.qc 
	#include </bot_move.qc>


/*
not using - dont play on these much
frikbot/map_dm1.qc
frikbot/map_dm2.qc
frikbot/map_dm3.qc
frikbot/map_dm4.qc
frikbot/map_dm5.qc
frikbot/map_dm6.qc
*/


#endifdef





/*

estimated cost of frikbot package
compiled on 016.1.11 with fteqcc 1.0

 75000 strofs (of 1000000)
 42120 numstatements (of 524288)
  1097 numfunctions (of 16384)
  4202 numglobaldefs (of 32768)
   379 numfielddefs (343 unique) (of 2048)
  4554 numpr_globals (of 65536)
Writing progs.dat
506448 TOTAL SIZE
Writing progs.lno
 84 unique precache_models


vs.

no frikbot code
compiled on 016.1.10 with fteqcc 1.0
(maphack, hip, other sections enabled)

 65188 strofs (of 1000000)
 35323 numstatements (of 524288)
   982 numfunctions (of 16384)
  3417 numglobaldefs (of 32768)
   322 numfielddefs (292 unique) (of 2048)
  3773 numpr_globals (of 65536)
Writing progs.dat
428260 TOTAL SIZE
Writing progs.lno
 84 unique precache_models


the frikbot code base used (at compile date indicated):

strofs	9812
 statements	6797
 functions	115
 globaldefs	785
 fielddefs	57
 numpr_globals	781
 bytes in progs.dat	78188
 
*/


// --------------------------------------------------------------------------------------------------------------------------

