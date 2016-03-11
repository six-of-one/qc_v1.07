/* ::-::
 *
 * Cataboligne
 *
 * file: _defs.qc 
 *
 * date: 016.2.19
 *
 * qc - painkeep module - extract from archon
 *
 */

#ifdef code_pkplus_
#define PK_ITEM_MASK				4095 // mask off non items bits
#else
#define PK_ITEM_MASK				255
#endifdef

float DEF_PK_ITEMS; // pk bit flags
#define PK_IT_AXE					1
#define PK_IT_GRAVITYWELL		2
#define PK_IT_TURRET				4
#define PK_IT_CANPAB				8
#define PK_IT_GRAPGUN			16
#define PK_IT_AIRGUN				32
#define PK_IT_CLIGHT				64
#define PK_IT_BEARTRAP			128

#define PKPLUS_IT_EGO					256
#define PKPLUS_IT_TOMB					512
#define PKPLUS_IT_ACTOR				1024
#define PKPLUS_IT_PHONE				2048

#define PK_IT_CARY				3982 // throwables - fire & forget - grav, turret, can, beartrap, ego, tomb, phone, actor
#define PK_IT_RANGE				112 // range weps - grap, airgun, chainthunder

#define PK_EXPL_DMG		-1666667	// tell fire code to use explode code

.float pk_gravitywellammo, pk_turretammo, pk_canpabammo, pk_beartrapammo;
.float pk_explode_ammo;
.float pk_currentInventory;
.float pk_currentitem;
.float pk_items;

.float pkprevweapon;

// protos

void()	pk_DmgSkin;

// pk  reference section
// these fields will get reused by vars ents

#ifdef reuse_fields
.entity pk_ent;
.float pk_timer;
.float pk_tout;
.float pk_sndtimer;
#endifdef

// hub

/// FIX: this is the score / activate things deal
float m_score_rel1;
float m_score_rel2;
float ply_count; // count 'em & weep

// only in hub - these need transition to std centerprint
#define	SVC_CENTERPRINT		26

#define PK_SF_HUB				1024	// moved to pk_flags
#define  PK_HUB2					131072 // bit if TRUE, using custom hub - only used for level transtion from hub vote

#define PK_TP_TIMEMASK			63

#define MOTDTIME					120		// The amount of "frames" for the motd message (minimum should be 20)
#define DONTALLOWBOTS			1		// If we want to show anti bots messages at startup

.float voteIntermission;
.float revotemsg;
.float hubstartupmessage;
.float messagetimeout;
.float laststattime;

// see if these are needed
string vmotd					= "\\/ersion \b3\b.\b0\b\n\n";
string motd2					= "\n\n[\\/\b1\b.\b1\b.\b0b\b] \b_-=\b* \bC\bataboligne\n\nhttp://www.moddb.com/mods/chaos-archon/\n\n";

float PK;									// if set true painkeep code is enabled
float pk_flags;							// replaces old usage of temp1, savedgamecfg stores this

entity theHub; // variable holding the hub
#define inHubMap	theHub
//float inHubMap;

float PK_ADMINMAP;						// if true this is an admin map command that overrides custom hub call from GotoNextMap
float custom_hub_loaded;				// if TRUE custom hub is used

float st_pk_hub;				// cvar to turn off hub - fix

float(float cn) bot_vote;			// bot...vote
void() hub_control_status;
void() updateStatusDisplay;

// grav

#define GRAV_PULL				0.5	// % chance a gravity well will pull a rune loose - mostly depends on player being caught on something and in range of pull
#define SGRAV_PULL				0.8	// % chance a super gravity well / reality bomb will pull a rune loose

float PK_GRV_TIME;
float PK_GRV_SET;
float PK_GRV_RSP; // special respawn override

// turrets

#ifdef reuse_fields
#define	turret_base	pk_ent
#define	turret_ownertimeout	pk_timer
#define	turret_soundtimeout	pk_sndtimer
#define	turret_timeout	pk_tout
#else
.entity turret_base;
.float turret_ownertimeout;
.float turret_soundtimeout;
.float turret_timeout;
#endifdef

float PK_TUR_AMMO; // base cells to fire, 0 = infinite
float PK_TUR_HEAL; // health we get - base = 2/3 this, < 0 = no limit
float PK_TUR_QUADCON;
float PK_TURRETAMMO_MAX;
float PK_TUR_SET; // set non 0 when vars loaded
float PK_TUR_TARGOWN; // time after which turret shoots owner, 0 = dont target owner
float PK_TUR_TIME; // time to live, after which explode, 0 = no timeout
float PK_TUR_VARIETY; // a variety of turrets - 

