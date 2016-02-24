/* ::-::
 *
 * Cataboligne
 *
 * file: x_monsters.qc
 *
 * date: 2.5.15
 *
 * qc - extra monsters module
 *
 */
 
 
// controlled by compiler.qc defines
// can extend control to individual monsters
// files called here should #message         compiling {filename.qc} to indicate compile
//
// ****************************************************************************


#ifdef xmonsters

	#ifdef message_top
	#message         			-- compile: extra monsters 
	#endifdef

// let random monster code know which modules are compiled in so they can be used
// note: these must be set to proper bit as indicated in included .qc files

// bits:		1		2		4		8		16		32		64		128		256

#define INCL_VOMITUS			0
#define INCL_BOSSMAN			0
#define INCL_SPIDER				0
#define INCL_RAPTOR				0
#define INCL_MANGA				0
#define INCL_BLARG				0
#define INCL_HEXIMP				0
#define INCL_YOUNG				0
#define INCL_CLINGER			0

// random extra monster code will have to:
// X_MONSTER_MASK = cvar("svx_x_monster") & (INCL_VOMITUS | INCL_BOSSMAN);

// this will <and> the server admin choices with the compile modules, a zero result indicating rnd monster shutdown

// ****************************************************************************

// compile code

#include </vomitus.qc>
#include </bossman.qc>
#include </spider.qc>
#include </raptor.qc>
#include </manga.qc>
#include </blarg.qc>
#include </heximp.qc>
//#include </scourge.qc>

#else

//#message         			-- exclude: extra monsters NOT compiled 

/*
//	make code live if these are ever used as targeted map monsters and module is not compiled in


void() monster_vomit =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_bossman =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_spider =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_raptor =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_manga =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_blarg =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

void() monster_heximp =
{
	self.think = remove_monster;
	self.nextthink = time + 2 + (random() * REMOVE_MON_SPREAD);
};

*/

#endifdef

