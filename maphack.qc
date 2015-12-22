/* ::-::
 *
 * Cataboligne
 *
 * file: maphack.qc
 *
 * date: 3.19.15
 *
 * qc - quake hack module
 *
 */
 
 // quake hack section - quake is now a roguelike !
 ///												yes gracie, this is a thing

/*

IDEA:

use file ops (darkplaces) to read hack section of map chunks, and eliminate copy codes below


OPLST:

hack notes:

8.19.14:

origin probs while dead ?

pond / river
music / sound areas -- trigger an ent - start music, raise vol, trigger resets think, think expires - lower vol, music off


 - gets dark inside bldgs (rains in them too)

- target_speaker fails copy (doesnt make sound anyway)


IDEA: rescue - if a player is stuck for X minutes (2 or 3) a rescue impulse will take them to the last set rescue point
- start spawn 1st time, nearest deathmatch spawn to last rescue op
- range is radius of 1.4 * biome lefty value
- blocked in boss fight areas

- only thing for plats now is 4x - and make a rotate angle_y test for copy
  (maybe same for doors!)



imp: chains of map_hacks in storage could implement as features - lava pools, hallway mazes, ponds, rivers, etc
-- is this a map thing, or does code need to be done? (think its just a map thing - the code is done)

fix: delete hack does not remove all buttons and doors
- nor does hide hack hide them
- does not hide non-solid (torch copy models)
 *** warning:   hack hiding ent: maphack_trigger

 *** warning:   hack hiding ent: Archon Altar --- could be a bit of a prob
(so then runes & altars, etc should relo if in a hiding hack)

firing explode shot at far away hack
SV_PushMove: entity #3521 has an invalid modelindex 0.000000
SV_PushMove: entity #3525 has an invalid modelindex 0.000000
(unending - dropped on space overflow)

*/

#ifndef map_hack

// module not used

	#eof

#endifdef



#define refire_time	invisible_time

// dp stuff we used

#include <incl/use_copyentity.qc>

.float alpha;

#include <incl/use_vtos.qc>

// borrowed from other code

#define  MAXFL                                               16777215

float noway_above; // no worky w/o more code
float noway_below;

.float msgcount;
.float rotate_type;
.float mean, stdev;
.float tomb_time, tomb_death_time;
.string group;
.string target1, target2;
.string class_select;
.vector movement;
.vector ip_orgOrigin;
.entity dropent;
.float modelindex_morph;
.string event;
.float volume;
.float mcode;


// may conflict with ifdefs

.vector dest;

// needs changed

void() SUB_Nop =
{
	return;
};

entity(float mvt, float sd, float flg, float ct, vector org, vector smin, vector smax, vector an, vector vel, string cname, string md, void() tch, float tht, void() thk, void() thd, entity ow, entity reset) chaos_spawn =
{
	local entity chaos_e;

	chaos_e = reset;
	if (chaos_e == world) chaos_e = spawn ();
#ifdef warning
	else 
		if (WARNING & 1) {bprint("chaos_spawn() resetting: "); bprint(chaos_e.classname); bprint("\n"); }
#endifdef
	if (chaos_e == world) // failed to spawn, call fn still needs to check if live ent
		{
#ifdef warning
		if (WARNING & 1) bprint("chaos_spawn() - ERROR: spawn() failed, returned world!\n");
#endifdef
		return(world);
		}

// init basic stuff
//	if (master_owner)	chaos_e.owner = master_owner;
//	else 
	chaos_e.owner = ow;
	chaos_e.classname = cname;
	chaos_e.movetype = mvt;
	chaos_e.solid = sd;
	chaos_e.flags = flg;
	chaos_e.angles = an;
	chaos_e.velocity = vel;

//	chaos_e._killmsg = chaos_e._killmsg2 = chaos_e.grab_callback = 
	chaos_e.th_stand = chaos_e.th_die = 
	chaos_e.th_walk = chaos_e.th_melee = /* chaos_e.upgrade_fn = */ chaos_e.touch = SUB_Null;

	if (tch != SUB_Null) chaos_e.touch = tch;
	if (thd != SUB_Null) chaos_e.th_die = /* chaos_e.th_stand = */ thd; // gen think & content chk

// clear all thoughts when we spawn - keep us out of trouble when we do weird stuff
//			this is mostly where the engine calls one of these - like with monster ai

	chaos_e.th_pain = SUB_Null;
	chaos_e.th_die = SUB_Null;
	chaos_e.th_melee = SUB_Null;
	chaos_e.th_missile = SUB_Null;
	chaos_e.th_run = SUB_Null;
	chaos_e.th_stand = SUB_Null;
	chaos_e.th_walk = SUB_Null;

	if (thk != SUB_Null) // if we need to think
	{
//		chaos_e._stand = 
		chaos_e.think = thk;
		chaos_e.nextthink = time + tht;
	}

//	if (ct) content_cycle(chaos_e, ct, CONTENT_CHKTM);

//	if (org != '0 0 0') // removed 015.12.3 - causing maphack bugs
	setorigin (chaos_e, org);
//	else setorigin (chaos_e, self.origin); - need to check against pk_bot_qc single reset instance
	setmodel (chaos_e, md);
	setsize (chaos_e, smin, smax);

	return(chaos_e);
};



float(entity hent, string match, string srch) cnt_ent =
{
	local float rc;
	local entity sr, ch;

	sr = world;
	ch = hent;
	rc = 0;
	while (1)
	{
			if (match == "classname") sr = find (sr, classname, srch);
//			else if (match == "netname") sr = find (sr, netname, srch);
//			else if (match == "map") sr = find (sr, map, srch);
			else if (match == "target") sr = find (sr, target, srch);
			else if (match == "targetname") sr = find (sr, targetname, srch);
/*
			else if (match == "weaponmodel") sr = find (sr, weaponmodel, srch);
			else if (match == "deathtype") sr = find (sr, deathtype, srch);
			else if (match == "class_select") sr = find (sr, class_select, srch);
//			else if (match == "quakeset") sr = find (sr, quakeset, srch);
//			else if (match == "scode") sr = find (sr, scode, srch);
			else if (match == "owner")
			{
				sr = find (sr, classname, srch);
				if (sr.owner == self) rc = rc + 1;
			}
			else
			rc = rc + 1;
*/	
			if (!sr) return(rc);

			rc = rc + 1;

// loop safety - max of 32768 ents
			if (rc > 32768)
			{
				hent.chain = world;
				return(0);
			}
			if (hent)
			{
				ch.chain = sr;
				ch = sr;
				ch.chain = world; // remove other potential chains left around - not even sure if this can happen
			}
	}

};

// give best ident of an item possible

string(entity e) item_ident =
{
	local string f;

	f = "item has no identity!";
	if (e.netname != string_null) f = e.netname;
	else if (e.classname != string_null) f = e.classname;
	else if (e.class_select != string_null) f = e.class_select;

	return(f);
};



void() func_model_frames =
{
	if (self.state)
	{
		self.frame = self.frame + 1;
		if (self.frame > self.state) self.frame = self.count;
	}

	if (self.dmg)
	{
		if (self.aflag)
		{
			self.skin = self.skin + 1;
			if (self.skin > self.dmg) self.skin = self.cnt;
		}
		if (self.lip)
		{
			self.skin = self.skin + self.lip;
			if (self.lip > 0)
			if (self.skin == self.dmg) self.lip = -1;
			if (self.lip < 0)
			if (self.skin == self.cnt) self.lip = 1;
		}
	}
	self.nextthink = time + self.delay;
};

// used for various effects (8 ray star & visage level decor)
// map hack uses this for torches & flames that normally go static

