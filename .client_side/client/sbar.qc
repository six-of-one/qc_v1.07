/*

client/sbar.qc

This is a slight redesign of the quake item bar.

*/

var float ibar_alpha = 1;

float SB_BOTTOM = 0;
float SB_MIDDLE = 1;
float SB_TOP    = 2;
float SB_BOTTOM_RIGHT = 3;
float sb_align;


//-----------------------------------------------------------------------------
// Custom hud config init / shutdown
//-----------------------------------------------------------------------------


void() Sbar_Init =
{
	enginebar = 1;
	if((cvar("viewsize") >= 115) && (cvar("viewsize") <= 119))
		{
			compass = 1;
			ibar_flag = cvar("viewsize") - 114;
			if (ibar_flag == 0 ) ibar = 0;
			else ibar = 1;
			if (ibar_flag == 3 ) enginebar = 0;
			cvar_set("viewsize", "110");
		}
	else if((cvar("viewsize") >= 110) && (cvar("viewsize") <= 114))
		{
			compass = 0;
			ibar_flag = cvar("viewsize") - 110;
			if (ibar_flag == 0 ) ibar = 0;
			else ibar = 1;
			if (ibar_flag == 3 ) enginebar = 0;
			cvar_set("viewsize", "110");
		}
	if(cvar("viewsize") == 101) compass = 1;

	weapons_offset = autocvar_hud_weapons_offset;
	var float autocvar_waterfog = 0;
	waterfog = autocvar_waterfog;

	if (((getkeybind(67)=="")&&(getkeybind(99) =="")))	localcmd("bind c compass\n");
	if (((getkeybind(88)=="")&&(getkeybind(120)=="")))	localcmd("bind x itembar\n");
	if (((getkeybind(70)=="")&&(getkeybind(102)=="")))	localcmd("bind f itembar\n");
	if (((getkeybind(82)=="")&&(getkeybind(114)=="")))	localcmd("bind r compass\n");
	if (((getkeybind(91)=="")&&(getkeybind(123)=="")))	localcmd("bind [ consizedown\n");
	if (((getkeybind(93)=="")&&(getkeybind(125)=="")))	localcmd("bind ] consizeup\n");


	cvar_set("vid_conheight", ftos(cvar("vid_conwidth")*cvar("vid_height")/cvar("vid_width")));
};

void() Sbar_Shutdown =
{
	if((cvar("viewsize") >= 110) && (cvar("viewsize") < 120))
	{
		if(compass == 1) cvar_set("viewsize", ftos(110 + ibar_flag + 5));
		else cvar_set("viewsize", ftos(110 + ibar_flag));
	}
	if((cvar("viewsize") >= 100) && (cvar("viewsize") < 110) && compass )
		cvar_set("viewsize", "101");
};


//-----------------------------------------------------------------------------
// Sbar_Draw functions
//-----------------------------------------------------------------------------

vector(vector v) sbar_align =
{
	if (sb_align == SB_MIDDLE)
	{
		v_x = v_x + (vid_conwidth / 2);
		v_y = v_y + (vid_conheight / 2);
		return v;
	}

	if (sb_align == SB_TOP)
	{
		v_x = v_x + (vid_conwidth / 2);
		// no change to v_y
		return v;
	}
	if (sb_align == SB_BOTTOM_RIGHT)
	{
		v_x = vid_conwidth - ( 320 - v_x );
		v_y = vid_conheight - v_y;
		return v;
	}

	// SB_BOTTOM - the default
	v_x = v_x + (vid_conwidth / 2);
	v_y = vid_conheight - v_y;
	return v;
};
 
/*
void(vector pos, string pic, float alph, float escala, float tre) Sbar_DrawPic2 =
{
	local vector siz;
	siz = drawgetimagesize(pic);
	siz_x = siz_x * escala;
	siz_y = siz_y * tre;
	
	//siz_x = drawgetimagesize(pic) * escala;
	//siz_y = drawgetimagesize(pic) * tre;

	pos = sbar_align(pos);
	drawpic(pos, pic, siz, VEC_1, alph, DRAWFLAG_NORMAL);
};
*/

void(vector pos, string pic, float alph, float escala) Sbar_DrawPic =
{
	local vector siz;
	siz = drawgetimagesize(pic) * escala;
	pos = sbar_align(pos);
	drawpic(pos, pic, siz, VEC_1, alph, DRAWFLAG_NORMAL);
};

void(vector pos, float char, float alph) Sbar_DrawCharacter =
{
	pos = sbar_align(pos);
	drawcharacter(pos, char, '8 8 0', VEC_1, alph, DRAWFLAG_NORMAL);
};

void(vector pos, string str, float alph,vector medida,vector coloracion) Sbar_DrawString =
{
	pos = sbar_align(pos);
	drawstring(pos, str, medida, coloracion, alph, DRAWFLAG_NORMAL);
};


void(vector pos, float num, float digits, float color, float alpha) Sbar_DrawNum =
{
	string pic, s, digit;
	float i, len, cnt;
	vector v;

	s = ftos(num);
	len = strlen(s);
	
	// draw the last 'digits' chars of s
	cnt = digits;
	if (len < digits) cnt = len;

	for (i=1; i<=cnt; i=i+1)
	{
		digit = substring(s, len - i, 1);
		if (digit == "-")
			digit = "minus";
		if (color)
			pic = strcat("gfx/anum_", digit);
		else
			pic = strcat("gfx/num_", digit);

		v = pos + ('24 0 0' * (digits - i));
		Sbar_DrawPic(v, pic, alpha,1);
	}
};


//-----------------------------------------------------------------------------
// Sbar_DrawCompass
//-----------------------------------------------------------------------------

vector(float x, float y) vec2 =
{
	vector v;
	v_x = x;
	v_y = y;
	return v;
};

void() Sbar_DrawCompass =
{

	sb_align = SB_TOP;

	local string compass_string, s, point;
	local float ang, yaw, ofs, i, strofs;
	
	compass_string = "N...ne...E...se...S...sw...W...nw...";
	compass_string = strconv(CONV_SAME, CONV_RED, CONV_RED, compass_string);
	point = strconv(CONV_SAME, CONV_RED, CONV_RED, ".");
	
	// Note: STAT_COMPASS_NORTH is a stat I was using in a server side
	// mod so that the level could change the north position of the compass (and basically
	// pretend that the entire level is aligned at any compass angle. I've left the code
	// here so that it's easy to add back.
	ang = 365 - (input_angles_y /* - GetStat_FLOAT_TRUNCATED(STAT_COMPASS_NORTH) */ );
	while (ang < 0)
	{ ang = ang + 360; }
	while (ang >= 360)
	{ ang = ang - 360; }
	
	ang = ang * 0.1;//(365 - angle) * 0.1;
	yaw = ceil(ang);
	ofs = (ceil(ang) - ang) * 8;
	yaw = yaw - 5;
	
	for (i=0; i<9; i=i+1)
	{
		strofs = yaw + i;
		if (strofs > 35)
			strofs = strofs - 36;
		if (strofs < 0)
			strofs = strofs + 36;
		// a hack to centre '.' characters a bit more
		// theres no centred red dot in conchars
		s = substring(compass_string, strofs, 1);
		if (s == point)
			Sbar_DrawString(vec2(-40 + ofs + i*8 + 2, 8 - 1), s, 1,'8 8 0','1 1 1' );
		else
			Sbar_DrawString(vec2(-40 + ofs + i*8, 8), s, 1,'8 8 0', '1 1 1');
	}
	
	s = strcat(chr2str(16), "        ", chr2str(17));
	Sbar_DrawString('-40 8 0', s, 1,'8 8 0','1 1 1');
};

//-----------------------------------------------------------------------------
// item by classic bite
//-----------------------------------------------------------------------------

// op -
// 	- 1 - quake items

string (float bc, float op) item_by_clbit =
{
	if (op == 1)
	{
		if (bc == IT_AXE)														return("an Axe");
		if (bc == IT_SHOTGUN)												return("a Shotgun");
		if (bc == IT_SUPER_SHOTGUN)										return("a Double barrel shotgun");
		if (bc == IT_NAILGUN)												return("a Nailgun");
		if (bc == IT_SUPER_NAILGUN)										return("a Perforator");
		if (bc == IT_GRENADE_LAUNCHER)									return("a Grenade launcher");
		if (bc == IT_ROCKET_LAUNCHER)										return("a Rocket launcher");
		if (bc == IT_LIGHTNING)												return("a Lightning gun");
		if (bc == IT_MJOLNIR)												return("Mjolnir");

		if (bc == IT_INVULNERABILITY)										return("a Pentagram");
		if (bc == IT_SUIT)													return("an Environmental suit");
		if (bc == IT_INVISIBILITY)											return("a Ring");
		if (bc == IT_QUAD)													return("a Quad damage");

		if (bc == IT_ARMOR1)													return("Green Armor");
		if (bc == IT_ARMOR2)													return("Yellow Armor");
		if (bc == IT_ARMOR3)													return("Red Armor");

		if (bc == IT_SUPERHEALTH)											return("Mega Health");

		if (bc == IT_KEY1)													return("Silver key");
		if (bc == IT_KEY2)													return("Gold key");

		if (bc == IT_SHELLS)													return("a box of Shells");
		if (bc == IT_NAILS)													return("a box of Spikes");
		if (bc == IT_ROCKETS)												return("a box of Rockets");
		if (bc == IT_CELLS)													return("a box of Cells");
	}

/// op 2

//	if (bc == MC_HEALTHROT)												return("item_health_15");
//	if (bc == MC_HEALTH)													return("item_health");
//	if (bc == MC_SIGIL1)													return("item_sigil1");
//	if (bc == MC_SIGIL2)													return("item_sigil2");
//	if (bc == MC_SIGIL4)													return("item_sigil4");
//	if (bc == MC_SIGIL8)													return("item_sigil8");

//	if (bc == MC_SIGIL16)												return("item_sigil16");
//	if (bc == MC_SIGIL32)												return("item_sigil32");
//	if (bc == MC_SIGIL64)												return("item_sigil64");

/// op 3
	if (op == 3)
	{
		if (bc == WEP_GWELL) return("a Gravity Well");
		if (bc == WEP_TURRET) return("an Auto Sentry");
		if (bc == WEP_BTRAP) return("a Beartrap");
		if (bc == WEP_EXPSH) return("Exploding shotgun shells");
		if (bc == WEP_GRAP) return("a Harpoon");
		if (bc == WEP_AIRG) return("an Air Cannon");
		if (bc == WEP_CPNB) return("a Can of Pork and Beans");

		if (bc == WEP_EGO) return("an Ego");
		if (bc == WEP_TOMB) return("a Tomb");
		if (bc == WEP_ACTOR) return("an Actor");
		if (bc == WEP_PHONE) return("a Phone");
	}
	return("");
};

//-----------------------------------------------------------------------------
// monster names
//-----------------------------------------------------------------------------

string(float mb) monster_id =
{
	local string s2;

	s2 = "";

	if (mb == CB_M_ARMY) 			s2 = "Army Grunt";
	if (mb == CB_M_FISH) 			s2 = "Fish";
	if (mb == CB_M_KNIGHT) 			s2 = "Knight";
	if (mb == CB_M_DOG) 				s2 = "Rabid Dog";
	if (mb == CB_M_DEMON) 			s2 = "Fiend";
	if (mb == CB_M_ENF) 				s2 = "Enforcer";
	if (mb == CB_M_HKNIGHT) 		s2 = "Hell Knight";
	if (mb == CB_M_OGRE) 			s2 = "Ogre";
	if (mb == CB_M_SHALR) 			s2 = "Shalrath";
	if (mb == CB_M_SHAMBL) 			s2 = "Shambler";
	if (mb == CB_M_SCRAG) 			s2 = "Scragg";
	if (mb == CB_M_ZOMBY) 			s2 = "Zomby";
	if (mb == CB_M_CTHON) 			s2 = "Cthon";
	if (mb == CB_M_TARBABY) 		s2 = "Spawn";
	if (mb == CB_M_SCOURGE) 		s2 = "Scourge";
	if (mb == CB_M_SHUBS) 			s2 = "Shub Niggurath";
	if (mb == CB_M_SVORE) 			s2 = "Vorerel";
	if (mb == CB_M_GREMLIN) 		s2 = "Gremlin";
	if (mb == CB_M_VOMIT) 			s2 = "Vomitus";
	if (mb == CB_M_SPIKEMINE) 		s2 = "Spike Mine";

	return(s2);
};

string(float mb) transmogrify =
{
	local string s2;

	s2 = "spike ball";

	if (mb == 1) 			s2 = "spike ball";
	if (mb == 2) 			s2 = "rocket box";
	if (mb == 4) 			s2 = "explode box";
	if (mb == 8) 			s2 = "gas cylinders";
	if (mb == 16) 			s2 = "batterys";
	if (mb == 32) 			s2 = "quad";
	if (mb == 64) 			s2 = "rocket launcher";
	if (mb == 128) 			s2 = "health box";
	if (mb == 256) 			s2 = "Chaos";
	if (mb == 512) 			s2 = "nodule";

	return(s2);
};

string(float mb) rune_power =
{
	local string s2;

	s2 = "unknown";

	if (mb == 1) 			s2 = "Resistance";
	if (mb == 2) 			s2 = "Damage";
	if (mb == 4) 			s2 = "Haste";
	if (mb == 64) 			s2 = "Vampire";
//	if (mb == 4194304		s2 = "Expulse (remove rune)";
	
	return(s2);
};



//-----------------------------------------------------------------------------
// Sbar_DrawInventory
//-----------------------------------------------------------------------------


// test mapcode mc and return TRUE if an infinite ammo weapon

float(float mc) inf_ammo_wep =
{
	if (mc == MC_AXE) return(TRUE);
	if (mc == MC_GRAP) return(TRUE);
	if (mc == MC_AIRGUN) return(TRUE);
	if (mc == MC_HOOK) return(TRUE);
	if (mc == MC_HIP_MJOLNIR) return(TRUE);
	if (mc == MC_DEEPSLEEP) return(TRUE);
	if (mc == MC_D_SAW) return(TRUE);
	if (mc == MC_D_PISTOL && (cammo == 0)) return(TRUE);
	if (mc == MC_W_KNIFE) return(TRUE);
	if (mc == MC_Q2_BLASTER) return(TRUE);
	if (mc == MC_Q2_GRAPPLE) return(TRUE);
	if (mc == MC_Q3_GAUNTLET) return(TRUE);
	if (mc == MC_Q3_GRAPPLE) return(TRUE);
	if (mc == MC_QUANTUM) return(TRUE);
	if (nothuman && (cammo ==1)) return(TRUE); // a morph with ammo 1 wep - assume builtin
	return(FALSE);
};

//  for the 4 small sized ammo counts on the right side
void(vector vcol, vector valor, float ammo, float transparencia) DrawAmmo =
{
	vector v;
	string s;
	v = valor;
	v_y = v_y + weapons_offset;

if (vcol != '0 0 0')
{
	if ((ammo >= 10) && (ammo <= 99)) v_x = v_x + 7;
	if ((ammo >= 0) && (ammo <= 9)) v_x = v_x + 14;
//	s = strconv(CONV_SAME, CONV_RED, CONV_WHITESPECIAL, ftos(ammo));
	Sbar_DrawString(v, ftos(ammo), transparencia, '7 7 0', vcol);
	return;
}
if (ammo >= 100)
{
	s = strconv(CONV_SAME, CONV_RED, CONV_WHITESPECIAL, ftos(ammo));
	Sbar_DrawString(v, s, transparencia, '7 7 0','0.5 0.7 1');
}
if ((ammo >= 10) && (ammo <= 99)) 
{
	v_x = v_x + 7;
	s = strconv(CONV_SAME, CONV_RED, CONV_WHITESPECIAL, ftos(ammo));
	Sbar_DrawString(v, s, transparencia, '7 7 0','1 1 1');
}
if ((ammo >= 0) && (ammo <= 9))
{
	v_x = v_x + 14;
	s = strconv(CONV_SAME, CONV_RED, CONV_WHITESPECIAL, ftos(ammo));
	Sbar_DrawString(v, s, transparencia, '7 7 0','1 0.5 0.5');
}
};

