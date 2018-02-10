/* ::-::
 *
 * Cataboligne
 *
 * file: monster_defs.qc 
 *
 * date: 017.1.11
 *
 * qc - monsters module - defines
 *
 */

// enhanced monster section

// using this no matter what
#define	jumpdmg  									dodmg

#ifdef monsters_plus__

// archon monster speed module - some monsters move differently

#define mon_speed
#ifdef mon_speed
// speed divsors:
//		< 1 - slow down
//		> 1 - speed up


// speed contants for monsters
// slowing down too much or speeding up too much looks "funny" (admittedly chaotic tho), try to say in limits

#define	MON_NORM		0.1 // base think speed for animation frames
#define	MON_FAST		0.07 // 1.429 times faster
#define	MON_SLOW		0.16 // 0.625 times slower
// divisor - divide monsters speed up by this value --- > 1 slows monsters, < 1 speeds up monsters
// shoot poison potions to slow monsters down
// note: this is a global effect that happens to all .speed controled monsters - .lip is an individual monster speed divisor
//float MON_SPEED_DIV;
#define	MON_SPEED_DIV		1
#define	speed_div		lip

// super monsters have a chance to speed up on thier own during pain frames
#define mon_superspeed_chn 0.05 // chance per pain frame a super monster will speed up
#define mon_superspeed_fact 0.001 // speed up factor per instance
#define mon_superspeedup_max 0.085 // 1.176 times faster - max super monsters can speed up

#endifdef


// Monsters can summon minions!

void(string ms) SummonMonster;

#define SV_SETMINE 0.15 // chance to summon a spike mine
#define SV_CKTIME 15 // how frequently we check - 15 rels
#define SV_MINELIM 3 // max mines one monster can make

// supervore = 65536
// super 3x scrag = 1024
// death knight = 64
#define SV_MINEALLOW 66624 // allow monsters to set mines by bitmask


// assigned monster bit codes used by vars sections		- use mask_x

#define CB_M_ARMY						1
#define CB_M_FISH							2
#define CB_M_KNIGHT					4
#define CB_M_DOG							8
#define CB_M_DEMON					16
#define CB_M_ENF							32
#define CB_M_HKNIGHT				64
#define CB_M_OGRE						128
#define CB_M_SHALR						256 // + super vore ?
#define CB_M_SHAMBL					512
#define CB_M_SCRAG					1024
#define CB_M_ZOMBY					2048
#define CB_M_CTHON					4096 // boss
#define CB_M_TARBABY				8192
#define CB_M_SCOURGE				16384
#define CB_M_SHUBS					32768
#define CB_M_SVORE						65536 // super vore

#define CB_M_SCOURGE				16384
#define CB_M_GREMLIN				131072
#define CB_M_VOMIT						262144 // guy id left out

#define CB_M_SPIKEMINE				524288	// Hipnotic spiked mine
//#define CB_M_					1048576
//#define CB_M_					2097152
//#define CB_M_					4194304
//#define CB_M_					8388608

#define CB_M_BLARG						1
#define CB_M_RAPTOR					2
#define CB_M_SPIDER					4	// first 3 featured in ultimate mod
#define CB_M_MANGA					8
#define CB_M_BOSSMAN				16 // Bossman by Wendigo - from Blahbalicious
#define CB_M_CLING						32 // alien infestation by Lord Havoc
#define CB_M_HEXIMP					64	// Hexen2 Imp by Claus Kruuskopf AKA WiCKeD

/* special - will use something else
// extras used by morph mod - these are not coded as monsters yet
#define CB_M_IMP							2097152
#define CB_M_ARACHN					4194304
#define CB_M_CYBER						8388608

#define CB_M_GUNNEY					64
#define CB_M_SUPTANK				128
#define CB_M_TANK						256
*/


// monster enhancements - allow upgrade flags

#define	MFL_ENHANCE			1048576			// allow individual monsters spawn & ops code to activate enhanced monster elements
#define	MFL_ENSUPER				524288			// allow monster spawn & ops code to use SUPER & SUPER_XMAD monsters

// bigger monsters - see scale list
#define	MFL_SXMAD					8192			// super extra mad monster
#define	MFL_SUPER					4096			// super monster
#define	MFL_BSUP						12288		// both super flags

// possible enhance flags - if any are set, rnd enhance wont happen

#define	MFL_ANYLOW				12526			// enhanced monster low bits  -- 16 is excluded since hip / rogue used it on some for spawn silent



/*
// super monster scale
													super ogre model		- '1.6 1.6 1.2'
													super ogre XMAD		- '1.9 1.9 1.4'		- in death frames '2.0 2.0 1.5'
													super demon model	- '1.5 1.5 1.5'
													super demon XMAD	- '1.9 1.9 1.9'
													3 head dog model		- '1.5 1.5 1.5'
													baby scorg model		- '0.23 0.23 0.23'
													mini scorg model		- '0.45 0.45 0.45'
													super scorg model		- '2 2 2'
													super scorg XMAD		- '3 3 3'
													super scorg Ultra		- '6 6 6'
													large scrag model		- '1.75 1.75 1.75'
													super scrag model		- '2 2 2'
													vorizel model				- '1.5 1.5 1.4'
*/



#define	gibdmg  										dmg_save
#define	meleedmg									orbitPosition

// time signal for super ops like self healing
#define	sup_time									invisible_time
#define	mon_add_flags						self.pk_turretammo
// these are individual to each monster
#define mon_enh_mask						self.pkplus_phoneammo


#ifdef code_painkeep_
	// if pk is in, monsters will never use these - note .cfg adjust as detailed
	// tests of worked:
	//						set		mon_super_scale 	pkplus_actorammo
	//						set		__monster_ogre_$mon_super_scale		1.6

// stats for super monsters - these should load from cfg
#define	mon_enh_chance					self.pk_gravitywellammo
#define	mon_super_scale					self.pkplus_actorammo
#define	mon_xmad_scale					self.pkplus_actortype
#define	mon_super_chance 				self.pk_beartrapammo
#define	mon_xmad_chance 				self.pk_explode_ammo
#define	mon_super_emheal_chn 	self.pk_canpabammo
#define	mon_super_heal  					self.pkplus_egoammo
#define	mon_xmad_heal  					self.pkplus_tombammo


#else
// must use these or code breaks
.float		pk_turretammo;
.float		pkplus_phoneammo;
.float		orbitPosition;
// if no pk module, these are hard now coded
#define	mon_enh_chance			0.2			// chance to enhance a monster - requires mon_enh_mask !
#define	mon_super_scale			1.5			// scale up a SUPER monster
#define	mon_xmad_scale			2				// scale up extra mad even more
#define	mon_super_chance		0.04			// chance a spawning monster can go SUPER
#define	mon_xmad_chance		0.15			// chance a monster in pain can go SUPER EXTRA MAD
#define	mon_super_emheal_chn 0.4	// chance to heal
#define	mon_super_heal 			40 			// how much a super could heal in a pain frame
#define	mon_xmad_heal		80 			// how much a super thats extra mad could heal in a pain frame
#endifdef

// move this ?
#define FL_DEMONBOOM				65536 // demon on overload!

#endifdef


#ifdef quakemonsters

	#ifdef message_top
	#messagecompiling monster_x/monster_defs.qc 
//	#message         			-- compile: monster defs 
	#define mdef_hdr
	#endifdef

#endifdef

#ifdef xmonsters

	#ifdef message_top
	#ifndef mdef_hdr
	#messagecompiling monster_x/monster_defs.qc 
	#endifdef
	#endifdef

#endifdef