void() func_model =
{
	if (self.model)
	{
		self.mdl = self.model;
		if (time < 2) precache_model (self.mdl);
		setmodel (self,self.mdl);
	}

// set these only if they are set - otherwise use defaults
	if (self.count) self.frame = self.count;
	if (self.cnt) self.skin = self.cnt;

	self.lip = self.aflag = 0;
	if (self.dmg)
	if (self.dmg < 0) self.lip = 1; // reversable loop
	else self.aflag = 1; // regular loop
	self.dmg = fabs(self.dmg);

	if (self.state || self.dmg)
	{
		if (self.delay <= 0) self.delay = 0.1;
		self.think = func_model_frames;
		self.nextthink = time + self.delay;
	}
// if mapper didnt say it can move...it cant
	if (self.map != "move") self.map = "nonmove";

// note "copystatic" - make static when copied as a template - originals must remane non static for copy data
// and this fails

	if (self.wad == "static") makestatic(self); // gone from live ents - note: archon map tech may have changeable terrain
};


void() random_monster_wakey =
{
	local entity f;

// no matter what, this goes away after 1 use
	self.think = SUB_Remove;
	self.nextthink = time + 2;

	if (!self.owner) return;

// already killed - hope th_die got called, or he will be framestuck till random removes him
	if (self.owner.health < 1) return;

/*
	- deprecating, caused problems with spawn / tarbaby
	- random code below will remove them anyway
		||
		(self.owner.health < 1) || // got killed - likely a monsta_frag --- note: chaos vector
//		(self.owner.think == (void ()) 0))
		(!self.owner.think))
	{
		self.owner.think = SUB_Remove;
		self.owner.nextthink = time + 15 + random() * 2;
		return;
	}
*/

// note: the lead in code that sets this condition now does not happen...
	if (self.owner.think == SUB_Remove) return; // some failure is removing the monster

// could be a biome monster - try a drop
	if (self.owner.wad == "drop")
	{
		f = self;
		self = self.owner;
		droptofloor();
		self = f;
	}

//	self.owner.think(); // attempt to *_start_go
	self.owner.nextthink = time; // attempt to think with *_start_go

// have had some non solid monsters from cubes - 11.19.12
	if (!self.owner.solid) self.owner.solid = SOLID_SLIDEBOX;

	if (!self.owner.takedamage) self.owner.takedamage = DAMAGE_AIM;

	if (self.owner.class_select == "class_monster")
	if (self.owner.enemy.classname == "player")
	{
		self.owner.goalentity = self.owner.enemy;
//		self.owner.nextthink = time + 2 + random() * 2;
//		self.owner.think = self.owner.th_walk;
		self = self.owner;
		FoundTarget();
		return;
	}

//	f =  find_tdest(FL_RSTELE | FL_RSSTART | FL_ITEM, null_string);
//	if (!f) 
		f = findradius(self.owner.origin, 2000);

	if (f) // these should be random monsters - when they get here there should be no enemy
//	if((self.owner.enemy == world) || (self.owner.enemy == self))	//If he doesn't have an enemy
	{
		self.owner.goalentity = f;	// target entity f
//		if (self.owner.th_walk != (void ()) 0)
		if (self.owner.th_walk)
		{
			self.owner.nextthink = time + 2 + random() * 2;
			self.owner.think = self.owner.th_walk;
		}
	}
};

// fn(q3_play_sound) - play a sound for target_speaker, repeating or by activator
// fn(q3_sound_think) - periodic repeating sound for target speaker

//#define Q3_LOOPON				1
//#define Q3_LOOPOFF				2
//#define Q3_GLOBAL				4
//#define Q3_ACTIVATOR			8

void() q3_play_sound =
{
	sound (self, CHAN_AUTO, self.noise, self.volume, self.aflag);
};

void() q3_sound_think =
{
	q3_play_sound();
	self.nextthink = time + self.wait + self.delay * crandom();
};

/*		q3 ---
	QUAKED target_speaker (0 .7 .7) (-8 -8 -8) (8 8 8) LOOPED_ON LOOPED_OFF GLOBAL ACTIVATOR
Sound generating entity that plays .wav files. Normal non-looping sounds play each time the target_speaker is triggered. Looping sounds can be set to play by themselves (no activating trigger) or be toggled on/off by a trigger.
-------- KEYS --------
noise : path/name of .wav file to play (eg. sound/world/growl1.wav - see Notes).
wait : delay in rels between each time the sound is played ("random" key must be set - see Notes).
aflag : ATTN_* codes
random : random time variance in rels added or subtracted from "wait" delay ("wait" key must be set - see Notes).
targetname : the activating button or trigger points to this.
notfree : when set to 1, entity will not spawn in "Free for all" and "Tournament" modes.
notteam : when set to 1, entity will not spawn in "Teamplay" and "CTF" modes.
notsingle : when set to 1, entity will not spawn in Single Player mode (bot play mode).
-------- SPAWNFLAGS --------
LOOPED_ON : sound will loop and initially start on in level (will toggle on/off when triggered).
LOOPED_OFF : sound will loop and initially start off in level (will toggle on/off when triggered).
GLOBAL : sound will play full volume throughout the level.
ACTIVATOR : sound will play only for the player that activated the target.
-------- NOTES --------
The path portion value of the "noise" key can be replaced by the implicit folder character "*" for triggered sounds that belong to a particular player model. For example, if you want to create a "bottomless pit" in which the player screams and dies when he falls into, you would place a trigger_multiple over the floor of the pit and target a target_speaker with it. Then, you would set the "noise" key to "*falling1.wav". The * character means the current player model's sound folder. So if your current player model is Visor, * = sound/player/visor, if your current player model is Sarge, * = sound/player/sarge, etc. This cool feature provides an excellent way to create "player-specific" triggered sounds in your levels.

The combination of the "wait" and "random" keys can be used to play non-looping sounds without requiring an activating trigger but both keys must be used together. The value of the "random" key is used to calculate a minimum and a maximum delay. The final time delay will be a random value anywhere between the minimum and maximum values: (min delay = wait - random) (max delay = wait + random).
*/
void() target_speaker =
{
	if (time < 2) precache_sound (self.noise);

	self.aflag = ATTN_NORM;
	if (self.spawnflags & 4) self.aflag = ATTN_NONE; // Q3_GLOBAL

	if (!self.volume) self.volume = 1;

	self.use = q3_play_sound;

// does NOT operate with map hack - they do not relocate or ever turn off
//				we really only want this when loading a real q3 map
	if (time < 2)
	if (self.spawnflags & 1) // Q3_LOOPON - translated to q1 ambient - note: can not be turned off
	{
		ambientsound (self.origin, self.noise, 0.5, ATTN_STATIC);
//		loop_sound(self, CHAN_WEAPON,self.noise, 1, attn, 8.25, self.origin, 0, LOOPFOREVER); // FIX - want this for loopoff - problem is we need the sound length
//		remove(self);
	}
//	else if (self.spawnflags & Q3_LOOPOFF) // finish this
//	{
//		ambientsound (self.origin, self.noise, 0.5, ATTN_STATIC);
//		loop_sound(self, CHAN_WEAPON,self.noise, 1, attn, 8.25, self.origin, 0, LOOPFOREVER);
//	}
	else if (self.wait)
	{
		self.think = q3_sound_think;
		self.nextthink = time + self.wait + self.delay * crandom();
	}
};

// makestatic wrapped - so if we have deletable hacks we can delete ents

void(entity e) makestatic =
{
	if (mh)
	if (mh.spawnflags & NOPERSIST)
	{
		e.movetype = MOVETYPE_NONE;		// same conds as makestatic - for the func_illusionary - func_wall trick
		e.solid = SOLID_NOT;
		return;
	}
	_makestatic(e);
};

