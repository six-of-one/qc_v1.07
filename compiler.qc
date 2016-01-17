/* ::-::
 *
 * Cataboligne
 *
 * file: compiler.qc
 *
 * date: 11/21/14
 *
 * qc - precompiler specific codes
 *
 */
 
 
 /*
		This file is the core of the vanilla Quake-C recode ""qc++"" with fteqcc

		quake-c can not be more complicated

		The vision of this code base is the ability to include various secitons simply by
		using the defines below to control what is compiled in.  SWITCH indicates module controls.

		Some major changes have sub-section includes such as the hipnotic mission pack

		release plan: v106 recoded (*), v107 clean, v107 only, pk 3.0, chaos mod mark III

 */



/// **************************************
/// compiler ID section
///
/// **************************************

// #message controls

// note: use of  (backspace, hex edit hacked into qc file) to replace "#message" element of line output with blanks, or "compiling"

// comment message controls out to remove all but "compiling"  messages
// to remove compiling (and all messages) use "qcc > /dev/null"

// display all #messages
#define message_all

// display top #message
#define message_top

// display only warning #message - these are NOT compiler warnings
// and none have been assigned as yet
//#define message_warn

// define parms to show include files on compile

// indicate everytime include happens, even if compile doesnt
#define id_include_always

// only indicate when included code is compiled
//#define id_include


#ifdef message_top
#define modinfo
#message         			code identity: 
#message         			-- version 2.0 qc++ -- compile with fteqcc 
#endifdef

#ifdef message_all
	#ifndef modinfo
	#define modinfo
#message         			code identity: 
	#endifdef
	#define module_list

#message         			-- (c) 1996 iD software, (c) 2014 Number Six 
#message         			-- GPL - see LICENSE for rights and details 
#message          

#else

// list modules included
//#define module_list

#endifdef

#ifdef module_list
#message         			code modules: 
#endifdef

// this is 50 bytes shorter
#pragma COPYRIGHT (c) 1.06 iD 1996, 1.07 Six 2014

// more detail - takes more bytes
//#pragma COPYRIGHT v1.06 iD (c)1996 v1.07 Number Six (c)2014 -GPL- www.moddb.com/groups/qc


// version history tally														[ includes major / minor code sections by define control ]

// 1.0.7				- qc++															[ opgrade, codefix, unused, pointless_warning, noobjerr, debug, warning, nodprint, noautoaim, xvars?, nondp, glowcorpse ]
// 1.0.7.1			- quake monsters now optional, x monsters +8 pack		[ local_test ]
// 1.0.7.2			- hipnotic code base shoehorn
// 1.0.7.3			- map_hack										+	[ q_mapseq, hip_mapseq, has_issues, no_bossgate, no_epgate ]
// 1.0.7.4			- code_bots, code_frikbots
// 1.0.7.5			- code_painkeep


#define VERSION 	"1.0.7.4 qc++"

/// **************************************
/// code weaver section
///
/// **************************************

// this section deals with what portions of the code base get compiled in and which get left out
// note - defines MUST be commented out or removed - you cannot define null or 0 to clear them


/// compiler controls

// dont list unused vars warning when compiling
//#pragma warning disable Q302

// turn off warnings for map spawn functions - most are normally only called by the engine
#pragma warning off F300



// ******************************************************************************************************************

// main ka-hoona
// note: (to self) - this no longer has any effect ?  when did this happen

/// SWITCH
#define qc++

#ifdef qc++
	#ifdef module_list
	#message         			- qc++ 
	#endifdef
	#define modulein
#endifdef


// ******************************************************************************************************************

/// SWITCH
//#define qcvers

// takes up a global var (and string space), but gives the progs.dat code a qc version in the console		- requires localcmd(vers); somewhere in code

#ifdef qcvers

	#ifdef module_list
	#message         			- qcvers 
	#endifdef
	#define modulein

// if this alias is set, when you type "version" in the console it will respond with the string
// with darkplaces this will display the darkplaces version first then this string
// requires an addtional instruciton thus:
//		localcmd(vers);
// to be run once somewhere in worldspawn()

string vers						= "alias version \"echo quake-c: 1.0.7.4 qc++\"\n";

// this is better off being placed in a config file - for instance default.cfg like so:
// alias version "echo quake-c: 1.0.7 qc++"
#endifdef