void(vector valor, string pic, float itemnum, float item2num, float transparencia, float scale) DrawInventory =
{
	vector v;
	v = valor;
	if (items & itemnum || items2 & item2num)
	{
		Sbar_DrawPic(v, pic, transparencia, scale);
	}
};
 
// scale - usual scale, cause some weps scale wrong
// spcl - pk wep, etc

void(vector valor, string pic1, string pic2, float itemnum, float scale, float spcl) DrawInventoryWeapon =
{
	vector v, y;
	string pic;
	float inv_alm, draw, has, bscale;
	float awepflash, awicofset, awicof;

	bscale = 1; // big scalar
// if invisible, ghost all holstered weps
	inv_alm = 1;
	if (items & IT_INVISIBILITY) inv_alm = 0.2;

	has = items & itemnum;
	draw = (currentweap == itemnum);

// testing pk weps
	if (spcl == STAT_PKWEP)
	{
		has = pk_inv & itemnum;
		draw = (pk_wep == itemnum);

// these are silly, but pk code does not clear inventory on switching to a non pk wep
		if ((pk_wep == PK_IT_AIRGUN) && (mcode != MC_AIRGUN)) draw = FALSE;
		if ((pk_wep == PK_IT_CLIGHT) && (mcode != MC_CHTHUNDR)) draw = FALSE;
		if ((pk_wep == PK_IT_GRAPGUN) && (mcode != MC_GRAP) && (mcode != MC_HOOK)) draw = FALSE;
	}

	if (has)
	{
		awepflash = 1;
		awicof = awicofset = 1;
		if (cammo >= 1)
		if (! inf_ammo_wep(mcode))
//		if (mcode != MC_HIP_MJOLNIR) // we dont flash the hammer - it has no ammo attack - now handled in inf_ammo_wep
		{
			if (cammo < autocvar_hud_flash_numeral) awepflash = flashawep;
			if (cammo < autocvar_hud_flash_icon) awicofset = flashawep;
		}

      v = valor;
		v_y = v_y + weapons_offset;    
		if (draw)
		{
			vector v_bl, v_c;
			if (autocvar_hud_bigwep) // make the drawn wep icon 2x
			{
				bscale = 2;
				v_x = v_x -  24;
				v_bl = '0 -3 0';
				v_c_y = 9; // dmg flare adjust
			}
			pic = pic2;
			inv_alm = 1;
// dang hacks
			if (pic1 == "gfx/inv_lightng") y = '24 0 0';
// code damage weps - color change &| dmg_flare
			if (dmg_flare > 1)
				Sbar_DrawPic(v + v_c + y, "gfx/dmg_flare2", ibar_alpha, 0.125 * bscale); // NOTE: scale deal
			if (dmg_flare)
				Sbar_DrawPic(v + v_c  + y, "gfx/dmg_flare", ibar_alpha, 0.125 * bscale);
			else
				if (!autocvar_hud_bigwep)
					Sbar_DrawPic(v + y + v_bl + '3 -16 0', "gfx/spell_bar", ibar_alpha, 0.5 * bscale);

// code hasted weps - dbl shadow image on active wep
			if ((rune_flag & RUNE_FLG_HS) || (rune_flag & TECH_TEIM))
				Sbar_DrawPic(v + '2 5 0', pic, ibar_alpha * 0.45, scale * bscale);

// live ammo count for drawn weapon
			if ((mcode == MC_HIP_MJOLNIR) && (cammo > 14) || ! inf_ammo_wep(mcode))
			if (!itemnum & no_ammo) // morph built in no ammo coding
			if (cammo > 0) DrawAmmo('0.3 0.3 1', v + y + '-24 4 0', ceil(cammo), ALPHA_FULL * awepflash);
			awicof = awicofset;

			if (autocvar_hud_bigwep)
			{
				v_y = v_y + 9; // move main icon up
				if (pic == "gfx/inv_lightng") v_x = v_x - 24;
				else if (pic == "gfx/inv2_lightng") v_x = v_x - 24;
				else if (pic == "gfx/inva2_lightng") v_x = v_x - 24;
			}
		}
		else
			pic = pic1;

		Sbar_DrawPic(v, pic, ibar_alpha * inv_alm * awicof, scale * bscale);
	}
};

void(vector valor, string pic1, float scale) DrawInventoryWeaponHip =
{
	string pic; pic = pic1;
	vector v; v = valor;
	v_y = v_y + weapons_offset;    
// code hasted weps - dbl image on active wep
	if ((rune_flag & RUNE_FLG_HS) || (rune_flag & TECH_TEIM))
		Sbar_DrawPic(v + '2 5 0', pic, ibar_alpha * 0.65, scale);

	Sbar_DrawPic(v, pic, ibar_alpha, scale);
};

void(vector valor, string pic, float transparencia, float scale) DrawInventoryAmmo =
{
	vector v;
	v = valor;
	v_y = v_y + weapons_offset;
	Sbar_DrawPic(v, pic, transparencia, scale);
}; 


// print score line for player #plr - 1 at vr
float use_lead, leader; // using leader score, dont print following catch up - its already printed as "leading by score"

float p2, p3, p4, p5, p6;

void(float plr, vector vr) score_line =
{
	float f, k;
	vector cl1, cl2, cl3;

	cl1 = '1 0.9 1';
	cl2 = '1 1 1';

	plscore = stof(getplayerkey(plr - 1, "frags"));
	f = fabs(plscore);

	if (plr == pred) // high score - red
	{
		cl1 = '1 0.4 0.4';
		cl2 = '1 0.1 0.1';
	}
	else
	if (plr == plnum) // on list, or forced top / bottom, blue style name & score
	{
		cl1 = '0.2 0.2 1';
		cl2 = '0.1 0.1 1';
	}
	plname = getplayerkey(plr - 1, "name");
	Sbar_DrawString(vr + '28 -12 0', plname, ALPHA_FULL, '7 7 0',cl1);

// display player score
	while (f > 999)
	{
		f = floor(f / 10);
		vr_x = vr_x - 7;
	}
	if (plscore < -99) vr_x = vr_x - 7; // compensate (-) sign
	if (plscore > -10 && plscore < 0) vr_x = vr_x + 7; // compensate wut?
	if (plscore > p3rd) DrawAmmo(cl2, vr, plscore, ALPHA_FULL);

// display range to fraglimit / high frag score
	if ((plr == plnum) || (autocvar_hud_frags_style & 128))
	{
		rfgl = FALSE;
		if (fraglimit)
		{
			vr_x = vr_x - 24;
			f = fraglimit - plscore;
			while (f > 999)
			{
				f = floor(f / 10);
				vr_x = vr_x - 7;
			}
			DrawAmmo('0.1 1 0.1', vr, floor(fraglimit - plscore), ALPHA_FULL); // fraglimit in green
			rfgl = TRUE;
		}

// display range (s) to high score, or leader value over 2nd place
		rhs = FALSE;
		if (use_lead && (autocvar_hud_frags_style & 128))
		{
			use_lead = FALSE;
			leader = TRUE; // because loop clears it and fudges the display
		}
		else
		if ((autocvar_hud_frags_style & 16) || (autocvar_hud_frags_style & 128))
		if (maxclients > 1)
		if (topscore > 0)
		if (topscore > plscore || pred == plnum)
		{
			cl3 = '0.76 0.12 1'; // score track clr - pts to high score
			vr_x = vr_x - 24;
			f = topscore - plscore;
			if ((pred == plnum) && (plr == pred))
			{
				leader = use_lead = TRUE;
 				if (plscore > plead) f = plscore - plead; // in 1st place - see if we outrank #2
				else leader = use_lead = FALSE;
				cl3 = '0.79 0.89 0.2'; // leading by score cce737
			}
			else rhs = 1;
			k = f;
			while (f > 999)
			{
				f = floor(f / 10);
				vr_x = vr_x - 7;
			}
			if (rhs || leader) DrawAmmo(cl3, vr, floor(k), ALPHA_FULL);
		}
	}
};

// scale power bar for console display

// pow - power level for bar indicator or sub level
// return:
// scl - the scaled value so bar will fit on screen

// scale chart																											1 unit =
// 0 - 100						- full scale, up to 100 screen units						1
// 101 - 5000				- 4900 scaled into 101 - 360 screen uinits			0.053
// 5001 - 60000+	- 55000 scaled into 361 - 480									0.00218
// max bar position capped at 480

float(float pow) bar_scale =
{
	local float scl;

	scl = pow;

	if (pow < 0)
		scl = 0;
	else if (pow > 5000)
		scl = 360 + ((pow - 5000) / 55000) * 120;
	else if (pow > 100)
		scl = 100 + ((pow - 100) / 4900) * 260;

	if (scl > 480) scl = 480;
	
	return(scl);
}

float svtime; // save time for next loop

