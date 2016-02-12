/* ::-::
 *
 * Cataboligne
 *
 * file: local_ent.qc
 *
 * date: 5.12.15
 *
 * qc - local entity module
 *
 */

#ifdef id_include_always
#messageinclude   incl/local_ent.qc 
#endifdef

#ifndef use_local_ent

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/local_ent.qc 
	#endifdef
	#endifdef

#define use_local_ent

// use a spawned entity for local var storage in a function
// seq was chosen so that if locus cleared to world, nothing significant would be reset

entity locus;

// the goal is to have an easy replacement for local declaration that do NOT use global spots -
// 		local float lvar;
// becomes -
//			#define lvar f0__

// then uses the entity local.button0 to store / use the data

// pre selected float - selected for minimal use, just in case

#define		f0__		locus.button0
#define		f1__		locus.button1
#define		f2__		locus.button2
#define		f3__		locus.t_length
#define		f4__		locus.t_width
#define		f5__		locus.bubble_count
#define		f6__		locus.frags
#define		f7__		locus.dmg_take
#define		f8__		locus.dmg_save
#define		f9__		locus.skin

// pre selected vector

#define		v0__		locus.dest1
#define		v1__		locus.dest2
#define		v2__		locus.pos1
#define		v3__		locus.pos2
#define		v4__		locus.finaldest
#define		v5__		locus.finalangle
#define		v6__		locus.mins
#define		v7__		locus.maxs
#define		v8__		locus.absmin
#define		v9__		locus.absmax

// this is the only way to do these
// if remapped it requires additional defines in the var setup to work -
// #define 	org_x 	v0___x

#define		v0___x		locus.dest1_x
#define		v0___y		locus.dest1_y
#define		v0___z		locus.dest1_z

#define		v1___x		locus.dest2_x
#define		v1___y		locus.dest2_y
#define		v1___z		locus.dest2_z

#define		v2___x		locus.pos1_x
#define		v2___y		locus.pos1_y
#define		v2___z		locus.pos1_z

#define		v3___x		locus.pos2_x
#define		v3___y		locus.pos2_y
#define		v3___z		locus.pos2_z

// pre selected string

#define		s0__		locus.noise
#define		s1__		locus.noise1
#define		s2__		locus.noise2
#define		s3__		locus.noise3
#define		s4__		locus.noise4
#define		s5__		locus.wad
#define		s6__		locus.deathtype
#define		s7__		locus.group
#define		s8__		locus.message
#define		s9__		locus.netname

// pre selected entity

#define		e0__		locus.owner
#define		e1__		locus.enemy
#define		e2__		locus.oldenemy
#define		e3__		locus.aiment
#define		e4__		locus.goalentity
#define		e5__		locus.groundentity
#define		e6__		locus.trigger_field
#define		e7__		locus.movetarget
#define		e8__		locus.dmg_inflictor

// TESTING

	#ifdef local_test

	#define pp1 bprint("          *** locus - nesting warning in: ")
	#define pp2 bprint("  h:  "); bprint(ftos(system_hash)); bprint("  ***\n")
	#define pp3 bprint("          *** locus - made: ")
	#define pp4 bprint("          *** locus - derezed: ")
	#define u__ "use"
	#define cl__ "clear"
	#define lcn__ "class_locus"

// TESTING monsters - put test print back
#define local_ent() remove(locus); locus = spawn();
#define local_ent_exit()

//#define local_ent(leid) if (locus.netname == u__) {pp1; bprint(#leid); pp2;} else remove(locus); locus = spawn(); locus.netname = u__; locus.classname = lcn__; locus.map = #leid; syh; locus.lefty = system_hash; pp3; bprint(#leid); pp2;
//#define local_ent_exit(leeid) locus.netname = cl__; pp4; bprint(#leeid); pp2;

// NORMAL

	#else

#define local_ent() remove(locus); locus = spawn();
#define local_ent_exit()

	#endifdef

// was put here because of use in test code above
#define syh  system_hash = system_hash + 1 + rint(random() * 2); 


// self removing - for cases unknown
// originally for cases where the exit might not remove locus - now done differently
// might still be used for nests
#define local_ent_sr() locus = spawn(); locus.think = SUB_Remove; locus.nextthink = time + 0.01;

#endifdef

