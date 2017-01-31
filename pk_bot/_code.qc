/* ::-::
 *
 * Cataboligne
 *
 * file: _code.qc 
 *
 * date: 017.1.30
 *
 * qc - pk*bot module - extract from archon
 *
 */


/// this is the pk*bot code file loaded by progs.src



// code_pkbots is defined or not defined in compiler.qc, the master control file
//						  module options are set here

#ifdef code_pkbots

	#ifdef message_top
	#message         			-- compile: pk*bot X-pk (Version cm2) 
	#endifdef



	#ifdef xvars0

// server controls section - enables options to allow server console control
// note: these are controlled by xvars - if that system is disabled, these will be too



	#endifdef


// allow botcam, compile code
//#define botcam

// main bot modules

	#ifdef nodprint

	#define		dprint		//

	#endifdef


// call moved to defs.qc
//	#messagecompiling pk_bot/bot.defs.qc 
//	#include </bot.defs.qc>

	#messagecompiling pk_bot/bot_tally.qc 
	#include </bot_tally.qc>


	#messagecompiling pk_bot/bot.qc 
	#include </bot.qc>

	#messagecompiling pk_bot/bot_func.qc 
	#include </bot_func.qc>

	#messagecompiling pk_bot/botfight.qc 
	#include </botfight.qc>

	#messagecompiling pk_bot/botthink.qc 
	#include </botthink.qc>

	#messagecompiling pk_bot/botspawn.qc 
	#include </botspawn.qc>

	#messagecompiling pk_bot/botsignl.qc 
	#include </botsignl.qc>

	#messagecompiling pk_bot/botmove.qc 
	#include </botmove.qc>
		
	#messagecompiling pk_bot/botnoise.qc 
	#include </botnoise.qc>

	#messagecompiling pk_bot/botvis.qc 
	#include </botvis.qc>

	#messagecompiling pk_bot/botgoal.qc 
	#include </botgoal.qc>

	#messagecompiling pk_bot/bot_ai.qc 
	#include </bot_ai.qc>

	#messagecompiling pk_bot/pkbot.qc 
	#include </pkbot.qc>

	#messagecompiling pk_bot/botroute.qc 
	#include </botroute.qc>

	#messagecompiling pk_bot/botimp.qc 
	#include </botimp.qc>


#endifdef





/*

estimated cost of pk*bot package
compiled on 016.1.11 with fteqcc 1.0

134840 strofs (of 1000000)
 78103 numstatements (of 524288)
  1778 numfunctions (of 16384)
  7757 numglobaldefs (of 32768)
   510 numfielddefs (467 unique) (of 2048)
  8254 numpr_globals (of 65536)
Writing progs.dat
922956 TOTAL SIZE
Writing progs.lno
103 unique precache_models


vs.

no pk*bot code
compiled on 016.1.10 with fteqcc 1.0
(maphack, hip, other sections enabled)




the pk*bot code base used (at compile date indicated):

strofs	9812
 statements	6797
 functions	115
 globaldefs	785
 fielddefs	57
 numpr_globals	781
 bytes in progs.dat	78188
 
*/


// --------------------------------------------------------------------------------------------------------------------------

