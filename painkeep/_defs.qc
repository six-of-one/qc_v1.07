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

#ifdef code_pkplus
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

// air cannon

#define AIRG_EXCLUDEENTITY		1
#define AIRG_STEPCONVERTEDTOFLY	2

.float AIRG_Flags; // replace with cvar detect?

// turrets

.entity turret_base;
.float turret_ownertimeout;
.float turret_soundtimeout;
.float turret_timeout;

float PK_TUR_AMMO; // base cells to fire, 0 = infinite
float PK_TUR_HEAL; // health we get - base = 2/3 this, < 0 = no limit
float PK_TUR_QUADCON;
float PK_TURRETAMMO_MAX;
float PK_TUR_SET; // set non 0 when vars loaded1
float PK_TUR_TARGOWN; // time after which turret shoots owner, 0 = dont target owner
float PK_TUR_TIME; // time to live, after which explode, 0 = no timeout
float PK_TUR_VARIETY; // a variety of turrets - 

void(entity e, float tm) turret_KillStraker;
void() turret_dropTurret;

// b-traps

#define	beartrap_time		turret_timeout
#define	bt_immune_time	turret_soundtimeout

/// figure this out

string MAP_MODE; // genre of loaded map (if detected) Q quake (default), Q2 quake 2, Q3 quake 3, D doom, W wolf, PK painkeep


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

.entity tomb_target;
.entity tomb_touchable;
.float tomb_time;
.float tomb_immune_time;
.float tomb_death_time;
.float tombdmg_time;
.float tombsoundtime;