// ambient sound wrapped - so if we have deletable hacks we can delete the sound ent

void(vector pos, string samp, float vol, float atten) ambientsound = 
{

// the reality of maphack and lights / ambient
//		- if hacks are not persistent, we can NOT have static ents

	if (mh)
	if (mh.spawnflags & NOPERSIST) // NOTE: should this be some other global setting so these cant be mixed with diff biomes?
	{
		self.noise=samp;
		self.volume=vol;
		self.aflag = atten;
//		target_speaker();
		q3_play_sound(); /// TEST this with th_0002


		#ifdef warning
//																				if (WARNING & 524288)
																				{
																					bprint(" *** fa_sound ent: ");
																					bprint(item_ident(self));
																					bprint(" - hear: ");
																					bprint(self.noise);
																					bprint(" org: ");
																					bprint(vtos(self.origin));
																					bprint("\n");
																				}
		#endifdef

		return;
	}
// std ambient sounds
	_ambientsound(pos, samp, vol, atten);
};



/*QUAKED func_mapday (.6 .1 .6) (-8 -8 -8) (8 8 8) 
--------  CAT  -------
Chaos Mod MK II

Day night cycle via r_ambient control
For map hacks system

-------- NOTES --------
"rad_time"      "#"     - how long until cycle starts after init
"state"         "#"     - where daylight starts
"speed"         "#"     - rate at which daylight changes, up or down
"delay"         "#"     - time between changes

"volume"        "#"     - max daylight - when hit cycle starts down
"count"         "#"     - time to sit at max
"height"        "#"     - min daylight - when hit cycle starts up
"cnt"           "#"     - time to sit at min


"targetname"    "{n}"   - targets for control sequence
"target1"
"target2"

"button0"       "#"     - level to set on targeted action
"button1"       "#"     - set and stop cycle
"button2"       "#"     - set and start cycle there
"button3...x"   "#..."  - levels to set sequentially with each subsequent target call

*/

// round and round the sun we go, the moon goes round the earth
// we do not die of death, we die of vertigo

void() func_mapday =
{
	local float autocvar_sv_c_hackday;

	self.think = func_mapday;

// run times
	if (self.rad_time)
	{
		self.nextthink = time + self.rad_time;
		self.rad_time = 0;
	}
	else self.nextthink = time + self.delay;

// start level
	if (self.state)
	{
		self.light_lev = self.state; // set init level
		self.state = 0;
	}

	self.light_lev = self.light_lev + self.aflag; // current run level

// set dir if not
	if (!self.aflag) self.aflag = self.speed;

	if (self.light_lev > self.volume) // hit max
	{
		self.light_lev = self.volume;
		self.aflag = 0 - self.speed;
		self.nextthink = time + self.count;
	}

	if (self.light_lev < self.height) // hit min
	{
		self.light_lev = self.height;
		self.aflag = self.speed;
		self.nextthink = time + self.cnt;
	}

	if (autocvar_sv_c_hackday) self.light_lev = autocvar_sv_c_hackday;

	localcmd("r_ambient ");
	localcmd(ftos(self.light_lev));
	localcmd("\n");

};


// spawnflags - hacks / biome

#define		FADEIN					1
#define		WORLDH					2
#define		DESTROYH					4
#define		HOLDH						8
#define		AUTOLOAD					16
// in defs - used in other modules
//#define		NOPERSIST			32
//#define		RANDOMH				64
#define		ENTREPLACE				128

// spawnflags - maphack_triggers

#define		NOAUTO	   			2


void() InitTrigger;
void() func_maphack;

// copy trigger data for map hacks

// copy from self.owner or biome (if set) to self
// self.owner should be the maker hack, but is likely the trigger

void() hack_trigger_cp =
{
// this is where we can do biomes
	if (biome) self.owner = biome;

	self.mean = self.owner.mean;
	self.stdev = self.owner.stdev;
	self.count = self.owner.count;
	self.cnt = self.owner.cnt;
	self.delay = self.owner.delay;
	self.map = self.owner.map;
	self.rotate_type = self.owner.rotate_type;
	self.t_length = self.owner.t_length;
	self.lefty = self.owner.lefty;
	self.stack1 = self.owner.stack1;
	self.stack2 = self.owner.stack2;
	self.stack3 = self.owner.stack3;
	self.stack4 = self.owner.stack4;
	self.stack5 = self.owner.stack5;
	self.stack6 = self.owner.stack6;
	self.stack7 = self.owner.stack7;
	self.stack8 = self.owner.stack8;
	self.stack9 = self.owner.stack9;
	self.stack10 = self.owner.stack10;
	self.stack11 = self.owner.stack11;
	self.stack12 = self.owner.stack12;
	self.stack13 = self.owner.stack13;
	self.stack14 = self.owner.stack14;
	self.stack15 = self.owner.stack15;
	self.stack16 = self.owner.stack16;
	self.target1 = self.owner.target1;
	self.target2 = self.owner.target2;
	self.group = self.owner.group;
	self.refire_time = self.owner.refire_time;
	self.spawnflags = self.owner.spawnflags;
};
 
// set a biome with a trigger
// see func_maphack for biome data

void() biome_use = 
{
	if (self.stack1 == "worldspawn")
		biome = world;
	else
		biome = self;
};

void() func_biome = 
{
	self.use = biome_use;
	biome = world;
	if (self.spawnflags & WORLDH) biome = self; // initial biome active on worldspawn
	self.spawnflags = self.spawnflags - (self.spawnflags & WORLDH);
};

// probe for a hack at test origin - if none found, make via func_maphack

// self is trigger ent, with maphack as its owner
// note - some ent vars are passed blind !!!

#define mh_search		self.goalentity

void(vector horg) maphack_probe =
{
	self.trigger_field = world; // for using this as a detector - if this comes back world, we found another hack here3W
	mh_search = find (world, classname, "func_maphack");//self.chain; // not gonna do anything if there is not 1 existing maphack !
	self.count = 6;
	while (mh_search && self.count > 0)
	{
		self.oldorigin = mh_search.origin;
		if ((self.oldorigin == horg) && (self != mh_search))
		{
#ifdef warning
																			if (WARNING & 131072)
																			{
																				bprint(" *** warning:   map hack found by probe: ");
																				bprint(vtos(mh_search.origin));
																				bprint(", desired: ");
																				bprint(vtos(horg));
																				bprint(", trigger owner at: ");
																				bprint(vtos(self.owner.origin));
																				bprint("\n");
																			}
#endifdef
				self.count = 0;
		}
		else
			mh_search = find (mh_search, classname, "func_maphack");
	}

	if (self.count) // nothing found there - make it
	{
		self.trigger_field = chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  horg , '-16 -16 -16', '16 16 16', '0 0 0', '0 0 0', "func_maphack", string_null, SUB_Null, 0.02, func_maphack, SUB_Null, self, world);

#ifdef warning
																			if (WARNING & 65536)
																			{
																				bprint(" *** warning:  *map hack load trigger made chunk: ");
																				bprint(vtos(self.trigger_field.origin));
																				bprint("\n");
																			}
#endifdef
	}
};


// make chunks

