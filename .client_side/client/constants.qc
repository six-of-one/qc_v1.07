/*

Constants used only on the client.

*/

// add-entity mask bits
float MASK_ENGINE					= 1;
float MASK_ENGINEVIEWMODELS	= 2;
float MASK_NORMAL					= 4;

// renderflag bits
float RF_VIEWMODEL				= 1;
float RF_EXTERNALMODEL			= 2;
float RF_DEPTHHACK				= 4;
float RF_ADDATIVE					= 8;
float RF_USEAXIS					= 16;

// flags for 2d drawing
float DRAWFLAG_NORMAL       	= 0;
float DRAWFLAG_ADDITIVE     	= 1;
float DRAWFLAG_MODULATE     	= 2;
float DRAWFLAG_2XMODULATE   	= 3;

// setview parameter
float VF_MIN						= 1;	//(vector)
float VF_MIN_X						= 2;	//(float)
float VF_MIN_Y						= 3;	//(float)
float VF_SIZE						= 4;	//(vector) (viewport size)
float VF_SIZE_Y					= 5;	//(float)
float VF_SIZE_X					= 6;	//(float)
float VF_VIEWPORT					= 7;	//(vector, vector)
float VF_FOV						= 8;	//(vector)
float VF_FOVX						= 9;	//(float)
float VF_FOVY						= 10;	//(float)
float VF_ORIGIN					= 11;	//(vector)
float VF_ORIGIN_X					= 12;	//(float)
float VF_ORIGIN_Y					= 13;	//(float)
float VF_ORIGIN_Z					= 14;	//(float)
float VF_ANGLES					= 15;	//(vector)
float VF_ANGLES_X					= 16;	//(float)
float VF_ANGLES_Y					= 17;	//(float)
float VF_ANGLES_Z					= 18;	//(float)
float VF_DRAWWORLD				= 19;	//(float)
float VF_DRAWENGINESBAR			= 20;	//(float)
float VF_DRAWCROSSHAIR			= 21;	//(float)

float VF_CL_VIEWANGLES			= 33;	//(vector)
float VF_CL_VIEWANGLES_X		= 34;	//(float)
float VF_CL_VIEWANGLES_Y		= 35;	//(float)
float VF_CL_VIEWANGLES_Z		= 36;	//(float) 

// input events
float INPUT_KEYDOWN   			= 0;
float INPUT_KEYUP     			= 1;
float INPUT_MOUSEMOVE 			= 2;

// stats
// 0 - 31 are reserved for standard engine stats
// 32 - 128 are for QuakeC modders
float STAT_HEALTH					= 0;
//float STAT_FRAGS					= 1; // commented out in engine, not sure why
float STAT_WEAPONMODEL			= 2;
float STAT_AMMO					= 3;
float STAT_ARMOR					= 4;
float STAT_WEAPONFRAME			= 5;
float STAT_SHELLS					= 6;
float STAT_NAILS					= 7;
float STAT_ROCKETS				= 8;
float STAT_CELLS					= 9;
float STAT_ACTIVEWEAPON			= 10;
float STAT_TOTALSECRETS			= 11;
float STAT_TOTALMONSTERS		= 12;
float STAT_SECRETS				= 13; // bumped on client side by svc_foundsecret
float STAT_MONSTERS				= 14; // bumped by svc_killedmonster
float STAT_ITEMS					= 15;
float STAT_VIEWHEIGHT			= 16;
float STAT_VIEWZOOM				= 21;
float STAT_HIP_IT_EMPATY_SHIELD		= 56;
float STAT_HIP_IT_WETSUIT		= 57;

// defined in engine code

float STAT_FRAGLIMIT				= 235;
float STAT_TIMELIMIT				= 236;

// Archon extended HUD
float STAT_MCODE 					= 33; // track mcode of current weap in csqc - heh heh
float STAT_RUNEFLAG 				= 34; // track rune_flag
float STAT_PKM 					= 49; // track painkeep PK mode

