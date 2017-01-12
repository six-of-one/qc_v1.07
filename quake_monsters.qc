/* ::-::
 *
 * Cataboligne
 *
 * file: quake_monsters.qc
 *
 * date: 3.8.15
 *
 * qc - quake monsters module
 *
 */

// allow exclusion of quake one standard monsters
// controlled by compiler.qc defines
// can extend control to individual monsters
// files called here should #message         compiling {filename.qc} to indicate compile
//
// ****************************************************************************

// see speed module in quake_monsters.qc

#ifdef quakemonsters

	#ifdef message_top
	#message         			-- compile: quake monsters 
	#endifdef

// let random monster code know which modules are compiled in so they can be used
// bits:		1		2		4		8		16		32		64		128		256		512		1024			2048			4096

#define INCL_OGRE				1
#define INCL_DEMON			2
#define INCL_SHAMBLER	4
#define INCL_KNIGHT			8
#define INCL_SOLDIER		16
#define INCL_WIZARD		32
#define INCL_DOG					64
#define INCL_ZOMBY			128
// exclude boss - cthon as random monster
#define INCL_SPAWN			256
#define INCL_HKNIGHT		512
#define INCL_FISH					1024
#define INCL_SHALRATH	2048
#define INCL_ENFORCER	4096
// exclude shubs as random monster

// compile code

#messagecompiling ogre.qc 
#include <ogre.qc>

#messagecompiling demon.qc 
#include <demon.qc>

#messagecompiling shambler.qc 
#include <shambler.qc>

#messagecompiling knight.qc 
#include <knight.qc>

#messagecompiling soldier.qc 
#include <soldier.qc>

#messagecompiling wizard.qc 
#include <wizard.qc>

#messagecompiling dog.qc 
#include <dog.qc>

#messagecompiling zombie.qc 
#include <zombie.qc>

#messagecompiling boss.qc 
#include <boss.qc>

#messagecompiling tarbaby.qc 
#include <tarbaby.qc>

#messagecompiling hknight.qc 
#include <hknight.qc>

#messagecompiling fish.qc 
#include <fish.qc>

#messagecompiling shalrath.qc 
#include <shalrath.qc>

#messagecompiling enforcer.qc 
#include <enforcer.qc>

#messagecompiling oldone.qc 
#include <oldone.qc>

#else

	#ifdef message_top
	#message         			-- exclude: quake monsters NOT compiled 
	#endifdef

// quake monsters removed - clear random monster settings

#define INCL_OGRE				0
#define INCL_DEMON			0
#define INCL_SHAMBLER	0
#define INCL_KNIGHT			0
#define INCL_SOLDIER		0
#define INCL_WIZARD		0
#define INCL_DOG					0
#define INCL_ZOMBY			0
// exclude boss - cthon as random monster
#define INCL_SPAWN			0
#define INCL_HKNIGHT		0
#define INCL_FISH					0
#define INCL_SHALRATH	0
#define INCL_ENFORCER	0
// exclude shubs as random monster

// for lasers - has separate ifdef that only allows laser code to compile

#include <enforcer.qc>

// NOTE - removing monsters module breaks a number is single player quake 1 maps
// think to fire all monster targets with dummy spawns

// test with "map e1m7" - the kill cthon barrier will be removed in the random time interval

#define REMOVE_MON_SPREAD 5

void() remove_monster;

void() monster_boss =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_demon1 =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_dog =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_enforcer =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_fish =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_hell_knight =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_knight =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_ogre =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_oldone =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_shalrath =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_shambler =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_army =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_tarbaby =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_wizard =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_zombie =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

	#ifndef hip_monsters
void() monster_scourge =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};
	#endifdef



#endifdef