void() maphack_fire =
{
// test destination location - 8 ray star + center - up & down added 8.6.14

// need this for up & down 1 level thru a hole / port
	maphack_probe(self.origin);

	self.dest1 = '0 0 0';
	self.dest1_x = self.lefty;
	maphack_probe(self.origin + self.dest1); // 1024 0 0
	maphack_probe(self.origin - self.dest1); // -1024 0 0

	if (self.aflag == -666)
	{
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin + self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin - self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
	}

	self.dest1_y = 0 - self.lefty;
	maphack_probe(self.origin + self.dest1); // 1024 -1024 0
	maphack_probe(self.origin - self.dest1); // -1024 1024 0

	if (self.aflag == -666)
	{
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin + self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin - self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
	}

	self.dest1_y = self.lefty;
	maphack_probe(self.origin + self.dest1); // 1024 1024 0
	maphack_probe(self.origin - self.dest1); // -1024 -1024 0

	if (self.aflag == -666)
	{
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin + self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin - self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
	}

	self.dest1_x = 0;
	maphack_probe(self.origin + self.dest1); // 0 1024 0
	maphack_probe(self.origin - self.dest1); // 0 -1024 0

	if (self.aflag == -666)
	{
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin + self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin - self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
	}

// up down set - only if biome lip was set
	
	if (biome)
	if (biome.lip)
	if (self.aflag == -666)
	{
		self.dest1_y = 0;
		self.dest1_z = biome.lip;

		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 1, 0,  self.origin + self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 1, 0,  self.origin - self.dest1, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.02, maphack_trigger, SUB_Null, self, world);
	}
	
//*/
// turn off one shot self replicator
	if (biome.group == "start2")
	{
		biome.refire_time = biome.refire_time - 6;
		if (biome.refire_time < 1)
			biome.group = string_null; // turn off
	}
};

// auto load some biome, like lava

float autobiome;

// touch an auto load trigger to make next chunk(s)

void() maphack_touch =
{
	if (other.classname != "pk*bot")
	if (other.classname != "player")
		return;

// for crossover debounce
	if (!self.flags) // so respawn / teleport made triggers fire instantly
	if (vlen(other.velocity) < 250) // or player is not moving fast
	if (time < self.ltime) return;

#ifdef warning
																			if (WARNING & 16384)
																			{
																				bprint(" *** warning:   map hack touch: ");
																				bprint(vtos(self.origin));
																				bprint(", owner at: ");
																				bprint(vtos(self.owner.origin));
																				bprint("\n");
																			}
#endifdef


	if (self.group == "start" || self.group == "start2")
	if (autobiome < 1)
	{
		autobiome = self.refire_time;
		if (!autobiome) autobiome = 24; // default - build 24 chunks
	}

/// TDO: single time spawn, like a structure - dont set this, dont need trigger set
	self.aflag = -666; // code to spawn next trigger set - because a player caused this by touch, was not set off by autofire
// remove _all_ old triggers
	self.enemy = find (world, classname, "maphack_trigger");
	while (self.enemy)
	{
		if ((self.enemy != self) && !(self.enemy.spawnflags & NOAUTO)) remove(self.enemy);
		self.enemy = find (self.enemy, classname, "maphack_trigger");
	}
	maphack_fire();

// these never persist - NOAUTO flag is so wipe code above doesnt remove map spec ones
	remove(self);
};

#define TRIG_PAD		64

void() maphack_trigger =
{
	hack_trigger_cp(); /// the _only_ reasons for this - copy: .group (autofire seq), .lefty

	if (self.lefty > 0)
	{
		InitTrigger ();
		self.touch = maphack_touch;
		if (self.think == maphack_trigger) // dont resize map spec triggers
		{
			self.model = string_null;
			self.ltime = time + 2; // delay for crossover
			self.dest1_x = 0 - (self.lefty / 2) - TRIG_PAD; // 128 - need overlap, triggers sometimes miss
			self.dest1_y = 0 - (self.lefty / 2) - TRIG_PAD;
			self.dest1_z = -512;
			self.dest2_x = self.lefty / 2 + TRIG_PAD;
			self.dest2_y = self.lefty / 2 + TRIG_PAD;
// note - flyer issues at any greater height - the main issue being flying above the triggers
			self.dest2_z = 2048;

// biomes may spec up & down direction with lip - restricts size of trigger up & down, makes above & below triggers
			if (biome)
			if (biome.lip > 0)
			{
				self.dest1_z = -128; // because our chosen "basement" is 128 below the 0 line
				self.dest2_z = biome.lip - 128;
			}
			setsize(self, self.dest1, self.dest2);
		}


#ifdef warning
																			if (WARNING & 32768)
																			{
																				bprint(" *** warning:   map hack trigger @: ");
																				bprint(vtos(self.origin));
																				bprint("\n");
																			}
#endifdef
		
	}
	else
		remove(self);

};

// fade hack chunks in from 0.1

void() maphack_poof =
{
	if (self.alpha < 1)
	{
		self.nextthink = time + 0.1;
		self.alpha = self.alpha + 0.08;
	}
};


/// removing this in favor of engine mod with farclip to make anything outside that non-exist till it should exist

//#define hidehack

#ifdef hidehack

// hide far away hacks, check every 10 rels

entity maphack_hide;
float autocvar_sv_c_hackdist = 10000;

.float svthink; // save think time, or indicate not thinking - 0 means ent is not hidden, -1 not thinking
.entity hh_chn;

void() hide_hacks =
{
	local entity hh;
	hh = self;
	self.hh_chn = world;

	self.nextthink = time + 5;

// get list of players
	cnt_ent(self, "class_select", "class_player");
	self.goalentity = self.chain;

// get list of hacks
	cnt_ent(self, "classname", "func_maphack");
	self.dropent = self.enemy = self.chain;

/*
// loop players - hacks have to be hidden for ALL players
//						will have to manage the hh_chn list, removing any hack that is visible to any player

	while (self.goalentity)
	{
		self.dropent = self.enemy; // restart for every player
		if (self.goalentity.ishuman)	
*/
		if (self.goalentity)
		while (self.dropent)
		{
// notes - on multi server, have to check EVERY player origin, even bots - bots could have a much smaller vis radius though

			if (self.dropent.movement == '0 0 0') // dont check source placeholders or feature sets
			if (!(self.dropent.spawnflags & 64)) // spawnflags say no
			if (vlen(self.dropent.origin - self.goalentity.origin) > autocvar_sv_c_hackdist)
			{
				if (self.dropent.svthink != -6) // only hide once
				{
																						bprint(" *** warning:   hack hiding at : ");
																						bprint(vtos(self.dropent.origin));
																						bprint("\n");
					self.dropent.svthink = -6;
					self.dropent.modelindex_morph = self.dropent.modelindex;
					self.dropent.modelindex = 0;
					self.dropent.nextthink = -1;
// special - hide hacks chain, because findradius uses .chain
					hh.hh_chn = self.dropent;
					hh = self.dropent;
				}
			}
			else if (self.dropent.svthink == -6)
			{
																						bprint(" *** warning:   hack revealing at : ");
																						bprint(vtos(self.dropent.origin));
																						bprint("\n");
				self.dropent.svthink = 6; // indicate restore happens for next bit
				if (self.dropent.delay) self.dropent.nextthink = time + self.dropent.delay; // note: delay code currently not viable
				self.dropent.modelindex = self.dropent.modelindex_morph;
// reveal hacks chain
				hh.hh_chn = self.dropent;
				hh = self.dropent;
			}
			
			self.dropent = self.dropent.chain;
		}
		hh.hh_chn = world;
//		self.goalentity = self.goalentity.chain;
//	}
		hh = self.hh_chn;
		while (hh)
		{
/// note: this system is "fuzzy" with movable ents - things may be hidden in visible hacks & restored for hidden hacks, and some may even get lost!
			// one improvement would be to use the actual hack bounding box as a double check to things found in the radius
			self.aiment =  findradius(hh.origin, hh.lefty * 1.46); // radius should cover the whole hack
			while (self.aiment && hh)
			{
				if (self.aiment.classname != "func_maphack") // dont do op on hacks
				if (self.aiment.class_select != "trigger_secret") // dont do op on triggers - note this id's _all_ trigger fields
				if (!(self.aiment.flags & FL_CLIENT)) // dont hide / reveal players or bots
				if (hh.svthink == -6)
				{
	// hide model and stop thinking
					self.aiment.modelindex_morph = self.aiment.modelindex; // may want to exclude viswep - the only non player / nonbot ent to use this
					self.aiment.modelindex = 0;
	// note: some code modifies nextthink for vars ents
					self.aiment.svthink = self.aiment.nextthink - time;
					self.aiment.nextthink = -1;
																						bprint(" *** warning:   hack hiding ent: ");
																						bprint(item_ident(self.aiment));
																						bprint("\n");
				}
				else if (hh.svthink == 6)
				{
					self.aiment.modelindex = self.aiment.modelindex_morph;
/// note: may want to check for 0 void in think !
					if (self.aiment.svthink > 0)
						self.aiment.nextthink = self.aiment.svthink + time;
																						bprint(" *** warning:   hack revealing ent: ");
																						bprint(item_ident(self.aiment));
																						bprint("\n");
					self.aiment.svthink = 0;
				}
				self.aiment = self.aiment.chain;
			}
			if (hh.svthink == 6) hh.svthink = 0;
			hh = hh.hh_chn;
		}
};