float STAT_EXPSHELL 				= 35; // track splode shells - dual purpose spell cost
float STAT_PKINV 					= 36; // track pk inv - 3 weps
float STAT_PKWEP 					= 37; // track pk inv - cur wep

float STAT_PKGWELL 				= 38; // pki ammos
float STAT_PKTURR 				= 39; // pki ammos
float STAT_PKBT 					= 40; // pki ammos
float STAT_PKCOPB 				= 41; // pki ammos
float STAT_PKTOMB 				= 42; // pki ammos
float STAT_PKEGO 					= 43; // pki ammos
float STAT_PKPH 					= 44; // pki ammos
float STAT_PKMASK 				= 45; // pki ammos

float STAT_AMBUL 					= 46; // enh ammos
float STAT_AMSLUG 				= 47; // enh ammos
float STAT_AMGAS 					= 48; // enh ammos

float STAT_WSUIT 					= 49; // enh powers
float STAT_X_ITEMS 				= 50; // enh powers
float STAT_XP 						= 51; // xp for stuff
float STAT_DEADFLAG 				= 52; // for bones
float STAT_SILENCE 				= 53; // for bones

//float STAT_STK1 	= 50; // string data
//float STAT_STK2 	= 51; // string data

float STAT_VOL 					= 64; // track morph cost or chaos level
float STAT_MORPH 					= 65; // track morph cost or chaos level
float STAT_ARCHON 				= 66; // track archon power for power bar display

/// ***************************************************************************************
/// fooey.  these will be tricky to maintain since the list is built on the fly
///					this will need to be UPDATED everytime we add, re-arrange or change items
// note: some kind of query system could be added - via pk_mcode in server

#define MC_MASK						4095;			// Six - 017.1.12 mask off upper bits used for clr_x

float MC_AXE 						= 100;
float MC_SHOTGUN 					= 101;
float MC_SUPER_SHOTGUN 			= 102;

float MC_PULSE_NAILGUN 			= 135;
float MC_GRAP 						= 137;
float MC_CHTHUNDR 				= 136;
float MC_AIRGUN 					= 138;
float MC_EXPSHOTGUN		= 143;
float MC_HOOK 						= 148;
float MC_HIP_MJOLNIR 			= 149;
float MC_HIP_LASERCAN 			= 150;
float MC_HIP_PROXGUN 			= 151;
float MC_D_SAW						= 155;
float MC_D_PISTOL					= 156;
float MC_W_KNIFE					= 191;
float MC_Q2_BLASTER				= 210;
float MC_Q2_GRAPPLE				= 220;
float MC_Q2_RAILGUN 				= 218;
float MC_Q3_GAUNTLET				= 255;
float MC_Q3_GRAPPLE				= 256;
float MC_Q3_HOLDMEDKIT			= 286;
float MC_Q3_HOLDTELE				= 287;
float MC_C_FLAMER 				= 293;
float MC_DEEPSLEEP 				= 291;
float MC_QUANTUM	  				= 292;

float MC_PKC	  					= 1000;
float MC_PKC_OOR	  				= 1001; // out of range
float MC_MC	  						= 1002;
float MC_MCAS 						= 1004;

// pk inv - collectables
float PK_IT_AXE					= 1;
// now specials via x_ents
//float PK_IT_GRAPGUN				= 16;
//float PK_IT_AIRGUN				= 32;
//float PK_IT_CLIGHT				= 64;
float PK_IT_GRAPGUN				= 4194304;
float PK_IT_AIRGUN				= 8388608;
float PK_IT_CLIGHT				= 2097152;

float PK_IT_GRAVITYWELL			= 2;
float PK_IT_TURRET				= 4;
float PK_IT_BEARTRAP				= 8;
float PK_IT_CANPAB				= 128;
float PKPLUS_IT_EGO				= 256;
float PKPLUS_IT_TOMB				= 512;
float PKPLUS_IT_ACTOR			= 1024;
float PKPLUS_IT_PHONE			= 2048;