// ******************************************************************************************************************

/*
	an operation upgrade to vanilla qc 1.06

*/

	// 11.23.14
	// fx_warning
	// - some vars commented out to fix this compiler warning:
	//    defs.qc:401: warning: empty_float  no references


// quake one operation upgrade

/// SWITCH
#define opgrade
/// opgrade turned ON



// do all the opgrade sub-items
#ifdef opgrade

	#ifdef module_list
	#message         			- opgrade 
	#endifdef
	#define modulein

// controls advanced intermission message load - !nondp must turn this off
#define opgrade__

//	part of opgrade - fix some q1 code issues - many also fix compiler warnings
/// SWITCH
#define codefix
/*

	codefix - removing this define puts code flaws back
'						fixing these flaws possibly affects game play, map loads, and monster behavior
'						e.g. - map loads, monsters, and entities may _not_ perform the same under the fixed code

	example in misc_fireball() - 

	if (!self.speed)
		self.speed == 1000;

this is fixed with
		self.speed = 1000;
*/


// remove autoaim from code
// this is done by translating all aim() calls as v_forward, which is set in PlayerPreThink() from v_angle
// more properly this should re-calculate v_forward every time aim() is called - see defs.qc

/// SWITCH
#define noautoaim


// instead of a regular function
// this saves a function def and a global def at the expense of more statements
// this is really an esthetic choice as both methods do the same thing op wise

#define crandom() 2*(random() - 0.5)

// quake 1 optioned sections
/// NOTE: if these are defined standard singleplayer may be broken!

// if you want to remove rune controlled gate code
/// SWITCH
//#define no_bossgate
//#define no_epgate

// end of opgrade subs



#else
/// opgrade turned OFF


// if we turn off opgrade and qc++ we have (mostly) v106 behavior in the base code
// in theory anyway
	#ifndef qc++

// compile in un-used code sections
// these are bits of quake-c that are:
//		- vars never referenced - not even in the engine
//		- code that serves no purpose
/// SWITCH
//#define unused

// end not using qc++
	#endifdef


// end of opgrade not used
#endifdef


#ifdef codefix
	#ifdef module_list
	#message         			- codefix 
	#endifdef
	#define modulein
#endifdef

#ifdef unused
	#ifdef module_list
	#message         			- unused 
	#endifdef
	#define modulein
#endifdef

#ifdef noautoaim
	#ifdef module_list
	#message         			- noautoaim 
	#endifdef
#endifdef

#ifdef no_bossgate
	#ifdef module_list
	#message         			- no_bossgate 	* 
	#endifdef
	#ifndef breaker
	#define breaker
	#endifdef
#endifdef

#ifdef no_epgate
	#ifdef module_list
	#message         			- no_epgate 	* 
	#endifdef
	#ifndef breaker
	#define breaker
	#endifdef
#endifdef


// ******************************************************************************************************************

// some code is pointless, but removing it creates warnings			- mostly these are return FALSE; };
// comment this out to remove the pointless code, the following bit removes the warnings!
/// SWITCH
//#define pointless_warning

/// NOTE: this masks off no return value compiler WARNINGS !
#ifndef pointless_warning
// comment this out to see any related warnings
#pragma warning disable Q206
#endifdef

// ******************************************************************************************************************



// part of opgrade - remove objerror if possible to continue, also removes error()
// but we do this always - there is no reason for map spudge to break the server
// "spudge" - crap in a map that shouldnt be - like missing targets, broken trains and such
/// SWITCH
#define noobjerr

#ifdef noobjerr
	#ifdef module_list
	#message         			- noobjerr 
	#endifdef
	#define modulein
#endifdef


// ******************************************************************************************************************


// include all debug / warning code - uncomment this define to use
// this includes _cheat_ impulses
// includes special map spawns

/// * all code wrapped with #ifdef debug MUST be deleted from live server / release code !

/// SWITCH
//#define debug

#ifdef debug

	#ifdef module_list
	#message         			- debug 	* 
	#endifdef
	#define modulein
	#ifndef breaker
	#define breaker
	#endifdef

// optional warning code display system - see below
/// SWITCH
	#define warning