#endifdef

// delete a hack and all its sub ents

// self must be the hack

void() delete_hack =
{
	maphack_probe(self.origin);
	if (self.trigger_field) // nothing found
	{
		remove(self.trigger_field);
		self.trigger_field = world;
	}
	else if (self != self.goalentity)
	{
// found a hack - destroy it and all sub ents
		self.aiment =  findradius(self.origin, self.lefty * 1.5); // radius should cover the whole hack
		while (self.aiment && self.goalentity)
		{
			if (self.aiment.l_hash > 10000)
			if (self.aiment.l_hash == self.goalentity.l_hash) // same hash
			{
				self.aiment.think = SUB_Remove;
				self.aiment.nextthink = time;
																						bprint(" *** warning:   hack derezing - destroying : ");
																						bprint(item_ident(self.aiment));
																						bprint("\n");
			}
			self.aiment = self.aiment.chain;
			if (!self.aiment) remove(self.goalentity);
		}
		self.goalentity = world;
	}
};

void() target_speaker;


void() func_copymod =
{
// place holder for - removed - was prev version copy system
	self.think = SUB_Remove;
	self.nextthink = time + random();
};

/*QUAKED trigger_respawn (.5 .5 .5) ?
--------  CAT  -------
map hack trigger to set a respawn point for an area (used to be a map and used info_player_start

MAPHACK:
copied by script from info_player_start

if manually entered in map:
-------- KEYS --------
origin: spawn location
angle : viewing angle when spawning
*/

void() trigger_respawn_touch =
{
	if (other.classname != "player") return;
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX) return;

	other.movetarget = self;
};

void() trigger_respawn =
{
	InitTrigger ();
	self.touch = trigger_respawn_touch;
};


float(string s) findentityfield =
{
	f0__ = 1;
	while (f0__ < numentityfields())
	{
		if (entityfieldname(f0__) == s) return(f0__);

		f0__ = f0__ + 1;
	}
}

// fn(mh_drop_key) - in sp coop mode, if a player dies, drop his key, unless in lava
// notes: what about DM?
// idea: pick a random spot - info_dm or so to avoid in lava / unreachable

void() mh_drop_key =
{
	
	e1__ = self;
	if (e1__.items & IT_KEY1)
	{
		self = spawn();
		self.origin = e1__.origin;
		item_key1();
		self.velocity_z = 300 + 100 * random();
		self.velocity_x = crandom() * 100;
		self.velocity_y = crandom() * 100;
	}
	if (e1__.items & IT_KEY2)
	{
		self = spawn();
		self.origin = e1__.origin;
		item_key2();
		self.velocity_z = 300 + 100 * random();
		self.velocity_x = crandom() * 100;
		self.velocity_y = crandom() * 100;
	}
	self = e1__;
};

// end of episode text scroll

void() eoe_scroll =
{
	if (!self.netname)
	{
		s1__ = strcat("maps/", self.oh.netname,".bsp");
		s0__ = cvar_string(strcat("__fin_",ftos(intermission_running),s1__)); // hipnotic deal
		if (strlen(s0__) < 6) s0__ = cvar_string(strcat("__fin_",s1__));
		self.netname = strcat(" CONGRATULATIONS!...",strreplace("&", " ", s0__));
// have to check for all 15 runes for qone single player - if we are here there will be no intermission_running = 3 to display the 2nd message
// FIX: hipnotics double bubble
		if ((serverflags&15) == 15) self.netname = strcat(self.netname,"...",strreplace("&", " ", cvar_string("__fin_q1end")));
	}
	self.nextthink = time + cvar("scr_printspeed_ibar") / 60;
	putentityfieldstring(findentityfield("netname"), self, substring(self.netname, 1,strlen(self.netname) - 1));
	stuffcmd(self.owner, "infobar 3 \"");
	stuffcmd(self.owner, substring(self.netname, 0, 90));
	stuffcmd(self.owner, "\"\n");
	if (!self.netname) remove(self);
};

// fn(retarget) - change target to a random or unique list for hack stuff - we need to think here so all of hack chunk can be built first

// o{n} - only 1 of these targetname ents, remove all others
// r{n} - choose a random targetname of all these for all targets 
// p{n} - choose a random targetname a one time link - IMP: used to / had a spawnflag for relink option?
// none above - add maphack system_hash to all t / tn 

// save a target with "&{trgid}"for later reference by "&"
string save_targ;

void() retarget =
{
	s6__ = substring(self.target,0,1);
	if (self.target)
	if ( s6__ != "r" && s6__ != "p" && s6__ != "o")
	{
// refer another field
		if (s6__ == "<") 
		{
			s6__ = substring(self.target,1,strlen(self.target) - 1);
			s6__ = getentityfieldstring(findentityfield(s6__), self);
		}
		else if (self.target == "&") s6__ = save_targ;
		else
		s6__ = strcat(self.target, ftos(mh.l_hash));
		putentityfieldstring(findentityfield("target"), self, s6__);
		if (substring(s6__,0,1) == "&") save_targ = strzone(s6__);
	}
// event_lightning doors multiplex
	if (self.group == "lightning") self.group = self.target;

	s6__ = substring(self.targetname,0,1); 
	if (self.targetname)
	if ( s6__ != "r" && s6__ != "p" && s6__ != "o")
	{
// map_hack map name short
		if (self.targetname == "$MHN") s6__ = mh.netname;
		else if (self.targetname == "&") s6__ = save_targ;
		else
		s6__ = strcat(self.targetname, ftos(mh.l_hash));
		putentityfieldstring(findentityfield("targetname"), self, s6__);
		if (substring(s6__,0,1) == "&") save_targ = strzone(s6__);
	}
};

// locate target based on 1st letter code above
// self is ent with target seek
// self.movetarget is ent pointer for targetname ent sought

void() ltarget =
{
	self.movetarget = world;
	s6__ = substring(self.target,0,1); 
	if (s6__ == "r" || s6__ == "p")
	{
		self.f__ = cnt_ent(self,"targetname",self.target);
		self.f__ = rint(random() * self.f__); // its 4 bytes less this way
		while (self.f__ > 0)
		{
			self.f__ = self.f__ - 1;
			self.chain = self.chain.chain;
			if (self.f__ < 1 && self.chain)
			{
				self.movetarget = self.chain;
				if (s6__ == "p")
				{
// note remove "p" as 1st so we dont locate that target again - after that its a regular t / tn set
					s6__ = strcat("_",self.target, ftos(mh.l_hash));
					putentityfieldstring(findentityfield("targetname"), self, s6__);
					s6__ = strcat("_",self.movetarget.targetname, ftos(mh.l_hash));
					putentityfieldstring(findentityfield("targetname"), self.movetarget, s6__);
				}
			}
		}
	}
};

