/* ::-::
 *
 * Cataboligne
 *
 * file: _code.qc 
 *
 * date: 016.1.10
 *
 * qc - painkeep module - 3.0 extract from archon
 *
 */


/// this is the painkeep code file loaded by progs.src



// code_painkeep is defined or not defined in compiler.qc, the master control file
//						  module options, if any, are set here

#ifdef code_painkeep_

	#ifdef message_top
	#message         			-- compile: painkeep version 3.0 
	#endifdef

// compile in pk plus modules
//#define code_pkplus_
// moved to compiler.qc for defs


	#ifdef xvars0

// server controls section - enables options to allow server console control
// note: these are controlled by xvars - if that system is disabled, these will be too



	#endifdef



// main pk modules

#define meantime(lMean,lStDev) lMean + crandom() * lStDev

// call moved to defs.qc
//#messagecompiling painkeep/_defs.qc 
//#include </_defs.qc>


//	#messagecompiling painkeep/pk.qc 
//	#include </pk.qc>

#messagecompiling painkeep/hub.qc 
#include </hub.qc>

#messagecompiling painkeep/turret.qc 
#include </turret.qc>

#messagecompiling painkeep/beartrap.qc 
#include </beartrap.qc>

#messagecompiling painkeep/gravity.qc 
#include </gravity.qc>

#messagecompiling painkeep/horn.qc 
#include </horn.qc>

#messagecompiling painkeep/copb.qc 
#include </copb.qc>

#messagecompiling painkeep/bolt.qc 
#include </bolt.qc>

#messagecompiling painkeep/grap.qc 
#include </grap.qc>

#messagecompiling painkeep/exploder.qc 
#include </exploder.qc>

#messagecompiling painkeep/pulse_nail.qc 
#include </pulse_nail.qc>

#messagecompiling painkeep/dmg_skin.qc 
#include </dmg_skin.qc>

#messagecompiling painkeep/sparks.qc 
#include </sparks.qc>

#messagecompiling painkeep/drip.qc 
#include </drip.qc>

#messagecompiling painkeep/sound.qc 
#include </sound.qc>

#messagecompiling painkeep/lightning.qc 
#include </lightning.qc>

#messagecompiling painkeep/zombie2.qc 
#include </zombie2.qc>


#messagecompiling painkeep/tomb.qc 
#include </tomb.qc>

#messagecompiling painkeep/ego.qc 
#include </ego.qc>

#messagecompiling painkeep/phone.qc 
#include </phone.qc>

#endifdef






/*

estimated cost of painkeep package
compiled on 016.1. with fteqcc 1.0



vs.

no painkeep code
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



the painkeep code base used (at compile date indicated):

 statements
 functions
 global defs
 field defs
 numpr globals
 bytes in progs.dat
*/


// --------------------------------------------------------------------------------------------------------------------------