void() Sbar_DrawInventory =
{

	ibar_alpha = cvar("sbar_alpha_fg");

	ALPHA_FULL = ibar_alpha;
	ALPHA_MEDIUM = ibar_alpha * 0.7;
	ALPHA_90 = ibar_alpha * 0.9;
	ALPHA_LOW = ibar_alpha * 0.4;

	float casting, converting, f, k, shells, rockets, nails, cells, health, armorval, explodeshot, explodsht_alp, inv_alm, slugs, bullets, gas, volspec, plevel, archon_magic, morph, xp;
	float pk_gwell, pk_tur, pk_bt, pk_copb, pk_tomb, pk_ego, pk_mask, pk_phone, wsuit, deadflag, silence, arcvessel;
	vector pwr_step, wep_step, pk_wep_step, wep_axlv, arc_level, chaos_level, p_level, woff, v, clr;

	float healflash, hicof, armorflash, armicof, flashclv;

	string wep_sg, wep_ssg, wep_nail, wep_snail, wep_gren, wep_rock, wep_light, wep_mj, wep_prox, wep_laser, wep_harp, wep_airgun, wep_clg, wep_axe, wep_pnail;
	string target1, target2, instr;

	var string autocvar_hud_vampire_target = "";
	var string autocvar_hud_target1 = "";
	var string autocvar_hud_target2 = "";

// active (drawn in hand) weapon icons
	wep_axe = "gfx/inv2_axe";
	wep_sg = "gfx/inv2_shotgun";
	wep_ssg = "gfx/inv2_sshotgun";
	wep_nail = "gfx/inv2_nailgun";
	wep_snail = "gfx/inv2_snailgun";
	wep_gren = "gfx/inv2_rlaunch";
	wep_rock = "gfx/inv2_srlaunch";
	wep_light = "gfx/inv2_lightng";
	wep_mj = "gfx/inv2_mjolnir";
	wep_prox = "gfx/inv2_prox_gren";
	wep_laser = "gfx/inv2_laser";
	wep_harp = "gfx/inv2_harp";
	wep_airgun = "gfx/inv2_aircan";
	wep_clg = "gfx/inv2_clg";
	wep_pnail = "gfx/inv2_pnail";

// get data from server

	shells  = GetStat_FLOAT_TRUNCATED(STAT_SHELLS);
	nails   = GetStat_FLOAT_TRUNCATED(STAT_NAILS);
	rockets = GetStat_FLOAT_TRUNCATED(STAT_ROCKETS);
	cells   = GetStat_FLOAT_TRUNCATED(STAT_CELLS);
	cammo   = GetStat_FLOAT_TRUNCATED(STAT_AMMO);

	health = GetStat_FLOAT_TRUNCATED(STAT_HEALTH);
	armorval = GetStat_FLOAT_TRUNCATED(STAT_ARMOR);

// Archon data
	archon = GetStat_FLOAT_TRUNCATED(STAT_ARCHON);
	morph = GetStat_FLOAT_TRUNCATED(STAT_MORPH);
	nothuman = TRUE;
	mcode = floor(GetStat_FLOAT_TRUNCATED(STAT_MCODE) / 256);
	rune_flag = GetStat_FLOAT_TRUNCATED(STAT_RUNEFLAG);

	arcvessel = (rune_flag & RUNE_VESS);

	volspec = GetStat_FLOAT_TRUNCATED(STAT_VOL);

	target1 = autocvar_hud_target1; //GetStat_STRING(STAT_STK1);
	target2 = autocvar_hud_target2; //GetStat_STRING(STAT_STK2);

// pk data
	pk_inv = GetStat_FLOAT_TRUNCATED(STAT_PKINV);
	pk_wep = GetStat_FLOAT_TRUNCATED(STAT_PKWEP);
	explodeshot = GetStat_FLOAT_TRUNCATED(STAT_EXPSHELL);
	explodsht_alp = ALPHA_LOW;
	if ((mcode == MC_SHOTGUN) || (mcode == MC_SUPER_SHOTGUN)) explodsht_alp = ALPHA_FULL;

	pk_gwell = GetStat_FLOAT_TRUNCATED(STAT_PKGWELL);
	pk_tur = GetStat_FLOAT_TRUNCATED(STAT_PKTURR);
	pk_bt = GetStat_FLOAT_TRUNCATED(STAT_PKBT);
	pk_copb = GetStat_FLOAT_TRUNCATED(STAT_PKCOPB);
	pk_tomb = GetStat_FLOAT_TRUNCATED(STAT_PKTOMB);
	pk_ego = GetStat_FLOAT_TRUNCATED(STAT_PKEGO);
	pk_mask = GetStat_FLOAT_TRUNCATED(STAT_PKMASK);
	pk_phone = GetStat_FLOAT_TRUNCATED(STAT_PKPH);

// enhanced data
	bullets = GetStat_FLOAT_TRUNCATED(STAT_AMBUL);
	slugs = GetStat_FLOAT_TRUNCATED(STAT_AMSLUG);
	gas = GetStat_FLOAT_TRUNCATED(STAT_AMGAS);
	wsuit = GetStat_FLOAT_TRUNCATED(STAT_WSUIT);
	silence = GetStat_FLOAT_TRUNCATED(STAT_SILENCE);

	cl_items = GetStat_FLOAT_TRUNCATED(STAT_ITEMS);
	x_items = GetStat_FLOAT_TRUNCATED(STAT_X_ITEMS);
	xp = GetStat_FLOAT_TRUNCATED(STAT_XP);

	deadflag = GetStat_FLOAT_TRUNCATED(STAT_DEADFLAG);
	if (!deadflag) deadtime = 0;
	else if (!deadtime) deadtime = time;

	items = GetStat_BITS(STAT_ITEMS, 0, 23);
	items2 = GetStat_BITS(STAT_ITEMS, 23, 9);
	currentweap = GetStat_FLOAT_TRUNCATED(STAT_ACTIVEWEAPON);
// end data

// damage addative in effect for drawn weapon
// code hot weps - images sbar didnt use in this set and dmg_flare gfx

	dmg_flare = 0;
	if (rune_flag & RUNE_FLG_DM) dmg_flare = 1;
	if (rune_flag & TECH_AMP) dmg_flare = dmg_flare + 1;
	if (cl_items & IT_QUAD) dmg_flare = dmg_flare + 1;
	if (dmg_flare)
	{
		wep_sg = "gfx/inva2_shotgun";
		wep_ssg = "gfx/inva2_sshotgun";
		wep_nail = "gfx/inva2_nailgun";
		wep_snail = "gfx/inva2_snailgun";
		wep_gren = "gfx/inva2_rlaunch";
		wep_rock = "gfx/inva2_srlaunch";
		wep_light = "gfx/inva2_lightng";
		wep_laser = "gfx/inva2_laser";
	}

// things detected by mapcode and stored in global - need global turned off when wep goes away, like with death

	if (! cl_items & IT_NAILGUN) has_pnail = FALSE;
	if (mcode == MC_PULSE_NAILGUN) has_pnail = TRUE;

	if (! cl_items & IT_SUPER_NAILGUN) has_laser = FALSE;
	if (mcode == MC_HIP_LASERCAN) has_laser = TRUE;

	if (! cl_items & IT_GRENADE_LAUNCHER)
	{
		has_prox = FALSE;
		has_flamer1 = FALSE;
	}
	if (mcode == MC_HIP_PROXGUN) has_prox = TRUE;
	if (mcode == MC_C_FLAMER) has_flamer1 = TRUE;

	has_deepsleep = FALSE;
	if (mcode == MC_DEEPSLEEP) has_deepsleep = TRUE;

	if (! pk_inv & PK_IT_GRAPGUN) has_hook = FALSE;
	if (mcode == MC_HOOK) has_hook = TRUE;

// timers for these - this times them out

	if (!cl_items & IT_INVISIBILITY) ring = 0;
	if (!cl_items & IT_SUIT) suit = 0;
	if (!cl_items & IT_QUAD) quad = 0;
	if (!cl_items & IT_INVULNERABILITY) inv = 0;
	if (!silence) silencio = 0;

if (ibar_flag)
{
	weapons_offset = autocvar_hud_weapons_offset;

	if (!enginebar) weapons_offset = weapons_offset - 12;
	woff = '0 0 0';
	woff_y = weapons_offset;

// flasher set

	flasher = 1;
	flashhl = 1;
	flashawep = 1;
	flashclv = 1;
	sterix_fl = 1;

	if (autocvar_hud_flash_numeral)
	{
		flasher = ((1 + (time * 10) & 3)/2);
		flashhl = ((1 + ((time + 0.1) * 10) & 3)/2);
		flashawep = ((1 + ((time + 0.2) * 10) & 3)/2);
		sterix_fl = ((1 + (time * 10) & 3)/3);
	}


/// runes area left adjust
	pwr_step = '-400 53 0';

sb_align = SB_BOTTOM; ///NOTE: should this be alignt left ?

/// Archon power bars

//note vid_conheight and vid_conwidth are very important for this - they need consulted or set

//	if (mcode == -665) archon_magic = 2; // using magic from archon pts - for now we use (-) volume
//	if (mcode == -666) archon_magic = 1; // chaos archon
//	if (mcode == -667) archon_magic = 1; // order archon - for diff color bars
	if (morph == IMP_MCHAOS) archon_magic = 1;
	if (morph == IMP_MORDER) archon_magic = 1;

	if (archon_magic)
	{
		if (explodeshot > 0)
			plevel = archon - explodeshot; // archon magic cost
		if (plevel < 0)
		{
			flashclv = flasher;
			cvar_set("hud_message", "Casting spell will severly reduce your archon level!");
		}
	}
	else
	if (volspec < 0) plevel = archon - fabs(volspec); // morph cube cost or power shots

	if (plevel < 0) plevel = 0; // IMP: warn on - result - red # or such

// IMP: diff colors for archons themselves, 
//shows spell usage at top of bar (reduction amount)

// scale chaos level bar
	chaos_level = '-412 0 0';
	chaos_level_y = bar_scale(volspec);
	
// scale archon level bar
	arc_level = '-412 0 0';
	arc_level_y = bar_scale(archon);

// scale plevel result mark
	p_level = '-412 0 0';
	p_level_y = bar_scale(plevel);

	if (archon > 0)
	if (chaos_level_y < arc_level_y + 4)
		chaos_level_x = -409; // move over for second bar

// casting - technically any process that uses up archon pts
	casting = FALSE;
	if (archon_magic && (explodeshot > 0)) casting = TRUE;
	if ((plevel > 0) && (volspec < 0)) casting = TRUE;

	p_alph = ALPHA_FULL;
	if (casting) p_alph = ibar_alpha * 0.35; // shade spell cost portion

	if (archon_magic == 1)
	if (volspec > 0)
		Sbar_DrawPic(chaos_level, "gfx/inv_chaos_bar", p_alph * 0.8, 1); // chaos / order power - mana

	if (archon != 0)
	{
		Sbar_DrawPic(arc_level, "gfx/inv_archon_bar", p_alph, 1);
		if  (arc_level_y < 4) arc_level_y = 3;
		if (archon < 0)
		{
			Sbar_DrawString(arc_level + '13 5 0', "-", ALPHA_FULL, '7 7 0','1 0.1 0.1');
			arc_level_x = arc_level_x + 2;
			k = floor(archon);
			while (k < -999)
			{
				k = floor(k / 10);
				pwr_step_x = pwr_step_x + 7;
			}
		}
		DrawAmmo('1 1 0.2', arc_level + '20 5 0' - woff, fabs(archon), ALPHA_FULL * flashclv);

// converting XP to archon points indicator

		if (xp > xplast) xplast = xp;

/* not time based anymore
		if (time > 240) conrate = 64;
		else if (time > 180) conrate = 32;
		else if (time > 120) conrate = 16;
		else if (time > 60) conrate = 8;
		else if (time > 30) conrate = 4;
		else if (time > 10) conrate = 2;
		else conrate = 1;
*/
		if ((xp < xplast) || (xpltime > time))
		if (xp > 0)
		{
			converting = TRUE; // was to move runes over before we handled (-) pts
			v = '36 14 0';

			if (xp != xplast)
			{
				xpltime = time + 4;
				if (xp < xplast) conrate = xplast - xp; // get altars current rate by this guestimate
			}
			xplast = xp;
// display conversion rate above XP pts
			if (conrate)
			{
				Sbar_DrawString(arc_level + '28 24 0', "cr", ALPHA_FULL, '7 7 0','1 0.5 1');
				DrawAmmo('0 0 0', arc_level + '38 24 0' - woff, fabs(conrate), ALPHA_FULL * flashhl);
			}

// display XP as they decrement during conversion
			Sbar_DrawString(arc_level + '20 14 0', "(", ALPHA_FULL, '7 7 0','1 0.5 1');
			Sbar_DrawString(arc_level + '28 15 0', ftos(floor(xp)), ALPHA_FULL, '7 7 0','1 0.5 1');
			k = floor(xp);
			while (k > 9)
			{
				k = floor(k / 10);
				v_x = v_x + 7;
			}
			Sbar_DrawString(arc_level + v, ")", ALPHA_FULL, '7 7 0','1 0.5 1');
// show quad power drive
			if (cl_items & IT_QUAD) DrawInventoryAmmo(arc_level + v + '8 16 0',"gfx/sb_quad",    ALPHA_FULL * 0.8, 1.5);
		}

// power cost of spell, cube, or morph (non Archon) power shot

		k = arc_level_y;

		if (casting)
		{
// make sure we have a visible usage amt at high archon levels where scale is minimal for small amts
			if (arc_level_y > 100)
			if ((arc_level_y - p_level_y) < 4) p_level_y = arc_level_y - 3;
			Sbar_DrawPic(p_level, "gfx/inv_archon_bar", ALPHA_FULL, 1);
// tic line for usage
			if (p_level_y < 1) p_level_y = 1;
			Sbar_DrawPic(p_level + '6 0 0', "gfx/spell_bar", ALPHA_FULL, 0.5);

//			if  (plevel < 10) p_level_y = p_level_y + 10 - plevel;
			if ((p_level_y < 7) && (arc_level_y > 10)) p_level_y = 7; // hold text amt here if poss.
			if (p_level_y > 6) DrawAmmo('0 0 0', p_level + '20 0 0' - woff, plevel, ALPHA_FULL);
			k = p_level_y;
		}
	}


	if (chaos_level_y > 0) // c/o power numeric
	{
		if (archon > 0)
		{
			if (chaos_level_y < k + 4) chaos_level_x = -409;
			if ((chaos_level_y >= (k - 14)) && (chaos_level_y <= (arc_level_y+ 8))) // dont over write archon pts - hold till passed
				chaos_level_y = k - 14;
			if (chaos_level_y < 7) chaos_level_y = arc_level_y + 9; // put above if arc level would lower off HUD
		}

		if  (volspec > 0)
			Sbar_DrawString(chaos_level + '20 5 0', ftos(volspec), ALPHA_FULL, '7 7 0','1 0.5 1');
	}

/// morph cube status here


/*
// test to find lowest val in left draw coords

	DrawAmmo('0 0 0', '-300 100 0', chaos_level_y, ALPHA_FULL);
	DrawAmmo('0 0 0', '-300 80 0', p_level_y, ALPHA_FULL);
	DrawAmmo('0 0 0', '-300 60 0', arc_level_y, ALPHA_FULL);
	DrawAmmo('0 0 0', '-300 40 0', cnt_left, ALPHA_FULL);
*/

// move runes over for low range digit display
	cnt_left = cnt_left + woff_y;

//	if ((archon < 0) && converting) // de-archoned & converting pts
//		pwr_step = '-370 53 0';

	if ((archon != 0) && (arc_level_y < cnt_left + 2))
		pwr_step_x = pwr_step_x + 30;
//		pwr_step = '-370 53 0';
//	if ((plevel > 0) && (p_level_y < cnt_left + 6))
	else if (casting && (p_level_y < cnt_left + 6))
		pwr_step_x = pwr_step_x + 30;
	else if ((volspec > 0) && (chaos_level_y < cnt_left + 2))
		pwr_step_x = pwr_step_x + 30;

	cnt_left = 0; // recount every time

// armor, health in bar 2, 3
// keys, artifacts in bar 3


	wep_step = '55 -10 0'; // morph ID's
	if (health > 999) wep_step = '65 -10 0';
	if (ibar_flag == 1) wep_step = '35 -10 0';
	if (ibar_flag > 2)
	{
		wep_step = '30 -27 0';
		DrawInventory(pwr_step + '10 -15 0' + woff, "gfx/sb_key1", IT_KEY1, 0, ALPHA_FULL, 1.4);
		DrawInventory(pwr_step + '0 -15 0' + woff, "gfx/sb_key2",IT_KEY2 , 0, ALPHA_FULL, 1.4);
		if (cl_items & (IT_KEY1 | IT_KEY2)) pwr_step_y = pwr_step_y + 4;
	}

/// hud message for cfg scripts - instead of console print which gets lost fast on busy servers
	
	var string autocvar_hud_message, autocvar_hud_message2, autocvar_hud_message3, autocvar_hud_message0;
	var float autocvar_hud_message_buffer = 3; // buffer messages per cvar
	var float autocvar_hud_message_timer = 10;
	var float autocvar_hud_message_offset = 250;
	var float autocvar_hud_message_dualpr = 0;
	var float autocvar_hud_rels = 0;
	vector hudoff;
	float huds, hudtime, timelimit, timeflasher, timeflasher2;
	vector cl1, cl2;

// for countdowns
	timelimit = cvar("timelimit"); //GetStat_FLOAT_TRUNCATED(STAT_TIMELIMIT);
	fraglimit = cvar("fraglimit"); //GetStat_FLOAT_TRUNCATED(STAT_FRAGLIMIT);

	if (ibar_flag > 2)
	{
// show HUD time if we replace the engine bar which has its own time - turn off for showtime
		if (autocvar_hud_rels)
		if (!cvar("showtime"))
		{
			hudtime = time;
			timeflasher = 1;
			timeflasher2 = 1;
			cl1 = '1 0.9 1';
			cl2 = '1 1 1';
			if (timelimit > 0)
			{
				hudtime = timelimit - time;
				if (hudtime < autocvar_hud_flash_numeral)
				{
					cl2 = '1 0.4 0.4';
					timeflasher = flasher;
				}
				if (hudtime < autocvar_hud_flash_icon)
				{
					cl2 = cl1 = '1 0.1 0.1';
					timeflasher2 = flashhl;
				}
			}
			if (autocvar_hud_rels == 1)
			{
				v = '0 0 0';
				
				k = hudtime;
				while (k > 999)
				{
					k = floor(k / 10);
					v_x = v_x - 7;
				}
				DrawAmmo(cl2, '244 26 0' + v, floor(hudtime), ALPHA_FULL * timeflasher);
				Sbar_DrawString('271 26 0' + woff, "rels", ALPHA_FULL * timeflasher2, '7 7 0',cl1);
			}
			else
			{
				k = floor(hudtime/60);
				f = floor(hudtime - (k * 60));
				DrawAmmo(cl2, '256 26 0', k, ALPHA_FULL * timeflasher);
				Sbar_DrawString('278 25 0' + woff, ":", ALPHA_FULL * timeflasher, '7 7 0',cl1);
				if (f < 10)
				Sbar_DrawString('285 26 0' + woff, "0", ALPHA_FULL * timeflasher, '7 7 0',cl2);
				DrawAmmo(cl2, '279 26 0', f, ALPHA_FULL * timeflasher);
			}
		}

// STATS section

// map
		
	string mn, m2, mdg;

// mod gamedir name
		mdg = cvar_string("fs_gamedir");

// map load name
		mn = substring(mapname, 5, strlen(mapname)); // strip maps/
		m2 = substring(mn, 0, strlen(mn) - 4); // strip .bsp

// player
		plnum = -1;

// score board ranking slot - set by server qc
// I can find no other way to get this # here
		plnum = cvar("cl_number") + 1;
		plname = getplayerkey(plnum - 1, "name");
		plscore = stof(getplayerkey(plnum - 1, "frags"));

	string clnick, clut, clutmap, clutmod, clscmap;
//	mn = substring(mapname, 5, strlen(mapname));
//	m2 = substring(mn, 0, strlen(mn) - 4);
//	mn = strcat("map_title_", m2); // attempt to find a user set conversion cvar

	float timep;
	float cl_uptime, cl_maptime, cl_modtime, cl_mapscore;

// client stat nick - option for fancy names
		clnick = cvar_string("cl_nick");
		if (clnick == "") clnick = plname;

// client total uptime
		clut = strcat("cl_uptime_", clnick);
// client mod uptime
		clutmod = strcat("cl_uptime_",mdg);
// client map uptime
		clutmap = strcat("cl_uptime_",m2);
// client map high score
		clscmap = strcat("cl_mapscore_",m2);

// tme passed since last stat update
		timep = time - svtime;

		if (timep >= 1.0) // track stats every second
		{

// score on this map
			if (!cl_mapscore) cl_mapscore = cvar(clscmap);

			if (cl_mapscore < plscore) cl_mapscore = plscore;
			
			localcmd("seta ");
			localcmd(clscmap);
			localcmd("\" ");
			localcmd(ftos(cl_mapscore));
			localcmd("\"\n");
			
// total up
			if (!cl_uptime) cl_uptime = cvar(clut);
			
			if (cl_uptime < time) cl_uptime = time;
			else cl_uptime = cl_uptime + timep;

			localcmd("seta \"");
			localcmd(clut);
			localcmd("\" \"");
			localcmd(ftos(cl_uptime));
			localcmd("\"\n");

// mod up
			if (!cl_modtime) cl_modtime = cvar(clutmod);
			
			if (cl_modtime < time) cl_modtime = time;
			else cl_modtime = cl_modtime + timep;

			localcmd("seta \"");
			localcmd(clutmod);
			localcmd("\" \"");
			localcmd(ftos(cl_modtime));
			localcmd("\"\n");

// map up
			if (!cl_maptime) cl_maptime = cvar(clutmap);
			
			if (cl_maptime < time) cl_maptime = time;
			else cl_maptime = cl_maptime + timep;

			localcmd("seta \"");
			localcmd(clutmap);
			localcmd("\" \"");
			localcmd(ftos(cl_maptime));
			localcmd("\"\n");

// save last time setting for add to stats
			svtime = time;
		}

// client map uptime

	float p2nd, style, pself;
	float mons, secs, tmon, tsec, flashermhc, flasher2mhc;
	var float autocvar_hud_frags_off = 0;
	var float autocvar_hud_frags_negative = 0;
	var float autocvar_master_high_score = 6;
	var string autocvar_master_high_nick = "_-=* [Six]";
// score stats package client side
	var float autocvar_hud_keepscores = 1;

// scores on new HUD
// singleplayer:
// 	display monster & secret counts

// for single player / coop
			mons = GetStat_FLOAT_TRUNCATED(STAT_MONSTERS);
			tmon = GetStat_FLOAT_TRUNCATED(STAT_TOTALMONSTERS);
			secs = GetStat_FLOAT_TRUNCATED(STAT_SECRETS);
			tsec = GetStat_FLOAT_TRUNCATED(STAT_TOTALSECRETS);

			style = autocvar_hud_frags_style & 3; // mask off bit 8

			pself = 0;

			k = maxclients;
			plead = p2 = p3 = p4 = p5 = p6 = 0;

// idic - logic for display of scores
			p2nd = 0;
			if (autocvar_hud_frags_negative)
			{
				if (autocvar_hud_frags_negative < 0) p2nd = autocvar_hud_frags_negative;
				else p2nd = -32767;
			}
			p3rd = p2nd;

			pred = -1; // this player number will be red in score list
			fgl = 0;
// get player num with top score on list
			while (k > 0)
			{
				plscore = stof(getplayerkey(k - 1, "frags"));
//				if (plscore > 32767) plscore = 32767; // this is coming in a signed short
				if (plscore >= p2nd)
				{
					pred = p1 = k;
					topscore = p2nd = plscore;
				}
				k = k - 1;
			}
// frag limit countdown message
			fgl = 0;
			if (fraglimit)
			{
				f = fraglimit - topscore;
				if (f < 7) fgl = floor(f); // show (< 7) frags left at bottom or score list
			}
			if (p1 == plnum && p2nd != p3rd) pself = TRUE;

			if (autocvar_hud_frags_style & 32) // always on top - steals slot one
			if (p1 != plnum)
			{
				pself = TRUE;
				p1 = plnum;
			}

// nasty brute force trickle down sort
			if (maxclients > 1)
			{
				k = maxclients;
				p2nd = p3rd;
				while (k > 0)
				{
					plname = getplayerkey(k - 1, "name");
					if (plname != "")
					if (k != p1)
					{
						plscore = stof(getplayerkey(k - 1, "frags"));
						if (plscore >= p2nd)
						{
							p2 = k;
							plead = p2nd = plscore;
						}
					}
					k = k - 1;
				}
				if (p2 == plnum && p2nd != p3rd) pself = TRUE;

				if (maxclients > 2)
				{
					k = maxclients;
					p2nd = p3rd;
					while (k > 0)
					{
						plname = getplayerkey(k - 1, "name");
						if (plname != "")
						if (k != p1 && k != p2)
						{
							plscore = stof(getplayerkey(k - 1, "frags"));
							if (plscore >= p2nd)
							{
								p3 = k;
								p2nd = plscore;
							}
						}
						k = k - 1;
					}
					if (p3 == plnum && p2nd != p3rd) pself = TRUE;
				}

				if (maxclients > 3)
				{
					k = maxclients;
					p2nd = p3rd;
					while (k > 0)
					{
						plname = getplayerkey(k - 1, "name");
						if (plname != "")
						if (k != p1 && k != p2 && k != p3)
						{
							plscore = stof(getplayerkey(k - 1, "frags"));
							if (plscore >= p2nd)
							{
								p4 = k;
								p2nd = plscore;
							}
						}
						k = k - 1;
					}
					if (p4 == plnum && p2nd != p3rd) pself = TRUE;
				}

				if (maxclients > 4)
				{
					k = maxclients;
					p2nd = p3rd;
					while (k > 0)
					{
						plname = getplayerkey(k - 1, "name");
						if (plname != "")
						if (k != p1 && k != p2 && k != p3 && k != p4)
						{
							plscore = stof(getplayerkey(k - 1, "frags"));
							if (plscore >= p2nd)
							{
								p5 = k;
								p2nd = plscore;
							}
						}
						k = k - 1;
					}
					if (p5 == plnum && p2nd != p3rd) pself = TRUE;
				}

				if (maxclients > 5)
				{
					k = maxclients;
					p2nd = p3rd;
					while (k > 0)
					{
						plname = getplayerkey(k - 1, "name");
						if (plname != "")
						if (k != p1 && k != p2 && k != p3 && k != p4 && k != p5)
						{
							plscore = stof(getplayerkey(k - 1, "frags"));
							if (plscore >= p2nd)
							{
								p6 = k;
								p2nd = plscore;
							}
						}
						k = k - 1;
					}
					if (p6 == plnum && p2nd != p3rd) pself = TRUE;
				}
			}

		if (autocvar_hud_frags > 0)
		{

			float intoff_frags = -140; // internal offset
			k = autocvar_hud_frags; // player preference cfg cnt <= 6
			if (k > 6) k = 6;
			v = '0 0 0';
			v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
			v_y = vid_conheight;

			if (cvar("deathmatch"))
			{
				leader = FALSE;
				if (!pself && (style == 3))
				{
					score_line(plnum, v);
					v_y = v_y - 10;
				}
				plscore = stof(getplayerkey(p1 - 1, "frags"));
// top score
				if (plscore > p3rd)
				{
					score_line(p1, v);
					v_y = v_y - 10;
				}
				k = k - 1;
				if ((k > 0) && p2 > 0)
				{
					plscore = stof(getplayerkey(p2 - 1, "frags"));
					if (plscore > p3rd)
					{
						score_line(p2, v);
						v_y = v_y - 10;
					}
					k = k - 1;
				}
				if ((k > 0) && p3 > 0)
				{
					plscore = stof(getplayerkey(p3 - 1, "frags"));
					if (plscore > p3rd)
					{
						score_line(p3, v);
						v_y = v_y - 10;
					}
					k = k - 1;
				}
				if ((k > 0) && p4 > 0)
				{
					plscore = stof(getplayerkey(p4 - 1, "frags"));
					if (plscore > p3rd)
					{
						score_line(p4, v);
						v_y = v_y - 10;
					}
					k = k - 1;
				}
				if ((k > 0) && p5 > 0)
				{
					f = plscore = stof(getplayerkey(p5 - 1, "frags"));
					if (plscore > p3rd)
					{
						score_line(p5, v);
						v_y = v_y - 10;
					}
					k = k - 1;
				}
				if ((k > 0) && p6 > 0)
				{
					f = plscore = stof(getplayerkey(p6 - 1, "frags"));
					if (plscore > p3rd)
					{
						score_line(p6, v);
						v_y = v_y - 10;
					}
				}
				if (!pself && (style == 2))
				{
					score_line(plnum, v);
					v_y = v_y - 10;
				}
				if (style)
				{
					if (fgl)
					{
						Sbar_DrawString(v + '28 -12 0', "frags left !", ALPHA_FULL * flashawep, '7 7 0','1 0.2 0.2');
						DrawAmmo('1 0.2 0.2', v, floor(fgl), ALPHA_FULL * flashhl);
						v_y = v_y - 10;
					}
					if (rfgl)
					{
						Sbar_DrawString(v + '28 -12 0', "* to fraglimit", ALPHA_FULL, '7 7 0','0.1 1 0.1');
						v_y = v_y - 10;
					}
					if (leader)
					{
//							Sbar_DrawString(v + '28 -12 0', "* leading by", ALPHA_FULL, '7 7 0','0.76 0.12 1');
						Sbar_DrawString(v + '28 -12 0', "* leading by", ALPHA_FULL, '7 7 0','0.79 0.89 0.2');
						v_y = v_y - 10;
					}
					if (rhs)
					{
						Sbar_DrawString(v + '28 -12 0', "* to high score", ALPHA_FULL, '7 7 0','0.76 0.12 1');
						v_y = v_y - 10;
					}
				}
// master score
				if (!autocvar_hud_frags_style & 64)
				if (autocvar_master_high_score > 0)
				{
					flashermhc = 1;
					flasher2mhc = 1;
					if (flashmhc < time) // periodic flash mhc title - like in the arcades
					{
						flashmhc =  time + 210 + random() * 20;
						if (random() < 0.1) flashmhc =  time + 410 + random() * 40;
					}
					if (flashmhc > (time + 200) && flashmhc < (time + 210)) flashermhc =  flasher; // 10 secs flash
					if (flashmhc > (time + 180) && flashmhc < (time + 196)) flasher2mhc = flashhl; // 16 secs flash

					f = autocvar_master_high_score;
					while (f > 999)
					{
						f = floor(f / 10);
						v_x = v_x - 7;
					}
					Sbar_DrawString(v + '0 -12 0', "Master high score", ALPHA_FULL * flashermhc, '7 7 0','1 0.5 1.0'); // note: title aligns with score value
					v_y = v_y - 10;
					DrawAmmo('1 0.5 1.0', v, autocvar_master_high_score, ALPHA_FULL * flasher2mhc);
					v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
					Sbar_DrawString(v + '28 -12 0', autocvar_master_high_nick, ALPHA_FULL * flasher2mhc, '7 7 0','1 0.5 1.0');
					v_y = v_y - 10;
				}
				
			}

// in single player & coop - display monsters killed & secrets found
// also display in DM if bit 8 set in *_style
			if (!cvar("deathmatch") || (autocvar_hud_frags_style & 8))
			{
// really not DM - give player name
				if (!cvar("deathmatch"))
				{
					v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
					f = plscore = stof(getplayerkey(p1 - 1, "frags"));
					plname = getplayerkey(p1 - 1, "name");
					Sbar_DrawString(v + '28 -12 0', plname, ALPHA_FULL, '7 7 0','1 0.4 0.4');
					if (plscore > p3rd)
					{
						while (f > 999)
						{
							f = floor(f / 10);
							v_x = v_x - 7;
						}
						DrawAmmo('1 0.1 0.1', v, plscore, ALPHA_FULL);
					}
					v_y = v_y - 10;
				}
// not DM, or DM and bit 8 set in style - load monster & secret counts
				cl1 = '1 0.9 1';
				cl2 = '1 1 1';
				v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
				if (mons > 0)
				{
					Sbar_DrawString(v + '28 -12 0', "monsters of ", ALPHA_FULL, '7 7 0',cl1);
					f = mons;
					while (f > 999)
					{
						f = floor(f / 10);
						v_x = v_x - 7;
					}
					DrawAmmo('1 0.1 0.1', v, mons, ALPHA_FULL);
					v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
					f = tmon;
					if (f < 10) v_x = v_x - 7;
					if (f > 99) v_x = v_x + 7;
/*
					while (f > 99)
					{
						f = floor(f / 10);
						v_x = v_x + 7;
					}
*/
					DrawAmmo(cl2, v + '102 0 0', tmon, ALPHA_FULL);
					v_y = v_y - 10;
				}
				v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
				if (secs > 0)
				{
					f = secs;
					while (f > 999)
					{
						f = floor(f / 10);
						v_x = v_x - 7;
					}
					DrawAmmo('0.1 0.1 1', v, secs, ALPHA_FULL);
					Sbar_DrawString(v + '28 -12 0', "secrets  of", ALPHA_FULL, '7 7 0',cl1);
					f = tsec;
					if (f < 10) v_x = v_x - 7;
					if (f > 99) v_x = v_x + 7;
					DrawAmmo(cl2, v + '102 0 0', tsec, ALPHA_FULL);
					v_y = v_y - 10;
				}
			}
// include map name - translate bsp name if we know it - could also be world.message
			if (autocvar_hud_frags_mapname)
			{
				cl1 = '0.9 0.9 1';
				Sbar_DrawString(v + '28 -12 0', "Map:", ALPHA_FULL, '7 7 0',cl1);
// translator
// maker supplied a map_ cvar - format map_{mapname} in a cfg file - which the server runs for each map ~/cfg/map/{mapname}.cfg
// could also place them in any cfg file, like info.cfg
// example: dm1
// in ~/cfg/map/dm1.cfg
// set map_title_dm1 "Place of Two Deaths"
				mn = strcat("map_title_", m2); // attempt to find a user set conversion cvar
// a few re-names
				if (cvar_string(mn) != "") m2 = cvar_string(mn);
				else if (m2 == "ac1") m2 = "Ariochs Castle";
				else if (m2 == "chv_hub") m2 = "Chaos Heaven [hub]";
				else if (m2 == "dm4_dark") m2 = "Bad Place [dark]";
// server tries to set this from world.message when player connects
				else if (cvar_string("map_title_world") != "") m2 = cvar_string("map_title_world");


				f = strlen(m2) - 15;
				v_x = (vid_conwidth / 2) + intoff_frags + autocvar_hud_frags_off;
				if (f > 0) v_x = v_x - (f * 7);
				Sbar_DrawString(v + '28 -22 0', m2, ALPHA_FULL, '7 7 0',cl1);

			}
			
		}

// new message system - persistent with timeout, settable from cfg files / code
		if (autocvar_hud_message != "")
		{
			huds = autocvar_hud_message_buffer; // # lines in buffer

 			if (autocvar_hud_message != autocvar_hud_message0) // message changed
			{
				if (huds > 3) huds = 3;
				if (huds == 3)
				{
					hudmsg_timer3 = hudmsg_timer2 - 2;
					cvar_set("hud_message3", autocvar_hud_message2);
					huds = huds - 1;
				}
				if (huds == 2)
				{
					hudmsg_timer2 = hudmsg_timer - 2;
					cvar_set("hud_message2", autocvar_hud_message0);
				}
				cvar_set("hud_message0", autocvar_hud_message);

				if (autocvar_hud_message_dualpr) // dual print every message to console
				{
					print(autocvar_hud_message);
					print("\n"); // so far none of these <\n> at the end
				}
			}

			hudoff_x = autocvar_hud_message_offset;
			if (!hudmsg_timer)
			if (autocvar_hud_message_timer > 0) hudmsg_timer = time + autocvar_hud_message_timer;
			else hudmsg_timer = time + 10; // default of 10 for nothing

			Sbar_DrawString(pwr_step + wep_step + woff + hudoff, autocvar_hud_message, ALPHA_FULL , '7 7 0','1 0.5 0.5');
			hudoff_y = hudoff_y + 9;
		}

		if (hudmsg_timer)
		if (hudmsg_timer < time)
		{
			hudmsg_timer = 0;
			cvar_set("hud_message", "");
		}
		if (hudmsg_timer2)
		if (hudmsg_timer2 < time)
		{
			hudmsg_timer2 = 0;
			cvar_set("hud_message2", "");
		}
		else
		{
			Sbar_DrawString(pwr_step + wep_step + woff + hudoff, autocvar_hud_message2, ALPHA_FULL , '7 7 0','1 0.5 0.5');
			hudoff_y = hudoff_y + 9;
		}
		if (hudmsg_timer3)
		if (hudmsg_timer3 < time)
		{
			hudmsg_timer3 = 0;
			cvar_set("hud_message3", "");
		}
		else
		{
			Sbar_DrawString(pwr_step + wep_step + woff + hudoff, autocvar_hud_message3, ALPHA_FULL , '7 7 0','1 0.5 0.5');
			hudoff_y = hudoff_y + 9;
		}
	}
	else // they get printed if not full custom HUD
	{
		if (autocvar_hud_message != "")
		{
			print(autocvar_hud_message);
			print("\n"); // so far none of these <\n> at the end
			cvar_set("hud_message", "");
		}
	}

/// morph ident and weapon / spell description and special status items

	no_ammo = 0;

	if (ibar_flag)
	{
		k = 1;
		huds = 0;
		if (!deadflag)
		{
			if (cl_items & IT_INVISIBILITY) k = 0.2;

			if (mcode == MC_PKC || mcode == MC_PKC_OOR)
			{
				DrawInventoryAmmo(pwr_step + wep_step + '200 60 0', "gfx/pkcb", ALPHA_FULL * k, 0.5);
				Sbar_DrawString(pwr_step + wep_step + woff + '202 65 0', "Cube active", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
				if (mcode == MC_PKC)
					Sbar_DrawString(pwr_step + wep_step + woff + '284 12 0', "press fire to open", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
				else
					Sbar_DrawString(pwr_step + wep_step + woff + '284 12 0', "out of range!", ALPHA_FULL, '7 7 0','0.77 0.9 0.05');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 2 0', "or change weapon", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			if (mcode == MC_MCAS || mcode == 1006 || mcode == 1007) // archons
			{
				DrawInventoryAmmo(pwr_step + wep_step + '200 60 0', "gfx/mcas", ALPHA_FULL * k, 0.5);
				Sbar_DrawString(pwr_step + wep_step + woff + '196 65 0', "Archon Spirit", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
				Sbar_DrawString(pwr_step + wep_step + woff + '168 65 0', "***               ***", ALPHA_FULL * flashawep, '7 7 0','1.5 0.1 0.1');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 32 0', "Congratulations!", ALPHA_FULL * flasher, '7 7 0','1 0.5 0.5');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 22 0', "select option with wheel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 12 0', "press ALT-fire -> Archon", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 2 0', "or change weapon", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			else if (mcode >= MC_MC && mcode < 1105)
			{
				DrawInventoryAmmo(pwr_step + wep_step + '200 60 0', "gfx/mcb", ALPHA_FULL * k, 0.5);
				Sbar_DrawString(pwr_step + wep_step + woff + '202 65 0', "Cube active", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 22 0', "select option with wheel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 12 0', "press ALT-fire to morph", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
				Sbar_DrawString(pwr_step + wep_step + woff + '284 2 0', "or change weapon", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			if (mcode >= MC_MC && mcode < 1105)
			{
				float decod;
				string mctl;
				decod = mcode - 1000;
				mctl = "Select a form";

				if (mcode > 1004) // actual selection
				if (had_decod != decod)
				{
// type selection paragraphs
					if (decod == 101)
					{
						localcmd("exec cfg/morph/m-hdr_beast_cprint.cfg\n");
					}
					else
/*
					if (decod == 103)
					{
						localcmd("exec cfg/morph/m-hdr_doom_cprint.cfg\n");
					}
					else
					if (decod == 103)
					{
						localcmd("exec cfg/morph/m-hdr_q2_cprint.cfg\n");
					}
					else
*/
					{
// show points in menu text
						localcmd("set mpts \"");
						localcmd(ftos(0 - volspec));
						localcmd("\"\n");
					}


					if (decod == IMP_MCHAOS)
					{
						mctl = "Archon Chaos";
						localcmd("exec cfg/morph/m-chaos_cprint.cfg\n");
					}
					if (decod == IMP_MORDER)
					{
						mctl = "Archon Order";
						if (had_decod != decod)
							localcmd("exec cfg/morph/m-order_cprint.cfg\n");
					}
					if (decod == IMP_MHUMAN)
					{
						mctl = "Marine";
						localcmd("exec cfg/morph/m-human_cprint.cfg\n");
					}
					if (decod == CHAR_D)
					{
						mctl = "UAC Marine";
						localcmd("exec cfg/morph/m-uac_cprint.cfg\n");
					}
					if (decod == CHAR_Q2)
					{
						mctl = "Space Marine";
						localcmd("exec cfg/morph/m-spm_cprint.cfg\n");
					}
					if (decod == CHAR_Q3)
					{
						mctl = "Sarge";
						localcmd("exec cfg/morph/m-sarge_cprint.cfg\n");
					}
					if (decod == CHAR_PK)
					{
						mctl = "Pain Killer";
						localcmd("exec cfg/morph/m-pk_cprint.cfg\n");
					}
					if (decod == CHAR_W)
					{
						mctl = "Blaskowitz";
						localcmd("exec cfg/morph/m-blask_cprint.cfg\n");
					}
					if (decod == IMP_MENF)
					{
						mctl = "Enforcer";
						localcmd("exec cfg/morph/m-enforcer_cprint.cfg\n");
					}
					if (decod == IMP_MOGRE)
					{
						mctl = "Ogre";
						localcmd("exec cfg/morph/m-ogre_cprint.cfg\n");
					}
					if (decod == IMP_MHKNIGHT)
					{
						mctl = "Hell Knight";
						localcmd("exec cfg/morph/m-hknight_cprint.cfg\n");
					}
					if (decod == IMP_MSHALR)
					{
						mctl = "Vore";
						localcmd("exec cfg/morph/m-shalrath_cprint.cfg\n");
					}
					if (decod == IMP_MSHAMBLR)
					{
						mctl = "Shambler";
						localcmd("exec cfg/morph/m-shambler_cprint.cfg\n");
					}
					if (decod == IMP_MDEMON)
					{
						mctl = "Fiend";
						localcmd("exec cfg/morph/m-fiend_cprint.cfg\n");
					}
					if (decod == IMP_MWIZARD)
					{
						mctl = "Scrag";
						localcmd("exec cfg/morph/m-scragg_cprint.cfg\n");
					}
					if (decod == IMP_MZOMBIE)
					{
						mctl = "Zomby";
						localcmd("exec cfg/morph/m-zomby_cprint.cfg\n");
					}
//					if (decod == IMP_MCTHON) mctl = "Cthon";
					if (decod == IMP_MCTHON)
					{
						mctl = "Lava Bomb";
						localcmd("exec cfg/morph/m-lava_cprint.cfg\n");
					}
					if (decod == IMP_MSCOURGE)
					{
						mctl = "Scourge";
						localcmd("exec cfg/morph/m-scourge_cprint.cfg\n"); // display center description - moved from server
					}
					if (decod == IMP_MGREMLIN_F)
					{
						mctl = "Gremlin";
						localcmd("exec cfg/morph/m-gremlin_cprint.cfg\n");
					}
					if (decod == IMP_MGREMLIN_L)
					{
						mctl = "Gremlin";
						localcmd("exec cfg/morph/m-gremlin_cprint.cfg\n");
					}
					had_decod = decod;
				}

				Sbar_DrawString(pwr_step + wep_step + woff + '284 42 0', mctl, ALPHA_FULL, '7 7 0','1 1 1');
			}
		}

		if (morph == IMP_MCHAOS)
		{
			wep_step_x = 35;
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/chaos", ALPHA_FULL * k, 0.11);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Archon Chaos", ALPHA_FULL, '7 7 0','1.5 0.1 0.1');
			huds = 6;
		}
		else if (morph == IMP_MORDER)
		{
			wep_step_x = 35;
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/order", ALPHA_FULL * k, 0.1);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Archon Order", ALPHA_FULL, '7 7 0','1.0 1.0 1.0');
			huds = 6;
		}
	  else
	  {
		if (deadflag)
		{
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/sb_xbones", ALPHA_FULL, 0.19);
		}
		if (morph == CHAR_Q || autocvar_hud_nomod)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/face1", ALPHA_FULL * k, 0.85);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Marine", ALPHA_FULL, '7 7 0','0.5 0.7 1');
			huds = 4;
			nothuman = FALSE; // he's a human
		}
		else if (morph == CHAR_D)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/dm_face", ALPHA_FULL * k, 0.11);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "UAC Marine", ALPHA_FULL, '7 7 0','0.16 0.2 0.29');
			huds = 4;
			nothuman = FALSE;
		}
		else if (morph == CHAR_Q2)
		{
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Space Marine", ALPHA_FULL, '7 7 0','0.5 0.7 1');
			nothuman = FALSE;
		}
		else if (morph == CHAR_Q3)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/sg_face", ALPHA_FULL * k, 0.11);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Sarge", ALPHA_FULL, '7 7 0','0.5 0.7 1');
			huds = 4;
			nothuman = FALSE;
		}
		else if (morph == CHAR_PK)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/pk_face", ALPHA_FULL * k, 0.11);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Pain Killer", ALPHA_FULL, '7 7 0','0.2 0.2 1');
			huds = 4;
			nothuman = FALSE;
		}
		else if (morph == CHAR_W)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/bw_face", ALPHA_FULL * k, 0.11);
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Blaskowitz", ALPHA_FULL, '7 7 0','0.7 0.7 0.7');
			huds = 4;
			nothuman = FALSE;
		}
		else if (morph == IMP_MENF)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/enf_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Enforcer", ALPHA_FULL, '7 7 0','0.5 0.7 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '85 0 0', "| Laser bolt", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE;
		}
		else if (morph == IMP_MOGRE)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/ogr_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Ogre", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Chainsaw", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_GRENADE_LAUNCHER)
				Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Grenades", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_ROCKET_LAUNCHER)
				Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Cluster Grenades", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER;
		}
		else if (morph == IMP_MHKNIGHT)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/hkn_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Hell Knight", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '105 0 0', "| Sword", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '105 0 0', "| Magic spikes", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SUPER_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '105 0 0', "| Focused spikes", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_ROCKET_LAUNCHER)
				Sbar_DrawString(pwr_step + wep_step + woff + '105 0 0', "| Explosive spikes *", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_ROCKET_LAUNCHER;
		}
		else if (morph == IMP_MSHALR)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/vr_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Vore", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
			{
				if (mcode == -505)
					Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Spike Bomb -->", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				else if (volspec == -1000)
				{
					Sbar_DrawString(pwr_step + wep_step + woff + '59 9 0', "| FIRE - summon *", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Sphere of Annihilation", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				}
				else
				{
					if (mcode == -500)
					{
						Sbar_DrawString(pwr_step + wep_step + woff + '59 9 0', "| ALT_FIRE - take control", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Sphere of Annihilation - not following", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}
					else if (mcode == -504)
						Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Sphere of Annihilation - out of range", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					else
					{
						if (mcode == -501)
							Sbar_DrawString(pwr_step + wep_step + woff + '59 9 0', "| Mouse wheel - height adjust", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						else if (mcode == -502)
							Sbar_DrawString(pwr_step + wep_step + woff + '59 9 0', "| Mouse wheel - bearing adjust", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + wep_step + woff + '59 27 0', "| FIRE - banish *", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + wep_step + woff + '59 18 0', "| ALT_FIRE / M3 - change control mode", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Sphere of Annihilation - following", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}
				}
			}
			if (currentweap == IT_LIGHTNING)
				Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Lightning", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SUPER_NAILGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Magic spikes", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_ROCKET_LAUNCHER)
				Sbar_DrawString(pwr_step + wep_step + woff + '59 0 0', "| Spike Bomb", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_SUPER_NAILGUN | IT_ROCKET_LAUNCHER | IT_LIGHTNING;
		}
		else if (morph == IMP_MSHAMBLR)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/sham_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Shambler", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '85 0 0', "| Claws", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_LIGHTNING)
				Sbar_DrawString(pwr_step + wep_step + woff + '85 0 0', "| Lightning", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_LIGHTNING;
		}
		else if (morph == IMP_MDEMON)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/fnd_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Fiend", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Hack & Slash", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Head spike", ALPHA_FULL, '7 7 0','1 0.5 0.5');
// demon rage explosion
			if (explodeshot == -501)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  Pentagram power surges beyond rage", ALPHA_FULL, '7 7 0','1 0.2 0.2');
			else if (explodeshot == -505)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  Not enough Archon power for RAGE", ALPHA_FULL, '7 7 0','1 0.2 0.2');
			else if (explodeshot == -506)
			{
				Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  Runes failed your RAGE", ALPHA_FULL, '7 7 0','1 0.2 0.2');
				explflg = 0;
			}
			else if (explodeshot == -504)
			{
				Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  B--O--O--M", ALPHA_FULL, '7 7 0','1 0.1 0.1');
				explflg = 0;
			}
			if (currentweap == IT_GRENADE_LAUNCHER)
			{
				if (explodeshot > 0 || explflg)
				{
					explflg = 1;
					Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| RAGE - Gonna pop in      or less", ALPHA_FULL, '7 7 0','1 0.1 0.1');
					if (explodeshot > 0)
						Sbar_DrawString(pwr_step + wep_step + woff + '225 0 0', ftos(explodeshot), ALPHA_FULL, '7 7 0','1 0.1 0.1');
					else
						Sbar_DrawString(pwr_step + wep_step + woff + '225 0 0', "**", ALPHA_FULL, '7 7 0','0 0 0');

					if (explodeshot < 5)
					{
						if (cl_items & IT_INVULNERABILITY)
							Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  Everyone will be blown straight to HELL!", ALPHA_FULL, '7 7 0','1 0.2 0.2');
						else if (rune_flag & (RUNE_FLG_HS |TECH_TEIM))
							Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  Hurry", ALPHA_FULL, '7 7 0','1 0.2 0.2');
					}
				}
				else
				{
					if (explodeshot == -502)
						Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  * - you will lose runes of power", ALPHA_FULL, '7 7 0','1 0.2 0.2');
					if (explodeshot == -503)
						Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  RAGE has overcome you...\n", ALPHA_FULL, '7 7 0','1 0.1 0.1');
					if (cl_items & IT_INVULNERABILITY)
						Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Fiendish onslaught of DOOM!", ALPHA_FULL, '7 7 0','1 0.1 0.1');
					else
						Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| RAGE", ALPHA_FULL, '7 7 0','1 0.1 0.1');
				}
			}
			no_ammo = IT_AXE | IT_SHOTGUN | IT_GRENADE_LAUNCHER;
		}
		else if (morph == IMP_MWIZARD)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/wz_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Scrag", ALPHA_FULL, '7 7 0','0 0.8 0');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Pain field", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Acid Spikes", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SUPER_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Focused spikes", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_ROCKET_LAUNCHER)
				Sbar_DrawString(pwr_step + wep_step + woff + '65 0 0', "| Explosive spikes *", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_ROCKET_LAUNCHER;
		}
		else if (morph == IMP_MZOMBIE)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/zm_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Zomby", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '66 0 0', "| Stench cloud", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '66 0 0', "| Rotten flesh", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SUPER_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '66 0 0', "| Plague flesh", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_NAILGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '66 0 0', "| Gib fountain", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN;
		}
		else if (morph == IMP_MCTHON)
		{
			if (mcode == -503 || mcode == -502 || mcode == -501)
			{
			if (!deadflag)
				DrawInventoryAmmo(pwr_step + wep_step + '-2 2 0', "gfx/cth_face", ALPHA_FULL * k, 0.11);
				Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Cthon", ALPHA_FULL, '7 7 0','1 0.2 0');
				Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  ALT_FIRE - return to Lava Bomb", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				if (mcode == -502)
				{
					if (random() < 0.03) explflg = 1;
					if (explflg)
						Sbar_DrawString(pwr_step + wep_step + woff + '65 18 0',   "HURRY!  Hit ALT_FIRE now or find more Lava fast!", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					else
						Sbar_DrawString(pwr_step + wep_step + woff + '65 18 0',   "HURRY!  Find more Lava fast!", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				}
				if (mcode == -501)
					Sbar_DrawString(pwr_step + wep_step + woff + '65 9 0', "  Cthon cannot exist away from Lava", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			else
			{
				explflg = 0;
			if (!deadflag)
				DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/lv_face", ALPHA_FULL * k, 0.11);
				Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Lava Bomb", ALPHA_FULL, '7 7 0','1 0.2 0');
				if (mcode == -504) // in lava code
					Sbar_DrawString(pwr_step + wep_step + woff + '91 9 0', "| ALT_FIRE - become Cthon !", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				if (currentweap == IT_AXE)
				if (pk_wep == PK_IT_AXE)
					Sbar_DrawString(pwr_step + wep_step + woff + '91 0 0', "| Lava balls", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				if (currentweap == IT_NAILGUN)
					Sbar_DrawString(pwr_step + wep_step + woff + '91 0 0', "| Lava nails", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				if (currentweap == IT_ROCKET_LAUNCHER)
					Sbar_DrawString(pwr_step + wep_step + woff + '91 0 0', "| Lava bombs *", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			huds = 6;
			no_ammo = IT_AXE | IT_NAILGUN | IT_ROCKET_LAUNCHER;
		}
		else if (morph == IMP_MSCOURGE)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/scr_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Scourge", ALPHA_FULL, '7 7 0','1 0.5 1');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '83 0 0', "| Stinger", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '83 0 0', "| 4 x perforator", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_LIGHTNING)
				Sbar_DrawString(pwr_step + wep_step + woff + '83 0 0', "| Lasrs", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_GRENADE_LAUNCHER)
				Sbar_DrawString(pwr_step + wep_step + woff + '83 0 0', "| Proximity bombs", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_SHOTGUN;
		}
		else if (morph == IMP_MGREMLIN_F || morph == IMP_MGREMLIN_L)
		{
			if (!deadflag)
			DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/grm_face", ALPHA_FULL * k, 0.11);
			huds = 6;
			Sbar_DrawString(pwr_step + wep_step + woff + '25 0 0', "Gremlin", ALPHA_FULL, '7 7 0','0 0.7 0');
			if (morph == IMP_MGREMLIN_F)
				Sbar_DrawString(pwr_step + wep_step + woff + '75 9 0', "| Flyer", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_AXE)
			if (pk_wep == PK_IT_AXE)
				Sbar_DrawString(pwr_step + wep_step + woff + '75 0 0', "| Bite", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			if (currentweap == IT_SHOTGUN)
				Sbar_DrawString(pwr_step + wep_step + woff + '75 0 0', "| Claws", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			no_ammo = IT_AXE | IT_SHOTGUN;
		}

		if (!deadflag)
		if (huds & 6) // drew a face
		{
			if (huds == 4) // a hooman
			{
				if (cl_items & IT_SUIT)
				if (wsuit > 0)
					DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/wet_face", ALPHA_FULL * k, 0.11);
				else
					DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/suit_face", ALPHA_FULL * k, 0.11);
			}
			if (cl_items & IT_INVULNERABILITY)
				DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/face_red", ALPHA_FULL * k, 0.11);
			if (cl_items & IT_QUAD)
				DrawInventoryAmmo(pwr_step + wep_step + '0 4 0', "gfx/face_blue", ALPHA_FULL * k, 0.11);
		}
	  }
	}


	if (deadflag) // display dead time and none else
	{
		k = time - deadtime;
		Sbar_DrawString(pwr_step + wep_step + woff + '105 0 0', "| dead (", ALPHA_FULL, '7 7 0','1 1 1');
		v = '0 0 0';
		if (k > 0)
		{
			Sbar_DrawString(pwr_step + wep_step + woff + '160 1 0', ftos(floor(k)), ALPHA_FULL, '7 7 0','1 1 1');
			while (k > 9)
			{
				k = floor(k / 10);
				v_x = v_x + 7;
			}
		}
		else
			Sbar_DrawString(pwr_step + wep_step + woff + '160 1 0', "*", ALPHA_FULL, '7 7 0','1 0.1 0.1');

		k = time - deadtime;
		if (k == 1)
			Sbar_DrawString(pwr_step + wep_step + woff + v + '166 0 0', ") rel", ALPHA_FULL, '7 7 0','1 1 1');
		else
			Sbar_DrawString(pwr_step + wep_step + woff + v + '166 0 0', ") rels", ALPHA_FULL, '7 7 0','1 1 1');
		return;
	}
	else
	if (ibar_flag > 1)
	{
		
		if (!archon_magic)
		{
			healflash = 1;
			hicof = 1;
			if (health < autocvar_hud_flash_numeral) healflash = flasher;
			if (health < autocvar_hud_flash_icon) hicof = flasher;

			if (cl_items & IT_SUPERHEALTH)
				DrawInventory(pwr_step + '2 0 0' + woff,"gfx/sb_mega",   IT_SUPERHEALTH, 0, ALPHA_FULL, 0.19);
			else
				DrawInventoryAmmo(pwr_step + '4 0 0', "gfx/sb_health", ALPHA_FULL * hicof, 0.17);
			
			DrawAmmo('1 0.15 0.15', pwr_step + '27 -10 0', health, ALPHA_FULL * healflash);

			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

// IMP: archons have shield here - dont use armor icons
		if (floor(armorval) >= 1)
		{
			armorflash = 1;
			armicof = 1;
			if (armorval < autocvar_hud_flash_numeral) armorflash = flasher;
			if (armorval < autocvar_hud_flash_icon) armicof = flasher;
			clr = '0.5 0.7 1';
			if (cl_items & IT_ARMOR3)
			{
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb__armor3", ALPHA_FULL * armicof, 0.28);
				clr = '1 0.3 0.3';
			}
			else if (cl_items & IT_ARMOR2)
			{
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb__armor2", ALPHA_FULL * armicof, 0.28);
				clr = '1 1 0.3';
			}
			else if (cl_items & IT_ARMOR1)
			{
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb__armor1", ALPHA_FULL * armicof, 0.28);
				clr = '0.3 1 0.3';
			}

			if (cl_items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3))
			{
				DrawAmmo(clr, pwr_step + '27 -10 0', armorval, ALPHA_FULL * armorflash);
				cnt_left = pwr_step_y;
				pwr_step_y = pwr_step_y + 27;
			}

		}

// power armors
		if (x_items & X_PWR_ARMOR)
		if (! x_items & X_PWR_SCREEN_ON)
		{
			armorflash = 1;
			armicof = 1;
			if (x_items & X_PWR_ARMOR_ON)
			{
				if (cells < autocvar_hud_flash_numeral) armorflash = flasher;
				if (cells < autocvar_hud_flash_icon) armicof = flasher;
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb_parmor", ALPHA_FULL * armicof, 0.19);
				DrawAmmo(clr, pwr_step + '27 -10 0', cells, ALPHA_FULL * armorflash);
			}
			else
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb_parmor0", ALPHA_FULL * armicof, 0.19);

			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

		if (x_items & X_PWR_SCREEN)
		if (! x_items & X_PWR_ARMOR_ON)
		{
			armorflash = 1;
			armicof = 1;
			if (x_items & X_PWR_SCREEN_ON)
			{
				if (cells < autocvar_hud_flash_numeral) armorflash = flasher;
				if (cells < autocvar_hud_flash_icon) armicof = flasher;
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb_pscreen", ALPHA_FULL * armicof, 0.19);
				DrawAmmo(clr, pwr_step + '27 -10 0', cells, ALPHA_FULL * armorflash);
				cnt_left = pwr_step_y;
				pwr_step_y = pwr_step_y + 27;
			}
			else
			if (! x_items & X_PWR_ARMOR)
			{
				DrawInventoryAmmo(pwr_step + '2 0 0', "gfx/sb_pscreen0", ALPHA_FULL * armicof, 0.19);
				cnt_left = pwr_step_y;
				pwr_step_y = pwr_step_y + 27;
			}
			
		}
	}

	if (ibar_flag > 2)
	{
		
		if (cl_items & IT_INVISIBILITY)
		{
			if (!ring) ring = time + 30;
			else if ((ring - time) > 0) DrawAmmo('0 0 0', pwr_step + '27 -8 0', ceil(ring - time), ALPHA_MEDIUM * flasher);
			else Sbar_DrawString(pwr_step + woff + '27 -8 0', " **", ALPHA_FULL * sterix_fl, '7 7 0','1 0.5 0.5');
			DrawInventoryAmmo(pwr_step + '2 0 0',"gfx/sb_invis",    ALPHA_LOW, 1.5);
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

		if (cl_items & IT_SUIT)
		if (wsuit > 0)
		{
//			if (!suit) suit= time + 30;
//			else 
			if ((wsuit - time) > 0) DrawAmmo('0 0 0', pwr_step + '27 -8 0', ceil(wsuit - time), ALPHA_MEDIUM * flasher);
			else Sbar_DrawString(pwr_step + woff + '27 -8 0', " **", ALPHA_FULL * sterix_fl, '7 7 0','1 0.5 0.5');
			DrawInventoryAmmo(pwr_step + '2 0 0',"gfx/sb_wsuit",    ALPHA_MEDIUM, 0.45);
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}
		else
		{
			if (!suit) suit= time + 30;
			else if ((suit - time) > 0) DrawAmmo('0 0 0', pwr_step + '27 -8 0', ceil(suit - time), ALPHA_MEDIUM * flasher);
			else Sbar_DrawString(pwr_step + woff + '27 -8 0', " **", ALPHA_FULL * sterix_fl, '7 7 0','1 0.5 0.5');
			DrawInventoryAmmo(pwr_step + '2 0 0',"gfx/sb_suit",    ALPHA_MEDIUM, 1.5);
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

		if (cl_items & IT_QUAD)
		{
			if (!quad) quad = time + 30;
			else if ((quad - time) > 0) DrawAmmo('0 0 0', pwr_step + '27 -8 0', ceil(quad - time), ALPHA_MEDIUM * flasher);
			else Sbar_DrawString(pwr_step + woff + '27 -8 0', " **", ALPHA_FULL * sterix_fl, '7 7 0','1 0.5 0.5');
			DrawInventoryAmmo(pwr_step + '2 0 0',"gfx/sb_quad",    ALPHA_FULL, 1.5);
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

		if (cl_items & IT_INVULNERABILITY)
		{
			if (!inv) inv = time + 30;
			else if ((inv - time) > 0) DrawAmmo('0 0 0', pwr_step + '27 -8 0', ceil(inv - time), ALPHA_MEDIUM * flasher);
			else Sbar_DrawString(pwr_step + woff + '27 -8 0', " **", ALPHA_FULL * sterix_fl, '7 7 0','1 0.5 0.5');
			DrawInventoryAmmo(pwr_step + '2 0 0',"gfx/sb_invuln",    ALPHA_FULL, 1.5);
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

// silencio

		if (silence > time)
		{
			if (!silencio) silencio = time + 30;
			else if ((silencio - time) > 0) DrawAmmo('0 0 0', pwr_step + '27 -8 0', ceil(silencio - time), ALPHA_MEDIUM * flasher);
			else Sbar_DrawString(pwr_step + woff + '27 -8 0', " **", ALPHA_FULL * sterix_fl, '7 7 0','1 0.5 0.5');
			DrawInventoryAmmo(pwr_step + '2 0 0',"gfx/sb_silence",    ALPHA_FULL, 0.2);
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 27;
		}

//		DrawInventory('60 48 0', "gfx/sb_invuln", IT_INVULNERABILITY, 0, ALPHA_MEDIUM, 1.5);
	}

// archon vessels

	if (arcvessel) // show that archon has a vessel
	{
		DrawInventoryAmmo(pwr_step + '12 0 0', "gfx/arcvess", ALPHA_FULL, 0.11);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 27;
	}

// ammo pack deal
	if (rune_flag & RUNE_AMMO)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_pack", ALPHA_FULL, 0.24);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}

	if (rune_flag & TECH_AMP)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_amp", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & TECH_TEIM)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_tiem", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & TECH_ADOC)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_adoc", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & TECH_DSH)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_dsh", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}

	if (rune_flag & RUNE_FLG_DM)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_dmg", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & RUNE_FLG_HS)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_hst", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & RUNE_FLG_RG)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_rgn", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & RUNE_FLG_RS)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_res", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}
	if (rune_flag & RUNE_VAMPIRE)
	{
		DrawInventoryAmmo(pwr_step, "gfx/rune_vmp", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}

// portable power point held
	if (x_items & X_PP)
	{
		DrawInventoryAmmo(pwr_step, "gfx/a_ppp", ALPHA_FULL, 0.25);
		cnt_left = pwr_step_y;
		pwr_step_y = pwr_step_y + 30;
	}

	if (enginebar) // always above bar while it is there
	{
		DrawInventory('40 48 0', "gfx/sb_invis",  IT_INVISIBILITY, 0, ALPHA_LOW, 1.5);
		DrawInventory('60 48 0', "gfx/sb_invuln", IT_INVULNERABILITY, 0, ALPHA_MEDIUM, 1.5);
		if (wsuit > 0)
			DrawInventoryAmmo('140 48 0', "gfx/sb_wsuit", ALPHA_FULL, 0.4);
		else
		DrawInventory('80 48 0', "gfx/sb_suit",   IT_SUIT, 0, ALPHA_MEDIUM, 1.5);
		DrawInventory('100 48 0',"gfx/sb_quad",   IT_QUAD, 0, ALPHA_FULL, 1.5);

		DrawInventory('120 48 0',"gfx/sb_mega",   IT_SUPERHEALTH, 0, ALPHA_FULL, 0.19);

// IMP: needs detection
//		DrawInventory('120 48 0', "gfx/sb_eshld", 0, HIP_IT_EMPATY_SHIELD, ALPHA_FULL, 1.5);
//		DrawInventory('140 48 0', "gfx/sb_wsuit", 0, HIP_IT_WETSUIT, ALPHA_FULL, 1.5);

		DrawInventory('170 48 0', "gfx/sb_sigil1", 0, 32, ALPHA_MEDIUM, 1.5);
		DrawInventory('190 48 0', "gfx/sb_sigil2", 0, 64, ALPHA_MEDIUM, 1.5);
		DrawInventory('210 48 0', "gfx/sb_sigil3", 0, 128, ALPHA_MEDIUM, 1.5);
		DrawInventory('230 48 0', "gfx/sb_sigil4", 0, 256, ALPHA_MEDIUM, 1.5);
	}

	local string rside_icon, lside_icon;
	local float rside_scale, lside_scale, draw_targ;

/// spells
	if (archon_magic)
	{
		if (ibar_flag < 3) pwr_step_y = pwr_step_y + 18;
		rside_icon = "gfx/reticle.spr_0";
		lside_icon = "gfx/reticle.spr_0";
		rside_scale = 0.05;
		lside_scale = 0.04;
		draw_targ = 0;
		if (morph == IMP_MORDER)
		{
			rside_icon = "gfx/reticle2.spr_0";
			lside_icon = "gfx/reticle2.spr_0";
		}
		if (explodeshot == -6)
		{
			Sbar_DrawString(pwr_step + '20 -5 0' + woff, "Spell cancelled...", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 20;
		}

		if (autocvar_hud_vampire_target != "")
		{
			Sbar_DrawString(pwr_step + '20 -5 0' + woff, "Vampire target:", ALPHA_FULL, '7 7 0','1 0.1 0.1');
			Sbar_DrawString(pwr_step + '130 -5 0' + woff, autocvar_hud_vampire_target, ALPHA_FULL, '7 7 0','1 0.5 0.5');
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 14;
		}

var float autocvar_hud_spell_list = 1;
var float autocvar_hud_spell_vessel_limit = 1;

		vector sploff;

		if (currentweap != IT_AXE) // casting spells
		{
// list spells in books in select order and place spell reticle on active spell

			sploff = '0 0 0';
//			if (autocvar_hud_spell_list > 0) sploff_y = autocvar_hud_spell_list * 21;
			if (autocvar_hud_spell_vessel_limit) sploff_x = -47; // move back enough for limit display

//			if (plevel > 0)
			if (casting)
			{
				if (currentweap == IT_SHOTGUN) // spell list 1 - teleports
				{
					if (autocvar_hud_spell_list > 0)
					if (arcvessel)
					{
						if (autocvar_hud_spell_vessel_limit) // display limits if this is on
						{
// but we are not going to enumerate the base 2000 - just the ups
//							Sbar_DrawString('328 40 0' + woff + sploff + '0 42 0', "(2000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 28 0', "(2500)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
//							Sbar_DrawString('328 40 0' + woff + sploff, "(2000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						Sbar_DrawString('314 40 0' + woff + sploff + '0 42 0', "Teleport", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('280 40 0' + woff + sploff + '0 28 0', "Teleport swap", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('280 40 0' + woff + sploff + '0 14 0', "Teleport self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (shells != 11) Sbar_DrawString('301 40 0' + woff + sploff, "Use beacon", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}
					else
					{
						if (autocvar_hud_spell_vessel_limit)
						{
							Sbar_DrawString('328 40 0' + woff + sploff + '47 14 0', "(none)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 0 0', "(none)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
//						Sbar_DrawString('328 40 0' + woff + sploff + '0 28 0', "(2000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
//						Sbar_DrawString('233 40 0' + woff + sploff + '0 28 0', "Teleport self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
//						Sbar_DrawString('280 40 0' + woff + sploff + '0 14 0', "Teleport self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('280 40 0' + woff + sploff + '0 14 0', "Teleport self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('244 40 0' + woff + sploff, "Create SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}

					if (shells == 3)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 42 0';
						else
						Sbar_DrawString('314 40 0' + woff + sploff, "Teleport", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - teleport target to reticle";
					}
					else if (shells == 5)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 28 0';
						else
						Sbar_DrawString('280 40 0' + woff + sploff, "Teleport swap", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (target2) instr = "*FIRE - swap targets";
					}
					else if (shells == 7)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 14 0';
						else
						Sbar_DrawString('280 40 0' + woff + sploff, "Teleport self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (target2) instr = "*FIRE - teleport to reticle";
					}
					else if (shells == 11)
					{
						if (explodeshot == 20)
						{
							Sbar_DrawString('301 40 0' + woff + sploff, "Set beacon", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							instr = "*FIRE - launch beacon";
						}
						else
						{
							Sbar_DrawString('245 40 0' + woff + sploff, "Teleport to beacon", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							instr = "*FIRE - cast teleport spell";
						}
					}
					else if (shells == 13)
					{
						if (autocvar_hud_spell_list < 1)
						Sbar_DrawString('244 40 0' + woff + sploff, "Create SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - Make a SOUL vessel";

						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "make: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (morph == IMP_MCHAOS)
						{
							if (pk_bt == 1) Sbar_DrawString(pwr_step + '60 -5 0' + woff, "Nodule", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							else if (pk_bt == 2)  Sbar_DrawString(pwr_step + '60 -5 0' + woff, "Gravestone", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							else Sbar_DrawString(pwr_step + '60 -5 0' + woff, "Copy target object", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						else
						{
							if (pk_bt == 2) Sbar_DrawString(pwr_step + '60 -5 0' + woff, "Sphere", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							else Sbar_DrawString(pwr_step + '60 -5 0' + woff, "Diamond", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;
					}
//					else Sbar_DrawString('280 40 0', "Unknown Magic", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				}
				if (currentweap == IT_SUPER_SHOTGUN) // spell list 1 - poly
				{
					if (autocvar_hud_spell_list > 0)
					{
						if (autocvar_hud_spell_vessel_limit)
						{
							Sbar_DrawString('328 40 0' + woff + sploff + '47 14 0', "(3000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						Sbar_DrawString('271 40 0' + woff + sploff + '0 28 0', "Polymorph self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('264 40 0' + woff + sploff + '0 14 0', "Polymorph other", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (morph == IMP_MCHAOS)
							Sbar_DrawString('250 40 0' + woff + sploff, "Metamorphose self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						else
							Sbar_DrawString('300 40 0' + woff + sploff, "Order form", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}

					if (nails == 3)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 28 0';
						else
						Sbar_DrawString('271 40 0' + woff + sploff, "Polymorph self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (explodeshot == 24) // no creature cost can be this val
							instr = "*FIRE - start polymorph selection";
						else
							instr = "ALT_FIRE - cast polymorph spell";
					}
					else if (nails == 5)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 14 0';
						else
						Sbar_DrawString('264 40 0' + woff + sploff, "Polymorph other", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (explodeshot == 24) // no creature cost can be this val
							instr = "*FIRE - start polymorph selection";
						else
						{
							if (pk_bt > 0)
							{
								Sbar_DrawString(pwr_step + '22 -5 0' + woff, "target becomes: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
								Sbar_DrawString(pwr_step + '130 -5 0' + woff, monster_id(pk_bt), ALPHA_FULL, '7 7 0','1 0.5 0.5');
								cnt_left = pwr_step_y;
								pwr_step_y = pwr_step_y + 18;
							}
							instr = "*ALT_FIRE - cast polymorph spell";
						}
					}
					else if (nails == 7)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (autocvar_hud_spell_list > 0) sploff = '0 14 0';
						else
						Sbar_DrawString('264 40 0' + woff + sploff, "Polymorph other", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (pk_bt > 0)
						{
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "target becomes: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString(pwr_step + '130 -5 0' + woff, monster_id(pk_bt), ALPHA_FULL, '7 7 0','1 0.5 0.5');
							cnt_left = pwr_step_y;
							pwr_step_y = pwr_step_y + 18;
						}
						instr = "*FIRE - cast polymorph spell (repeat)";
					}
					if (nails == 11)
					{
						if (morph == IMP_MCHAOS)
						{
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							cnt_left = pwr_step_y;
							pwr_step_y = pwr_step_y + 18;

							if (autocvar_hud_spell_list < 1)
							Sbar_DrawString('250 40 0' + woff + sploff, "Metamorphose self", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Archon becomes: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString(pwr_step + '130 -5 0' + woff, transmogrify(pk_bt), ALPHA_FULL, '7 7 0','1 0.5 0.5');
							instr = "*FIRE - cast transmogrify spell";
						}
						else
						{
							if (autocvar_hud_spell_list < 1)
							Sbar_DrawString('300 40 0' + woff + sploff, "Order form", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Choose other form", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							instr = "*FIRE - cast transform spell";
						}
					}
				}
				if (currentweap == IT_NAILGUN) // spell list 1 - poly
				{
					if (autocvar_hud_spell_list > 0)
					{
						if (autocvar_hud_spell_vessel_limit)
						{
							Sbar_DrawString('328 40 0' + woff + sploff + '47 28 0', "(4000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 14 0', "(5000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						Sbar_DrawString('292 40 0' + woff + sploff + '0 28 0', "Rune powers", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('286 40 0' + woff + sploff + '0 14 0', "Gravity well", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (rockets != 7) Sbar_DrawString('279 40 0' + woff + sploff, "Monster speed", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}

					if (rockets == 3)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (autocvar_hud_spell_list > 0) sploff = '0 28 0';
						else
						Sbar_DrawString('292 40 0' + woff + sploff, "Rune powers", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (pk_bt == 4194304)
						{
							if (rune_flag) Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Expulse (remove rune)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						else
						{
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Activate power: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							if (pk_bt == RUNE_FLG_RS) DrawInventoryAmmo(pwr_step + '130 4 0', "gfx/rune_res", ALPHA_FULL, 0.18);
							else if (pk_bt == RUNE_FLG_DM) DrawInventoryAmmo(pwr_step + '130 4 0', "gfx/rune_dmg", ALPHA_FULL, 0.18);
							else if (pk_bt == RUNE_FLG_HS) DrawInventoryAmmo(pwr_step + '130 4 0', "gfx/rune_hst", ALPHA_FULL, 0.18);
							else if (pk_bt == RUNE_VAMPIRE) DrawInventoryAmmo(pwr_step + '130 4 0', "gfx/rune_vmp", ALPHA_FULL, 0.18);
							else DrawInventoryAmmo(pwr_step + '130 2 0', lside_icon, ALPHA_FULL, 0.038);
							Sbar_DrawString(pwr_step + '158 -5 0' + woff, rune_power(pk_bt), ALPHA_FULL, '7 7 0','1 0.5 0.5');
							pwr_step_y = pwr_step_y + 4;
						}
						instr = "*FIRE - cast rune power spell";
					}
					if (rockets == 5)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 14 0';
						else
						Sbar_DrawString('286 40 0' + woff + sploff, "Gravity well", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						rside_icon = "gfx/inv_gwell";
						rside_scale = 0.18;
						instr = "*FIRE - cast gravity well spell";
					}
					if (rockets == 7)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (pk_bt == 1)
							Sbar_DrawString('272 40 0' + woff + sploff, "Monster faster", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						else
							Sbar_DrawString('272 40 0' + woff + sploff, "Monster slower", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - cast monster speed spell";
					}
				}
				if (currentweap == IT_SUPER_NAILGUN) // spell list 1 - poly
				{
					if (autocvar_hud_spell_list > 0)
					{
						if (autocvar_hud_spell_vessel_limit)
						{
							Sbar_DrawString('328 40 0' + woff + sploff + '47 84 0', "(6000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 70 0', "(5000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 42 0', "(3000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						Sbar_DrawString('244 40 0' + woff + sploff + '0 84 0', "Create power point", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('223 40 0' + woff + sploff + '0 70 0', "Create chaos teleport", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('286 40 0' + woff + sploff + '0 56 0', "Create items", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('223 40 0' + woff + sploff + '0 42 0', "Create painkeep items", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('244 40 0' + woff + sploff + '0 28 0', "Remove SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('167 40 0' + woff + sploff + '0 14 0', "Add 500 points to SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('133 40 0' + woff + sploff, "Return 500 points from SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}

					if (bullets == 3)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 84 0';
						else
						Sbar_DrawString('244 40 0' + woff + sploff, "Create power point", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}
					if (bullets == 5)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 70 0';
						else
						Sbar_DrawString('223 40 0' + woff + sploff, "Create chaos teleport", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}
					if (bullets == 7)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (autocvar_hud_spell_list > 0) sploff = '0 56 0';
						else
						Sbar_DrawString('286 40 0' + woff + sploff, "Create items", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "make: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + '60 -5 0' + woff, item_by_clbit(pk_bt, 1), ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;
					}
					if (bullets == 11)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (autocvar_hud_spell_list > 0) sploff = '0 42 0';
						else
						Sbar_DrawString('223 40 0' + woff + sploff, "Create painkeep items", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "make: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + '60 -5 0' + woff, item_by_clbit(pk_bt, 3), ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;
						
					}
					instr = "*FIRE - cast create spell";
					if (bullets == 13)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 28 0';
						else
						Sbar_DrawString('244 40 0' + woff + sploff, "Remove SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - recover all power from SOUL";
					}
					if (bullets == 15)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 14 0';
						else
						Sbar_DrawString('167 40 0' + woff + sploff, "Add 500 points to SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (explodeshot) instr = "*FIRE - Increase SOUL power";
					}
					if (bullets == 17)
					{
						if (autocvar_hud_spell_list < 1)
						Sbar_DrawString('133 40 0' + woff + sploff, "Return 500 points from SOUL vessel", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (explodeshot) instr = "*FIRE - Reduce SOUL power";
					}
				}
				if (currentweap == IT_LIGHTNING) // spell list 1 - poly
				{
					if (autocvar_hud_spell_list > 0)
					{
						if (autocvar_hud_spell_vessel_limit)
						{
							Sbar_DrawString('328 40 0' + woff + sploff + '47 56 0', "(5000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 28 0', "(4500)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 14 0', "(6000)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							Sbar_DrawString('328 40 0' + woff + sploff + '47 0 0', "(7500)", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}
						if (cells != 3) Sbar_DrawString('279 40 0' + woff + sploff + '0 70 0', "Heal / weaken", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('272 40 0' + woff + sploff + '0 56 0', "Imprison being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('280 40 0' + woff + sploff + '0 42 0', "Release being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('286 40 0' + woff + sploff + '0 28 0', "Summon being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString('286 40 0' + woff + sploff + '0 14 0', "Banish being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						if (cells != 17) Sbar_DrawString('209 40 0' + woff + sploff, "Change the flow of time", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					}

					if (cells == 3)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (autocvar_hud_spell_list > 0) sploff_y = 70;
						if (pk_bt == 1)
							Sbar_DrawString('300 40 0' + woff + sploff, "Heal being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						else
							Sbar_DrawString('286 40 0' + woff + sploff, "Weaken being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - cast health spell";
					}
					if (cells == 5)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 56 0';
						else
						Sbar_DrawString('272 40 0' + woff + sploff, "Imprison being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - cast imprison spell";
					}
					if (cells == 7)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 42 0';
						else
						Sbar_DrawString('280 40 0' + woff + sploff, "Release being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - cast release spell";
						if (target1) draw_targ = 1;
					}
					if (cells == 11)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (autocvar_hud_spell_list > 0) sploff = '0 28 0';
						else
						Sbar_DrawString('286 40 0' + woff + sploff, "Summon being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Summon a: ", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						Sbar_DrawString(pwr_step + '90 -5 0' + woff, monster_id(pk_bt), ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 14;
						instr = "*FIRE - cast summon spell";
					}
					if (cells == 13)
					{
						if (autocvar_hud_spell_list > 0) sploff = '0 14 0';
						else
						Sbar_DrawString('286 40 0' + woff + sploff, "Banish being", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - cast banish spell";
					}
					if (cells == 17)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "[ Select auxilliary options ]", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;

						if (pk_bt == 2)
							Sbar_DrawString('223 40 0' + woff + sploff, "Slow the flow of time", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						else
						if (pk_bt == 4)
							Sbar_DrawString('216 40 0' + woff + sploff, "Speed the flow of time", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						else
							Sbar_DrawString('202 40 0' + woff + sploff, "Restore the flow of time", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						instr = "*FIRE - cast time flow spell";
					}
				}
				sploff_x = 0; // cancel this now - only for showing limits
				DrawInventoryAmmo('372 50 0' + sploff, rside_icon, ALPHA_FULL, rside_scale);
			}

			if ((pk_mask & 2) || draw_targ) // spell requires targets
			{
				if (ibar_flag > 1) // ibar_f = 1, no instructions
				{
					if (!target1)
					{
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Select target with reticle", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;
					}
					else
					{
						if (!draw_targ)
						if ((nails != 5) || explodeshot == 24)
						{							
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Select alternate target with reticle", ALPHA_FULL, '7 7 0','1 0.5 0.5');
							cnt_left = pwr_step_y;
							pwr_step_y = pwr_step_y + 14;
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, "ALT_FIRE - use alternate target", ALPHA_FULL, '7 7 0','1 0.5 0.5');
						}

						if (instr)
						{
							cnt_left = pwr_step_y;
							pwr_step_y = pwr_step_y + 14;
							Sbar_DrawString(pwr_step + '22 -5 0' + woff, instr, ALPHA_FULL, '7 7 0','1 0.5 0.5');	
						}
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 18;
					}
				}

				if (target2)
				{
					DrawInventoryAmmo(pwr_step, lside_icon, ALPHA_MEDIUM, lside_scale);
					Sbar_DrawString(pwr_step + '22 -7 0' + woff, target2, ALPHA_MEDIUM, '7 7 0','1 0.5 0.5');
					cnt_left = pwr_step_y;
					pwr_step_y = pwr_step_y + 23;
				}
				if (target1)
				{
					DrawInventoryAmmo(pwr_step, lside_icon, ALPHA_FULL, lside_scale);
					Sbar_DrawString(pwr_step + '22 -7 0' + woff, target1, ALPHA_FULL, '7 7 0','1 0.5 0.5');
					cnt_left = pwr_step_y;
					pwr_step_y = pwr_step_y + 23;
				}
			}
			else
			if (pk_mask & 1) // spell selects location
			{
				if (ibar_flag > 1)
				{
					Sbar_DrawString(pwr_step + '22 -5 0' + woff, "Select destination with reticle", ALPHA_FULL, '7 7 0','1 0.5 0.5');
					if (instr)
					{
						cnt_left = pwr_step_y;
						pwr_step_y = pwr_step_y + 14;
						Sbar_DrawString(pwr_step + '22 -5 0' + woff, instr, ALPHA_FULL, '7 7 0','1 0.5 0.5');	
					}
					cnt_left = pwr_step_y;
					pwr_step_y = pwr_step_y + 20;
				}
			}
			else if (!pk_mask) // spell just fires off
			{
				if (instr)
				{
					cnt_left = pwr_step_y;
					pwr_step_y = pwr_step_y + 14;
					Sbar_DrawString(pwr_step + '22 -5 0' + woff, instr, ALPHA_FULL, '7 7 0','1 0.5 0.5');	
				}
			}
		}
		else
		{
			if (morph == IMP_MCHAOS)
				Sbar_DrawString(pwr_step + '22 -5 0' + woff, "FIRE - chaos bolt attack", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			else
			if (morph == IMP_MORDER)
			{
				if (pk_bt == 1)
					Sbar_DrawString(pwr_step + '22 -5 0' + woff, "FIRE - order bolt attack", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				else if (pk_bt == 2)
					Sbar_DrawString(pwr_step + '22 -5 0' + woff, "FIRE - order explosive bolt attack", ALPHA_FULL, '7 7 0','1 0.5 0.5');
				else if (pk_bt == 4)
					Sbar_DrawString(pwr_step + '22 -5 0' + woff, "FIRE - order melee attack", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			cnt_left = pwr_step_y;
			pwr_step_y = pwr_step_y + 14;
			if (morph == IMP_MCHAOS)
			{
				DrawInventoryAmmo('362 50 0', "gfx/inv_chaos_shot", ALPHA_FULL, 0.1);
				if (volspec > 2000) Sbar_DrawString(pwr_step + '22 -5 0' + woff, "ALT_FIRE - chaos beam", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
			else
			if (morph == IMP_MORDER)
			{
				if (pk_bt == 4)
					DrawInventoryAmmo('362 50 0', "gfx/oma", ALPHA_FULL, 0.1);
				else
				if (pk_bt == 2)
					DrawInventoryAmmo('362 50 0', "gfx/inv_order_shot", ALPHA_FULL, 0.15);
				else
					DrawInventoryAmmo('362 50 0', "gfx/inv_order_shot", ALPHA_FULL, 0.1);
				if (volspec > 2000) Sbar_DrawString(pwr_step + '22 -5 0' + woff, "ALT_FIRE - order beam", ALPHA_FULL, '7 7 0','1 0.5 0.5');
			}
		}

		return; // because archon should not have any stuff
	}

	
// TEST: display mapcode of currently held item
// Sbar_DrawString(pwr_step + '44 -5 0' + woff, ftos(mcode), ALPHA_FULL, '7 7 0','1 0.5 0.5');

sb_align = SB_BOTTOM_RIGHT;

//position and size of ibar items

// std inventory will maintain a 20 unit step, blocked, new inventory will increment where needed
// some items are on position swap out - laser for sng, etc.

/// weapon area right
	wep_step = '290 140 0';

	if (bullets > 0)
	{
		DrawInventoryAmmo(wep_step + '12 -10 0',"gfx/sb_bullet", ALPHA_FULL, 0.08);
//		if (mcode == MC_C_FLAMER)
//			DrawAmmo('0 0 0', wep_step + '-10 -15 0', bullets, ALPHA_FULL);
//		else
			DrawAmmo('0 0 0', wep_step + '-10 -15 0', bullets, ALPHA_MEDIUM);
		wep_step = wep_step + '0 20 0';
	}

	if (gas > 0)
	{
		DrawInventoryAmmo(wep_step + '12 -10 0',"gfx/sb_gas1", ALPHA_FULL, 0.1);
		if (mcode == MC_C_FLAMER)
			DrawAmmo('0 0 0', wep_step + '-10 -15 0', gas, ALPHA_FULL);
		else
			DrawAmmo('0 0 0', wep_step + '-10 -15 0', gas, ALPHA_MEDIUM);
		wep_step = wep_step + '0 20 0';
	}

	if (slugs > 0)
	{
		DrawInventoryAmmo(wep_step + '12 -10 0',"gfx/sb_slug", ALPHA_FULL, 0.08);
		if (mcode == MC_Q2_RAILGUN)
			DrawAmmo('0 0 0', wep_step + '-10 -15 0', slugs, ALPHA_FULL);
		else
			DrawAmmo('0 0 0', wep_step + '-10 -15 0', slugs, ALPHA_MEDIUM);
		wep_step = wep_step + '0 20 0';
	}

	pk_wep_step = '262 30 0';
	inv_alm = 1;
	if (items & IT_INVISIBILITY) inv_alm = 0.2;

	float bscale;
	bscale = 1;
	vector v_bl, v_a, v_b, v_c;
	v_a = v_b = v_c = '0 0 0';
	if (autocvar_hud_bigwep) // make the drawn wep icon 2x
	{
		bscale = 2;
		v_a_x = v_a_x -  24; // size adjust left all
		v_bl = '0 -3 0';
		v_b_y = 10; // main icon adjust up + flare
	}

	if (x_items & X_Q3_HTEL)
	{
		if (mcode == MC_Q3_HOLDTELE)
		{
			if (autocvar_hud_bigwep) // holdab tele has special adust - bottom of screen deal
			{
				v_bl = '0 0 0';
				v_b_y = 12;
			}
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/hld_tel", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', 1, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/hld_tel", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', 1, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_phone > 0) // || mcode == MC_Q3_HOLDTELE)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PKPLUS_IT_PHONE))
		{
			if (autocvar_hud_bigwep) // phone has special adust - bottom of screen deal
			{
				v_bl = '0 0 0';
				v_b_y = 12;
			}
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
//			if (mcode == MC_Q3_HOLDTELE) DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/hld_tel", ALPHA_FULL, 0.125 * bscale);
//			else 
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_phn", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_phone, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_phn", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_phone, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_mask > 0)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PKPLUS_IT_ACTOR))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_mask", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_mask, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_mask", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_mask, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_tomb > 0)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PKPLUS_IT_TOMB))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_tomb", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_tomb, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_tomb", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_tomb, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_ego > 0)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PKPLUS_IT_EGO))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_ego", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_ego, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_ego", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_ego, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (x_items & X_Q3_HMED)
	{
		if (mcode == MC_Q3_HOLDMEDKIT)
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/hld_med", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', 1, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/hld_med", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', 1, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_copb > 0) // || mcode == MC_Q3_HOLDMEDKIT)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PK_IT_CANPAB))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
//			if (mcode == MC_Q3_HOLDMEDKIT) DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/hld_med", ALPHA_FULL, 0.125 * bscale);
//			else 
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_copb", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_copb, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_copb", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_copb, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_bt > 0)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PK_IT_BEARTRAP))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_btrap", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_bt, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_btrap", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_bt, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_tur > 0)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PK_IT_TURRET))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_turr", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', pk_tur, ALPHA_FULL);
		}
		else
		{
			DrawInventoryAmmo(pk_wep_step, "gfx/inv_turr", ALPHA_FULL * inv_alm, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', pk_tur, ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

	if (pk_gwell)
	{
		if ((currentweap == IT_AXE) && (pk_wep == PK_IT_GRAVITYWELL))
		{
			if (dmg_flare) Sbar_DrawPic(pk_wep_step + v_a + v_b + '-2 2 0' + woff, "gfx/dmg_flare3", ALPHA_90, 0.15 * bscale);
			else if (!autocvar_hud_bigwep) Sbar_DrawPic(pk_wep_step + v_a + v_bl + '-2 -16 0' + woff, "gfx/spell_bar", ALPHA_90, 0.5 * bscale);
			if (pk_gwell > 0)
				DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_gwell", ALPHA_FULL, 0.125 * bscale);
			else
				DrawInventoryAmmo(pk_wep_step + v_a + v_b, "gfx/inv_sgwell", ALPHA_FULL, 0.125 * bscale);
			DrawAmmo('0 0 0', pk_wep_step + v_a + '-22 -5 0', fabs(pk_gwell), ALPHA_FULL);
		}
		else
		{
			if (pk_gwell > 0)
				DrawInventoryAmmo(pk_wep_step, "gfx/inv_gwell", ALPHA_FULL * inv_alm, 0.125);
			else
				DrawInventoryAmmo(pk_wep_step, "gfx/inv_sgwell", ALPHA_FULL, 0.125);
			DrawAmmo('0 0 0', pk_wep_step + '-22 -5 0', fabs(pk_gwell), ALPHA_MEDIUM);
		}
		pk_wep_step = pk_wep_step + '0 20 0';
	}

// for mjolnir ammo display (if hammer has enough ammo to fire ltn) clear pk items col
	if (currentweap == IT_MJOLNIR)
	if ((cammo > 14) || (mcode != MC_HIP_MJOLNIR))
	if (wep_step_y < pk_wep_step_y) wep_step_y = pk_wep_step_y;

//	if  // exclude non mjolnir items that use IT_MJOLNIR bit == 128
	DrawInventoryWeapon(wep_step, "gfx/inv_mjolnir",  wep_mj,  IT_MJOLNIR, 0.125, 0);
	if (cl_items & IT_MJOLNIR) wep_step = wep_step + '0 20 0';

	if (has_hook)
		DrawInventoryWeapon(wep_step, "gfx/inv_hook", "gfx/inv2_hook",  PK_IT_GRAPGUN, 0.125, STAT_PKWEP);
	else
		DrawInventoryWeapon(wep_step, "gfx/inv_harp", wep_harp,  PK_IT_GRAPGUN, 0.125, STAT_PKWEP);
	if (pk_inv & PK_IT_GRAPGUN) wep_step = wep_step + '0 20 0';

// for shotgun ammo display - clear pk items col
	if (wep_step_y < pk_wep_step_y) wep_step_y = pk_wep_step_y;

	DrawInventoryWeapon(wep_step, "gfx/inv_shotgun",  wep_sg,  IT_SHOTGUN, 1, 0);
	wep_axlv = wep_step + '-30 0 0'; // sycn with shotgun

//	if (wep_axlv_y < pk_wep_step_y) wep_axlv_y = pk_wep_step_y; // unless pk deposes it - note: shotgun is now *always* above pk col...

	if ((pk_wep == PK_IT_AXE) && (currentweap == IT_AXE))
	if (has_deepsleep)
		DrawInventoryWeapon(wep_axlv, "gfx/inv_deep_sleep",  "gfx/inv2_deep_sleep",  IT_AXE, 0.125, 0);
	else
		DrawInventoryWeapon(wep_axlv, "gfx/inv_axe",  wep_axe,  IT_AXE, 0.125, 0);


	DrawInventoryWeapon(wep_step + '0 20 0', "gfx/inv_aircan", wep_airgun,  PK_IT_AIRGUN, 0.125, STAT_PKWEP);
	if (pk_inv & PK_IT_AIRGUN) wep_step = wep_step + '0 20 0';

	DrawInventoryWeapon(wep_step + '0 20 0', "gfx/inv_sshotgun", wep_ssg, IT_SUPER_SHOTGUN, 1, 0);

	if (has_pnail)
		DrawInventoryWeapon(wep_step + '0 40 0', "gfx/inv_pnail",  wep_pnail,  IT_NAILGUN, 0.125, 0);
	else
		DrawInventoryWeapon(wep_step + '0 40 0', "gfx/inv_nailgun",  wep_nail,  IT_NAILGUN, 1, 0);

// Cataboligne - 9.9.13 - had to change, these had issues because Archon code is different on extra weps

	if (has_laser)
		DrawInventoryWeapon(wep_step + '0 60 0', "gfx/inv_laser", wep_laser, IT_SUPER_NAILGUN, 0.125, 0);
	else
		DrawInventoryWeapon(wep_step + '0 60 0', "gfx/inv_snailgun", wep_snail, IT_SUPER_NAILGUN, 1, 0);

	if (has_flamer1)
		DrawInventoryWeapon(wep_step + '0 80 0', "gfx/inv_flamer1",  "gfx/inv2_flamer1",  IT_GRENADE_LAUNCHER, 0.125, 0);
	else if (has_prox)
		DrawInventoryWeapon(wep_step + '0 80 0', "gfx/inv_prox_gren",  wep_prox,  IT_GRENADE_LAUNCHER, 0.125, 0);
	else
		DrawInventoryWeapon(wep_step + '0 80 0', "gfx/inv_rlaunch",  wep_gren,  IT_GRENADE_LAUNCHER, 1, 0);

	DrawInventoryWeapon(wep_step + '0 100 0', "gfx/inv_srlaunch", wep_rock, IT_ROCKET_LAUNCHER, 1, 0);

	DrawInventoryWeapon(wep_step + '-24 120 0', "gfx/inv_lightng",  wep_light,  IT_LIGHTNING, 1, 0);
	if (cl_items & IT_LIGHTNING) wep_step = wep_step + '0 20 0';

	DrawInventoryWeapon(wep_step + '0 120 0', "gfx/inv_clg",  wep_clg,  PK_IT_CLIGHT, 0.125, STAT_PKWEP);
	if (pk_inv & PK_IT_CLIGHT) wep_step = wep_step + '0 20 0';



	if (explodeshot > 0)
	{
		DrawInventoryAmmo('302 30 0', "gfx/sb_xpshells", explodsht_alp, 0.125);  
		DrawAmmo('0 0 0', '280 25 0', explodeshot, explodsht_alp);
	}

// for 4 small ammo icon positions

	if (morph > 60) // dont display for non humans unless they got some
	{
		if (shells > 0)
		{
			DrawInventoryAmmo('302 50 0', "gfx/sb_shells", ALPHA_FULL, 0.5);  
			DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_MEDIUM);
		}
		if (nails > 0)
		{
			DrawInventoryAmmo('302 70 0', "gfx/sb_nails", ALPHA_FULL, 0.5);
			DrawAmmo('0 0 0', '280 65 0', nails, ALPHA_MEDIUM);
		}
		if (rockets > 0)
		{
			DrawInventoryAmmo('302 90 0', "gfx/sb_rocket", ALPHA_FULL, 0.5);
			DrawAmmo('0 0 0', '280 85 0', rockets, ALPHA_MEDIUM);
		}
		if (cells > 0)
		{
			DrawInventoryAmmo('302 110 0',"gfx/sb_cells", ALPHA_FULL, 0.5);
			DrawAmmo('0 0 0', '280 105 0', cells, ALPHA_MEDIUM);
		}
		return;
	}
	DrawInventoryAmmo('302 50 0', "gfx/sb_shells", ALPHA_FULL, 0.5);  
	DrawInventoryAmmo('302 70 0', "gfx/sb_nails", ALPHA_FULL, 0.5);
	DrawInventoryAmmo('302 90 0', "gfx/sb_rocket", ALPHA_FULL, 0.5);
	DrawInventoryAmmo('302 110 0',"gfx/sb_cells", ALPHA_FULL, 0.5);

//highlight of current weapon ammo counter + position of ammo counters
	if (cl_items & IT_SHELLS)
	{
		if (explodsht_alp == ALPHA_FULL)
			DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_MEDIUM);
		else
		DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_FULL);
		DrawAmmo('0 0 0', '280 65 0', nails, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 85 0', rockets, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 105 0', cells, ALPHA_MEDIUM);
	}	
	else if (cl_items & IT_NAILS)
	{
		DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 65 0', nails, ALPHA_FULL);
		DrawAmmo('0 0 0', '280 85 0', rockets, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 105 0', cells, ALPHA_MEDIUM);
	}
		else if (cl_items & IT_ROCKETS)
	{
		DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 65 0', nails, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 85 0', rockets, ALPHA_FULL);
		DrawAmmo('0 0 0', '280 105 0', cells, ALPHA_MEDIUM);
	}
		else if (cl_items & IT_CELLS)
	{
		DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 65 0', nails, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 85 0', rockets, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 105 0', cells, ALPHA_FULL);
	}		
	if (cl_items & IT_AXE)// a strange dummy, but work´s fine!
	{
		if (cl_items & IT_SHELLS)	return;
		if (cl_items & IT_NAILS) 	return;
		if (cl_items & IT_ROCKETS) 	return;
		if (cl_items & IT_CELLS) 	return;
		DrawAmmo('0 0 0', '280 45 0', shells, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 65 0', nails, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 85 0', rockets, ALPHA_MEDIUM);
		DrawAmmo('0 0 0', '280 105 0', cells, ALPHA_MEDIUM);
	}
}

};