// check for cvar override to ent fields
// uses f0__, s2__, s3__, s4__
// e - ent to load
// es - ent string to search cvars for - has all ent fields appended to it - {es}_{fieldnames}

void(entity e, string es) cvar_fields =
{
	if (cvar(es))
	{
		f0__ = 1;
		s2__ = s4__ = entityfieldname(1);
		while (f0__ < 2 || s2__ != s4__)
		{
			s3__ = strcat(es,"_",s4__);
			if (cvar_type(s3__) & CVAR_TYPEFLAG_EXISTS)
			{
				putentityfieldstring(f0__, e, cvar_string(s3__));
			}
			f0__ = f0__ + 1;
			s4__ = entityfieldname(f0__);
		}
	}
};

// fn(SV_OnEntityPreSpawnFunction) - darkplaces special - setting org before spawnfn because of pack thrower
//       *** check copy stuff - % chance, special ops

// f2__ - preserve - used in func_maphack
// s1__ - preserve - used in func_maphack

//TEST REMOVE
float(string name, string value) registercvar = #93;

void() SV_OnEntityPreSpawnFunction =
{
// for maphack - loading sequence of existing maps, worldtype must be correct as ents load
	if (self.classname == "worldspawn" && mh) {world.worldtype == self.worldtype;


																				registercvar(strcat("___",mh.netname,"_st_",ftos(self.worldtype),"_wt_",ftos(world.worldtype)),"1");
							}

// entity override by script / cvar data
// __{classname} is the trigger for script replacement
// copy any ent that has cvar __copy#_{classname} defined and load its fields from the same
// loop until done

	if (self != nspawn)
	{
		f3__ = 0;
		while (cvar(strcat("__copy",ftos(f3__),"_",self.classname)))
		{
			nspawn = spawn();
			copyentity(self, nspawn);
			cvar_fields(nspawn, strcat("__copy",ftos(f3__),"_",self.classname));
			e0__ = self;
			self = nspawn;
			SV_OnEntityPreSpawnFunction(); // parse it too - otherwise it doesnt happen
			callfunction(self.classname);
			self = e0__;
			f3__ = f3__ + 1;
		}
	}
// now do main ent
	if (self) cvar_fields(self, strcat("__",self.classname));
	if (mh)
	{
		cvar_fields(self, strcat("__mh_",self.classname)); // only do these for hack ents
		cvar_fields(self, strcat("__",mh.netname,"_",self.classname)); // match a specific chunk
	}

// map_hack control - rotate point ents in hack around '0 0 0', relocate all ents to hack, set bmodel ent - modelindex, model
	if (mh)
	if (self.classname != "light" || self.targetname)
	{
#ifdef warning
																			if (WARNING & 524288)
																			{
																				bprint(" *** OEPSF relo - ent: ");
																				bprint(item_ident(self));
																				bprint(" *** ld org: ");
																				bprint(vtos(self.origin));
																				bprint(", hck add: ");
																				bprint(vtos(mh.origin));
																			}

#define warnbh if (WARNING & 524288) bprint("   REMOVED\n");
#else
#define warnbh
#endifdef

		if ((self.lefty < 1 && self.lefty > random()) || self.classname == "worldspawn")
		{
#ifdef warning
																			if (WARNING & 16384)
																			{
																				bprint(" *** lefty REMOVE:   ");
																				bprint(item_ident(self));
																				bprint(", mdl: ");
																				bprint(self.model);
																				bprint("\n");
																			}
#endifdef
			remove(self);
			return;
		}

		self.oh = mh;
		self.l_hash = mh.l_hash;
		if (self.target || self.targetname) retarget();

/// for now hacks will not rotate if they have bmodel ents such as: doors, plats, buttons, triggers
// for quake hack the 4 map part trick will be used
// point model ents, however that are not part of the inital map load _will_ need to be rotated

		if (substring(self.model,0,1) != "*")
		if (mh.rotate_type || mh.t_length)
		{

#ifdef warning
																			if (WARNING & 131072)
//																			if (WARNING & 4194304)
																			{
																				bprint(" *** warning:   attempting turn: ");
																				bprint(item_ident(self));
																				bprint(", mdl: ");
																				if (self.model)
																					bprint(self.model);
																				else
																					bprint(self.mdl);
																				bprint(", at: ");
																				bprint(vtos(self.origin));
																			}
#endifdef

	if (mh.t_length) f3__ = mh.t_width;
	else f3__ = mh.angles_y;

	if (f3__)
	{
		v1__ = vectoangles(self.origin);
		v1___x = 0;
		v1___y = anglemod(v1___y + f3__);
		makevectors(v1__);
		v1__ = vlen(self.origin) * v_forward;
		v1___z = self.origin_z;
		self.origin = v1__;
	}
/*
 /// this is the previous rotate - only works for 90, 180, 270, but the coords are precise
				makevectors(mh.angles); // this only works with multiples of 90 degrees! - need true vector calc
				if (v_forward_y == 1) // 90 deg
				{
					self.finaldest_x = 0 - self.origin_y;
					self.finaldest_y = self.origin_x;
				}
				if (v_forward_y == -1) // 270 deg
				{
					self.finaldest_x = self.origin_y;
					self.finaldest_y = 0 - self.origin_x;
				}
				if (v_forward_x == -1) // 180 deg
				{
					self.finaldest_x = 0 - self.origin_x;
					self.finaldest_y = 0 - self.origin_y;
				}
		*/




#ifdef warning
																			if (WARNING & 131072)
//																			if (WARNING & 4194304)
																			{
																				bprint(", to: ");
																				bprint(vtos(self.origin));
																				bprint(", add vec: ");
																				bprint(vtos(v_forward));
																				bprint(", angle: ");
																				bprint(ftos(mh.angles_y));
																				bprint("\n");
																			}
#endifdef

		}
	


#ifdef warning
																			if (WARNING & 524288)
																			{
																				bprint(", res: ");
																				bprint(vtos(self.origin));
																				bprint("\n");
																			}
#endifdef


		if (substring(self.model,0,1) == "*")
		{

// add index *{n} n value to maphack (owner) modelindex - the submodels MUST be stored in sequential slots by the engine in sv.models[]
// adjust self.model to modelindex - 1, for search in sv.model_precache[] - this has to be stored for this to work
// NOTE: fails on a map reload because all the submodels DONT load - seeking a fix
			f1__ = stof(substring(self.model,1,strlen(self.model) - 1));
			if (f1__ > 0)
			{
				self.modelindex = f1__ + mh.modelindex;
				s6__ = strcat("*", ftos(self.modelindex - 1));
				putentityfieldstring(e_model, self, s6__);
			}
		}

// primary entity relocate for hacks ents
		setorigin(self, self.origin + mh.origin);
	}

};

/*
void() SV_OnEntityPostSpawnFunction =
{
	if (mh)
	if (substring(self.model,0,1) == "*")
	{

// add index *{n} n value to maphack (owner) modelindex - the submodels MUST be stored in sequential slots by the engine in sv.models[]
// adjust self.model to modelindex - 1, for search in sv.model_precache[] - this has to be stored for this to work
// NOTE: fails on a map reload because all the submodels DONT load - seeking a fix
		f1__ = stof(substring(self.model,1,strlen(self.model) - 1));
		if (f1__ > 0)
		{
//			self.modelindex = f1__ + mh.modelindex;
//			s6__ = strcat("*", ftos(self.modelindex - 1));
			s6__ = strcat("*", ftos(f1__));
			putentityfieldstring(e_model, self, s6__);
		}
	}
};
*/
// operate episode gates - have to think because runes could be gathered or lost

