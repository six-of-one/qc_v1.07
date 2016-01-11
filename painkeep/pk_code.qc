/* ::-::
 *
 * Cataboligne
 *
 * file: pk_code.qc 
 *
 * date: 016.1.10
 *
 * qc - painkeep module - 3.0 extract from archon
 *
 */


/// this is the painkeep code file loaded by progs.src



// HIPNOTIC is defined or not defined in compiler.qc, the master control file
//						  module options are set in hipnotic/hip_control.qc

#ifdef code_painkeep

	#ifdef message_top
	#message         			-- compile: painkeep version 3.0 
	#endifdef




	#ifdef xvars0

// server controls section - enables options to allow server console control
// note: these are controlled by xvars - if that system is disabled, these will be too



	#endifdef



// main pk modules

// moved to defs.qc
//#messagecompiling painkeep/pk_defs.qc 
//#include </pk_defs.qc>


//	#messagecompiling painkeep/pk.qc 
//	#include </pk.qc>


#endifdef






/*

estimated cost of painkeep package
compiled on 016.1. with fteqcc 1.0

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
