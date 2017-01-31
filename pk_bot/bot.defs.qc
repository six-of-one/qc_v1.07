// **************************************
// bot consts & protos
// **************************************

entity bot_lvlreload; // Cataboligne - make sure bots continue after level ends

#define MSG_UPDATENAME			13
#define MSG_UPDATEFRAGS		14
#define MSG_UPDATECOLORS		17

float observer_time;			// time limit for observer mode

float ax_dmg; // record melee damage in T_Damage so bots can avoid endless axe wars
void() Bot_Melee;

// if .state ==, call cacheRoute when touching this item
#define CACHE_ROUTE_TOUCH		-1559742
// if .state ==, call  bot_toucheditem when touching this item
#define BOT_TOUCHED				-2479551
// do both
#define BOT_TOUCHED_CACHE_ROUTE_TOUCH	-4039293

#define BOT_SAVE_SKILL			12 // number of bots that can save skill between levels for 1 players parms

// bot mask for flags
#define BOTS						240		// (serverflags)                 11110000
#define TEAMBOTS					3840		//  (serverflags)            111100000000
//#define UNRESTRICTED			4096 		//  (serverflags)           1000000000000 - admin - allow anyone to issue bot impulse commands
#define TEAMFLAG					16384		//  (serverflags)         100000000000000
#define INITLEVEL				32768		//  (serverflags)        1000000000000000 - server - indicate bots need to be spawned after level load
//#define FL_OBSERVER				65536 	//  (serverflags)       10000000000000000 - admin - flag for observer restrict
#define DEDICATED				4194304	//  (serverflags) 10000000000000000000000

// orig

#define DONT_WANT				0
#define KINDA_WANT				20
#define WANT						35
#define MUST_HAVE				100
#define SEARCH_RADIUS			600
//#define LOOPTIME					20
#define MAXPATHERS				16
#define REGULARTARGET	 		0
#define CARRIED					1
#define DROPPED					2
#define NEVERTARGET				3
#define TELEPORT					4
#define LOCAL_TIME				7
#define CANTURN					1
#define NOTURN					2

// left flags
#define STRAFE_DIR				16
#define FAR_SEEK					32
//#define WATERUPDOWN				64
#define NODROP					128
//#define RUNAWAY					256
#define GETGOODY					512
#define ONTRAIN					1024
#define MULTIENEMY				2048

// do item touch bot checks - disabled because PK has its own master touch
//.void() bot_item_touch; 

.float id;

// orig
.float(entity e) th_weight;
.float(entity node, float len, entity item) th_cache;
.void() th_update;
.float istrigger;

.vector lastseenpos;
.float enemyrun;
.float goody_time;
.float strafetime;
.float strafeonly;
.void() strafethink;
.float strafeyaw;
.float strafedist;
.entity movetarget2;
.entity movetarget3;
.entity movetarget4;
.entity movetarget5;
.entity movetarget6;
.entity lastbot;
.float lasttime;
.float pather;
.float pathtype;
.float skil;
.float rocketlen;
.entity rocketcache;
.float lightninglen;
.entity lightningcache;
.float armorlen;
.entity armorcache;
.float pendinglen;
.entity pendingcache;
.float naillen;
.entity nailcache;
.float grenadelen;
.entity grenadecache;
.float poweruplen;
.entity powerupcache;
.float enemylen;
.entity enemycache;
.float endpoint;
.string teamname;


float VERBOSEBOT;
float BOTSPEED;
float NUMBOTS;
float GRAVITY;
float MAXJUMP;
float INVGRENADELEVELDIST;
float GRENADEMAXHEIGHT;
float LEVELJUMPTIME;
float NUMPATHS;
float NUMGIBS;
float NUMPATHERS;
float SKINSMODE;
float RECURSEDEPTH;
vector REBOUNDSPOT;
float REBOUND;
float TELEFRAGFLAG;
entity NOISEQUEUE;
float HELPING;
float NAMEBOTS;


// Cataboligne - xrp add in code implement
#define XRP 1 // if true xrps code will be used - mostly extra messages from bots


float c_skill; // holder - carry skill for bot spawning

float last_time_left;
float randombotskin;
float nearlight;

//float max_clients; // *frikbot merge
// float active_clients;

//deprecated
//float fClientNo;
//float fActiveClients;
//void (float abba) MakeGood;
//void (float scoretype) PrintScores;
//float () FindGood;

// id bots
void() bot_fixer; // fix broke bots
#define BOT_FIX_TIME 14
#define BOT_FIXED 1 // if this is true and a bots frags dont change in the time out, kill & restart that bot

// waypoint limit
float noway_above;
float noway_below;
#define noway_radius 108 // no new waypoint in this radius

// client links
float () getrandombotskin;
void () NewCarriedPath;
void () initBotLevel;
void() bot_skinParms;
void() bot_skinDecode;
//void() set_CarriedPath;
void() set_initBotLevel;
void(float con) bot_con;
void(entity targ, entity attacker) bot_kill;
void() bot_changeParms;
void() bot_changelevel;
void() ai_botstand;

// item links
void(entity e) bot_item_linx;
void(entity e) bot_BackpackSetup;

// admin
void(float skl) AddAnotherBot;
void(entity e) removeBot;
void () setVerboseMode;

// takeover, solves print to bot issues
// inactive while installed with frikbot code, which was adapted

/*
void(entity	client, string s) stuffcmd;
void(entity	client, string s) sprint;
void(entity	client, string s) centerprint;
*/

// orig
float () CheckWaterLevel;
float () CheckDropPath;
void () DropBotPath;
void () endEnemy;
float () BotFoundTarget;
vector () botaim;
//void () botImpulseCommand;

// deprecated
//void () initscore;
//void (entity killer, entity killed) countkill;
void (entity ply, float n) removeTeamBots;
void (entity ply, float n) addTeamBots;
void (entity e, float newskin) skinChange;
void () NewCarriedPath;
void (entity a, entity b) addTarget;
void (entity en2) secondEnemy;
void () bot_toucheditem;
void (entity node, entity targ, float len, entity item) cacheRoute;
void () setBotGravity;
void () bot_touched;
void () enemy_touched;
void (entity bot) bot_triggered;

void (entity noisemaker, entity noiseobject) signalnoise;
float (entity e) hearnoise;
entity () noisetarget;
float (entity targ) Spotvisible;
float (entity targ) Platvisible;
float (vector spot) dropline;
void () secret_touch;