void() hack_gthk =
{
 // this is an ep gate, bossgate should have no serverflags
	if (self.spawnflags & 15) self.lefty = (serverflags & self.spawnflags);
	else self.lefty = ((serverflags & 15) != 15);

	if (self.lefty)
	{
		setmodel (self, self.mdl);
		func_wall();
	}
	else
	{
// IDEA: fade out, or "magic" away, in case player can observe...
		self.model = string_null;
		self.solid = SOLID_NOT;
	}

	self.think = hack_gthk;
	self.nextthink = time + 4;
};


/// REMOVE - testing
// so I could load archon radix map
void() archon_fader = {};
void() archon_fadeinit = {};

// test whether a file really exists
// returns <  0 for file open fail

float(string f) filer =
{
	f0__ = fopen(f, FILE_READ);
	fclose(f0__);
	return(f0__);
};

// fn(func_maphack) - quake hack function

// like nethack - random quake level rooms, v1.0

// state - map segment to load as model

/*QUAKED func_maphack (.6 .1 .6) (-8 -8 -8) (8 8 8) FADEIN null null null AUTOLOAD
--------  CAT  -------
Chaos Mod MK II

spawnflags = 16			- auto load next chunk

Select a random map segment for quake hack mode maps

map segment:

"mean"			"#"		- start number - 1 default
"stdev"			"#"		- randomize this #, if 0 will count stack*
"count"			"#"		- prefer this segment number (> 0)
"cnt"			"#"		- preference percent for "count" - 0.3 default
"map"			"{name}"	- use this named segment
"delay"			"#"		- reset after delay rels if "map" not set
"rotate_type"	"1"		- rotate random 90 deg. incr
"lefty"			"#"     - trigger size set - total size value, must be + and evenly divisible by 2
"group"			"start"	- use auto fire trigger on this biome
"invisible_time"		"#"		- number of times to auto fire - code maps to refire_time
"stack*"        "map"   - map segments to randomize - 1 to 16 - stack1 MUST be set, probabilty of choice is equal unless --v
"button*"       "#"     - probability for each biome from 0 - 1000, if not assigned standard randomizer is used

targets:
"target1"       "{n}"   - list of ents to copy
"target2"       "{n}"   - list of ents to randomly copy
- will copy relative to 0,0,0 of maphack source
- ents that have model blank and mdl will set new models to mdl

button12 - system_hash id, for all things in this hack / belonging to this hack - note monsters can leave a hack
*/
//test - REMOVE
float one,two,tre;

void() func_maphack =
{

#ifdef hidehack
// hide hacks out of range - disabled, has issues
	if (!maphack_hide)
	{
		maphack_hide = spawn();
		maphack_hide.think = hide_hacks;
		maphack_hide.nextthink = time + 120;
	}

#endifdef

// handle persistence flags
#ifdef map_hack_no_persist
	if (self.spawnflags & RANDOMH) self.spawnflags = self.spawnflags | NOPERSIST;
#else
	self.spawnflags = self.spawnflags & 927; // remove 32 & 64 - goes to 512
#endifdef

	self.l_hash = system_hash; // id all parts of a hack - note: may only be for debug purposes now
	syh

/// should not need this with new trigger system - note 6 cube needs an init somehwere
// currently used to allow initial map_hack ents to set initial triggers

// build trigger - otherwise this gets boring fast
	if (self.spawnflags & AUTOLOAD)
// trigger for making more chunks 
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0,  self.origin, '-16 -16 -16', '16 16 16', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.03, maphack_trigger, SUB_Null, self, world);

	if (self.spawnflags & HOLDH) return;  // 8 is HOLD - placeholder, dont solid or load model

// dont spawn over another hack
	maphack_probe(self.origin);
	if (self.trigger_field) remove(self.trigger_field);
	else
	{
		remove(self);
		return;
	}
	
// tell all subs
	mh = self;

// did map spec hack supply its own mapname
	self.mdl = self.map;

	if (!self.mdl)
	{
// dynamic spawn, copy data - map spawn ents have no owner, so wont do this
		if (self.owner) hack_trigger_cp();

// use this as local biome - nothing else is called so this should be clear
#define l_biome 	e3__

		l_biome = self;

// biome provides probability on a per-chunk basis - we think so anyway
// negative mean allows map specced hacks to override biome, but stack1 MUST be set
		if (biome && (self.mean >= 0 || !self.stack1)) l_biome = biome;

// WONDER: if the compiler array hack can be loaded from a map spawn
		if (self.mean <= 0) self.mean = 1;
		if (!self.stdev)
		{
			if (l_biome.stack1) self.stdev = self.stdev + 1;
			if (l_biome.stack2) self.stdev = self.stdev + 1;
			if (l_biome.stack3) self.stdev = self.stdev + 1;
			if (l_biome.stack4) self.stdev = self.stdev + 1;
			if (l_biome.stack5) self.stdev = self.stdev + 1;
			if (l_biome.stack6) self.stdev = self.stdev + 1;
			if (l_biome.stack7) self.stdev = self.stdev + 1;
			if (l_biome.stack8) self.stdev = self.stdev + 1;
			if (l_biome.stack9) self.stdev = self.stdev + 1;
			if (l_biome.stack10) self.stdev = self.stdev + 1;
			if (l_biome.stack11) self.stdev = self.stdev + 1;
			if (l_biome.stack12) self.stdev = self.stdev + 1;
			if (l_biome.stack13) self.stdev = self.stdev + 1;
			if (l_biome.stack14) self.stdev = self.stdev + 1;
			if (l_biome.stack15) self.stdev = self.stdev + 1;
			if (l_biome.stack16) self.stdev = self.stdev + 1;
		}

// all chuncks have equal chance of being chosen, unless button* values set

		self.state = self.mean + rint(fabs(self.stdev) * random());

		if (l_biome.button1)
		{
			self.msgcount = 
			self.aflag = rint(random() * 1000);
			if (self.aflag <=  l_biome.button1) self.state = 1;
			else if (self.aflag <=  l_biome.button2) self.state = 2;
			else if (self.aflag <=  l_biome.button3) self.state = 3;
			else if (self.aflag <=  l_biome.button4) self.state = 4;
			else if (self.aflag <=  l_biome.button5) self.state = 5;
			else if (self.aflag <=  l_biome.button6) self.state = 6;
			else if (self.aflag <=  l_biome.button7) self.state = 7;
			else if (self.aflag <=  l_biome.button8) self.state = 8;
			else if (self.aflag <=  l_biome.button9) self.state = 9;
			else if (self.aflag <=  l_biome.button10) self.state = 10;
			else if (self.aflag <=  l_biome.button11) self.state = 11;
			else if (self.aflag <=  l_biome.button12) self.state = 12;
			else if (self.aflag <=  l_biome.button13) self.state = 13;
			else if (self.aflag <=  l_biome.button14) self.state = 14;
			else if (self.aflag <=  l_biome.button15) self.state = 15;
			else if (self.aflag <=  l_biome.button16) self.state = 16;
		}

/*
	*** warning set offloaded on 7.29.14 - see bkp

#ifdef warning
																			if (WARNING & 131072)
																			{
																				bprint(" *** warning:   biome % pick: ");
																				bprint(ftos(self.state));
																				bprint(", prob: ");
																				bprint(ftos(l_biome.button1 / 10));
																				bprint(", dice roll: ");
																				bprint(ftos(self.msgcount / 10));
																				bprint("\n");
																			}
#endifdef
*/

// .count is for a random chance in  .cnt that .count will be the preferred state for this biome / hack
		if (self.count)
		{
			if (!self.cnt) self.cnt = 0.3;
			if (self.cnt < random())
				self.state = self.count;
		}

/*
// test - block new hacks
	if (self.state == 1)
	{
		if ( one == 1) { remove(self); return; }
		one = 1;
	}
	if (self.state == 2)
	{
		if ( two == 1) { remove(self); return; }
		two = 1;
	}
	if (self.state == 3)
	{
		if ( tre == 1) { remove(self); return; }
		tre = 1;
	}
//*/

/// need a master default if this set fails
		self.mdl = l_biome.stack1;
//		if (self.state == 1) self.mdl = l_biome.stack1;
		if (self.state == 2 && l_biome.stack2) self.mdl = l_biome.stack2;
		if (self.state == 3 && l_biome.stack3) self.mdl = l_biome.stack3;
		if (self.state == 4 && l_biome.stack4) self.mdl = l_biome.stack4;
		if (self.state == 5 && l_biome.stack5) self.mdl = l_biome.stack5;
		if (self.state == 6 && l_biome.stack6) self.mdl = l_biome.stack6;
		if (self.state == 7 && l_biome.stack7) self.mdl = l_biome.stack7;
		if (self.state == 8 && l_biome.stack8) self.mdl = l_biome.stack8;
		if (self.state == 9 && l_biome.stack9) self.mdl = l_biome.stack9;
		if (self.state == 10 && l_biome.stack10) self.mdl = l_biome.stack10;
		if (self.state == 11 && l_biome.stack11) self.mdl = l_biome.stack11;
		if (self.state == 12 && l_biome.stack12) self.mdl = l_biome.stack12;
		if (self.state == 13 && l_biome.stack13) self.mdl = l_biome.stack13;
		if (self.state == 14 && l_biome.stack14) self.mdl = l_biome.stack14;
		if (self.state == 15 && l_biome.stack15) self.mdl = l_biome.stack15;
		if (self.state == 16 && l_biome.stack16) self.mdl = l_biome.stack16;		

	}