#else
// dont compile dprints - they use globals --- comment this #define out to compile dprint code, also you must set the developer cvar to have them print to console
/// cut dprint segments for final or gold release
/// SWITCH
#define nodprint

// dev warning system - uncomment to use independent of debug code - should be removed from gold / release code

/// SWITCH
//#define warning

/*
warning ideas

print fn entries
track global vars
track ent vars
track local vars on entry / exit?
spec track by cvar

*/

#endifdef


#ifdef nodprint
	#ifdef module_list
	#message         			- nodprint 
	#endifdef
#endifdef

#ifdef warning
	#ifdef module_list
	#message         			- warning 
	#endifdef
	#define modulein

	float WARNING;

#endifdef


// local testing - so we dont have to turn on all the debug code - but we can remove all test code for a run

/// all code wrapped with #ifdef local_test SHOULD be deleted from live server / release code !

/// SWITCH
#define local_test

// we always tell if local test or debug are compiled in

#ifdef local_test
	#ifdef module_list
	#message         			- local_test 	* 
	#endifdef
	#define modulein
	#ifndef breaker
	#define breaker
	#endifdef

//void()	frd1;

#endifdef


// ******************************************************************************************************************


/// non-darkplaces compile

// this is just a placeholder for certain bits of code that will only be optional in early releases
// uncomment the next line and certain darkplaces only code will not be compiled
/// SWITCH
//#define nondp

#ifdef nondp

	#ifdef module_list
	#message         			- nondp 
	#endifdef
	#define modulein

// turn off intermis msg update
	#undef opgrade__
#endifdef

/// remove the above section for dp only releases

// the darkplaces compile saves some resources

// ******************************************************************************************************************


// extra server cvars
// most should take the form "svx_{varname}"
// at this time these have limited effect

// note: these use up global vars and are designed to operate in a 3 (or 4) tiered system
//				 level 0 is the only level really necessary if server ops are agreeable with developer selected defaults

/// SWITCH
#define xvars

#ifdef xvars

// level 0 control - we _always_ want these compiled in
// - important server controls needed for daily ops

#define xvars0

// engine behavior control vars - how to default when things behave badly or fail
//	-	these mostly modify existing default behavior to an alternate option

#define xvars1

// vars level 2 stuff
// - mostly cosmetic items not affecting game play

#define xvars2

	#ifdef module_list
	#message         			- xvars 
	#endifdef
	#define modulein

#else

// high priority - still want these
/// SWITCH
#define xvars0

#endifdef

#ifndef xvars
#ifdef xvars0
	#ifdef module_list
	#message         			- xvars0 
	#endifdef
	#define modulein
#endifdef
#endifdef


// ******************************************************************************************************************

// possible options - permanent compile in
// these should ifndef on xvars*

//#define glowcorpse // dead with quad glows - fix code not compiled


// ******************************************************************************************************************

/// mod section - should be of interest to mod coders

// quake one - you can exclude various modules here

// this is for the sequencing of maps - the end of episode and finale texts
// these take up a bit of space (~3700 bytes), and if your mod does not require playing through q1 (such as DM mods), you might not want them
// if you comment this out - a GotoNextMap() will be called instead of displaying the end text
// now wrapped in opgrade - new method using cvar_string is used

#ifndef opgrade__

/// SWITCH
	#define q_mapseq

#endifdef

#ifdef q_mapseq
	#ifdef module_list
	#message         			- q_mapseq 
	#endifdef
	#define modulein
#endifdef

// mission pack 1
// NOTE: you need the media files and models to load maps or have entities using this code operate as intended
//					default behavior with HIPNOTIC turned OFF will replace ents with missing models, deactivate some freatures - etc

/// SWITCH
//#define HIPNOTIC

#ifdef HIPNOTIC
	#ifdef module_list
	#message         			- hipnotic 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// mission pack 2
// NOTE: you need the media files and models to load maps or have entities using this code operate as intended
/// SWITCH
//#define ROGUE

#ifdef ROGUE
	#ifdef module_list
	#message         			- rogue 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// painkeep
/// SWITCH
//#define code_painkeep

#ifdef code_painkeep
	#ifdef module_list
	#message         			- code_painkeep 
	#endifdef
	#define modulein
#endifdef

// use pk bots
/// SWITCH
//#define code_pkbots

