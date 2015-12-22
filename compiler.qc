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
		using the defines below to control what is compiled in.

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
// and non have been assigned as yet
//#define message_warn

// define parms to show include files on compile

// indicate everytime include happens, even if compile doesnt
#define id_include_always

// only indicate when included code is compiled
//#define id_include


#ifdef message_top
#message         			-- version 1.07 qc++ quake-c -- compile with fteqcc 
#endifdef

#ifdef message_all
#message         			-- (c) 1996 iD software, (c) 2014 Number Six 
#message         			-- GPL - see license.txt for rights and details 
#message          
#endifdef

// this is 50 bytes shorter
#pragma COPYRIGHT (c) 1.06 iD 1996, 1.07 Six 2014

// more detail - takes more bytes
//#pragma COPYRIGHT v1.06 iD (c)1996 v1.07 Number Six (c)2014 -GPL- www.moddb.com/groups/qc




//#define qcvers

// takes up a global var (and string space), but gives the progs.dat code a qc version in the console		- requires localcmd(vers); somewhere in code

#ifdef qcvers
// if this alias is set, when you type "version" in the console it will respond with the string
// with darkplaces this will display the darkplaces version first then this string
// requires an addtional instruciton thus:
//		localcmd(vers);
// to be run once somewhere in worldspawn()

string vers						= "alias version \"echo quake-c: 1.0.7 qc++\"\n";

// this is better off being placed in a config file - for instance default.cfg like so:
// alias version "echo quake-c: 1.0.7 qc++"
#endifdef

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

#define qc++

#ifdef qc++
	#ifdef message_all
	#message         			-- compile: qc++ v1.07 included 
	#endifdef
#endifdef


/*
	an operation upgrade to vanilla qc 1.06

*/

	// 11.23.14
	// fx_warning
	// - some vars commented out to fix this compiler warning:
	//    defs.qc:401: warning: empty_float  no references



// ******************************************************************************************************************

// quake one operation upgrade

#define opgrade
/// opgrade turned ON



// do all the opgrade sub-items
#ifdef opgrade

	#ifdef message_all
	#message         			-- compile: operation upgrade v1.07 included 
	#endifdef

//	part of opgrade - fix some q1 code issues - many also fix compiler warnings
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

#define noautoaim



// instead of a regular function
// this saves a function def and a global def at the expense of more statements
// this is really an esthetic choice as both methods do the same thing op wise

#define crandom() 2*(random() - 0.5)

// quake 1 optioned sections
/// NOTE: if these are enabled standard singleplayer may be broken!

// if you want to remove rune controlled gate code
//#define no_bossgate
//#define no_epgate

// end of opgrade subs



#else
/// opgrade turned OFF


// if we turn off opgrade and qc++ we have (mostly) v106 behavior in the base code
// in theory anyway
#ifndef qc++

	#ifdef message_all
	#message         			-- compile: quake-c v1.06 behavior 
	#endifdef


// compile in un-used code sections
// these are bits of quake-c that are:
//		- vars never referenced - not even in the engine
//		- code that serves no purpose
#define unused


// end not using qc++
#endifdef


// end of opgrade not used
#endifdef



// ******************************************************************************************************************

// some code is pointless, but removing it creates warnings			- mostly these are return FALSE; };
// comment this out to remove the pointless code, the following bit removes the warnings!
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
#define noobjerr

#ifdef noobjerr
	#ifdef message_all
	#message         			-- compile: objerror() and error() statements removed 
	#endifdef
#endifdef


// ******************************************************************************************************************


// include all debug / warning code - uncomment this define to use
// this includes _cheat_ impulses
// includes special map spawns

/// all code wrapped with #ifdef debug MUST be deleted from live server / release code !

//#define debug

#ifdef debug
//#message         			-- compile: debug code, warnings and options included 

// optional warning code display system
//#define warning

#else
// remove all dprints - they use globals --- comment this #define out to compile dprint code, also you must set the developer cvar to have them print to console
/// remove dprint segments for final or gold release
#define nodprint

#endifdef


// dev warning system - uncomment to use independent of debug code - should be removed from gold / release code

#define warning

/*
warning ideas

print fn entries
track global vars
track ent vars
track local vars on entry / exit?
spec track by cvar

*/

#ifdef warning

	#ifdef message_all
	#message         			-- compile: warning system active 
	#endifdef

	float WARNING;

#endifdef


// local testing - so we dont have to turn on all the debug code - but we can remove all test code for a run

/// all code wrapped with #ifdef local_test SHOULD be deleted from live server / release code !

#define local_test

// we always tell if local test or debug are compiled in

	#ifdef local_test
	#message         			-- compile: local test code activated *** 
	#endifdef

void()	frd1;

// ******************************************************************************************************************


/// non-darkplaces compile

// this is just a placeholder for certain bits of code that will only be optional in early releases
// uncomment the next line and certain darkplaces only code will not be compiled
//#define nondp

#ifdef nondp

	#ifdef message_all
	#message         			-- compile: darkplaces __not__ required - runs on any engine (in theory) 
	#endifdef

#endifdef

/// remove the above section for dp only releases

// the darkplaces compile saves some resources

// ******************************************************************************************************************


// extra server cvars
// most should take the form "svx_{varname}"
// at this time these have limited effect

// note: these use up global vars and are designed to operate in a 3 (or 4) tiered system
//				 level 0 is the only level really necessary if server ops are agreeable with developer selected defaults

//#define xvars

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

	#ifdef message_all
	#message         			-- compile: xvars total (level 0 - 3) control package 
	#endifdef

#else

// high priority - still want these
#define xvars0

	#ifdef message_all
	#message         			-- compile: xvars level 0 control package 
	#endifdef


#endifdef


// ******************************************************************************************************************

// possible options - permanent compile in
// these should ifndef on xvars*

//#define glowcorpse // dead with quad glows


// ******************************************************************************************************************

/// mod section - should be of interest to mod coders

// quake one - you can exclude various modules here

// this is for the sequencing of maps - the end of episode and finale texts
// these take up a bit of space (~3700 bytes), and if your mod does not require playing through q1 (such as DM mods), you might not want them
// if you comment this out - a GotoNextMap() will be called instead of displaying the end text

//#define q_mapseq



// mission pack 1
// NOTE: you need the media files and models to load maps or have entities using this code operate as intended
//					default behavior with HIPNOTIC turned OFF will replace ents with missing models, deactivate some freatures - etc

#define HIPNOTIC

// control file

#include <hipnotic/hip_control.qc>


// ******************************************************************************************************************

// mission pack 2
// NOTE: you need the media files and models to load maps or have entities using this code operate as intended
#define code_rogue


// ******************************************************************************************************************

// use pk bots
#define code_pkbots


// ******************************************************************************************************************

// use frik bots
#define code_frikbots


// ******************************************************************************************************************

// rune server
#define code_runes


// ******************************************************************************************************************

// quake monsters

// note: removing map monsters makes the attempt to allow all single player maps to be completed.  Say if you are playing with a random monster maker.
//				this references maps that have a trigger on a monster the causes some map action, such as a door to open

#define quakemonsters

// ******************************************************************************************************************

// extra monsters

//#define xmonsters

// ******************************************************************************************************************

// maphack system

#define map_hack


// ******************************************************************************************************************

// new code that... well, has issues
// it might be cool to run this code, but it just doesnt work quite right
// all code in this wrapper SHOULD be removed for release

// 1. quake 1 standard end of episode win text -- currently text is ignored, or displayed in infobar

// uncomment this to compile code that has issues
//#define has_issues

// ******************************************************************************************************************

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