// get ent file name base before we trick rotate
	s1__ = strcat(substring(self.mdl,0,strlen(self.mdl) - 4),".ent");
// base name for targeting
	s0__ = substring(self.mdl,5,strlen(self.mdl) - 9);
	putentityfieldstring(findentityfield("netname"), self, s0__);

// trick to rotate triggers and map bmodel ents
	if (self.t_length >= 1)
	{
		self.t_width = 0; // if hack thinks to a reload
		if (self.t_length > 3) self.t_length = 3;
		f2__ = rint(self.t_length * random()) * 90;
		if (f2__)
		{
// prepends 90_, 180_, 270_ to filename
			s0__ = ftos(f2__);
			s0__ = strcat("maps/MH/",s0__,"_", substring(self.mdl,5,strlen(self.mdl) - 5));
			putentityfieldstring(e_model, self, s0__);
			if (filer(self.model) >= 0) self.mdl = self.model;		// only use if it exists
		}
	}
	else
	if (self.rotate_type > 0)
	{
		self.aflag = 1;
		f3__ = self.rotate_type;
		if (self.rotate_type >= 1)
		{
			f3__ = 0.89;
// switching this out to a simple, if state is < (rotate_type >= 1) it wont rotate
			if (self.state < self.rotate_type) self.aflag = 0;

#ifdef warning
																			if (WARNING & 65536)
																			{
																				bprint(" *** warning:   biome no rotate for state: ");
																				bprint(ftos(self.state));
																				bprint(", r val: ");
																				bprint(ftos(floor(self.rotate_type)));
																				bprint("\n");
																			}
#endifdef
		}

		if (self.aflag)
		{
// rotated an increment of 90 degrees
			self.angles_y = rint(3.3 * random()) * 90;
// 7.12.14 - added rotate angle randomizer, only works with cliffs so far, any round-ish biome block could use this (in theory anyway)
// this does a lot to break up the repetitve monontony of similar blocks all rotated to some 90 deg. increment
			if (f3__ < 0.9) self.angles_y = self.angles_y + (f3__ * 100) * random();

#ifdef warning
																			if (WARNING & 65536)
																			{
																				bprint(" *** warning:   biome rotated for state: ");
																				bprint(ftos(self.state));
																				bprint(", deg: ");
																				bprint(ftos(f2__));
																				bprint(", at: ");
																				bprint(vtos(self.origin));
																				bprint("\n");
																			}
#endifdef
		}
	}

// make sure chunk really exists - if not, we could load a default placeholder
/// NOTE: for loader we dont want to do this

	if (filer(self.mdl) < 0) self.mdl = dh;
	else
// set default
		if (!dh) dh = self.mdl;

	setmodel (self,self.mdl);

	self.solid = SOLID_BSP; // act like map brushes
// reset upper / lower bounds for rnd items, etc.
// note outdoors issue with some chunks (a flat top that pokes thru noway_above 
//			 denies anything being on top of it after adjustment) thus "+ 80"
	if (self.absmin_z < noway_below) noway_below = self.absmin_z;
	if (self.absmax_z > noway_above) noway_above = self.absmax_z + 80;

	nspawn = world;
// engine builtin ent_load - woo!
/// NOTE: s1__ is saved across this ent_load and everything it calls, which is every spawn func
// if the flag for replace per map load is set and we have a valid ent file, dont load bsp ents
	if (!(self.spawnflags & ENTREPLACE) || (filer(s1__) < 0))

		ent_load(self.mdl);

// now set a possible t_length rotate for all future .ent file loads
	self.t_width = f2__;
	f2__ = 0;

// now we try .ent files, that can be rotated fully after the "trick" rotate 90 deg incr
	if (filer(s1__) >= 0) ent_load(s1__);

// using classname for now
//	if (!self.class_select) self.class_select = "class_biome"; 

	mh = world;

// issue with this - ents loaded need deleted - could suck in persist mode if there are makestatics
	if (self.delay > 0) // idea: fade replace?
	{
		self.nextthink = time + self.delay;
		self.think = func_maphack;
	}

// fade scenery into existance - at the cost of rendering engine efficiency
/// note: cost is ridculous - deprecated for now
/*
	if (self.spawnflags & FADEIN)
	{
		if (biome)
		{
			if (floor(biome.style) == self.state) return;
// trick to encode 2 no fade ins, could do more
			self.msgcount = rint((biome.style - floor(biome.style)) * 10);
			if (self.msgcount == self.state) return;
		}
		self.alpha = 0.05;
		self.think = maphack_poof;
		self.nextthink = time + 0.2;
	}
*/
	if (autobiome >= 0)
	{
		maphack_fire();
		autobiome = autobiome - 1;

#ifdef warning
																			if (WARNING & 65536)
																			{
																				bprint(" *** warning:   map hack autobiome: ");
																				bprint(vtos(self.origin));
																				bprint(", owner at: ");
																				bprint(vtos(self.owner.origin));
																				bprint(" - done\n");
																			}
#endifdef

//		remove(self);
	}

// a loader or a bad file - remove
	if (filer(self.mdl) < 0) remove(self);
};
/*
// code to load sub ent files - this will be move & used for ever changing nethack style increasing difficulty to load diff stuff
// unless we find a better way with cfg of replace scripts or some such
	s4__ = substring(self.mdl,0,strlen(self.mdl) - 4);
	s4__ = strcat(s4__, ".ent");
	
	ent_load(s4__);
*/