#ifdef code_pkbots
	#ifdef module_list
	#message         			- code_pkbots 
	#endifdef
	#define modulein
// include general bot code
		#ifndef code_bots
#define code_bots
		#endifdef
#endifdef

// ******************************************************************************************************************

// use frik bots
/// SWITCH
#define code_frikbots

#ifdef code_frikbots
	#ifdef module_list
	#message         			- code_frikbots 
	#endifdef
	#define modulein
// include general bot code
		#ifndef code_bots
#define code_bots
		#endifdef
#endifdef

// ******************************************************************************************************************

// rune server
/// SWITCH
//#define code_runes

#ifdef code_runes
	#ifdef module_list
	#message         			- code_runes 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// visible weapons - show player model with actual selected weapon
#ifndef nondp
/// SWITCH
#define code_viswep
#endifdef

#ifdef code_viswep
	#ifdef module_list
	#message         			- code_viswep 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// quake monsters

// note: removing map monsters makes the attempt to allow all single player maps to be completed.  Say if you are playing with a random monster maker.
//				this references maps that have a trigger on a monster the causes some map action, such as a door to open

/// SWITCH
#define quakemonsters

#ifdef quakemonsters
	#ifdef module_list
	#message         			- quakemonsters 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// extra monsters

/// SWITCH
//#define xmonsters

#ifdef xmonsters
	#ifdef module_list
	#message         			- xmonsters 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// maphack system

#ifndef nondp
/// SWITCH
#define map_hack
#endifdef

#ifdef map_hack
	#ifdef module_list
	#message         			- map_hack 
	#endifdef
	#define modulein
#endifdef

// ******************************************************************************************************************

// new code that... well, has issues
// it might be cool to run this code, but it just doesnt work quite right
// all code in this wrapper SHOULD be removed for release

// 1. quake 1 standard end of episode win text diaplay in Q-one -- currently text is ignored, or displayed in infobar

// uncomment this to compile code that has issues
/// SWITCH
//#define has_issues

#ifdef has_issues
	#ifdef module_list
	#message         			- has_issues 	* 
	#endifdef
	#define modulein
	#ifndef breaker
	#define breaker
	#endifdef
#endifdef


// ******************************************************************************************************************

#ifndef modulein
	#ifdef message_all
	#message         			- NO MODULES 	* 
	#endifdef
	#ifndef breaker
	#define breaker
	#endifdef
#endifdef

#ifdef breaker
	#ifdef message_all
	#message          
	#message         			* code has compiled that may break or adversly alter game play 
	#endifdef
#endifdef

#ifdef message_all
	#message          
#endifdef

// ******************************************************************************************************************

// control file(s)

#include <hipnotic/hip_control.qc>


/// **************************************
/// ops section
///
/// **************************************

// this section is the operating macro functions and variable section


// framer()

// implement a frame seqeunce where anything might happen in the frames
// one frame is incremented each entry - if this is changed in excode, set eframe appropriate to that

//  just mnemonics t0 help understand the code - we need brevity for the 256 limit
// t_  think_ functions
// t_on - function define for this loop - * can be called by other code *
// t_to - where we go when we hit end frame
// t_time - nextthink interval used in the _entire_ loop - unless adjusted in excode
// sframe - start_frame of the loop
// eframe - end_frame of the loop
/// excode --- run any arbitrary code - SUB_Null() __MUST__ be put in for nothing, you can NOT leave this blank!

#define framer(sframe,eframe,t_on,t_to,t_time,excode) void() t_on {if (self.think != t_on|| self.frame < sframe || self.frame >= eframe){self.frame = sframe - 1; self.think = t_on;} self.frame = self.frame + 1; self.nextthink = time + t_time; if (self.frame == eframe) {self.think = t_to;} excode;}

// self loop - does not think to a t_to on eframe

#define framerloop(sframe,eframe,t_on,t_time,excode) void() t_on {if (self.think != t_on|| self.frame < sframe || self.frame >= eframe){self.frame = sframe - 1; self.think = t_on;} self.frame = self.frame + 1; self.nextthink = time + t_time; excode;}

///framer($shotatt1, $shotatt6, player_shot1, player_run, 0.1,

