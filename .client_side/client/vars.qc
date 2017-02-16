/*

client/vars.qc

Variables that are needed in CSQC can be defined here.

*/

float vid_conwidth, vid_conheight;
float showscores;
var float ibar_flag = 0;
var float ibar = 0;
var float enginebar;
var float compass = 0;

var float autocvar_hud_weapons_offset = 0;
float weapons_offset;
var float waterfog = 0;

// finale and intermission
vector viewang, viewpos; 
vector discrepancy;
float finale;

// chaos mod mark II - the ARCH0NS

// items and extra items

float cl_items, x_items;

// inventory control

float items, items2, currentweap, cammo, mcode, archon, no_ammo;
float rune_flag, dmg_flare;
float pk_inv, pk_wep;

// flasher codes

float flasher, flashhl, flashawep, sterix_fl, nothuman, flashmhc;
float ALPHA_FULL, ALPHA_MEDIUM, ALPHA_LOW, ALPHA_90, p_alph;

// note setting > 1 will cause numbers of critical stats to flash on hud - health, current wep ammo, armor, etc
var float autocvar_hud_flash_numeral = 16;
// note setting > 1 will cause icons of critical stats to flash on hud - health, current wep ammo, armor, etc
var float autocvar_hud_flash_icon = 6;

// make drawn / unholstered weapon & ammo larger
var float autocvar_hud_bigwep = 1;

// scoring
float plscore;
string plname;

float p1, plnum, p3rd, pred, plead, fgl, topscore, rfgl, rhs, fraglimit;
var float autocvar_hud_frags_style = 3;
var float autocvar_hud_frags_mapname = 1;

var float autocvar_hud_frags = 6;

// has_* - once a mapcode item is detected, this allows holstered view
float has_laser, has_prox, has_pnail, has_hook, has_flamer1, has_deepsleep, has_ppoint, cnt_left, explflg;
float inv, quad, ring, suit, silencio, xplast, xpltime, deadtime, conrate, had_decod;

// hud special messaging system for cfg scripts
float hudmsg_timer, hudmsg_timer2, hudmsg_timer3;

// so we can use the new HUD with other mods / vanilla - set this cvar to one in a cfgs
var float autocvar_hud_nomod = 0;




















