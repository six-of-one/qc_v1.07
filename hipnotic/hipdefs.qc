/* Level pack definitons
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

//entity nullentity;
#ifdef hip_bulletholes
#define nullentity world
entity bulletholes;
entity lastbullet;
float numbulletholes;
#endifdef


#ifdef hip_weapons
#define	IT_MJOLNIR						128
#define	IT_LASER_CANNON				8388608
#define	IT_PROXIMITY_GUN				65536
#endifdef

#ifndef code_xents
// in items.qc - IT_SUPERHEALTH is removed
#undef	IT_SUPERHEALTH
// Six - do this until we figure out how to restore this
#define	IT_SUPERHEALTH			0
#endifdef

//added update stat message
#define	SVC_UPDATESTAT					3
#define	SVC_CUTSCENE  					34
//added total monster message
#define	STAT_TOTALMONSTERS			12
#define	STAT_TOTALSECRETS				11
.void()	  th_turn;
#define	AS_DODGING    					5

#ifdef hip_charmed

// horn of conjuring
#define	CHARMED_RADIUS					1500
#define	MAX_CHARMER_DISTANCE			200
#define	MIN_CHARMER_DISTANCE			150
#define	TOOCLOSE_CHARMER_DISTANCE	120

.float		charmed;
.entity	  charmer;
.float		huntingcharmer;
float horn_active;
entity horn_charmer;

void() UpdateCharmerGoal;
void() StopHuntingCharmer;
void() HuntCharmer;
void() FleeCharmer;
#endifdef

float visible_distance;
entity damage_inflictor;

#ifdef hip_footsteps
float footsteps;
#endifdef


//MED 11/09/96 added new spawnflags
#define	SPAWNFLAG_SUPERSPIKE			1
#define	SPAWNFLAG_LASER				2
#define	SPAWNFLAG_LAVABALL			4
#define	SPAWNFLAG_ROCKET				8
#define	SPAWNFLAG_SILENT				16

// Hipnotic Constants
#define	MIN_ANGLE_DELTA				10

.float color;

//
// Hipnotic entries
//
// is used by followtarget
.float wetsuit_time;

#ifdef hip_items
#define	HIP_IT_WETSUIT									2
#define	HIP_IT_EMPATHY_SHIELDS				4
#define	HIP_IT_HORN_OF_CONJURING		8

.float wetsuit_finished;
.float empathy_finished;
.float empathy_time;
.float empathy_sound;

// have to use a new items flag because we ran out of bits in the original
.float		items2;

// in combat.qc

//MED 01/10/97 added empathyused variable
float empathy_dmg;

#endifdef
// gremlin stuff
#ifdef hip_monsters
.float		gorging;
.float		stoleweapon;
float() GremlinCheckAttack;

// monster attack checks
float() ScourgeCheckAttack;
float() ArmagonCheckAttack;

void() ai_run_dodge;
#endifdef

.entity	  lastvictim;
// spawn variables
#ifdef hip_spawn
.void()	  spawnfunction;
.string	  spawnclassname;
.float		spawnsolidtype;
.string	  spawnmodel;
.void()	  spawnthink;
.entity	  spawnmaster;
.vector	  spawnmins;
.vector	  spawnmaxs;
#endifdef

// used by spawn, scourge, player
.float		spawnsilent;
.float		spawnmulti;

// laser cannon
//.vector	  old_velocity;
#define	old_velocity	oldorigin

//misc
.float		duration;
// used for linked list of entities
.entity	  next_ent;
// Mjolnir - and tesla trap
.float		struck_by_mjolnir;
// teleport invulnerability
.float		last_teleport_time;

// Miscellaneous
.float gravity;

//MED 01/05/97 added discharge variable
float discharged;
//MED 01/05/97 added hipnotic decoy
entity hipdecoy;
//
// Hipnotic's Prototypes
//
#ifdef hip_mapent
void() StopEarthQuake;
void( float value ) EarthQuakeTime;
void() earthquake_postthink;
void() earthquake_prethink;
float( entity counter ) counter_GetCount;

//multi explosion
void( vector loc, float rad, float damage, float dur, float pause, float vol) multi_explosion;
#endifdef

vector ( vector ang ) SUB_NormalizeAngles;
//void (entity srcent, entity destent) SUB_CopyEntity;
void(string targ, vector orig) become_decoy;


#ifdef hip_bulletholes
void() InitBulletHoles;
void( vector pos ) placebullethole;
#endifdef


//void(vector origin, vector dir, float color, float count, float lifespan) particlestream = #79;

#ifdef hip_rotate
// Rotation
.vector neworigin;
.vector rotate;
.float  rotate_type;
.string path;
.string group;

void() RotateTargets;
void() RotateTargetsFinal;
void() SetTargetOrigin;
void() LinkRotateTargets;
#endifdef

// used by armagon
.float  endtime;

// used by regular hip train
.string event;

// get unused

#include </../incl/use_dest.qc>

#include </../incl/use_waitmax.qc>
#include </../incl/use_distance.qc>
#include </../incl/use_volume.qc>

#include </../incl/use_writelong.qc>
#include </../incl/use_nextent.qc>

// from other areas of hipnotic code

// in hip ai.qc
float RUN_STRAIGHT;

// in player.qc - for flys sound
void() HeadThink;


float(float w) RankForWeapon;


#ifdef hip_weapons
// in player.qc
#ifndef code_xents
void()	player_hampain1;
#endifdef
void()  player_laser1;
void()  player_hammer1;
void()  player_mjolnir1;

// in weapons.qc

void() W_FireProximityGrenade;
#endifdef

// debug stuff

#ifdef debug
void() WetsuitCheat;
void() EmpathyShieldsCheat;
void() Genocide;
void() DumpEntities;
void() DumpLiveEntities;
void() ToggleDump;
void() DumpCoordinates;
float dump_coord;
#endifdef

// in client.qc

#ifdef hip_weapons
#ifndef code_xents
float modelindex_hammer;
#endifdef
#endifdef

void(float num_bubbles) DeathBubbles;


#ifdef nondp
void() HIP_Precache;
#endifdef

float(vector v, entity e) sky_touch;