/*

// code layout
// note logic change - if current self.frame is beyond start frame or end frame in either direction, we reset to start frame
// freset has been removed - no longer needed, if we re-enter, looping to self and see the endframe, that is a reset
// remove t_to and this line for framerloop: if (self.frame == eframe) { self.think = t_to; }


void() t_on 
{
	if (self.think != t_on|| self.frame < sframe || self.frame >= eframe)
	{
		self.frame = sframe - 1;
		self.think = t_on;
	}
	self.frame = self.frame + 1;
	self.nextthink = time + t_time;
	if (self.frame == eframe) { self.think = t_to; }
	excode; // run any arbitrary code - SUB_Null() for nothing, you can NOT leave this blank!
}

*/

// run arbitrary code in a specific frame, range of frames or set of frames

#define frame_arb(thisframe,arbcode) if (self.frame == thisframe) { arbcode; };

#define frametwo_arb(thisframe,thatframe,arbcode) if (self.frame == thisframe || self.frame == thatframe) { arbcode; };

#define framerange_arb(thisframe,thatframe,arbcode) if (self.frame >= thisframe && self.frame <= thatframe) { arbcode; };

// no instances of this logic yet
//#define framethree_arb(thisframe,thatframe,threeframe,arbcode) if (self.frame == thisframe || self.frame == thatframe || self.frame == threeframe) { arbcode; };
//#define framenot_arb(thisframe,arbcode) if (self.frame != thisframe) { arbcode; };
//#define framenottwo_arb(thisframe,thatframe,arbcode) if (self.frame != thisframe && self.frame != thatframe) { arbcode; };

// arbcode will run on any frame in the list
// use -666 to negate a frame test with this							- you could use any sufficiently small negative number, just always use the same one

//#define frameset_arb(thisframe,twoframe,threeframe,fourframe,fiveframe,sixframe,arbcode) if (self.frame == thisframe || self.frame == twoframe || self.frame == threeframe || self.frame == fourframe || self.frame == fiveframe || self.frame == sixframe) { arbcode; };



// ******************************************************************************************************************

// local ent var storage

#include <incl/local_ent.qc>

// method will replace everything below used for local vars

// ******************************************************************************************************************

// re-used variable assignments
//			a few entity variables go unused, many more are under used
//			one main issue is when you decide to make a re-used a unique new variable
// 		advantage here - if we have a conflict, comment out the define and make a regular entity variable

// hints
// use a script like lsevar to find out where evars are used
// use "grep -C 3" or so to check individual lines of code


/// issues - make sure _NOTHING_ uses the replace text - NOTHING ! -- the precompiler will swap EVERY LAST INSTANCE of matching text
// note: the precompiler might have some logic smarts - {something}_b does not seem to swap if #define {something} aa
//				 these have been checked extensively but might break new code or old mod code - they will have to be carefully checked

// the most recent entity spawned in certain functions - we re-use newmis

#define nspawn newmis

// self.frags is used repeatedly for local defines - excepting players / bots
// self.oldenemy is used for local defines - doors & plats

// ent var sub - semi relable between thinks

#define a__		aflag

// ent var subs for generic floats - NOT a reliable store		-- ** same as matched below **
// always check sub var prior to each use

#define f__			bubble_count

// ent var sub for generic vectors - NOT a reliable store

#define v__			dest1
#define v___x		dest1_x
#define v___y		dest1_y
#define v___z		dest1_z

// set an ent var for local damage - ldmg
// dmg_take is only referenced once in combat.qc

#define ldmg_			dmg_take

// dog & demon jump velocity length test - vector length ONLY -- jump_vel assigned:

#define jump_vel		jump_flag

// various random choices ents make - ONLY reliable locally !
// can NOT ! use f__ and rnd_ together in the same code

#define rnd_		bubble_count

// spike type for spikes, superspikes, hell knight shot, wizard shot

#define spike_type		bubble_count

// some local vector spot1, spot2 replacements
//			*** CAN NEVER happen for ANY door called code, which use dest*

#define spot1_		dest1

#define spot1__x		dest1_x
#define spot1__y		dest1_y
#define spot1__z		dest1_z

#define spot2_		dest2

#define spot2__x		dest2_x
#define spot2__y		dest2_y
#define spot2__z		dest2_z

// ent var fn call sub

#define call__		blocked


