void(entity e, float tm) turret_KillStraker;
void() turret_dropTurret;

// b-traps

#define BT_BUFFER				2	  	// The nuber of rels people are immune to beartraps after spawning

#ifdef reuse_fields
#define	beartrap_time		pk_timer
#define	bt_immune_time	pk_sndtimer
#else
.float beartrap_time;
.float bt_immune_time;
#endifdef

// pulse spikes

void() pulse_rebound;

/// figure this out

string MAP_MODE; // genre of loaded map (if detected) Q quake (default), Q2 quake 2, Q3 quake 3, D doom, W wolf, PK painkeep

// air cannon / horn

#define AIRG_EXCLUDEENTITY			1
#define AIRG_STEPCONVERTEDTOFLY	2

.float AIRG_Flags; // replace with cvar detect?

// At the moment the AIRG_Flags variable is used only for the exclusion routine
// Constant used on the AIRG_Flags to specifiy that we have converted this
#define AIRG_EXCLUDEENTITY			1
#define AIRG_STEPCONVERTEDTOFLY	2

.entity AIRG_FlyTracker;
.float AIRG_BlastTimeout;				// Airblast origin, & viewing angle
.float AIRG_FireCount;
.float AIRG_Flags;
.float AIRG_Timeout;
// Setting an entity's AIRG_Flags excludes it from harm
.vector AIRG_BlastAngle;
.vector AIRG_BlastOrigin;

void(float firstBlast) horn_airblast;

// harpoon

#define VW_HARP_FRADJ        20 // frame adjust from run / stand for a fired harp

#define GRAP_CORNER				8
#define GRAP_FIXED				4 		// The length is fixed.
#define GRAP_HARPOON				7
#define GRAP_IDEAL				0 		// Going nothing
#define GRAP_IN					2 		// It's comming back to the owner
#define GRAP_OUT					1 		// It's outing out
#define GRAP_ROPE					9
#define GRAP_ROPELENGTHEN		6		// lengthen rope
#define GRAP_ROPESHORTEN		5 		// shorten rope
#define GRAP_TOHARPOON			3 		// lengthen rope

.entity grap_cornerchainNext;	// next in the rope corner chain.
.float grap_firetest;

vector(entity hent) grap_vw_adj;
void() grap_releaseHarpoon;
void() grap_maintainHarpoon;
void(entity grapOwner) grap_remove;

// chain thunderbolt

#ifndef HIPNOTIC
float discharged;
#endifdef

.entity bolt_lightningFire;
.entity bolt_target;	    				// current player firing at ...
.entity bolt_targetNext;				// next target in the chain...
.entity bolt_targetTimeoutEntity; 	// Entity timeout, used just for the nextthink!
.float bolt_changeModelTimeout;		// used to change the view weapon modal timeout.
.float bolt_conduitTimeout;			// Entity conduit timeout if the entity handles it...
.float bolt_targetNextTimeout; 		// used to timeout the bolt_targetNext...
.float bolt_targetTimeout; 			// used to timeout the bolt_target...

void()	bolt_s_explode1;
void() player_conduitJerk;

// pk plus

.float pkplus_actorammo;
//.float pkplus_actorskin;
//.float pkplus_actortype;
.float pkplus_egoammo;
.float pkplus_phoneammo;
.float pkplus_tombammo;

// tombs

#define PKPLUS_TOMB_TIMETOFOLLOW	20
#define TOMB_BUFFER						3
#define PKPLUS_TOMB_DMG				3
float PKPLUS_TOMB_TIME;
float PKPLUS_EGOAMMO_MAX;
float PKPLUS_TOMBAMMO_MAX;
float PKPLUS_ACTORAMMO_MAX;
float PKPLUS_PHONEAMMO_MAX;

float PK_TOMB_SET;

#ifdef reuse_fields
#define tomb_touchable	pk_ent
#define tomb_target	goalentity
#define tomb_time	pk_tout
#define tombsoundtime	pk_sndtimer
#define tomb_immune_time	pk_timer
#define tomb_death_time	air_finished
#define tombdmg_time		waitmin
#else
.entity tomb_target;
.entity tomb_touchable;
.float tomb_time;
.float tomb_immune_time;
.float tomb_death_time;
.float tombsoundtime;
#endifdef
.float tombdmg_time;

// ego

#ifdef reuse_fields
#define	orbitPosition		pk_timer
#define	egosoundtime		pk_sndtimer
#else
.float orbitPosition;
.float egosoundtime;
#endifdef

// phone

entity telesnd; // teleport sound effect (dest) global - so holdable can change sound played (hackish way to do things)