// runes - another fooey - rune powers can randomize...but we think these flag values are constant and only the appearance changes

float RUNE_FLG_RS					= 1;
float RUNE_FLG_DM					= 2;
float RUNE_FLG_HS					= 4;
float RUNE_FLG_RG					= 8;
float RUNE_AMMO					= 16; // no rune code yet - for packs
float RUNE_FLG_FLY				= 32; // no rune code yet - for q3
float RUNE_VAMPIRE				= 64; // lithium rune
float TECH_DSH						= 131072; // techs from lith - leaves 10 bits for new runes above
float TECH_AMP						= 262144;
float TECH_TEIM					= 524288;
float TECH_ADOC					= 1048576;

// archon vessel

float RUNE_VESS						= 65536; // archon has made a soul vessel, now read as a rune

// x items

float X_PWR_ARMOR					= 1;
float X_PWR_SCREEN				= 2;
float X_PWR_ARMOR_ON				= 4;
float X_PWR_SCREEN_ON			= 8;

float X_PWR_ARM_INV				= 3; // pwr armor bits
float X_PWR_ARM_MASK				= 12; // pwr armor on bits

float X_BASE_KEY					= 48; // first two keys (bits 16 & 32 call key_touch) for translated items

float X_D_KEY_BIT					= 1008; // any doom key bit - 1111110000

float X_D_KEY_CRED				= 16;
float X_D_KEY_CBLUE				= 32;
float X_D_KEY_CYEL				= 64;
float X_D_KEY_SKRED				= 128;
float X_D_KEY_SKBLUE				= 256;
float X_D_KEY_SKYEL				= 512;

float X_Q2_KEY_BIT				= 8176; // any q2 key bit - 1111111110000

float X_Q2_KEY_RED				= 16; // q2 has lots of keys.  good for tech runes / etc
float X_Q2_KEY_BLUE				= 32;
float X_Q2_KEY_PYRAMID			= 64;
float X_Q2_KEY_CUBE				= 128;
float X_Q2_KEY_PASS				= 256;
float X_Q2_KEY_AIRSTRK			= 512;
float X_Q2_KEY_DATACD			= 1024;
float X_Q2_KEY_CDSPIN			= 2048;
float X_Q2_KEY_CHEAD				= 4096; // note: second head key
// 8192

float X_D_MAP						= 16384;
float X_D_VIS						= 32768;

float X_PP							= 65536; // portable power point

float X_INV							= 122867; ///  11101111111110011

// holdable - indicate only
float X_Q3_HTEL					= 131072;
float X_Q3_HMED					= 262144;

// player flags, calculated in 
float PFL_DEAD     				= 4;
float PFL_GIBBED   				= 8;
const float		CONTENT_EMPTY	= -1;
const float		CONTENT_SOLID	= -2;
const float		CONTENT_WATER	= -3;
const float		CONTENT_SLIME	= -4;
const float		CONTENT_LAVA	= -5;
const float		CONTENT_SKY		= -6;
//float		STAT_VIEWHEIGHT		= 16; // defined above with rest

// morph states

float IMP_MCHAOS					= 6;	// string STI_MCHAOS			= "impulse 6";
float IMP_MORDER					= 7;	// string STI_MORDER			= "impulse 7";
//Techs:
float IMP_MHUMAN					= 12;	// string STI_MHUMAN			= "impulse 12"; // NOTE: char_q - standard quake guy

//.float char_mode; // genre of player character - set by selection to vars morph states
// cant be 1, 2, 4, 8, 16, 32
float CHAR_W						= 10;
float CHAR_D						= 11;
float CHAR_Q						= 12;
float CHAR_PK						= 13;
float CHAR_Q2						= 14;
float CHAR_Q3						= 15;


float IMP_MSPECIAL				= 62;	// string STI_MSPECIAL		= "impulse 62";
float IMP_MTECH					= 63;	// string STI_MTECH			= "impulse 63";

// NOTE: 64 can NOT be used here - it matches the bit value 64