/*

	--- compile stats ---

016.1.11:

everything turned off			- there are no monsters, this is the most optimal sequence

 32744 strofs (of 1000000)
 10338 numstatements (of 524288)
   402 numfunctions (of 16384)
  1567 numglobaldefs (of 32768)
   214 numfielddefs (191 unique) (of 2048)
  1721 numpr_globals (of 65536)
Writing progs.dat
151184 TOTAL SIZE
Writing progs.lno
 50 unique precache_models
Compile Complete

optres_shortenifnots 112
optres_overlaptemps 5546
optres_constantarithmatic 33
optres_nonvec_parms 1515
optres_assignments 226
optres_unreferenced 10
numtemps 103
54 warnings


qc++ turned on		(from base)

 32744 strofs (of 1000000)
 10338 numstatements (of 524288)
   402 numfunctions (of 16384)
  1567 numglobaldefs (of 32768)
   214 numfielddefs (191 unique) (of 2048)
  1721 numpr_globals (of 65536)
Writing progs.dat
151184 TOTAL SIZE
Writing progs.lno
 50 unique precache_models
Compile Complete

optres_shortenifnots 112
optres_overlaptemps 5546
optres_constantarithmatic 33
optres_nonvec_parms 1515
optres_assignments 226
optres_unreferenced 10
numtemps 103
54 warnings


opgrade turned on		(from base)
- requires local_ent support

 29424 strofs (of 1000000)
 10237 numstatements (of 524288)
   398 numfunctions (of 16384)
  1547 numglobaldefs (of 32768)
   214 numfielddefs (191 unique) (of 2048)
  1692 numpr_globals (of 65536)
Writing progs.dat
146636 TOTAL SIZE
Writing progs.lno
 50 unique precache_models
Compile Complete

optres_shortenifnots 113
optres_overlaptemps 5573
optres_constantarithmatic 35
optres_nonvec_parms 1443
optres_assignments 228
optres_unreferenced 10
numtemps 92


xvars turned on		(from base)

 32820 strofs (of 1000000)
 10468 numstatements (of 524288)
   402 numfunctions (of 16384)
  1570 numglobaldefs (of 32768)
   214 numfielddefs (191 unique) (of 2048)
  1725 numpr_globals (of 65536)
Writing progs.dat
152340 TOTAL SIZE
Writing progs.lno
 50 unique precache_models
Compile Complete

optres_shortenifnots 112
optres_overlaptemps 5572
optres_constantarithmatic 33
optres_nonvec_parms 1545
optres_assignments 226
optres_unreferenced 10
numtemps 104
54 warnings



quake monsters turned on		(from base)

 44520 strofs (of 1000000)
 18655 numstatements (of 524288)
   628 numfunctions (of 16384)
  2125 numglobaldefs (of 32768)
   215 numfielddefs (192 unique) (of 2048)
  2372 numpr_globals (of 65536)
Writing progs.dat
244708 TOTAL SIZE
Writing progs.lno
 69 unique precache_models
Compile Complete

optres_shortenifnots 137
optres_overlaptemps 9876
optres_constantarithmatic 157
optres_nonvec_parms 3211
optres_assignments 285
optres_unreferenced 14
numtemps 151
75 warnings


frikbot turned on		(from base)
- requires local_ent support

 43108 strofs (of 1000000)
 17181 numstatements (of 524288)
   527 numfunctions (of 16384)
  2397 numglobaldefs (of 32768)
   275 numfielddefs (246 unique) (of 2048)
  2549 numpr_globals (of 65536)
Writing progs.dat
231232 TOTAL SIZE
Writing progs.lno
 50 unique precache_models
Compile Complete

optres_shortenifnots 187
optres_overlaptemps 9370
optres_constantarithmatic 38
optres_nonvec_parms 2228
optres_assignments 562
optres_unreferenced 14
numtemps 143
54 warnings


hipnotic turned on		(from base)
- requires local_ent support

 56724 strofs (of 1000000)
 24050 numstatements (of 524288)
   718 numfunctions (of 16384)
  2753 numglobaldefs (of 32768)
   272 numfielddefs (243 unique) (of 2048)
  3000 numpr_globals (of 65536)
Writing progs.dat
311304 TOTAL SIZE
Writing progs.lno
 65 unique precache_models
Compile Complete

optres_shortenifnots 217
optres_overlaptemps 14182
optres_constantarithmatic 98
optres_nonvec_parms 3339
optres_assignments 595
optres_unreferenced 35
numtemps 193
70 warnings


most stuff - no bots, no map_hack

 62100 strofs (of 1000000)
 32439 numstatements (of 524288)
   944 numfunctions (of 16384)
  3213 numglobaldefs (of 32768)
   273 numfielddefs (244 unique) (of 2048)
  3526 numpr_globals (of 65536)
Writing progs.dat
397720 TOTAL SIZE
Writing progs.lno
 84 unique precache_models
Compile Complete

optres_shortenifnots 244
optres_overlaptemps 18623
optres_constantarithmatic 228
optres_nonvec_parms 4955
optres_assignments 654
optres_unreferenced 37
numtemps 218
86 warnings


qc++ everything to date		- 016.1.11

 80964 strofs (of 1000000)
 46717 numstatements (of 524288)
  1215 numfunctions (of 16384)
  4489 numglobaldefs (of 32768)
   379 numfielddefs (343 unique) (of 2048)
  4857 numpr_globals (of 65536)
Writing progs.dat
556944 TOTAL SIZE
Writing progs.lno
 93 unique precache_models
Compile Complete

optres_shortenifnots 345
optres_overlaptemps 26522
optres_constantarithmatic 293
optres_nonvec_parms 6994
optres_assignments 1140
optres_unreferenced 48
numtemps 300
96 warnings


viswep		- 016.1.14			(from below)

 59268 strofs (of 1000000)
 30650 numstatements (of 524288)
   802 numfunctions (of 16384)
  3543 numglobaldefs (of 32768)
   341 numfielddefs (310 unique) (of 2048)
  4381 numpr_globals (of 65536)
Writing progs.dat
382068 TOTAL SIZE
Writing progs.lno
 71 unique precache_models
Compile Complete

optres_shortenifnots 246
optres_overlaptemps 16401
optres_constantarithmatic 191
optres_nonvec_parms 4474
optres_assignments 747
optres_unreferenced 23
numtemps 209
71 warnings

-----------------------------------------------------
 54764 strofs (of 1000000)
 28596 numstatements (of 524288)
   785 numfunctions (of 16384)
  3125 numglobaldefs (of 32768)
   329 numfielddefs (298 unique) (of 2048)
  3405 numpr_globals (of 65536)
Writing progs.dat
353176 TOTAL SIZE
Writing progs.lno
 69 unique precache_models
Compile Complete

optres_shortenifnots 226
optres_overlaptemps 15531
optres_constantarithmatic 164
optres_nonvec_parms 4373
optres_assignments 719
optres_unreferenced 21
numtemps 205
69 warnings
-----------------------------------------------------



v106.0		(original release)

 88540 strofs (of 1000000)
 20507 numstatements (of 524288)
  2091 numfunctions (of 16384)
  4290 numglobaldefs (of 32768)
   218 numfielddefs (195 unique) (of 2048)
  4327 numpr_globals (of 65536)
Writing ../progs.dat
381432 TOTAL SIZE
Writing ../progs.lno
225 unique precache_sounds
 95 unique precache_models
104 unique precache_files
Compile Complete

optres_shortenifnots 115
optres_overlaptemps 7237
optres_constantarithmatic 17
optres_nonvec_parms 3898
optres_assignments 408
optres_unreferenced 68
optres_dupconstdefs 101
numtemps 117
13 warnings


archon 1.2 beta

359556 strofs (of 1000000)
171474 numstatements (of 524288)
  5329 numfunctions (of 16384)
 17817 numglobaldefs (of 32768)
   580 numfielddefs (538 unique) (of 2048)
 18897 numpr_globals (of 65536)
Writing progs.dat
2146144 TOTAL SIZE
Writing progs.lno
645 unique precache_sounds
569 unique precache_models
104 unique precache_files
Compile Complete

optres_shortenifnots 1523
optres_overlaptemps 80088
optres_constantarithmatic 912
optres_nonvec_parms 23889
optres_assignments 4763
optres_unreferenced 74
optres_dupconstdefs 160
numtemps 811
233 warnings

*/