float IMP_MENG						= 65;	// string STI_MENG			= "impulse 65";
//Medieval:
float IMP_MSHAPESHIFT			= 69;	// string STI_MDEMO			= "impulse 61";
float IMP_MWRAITH					= 70;	// string STI_MWRAITH		= "impulse 70";
float IMP_MTHAM					= 71;	// string STI_MTHAM			= "impulse 71";
float IMP_MDRACON 				= 72;	// string STI_MDRACON		= "impulse 72";
float IMP_MTHIEF					= 73;	// string STI_MTHIEF			= "impulse 73";
float IMP_MJUMP					= 81; // jump over undefined morph states in select
//Quake 2:
float IMP_MGUNNEY			 		= 81;	// string STI_MGUNNEY		= "impulse 81";
float IMP_MTANK	 				= 82;	// string STI_MTANK			= "impulse 82";
float IMP_MSUPTANK				= 83;	// string STI_MSUPTANK		= "impulse 83";
//Doomer:
float IMP_MIMP	 					= 84;	// string STI_MIMP			= "impulse 84";
float IMP_MCYBER	 				= 85;	// string STI_MCYBER			= "impulse 85";
float IMP_MARACHN			 		= 86;	// string STI_MARACHN		= "impulse 86";
//Beastie:
float IMP_MENF	 					= 87;	// string STI_MENF			= "impulse 87";
float IMP_MZOMBIE					= 88;	// string STI_MZOMBIE		= "impulse 88";
float IMP_MWIZARD					= 89;	// string STI_MSCRAG			= "impulse 89";
float IMP_MOGRE					= 90;	// string STI_MOGRE			= "impulse 90";
float IMP_MHKNIGHT				= 91;	// string STI_MHKNIGHT		= "impulse 91";
float IMP_MSHALR					= 92;	// string STI_MSHALR			= "impulse 92";
float IMP_MSHAMBLR				= 93;	// string STI_MSHAMBLR		= "impulse 93";
float IMP_MDEMON					= 94;	// string STI_MDEMON			= "impulse 94";
float IMP_MCTHON					= 95;	// string STI_MCTHON			= "impulse 95";
float IMP_MDRAGON					= 96;	// string STI_MDRAGON		= "impulse 96";
float IMP_MSCOURGE				= 97;	// string STI_MSCOURGE		= "impulse 97";
float IMP_MGREMLIN_F				= 98;	// string STI_MGREMLIN		= "impulse 98"; // flying gremlin
float IMP_MGREMLIN_L				= 99;

// monster bits

float CB_M_ARMY					= 1;
float CB_M_FISH					= 2;
float CB_M_KNIGHT					= 4;
float CB_M_DOG						= 8;
float CB_M_DEMON					= 16;
float CB_M_ENF						= 32;
float CB_M_HKNIGHT				= 64;
float CB_M_OGRE					= 128;
float CB_M_SHALR					= 256; // + super vore ?
float CB_M_SHAMBL					= 512;
float CB_M_SCRAG					= 1024;
float CB_M_ZOMBY					= 2048;
float CB_M_CTHON					= 4096; // boss
float CB_M_TARBABY				= 8192;
float CB_M_SCOURGE				= 16384;
float CB_M_SHUBS					= 32768;
float CB_M_SVORE					= 65536; // super vore
float CB_M_GREMLIN				= 131072;
float CB_M_VOMIT					= 262144; // guy id left out
float CB_M_SPIKEMINE				= 524288;	// Hipnotic spiked mine

// bits for makeit
float WEP_GWELL					= 128;
float WEP_TURRET					= 256;
float WEP_BTRAP					= 512;
float WEP_EXPSH					= 1024;
float WEP_GRAP						= 2048;
float WEP_AIRG						= 4096;
float WEP_CPNB						= 8192;

float WEP_EGO						= 16384;
float WEP_TOMB						= 32768;
float WEP_ACTOR					= 65536;
float WEP_PHONE					= 131072;