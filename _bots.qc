/* ::-::
 *
 * Cataboligne
 *
 * file: _bots.qc 
 *
 * date: 016.1.11
 *
 * qc - general bot code used by most bot packages
 *
 */
 
 // id
 
 #ifdef id_include_always
#messageinclude   _bots.qc 
#endifdef

#ifndef use_bots

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   _bots.qc 
	#endifdef
	#endifdef

// only code out one time

#define use_bots

// most bot pkg use

#include <incl/use_nextent.qc>

// moved from frikbot

// this is included in the frikbot pkg but needs to be here for moved code
//allow botcam, compile code
/// SWITCH
#define botcam_op

.float ishuman;
.entity	_next, _last;
.float	b_frags, b_clientno, b_shirt, b_pants; 
.float	priority, ai_time, b_sound, missile_speed;
float 	active_clients;
float		max_clients;

entity	b_temp1, b_temp2, b_temp3;
entity 	player_head, phys_head, way_head;

 // ----------Commands---------
void(entity e, float chan, string samp, float vol, float atten) _b_sound = #8;
void(entity client, string s)	_b_stuffcmd = #21;
void(entity client, string s)	_b_sprint = #24;
void(entity client, string s, ...)	_b_centerprint = #73;
void(entity e)			_b_setspawnparms = #78;

vector(entity e, float sped)	_b_aim = #44;		// returns the shooting vector	


#ifndef map_hack
.string class_select;
.float button3, button11;
.string stack1;
float noway_above;
float noway_below;

void(float to, float f)		_b_WriteByte = #52;
void(float to, float f)		_b_WriteChar = #53;
void(float to, float f)		_b_WriteShort = #54;
void(float to, float f)		_b_WriteLong = #55;
void(float to, float f)		_b_WriteCoord = #56;
void(float to, float f)		_b_WriteAngle = #57;
void(float to, string s)	_b_WriteString	= #58;
void(float to, entity s)	_b_WriteEntity	= #59;
#endifdef

//void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7)
//_b_big_centerprint = #73;

//----------------------------------------------------------------------------

/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Function redclarations. These allow function 
designed to work for clients (sprint, so forth)
to mainly not complain when working with a bot

Although these shouldn't be needed anymore,
as the bots truly are clients now, if you don't
stop the SZ_ buffer from filling up by disabling
direct messages to the bots, it crashes quake :-(

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/
void(entity	client, string s) stuffcmd =
{
	if (client.group == "pk*bot") return; // *bot
	if (client.ishuman == 1)
		_b_stuffcmd(client, s);
	b_temp1 = player_head;

	while(b_temp1)
	{
#ifdef botcam
		if (b_temp1.classname == "botcam")
		{
			if ((b_temp1.enemy == client) && b_temp1.ishuman)
				_b_stuffcmd(b_temp1, s);
		}
#endifdef
		b_temp1 = b_temp1._next;
	}
};

void(entity	e) setspawnparms =
{
	if (e.ishuman == 1)
		_b_setspawnparms(e);
	else
	{
		b_temp1 = player_head;
		while(b_temp1)
		{
			if (b_temp1.ishuman)
			{
				_b_setspawnparms(b_temp1);
				return;
			}
			b_temp1 = b_temp1._next;
		}
		SetNewParms();
	}
};
void(entity	client, string s) sprint =
{
	if (client.group == "pk*bot") return; // *bot
	if (client.ishuman == 1)
		_b_sprint(client, s);
	b_temp1 = player_head;

	while(b_temp1)
	{
#ifdef botcam
		if (b_temp1.classname == "botcam")
		{
			if ((b_temp1.enemy == client) && b_temp1.ishuman)
				_b_sprint(b_temp1, s);
		}
#endifdef
		b_temp1 = b_temp1._next;
	}

};

// note: this redefines "void(entity client, string s, ...)" and can NOT use elipses - dur
// so far only affects pk

void(entity	client, string s) centerprint =
{
	if (client.group == "pk*bot") return; // *bot
	if (client.ishuman == 1)
		_b_centerprint(client, s);
	b_temp1 = player_head;

	while(b_temp1)
	{
#ifdef botcam
		if (b_temp1.classname == "botcam")
		{
			if ((b_temp1.enemy == client) && b_temp1.ishuman)
				_b_centerprint(b_temp1, s);
		}
#endifdef
		b_temp1 = b_temp1._next;
	}
};

#ifdef code_pkbots
vector () botaim;		// pk fn
#endifdef

vector(entity e, float sped) aim =
{
	e.missile_speed = sped;
#ifdef code_pkbots
	if (e.group == "pk*bot") return(botaim());
#endifdef
	return _b_aim(e, sped);
};

void(entity e, float chan, string samp, float vol, float atten) sound = 
{

	s0__ = cvar_string(strcat("__",samp));
	if (strlen(s0__) > 1) samp = s0__;

#ifdef warning
																				syh
																				registercvar(strcat("___snd_",ftos(system_hash)),strcat(samp," org: ",vtos(e.origin)," e: ",ftos(num_for_edict(e))));

#endifdef

#ifdef code_xents
// q2 silencer for wep channel stuff
	if (chan == CHAN_WEAPON)
	if (e.silencer_finished)
	{
		if (e.silencer_finished > time)
		{
			vol = vol * Q2_SILENCE;
		}
		else
		{
			e.silencer_finished = 0;
// ? #ifdef hud code test
			stuffcmd(e, "hud_message \"Silencer used up\"\n");
//			sprint (e, "Silencer used up\n");
		}
	}
#endifdef

	_b_sound(e, chan, samp, vol, atten);
//	pk_sound(e, chan, samp, vol, atten);
	
	if (samp == "items/inv3.wav")
		return;
	else if (e.classname == "player")
		e.b_sound = time + 1;
	else if (other.classname == "player")
		other.b_sound = time + 1;

};



//																				--- done in maphack engine - * only * runs under maphack!
#ifndef map_hack

void(float to, float f) WriteByte =
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteByte(to, f);
};
void(float to, float f) WriteChar =		
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteChar(to, f);
};
void(float to, float f) WriteShort =	
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteShort(to, f);
};

#ifndef use_WriteLong
#define use_WriteLong
void(float to, float f) WriteLong = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteLong(to, f);
};
#endifdef

void(float to, float f) WriteCoord = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteCoord(to, f);
};
void(float to, float f) WriteAngle = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteAngle(to, f);
};
void(float to, string s) WriteString = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteString(to, s);
};
void(float to, entity s) WriteEntity = 
{
	if ((to == MSG_ONE) && (msg_entity.ishuman != TRUE))
		return;
	_b_WriteEntity(to, s);
};

#else

// VERIFY: check with defs.qc for changes to original code

void(float to, float f) WriteByte		= #52;
#ifdef unused
void(float to, float f) WriteChar		= #53;																		// qc++ - seems not used in v1.06
#include <incl/use_writelong.qc>
//void(float to, float f) WriteLong		= #55;
#endifdef
#ifdef botcam_op
void(float to, float f) WriteAngle		= #57;
#endifdef
void(float to, float f) WriteShort		= #54; // used by frikbot
void(float to, float f) WriteCoord		= #56;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

#endifdef

// used by all bots
/*
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Rankings 'utilities'. Written by Alan Kivlin,
this code just fools clients by sending precisely
the same network messages as when a real player
signs on to the server.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*/

#define SVC_UPDATENAME	13
#define SVC_UPDATEFRAGS	14
#define SVC_UPDATECOLORS	17

void(entity who) UpdateClient =
{
	WriteByte (MSG_ALL, SVC_UPDATENAME);
	WriteByte (MSG_ALL, who.b_clientno);
	WriteString (MSG_ALL, who.netname);
	WriteByte (MSG_ALL, SVC_UPDATECOLORS);
	WriteByte (MSG_ALL, who.b_clientno);
	WriteByte (MSG_ALL, who.b_shirt * 16 + who.b_pants);
	WriteByte (MSG_ALL, SVC_UPDATEFRAGS);
	WriteByte (MSG_ALL, who.b_clientno);
	WriteShort (MSG_ALL, who.frags);
};


float(float clientno) ClientBitFlag =
{
	// bigger, but faster
	if (clientno == 0)
		return 1;
	else if (clientno == 1)
		return 2;
	else if (clientno == 2)
		return 4;
	else if (clientno == 3)
		return 8;
	else if (clientno == 4)
		return 16;
	else if (clientno == 5)
		return 32;
	else if (clientno == 6)
		return 64;
	else if (clientno == 7)
		return 128;
	else if (clientno == 8)
		return 256;
	else if (clientno == 9)
		return 512;
	else if (clientno == 10)
		return 1024;
	else if (clientno == 11)
		return 2048;
	else if (clientno == 12)
		return 4096;
	else if (clientno == 13)
		return 8192;
	else if (clientno == 14)
		return 16384;
	else if (clientno == 15)
		return 32768;
	return 0;
};


float() ClientNextAvailable =
{
	local float clientno;

	clientno = max_clients;
	while(clientno > 0)
	{
		clientno = clientno - 1;

		if (!(active_clients & ClientBitFlag(clientno)))
			return clientno;
	}

	return -1;
};

// pki if painkeep compiled in

// * bots can collect & use painkeep stuff - YAY (no gir, thats bad...aww. I wanted to explode.)

#ifdef code_painkeep_
void() use_pkitem =
{
	local float drp;

	drp = 0;

	if (self.health < 30) drp = 1;		// hurt - always use item - try most beneficial first

	else if (self.health < 66)
	{
		if (self.health < 40) drp = 1;
		else drp = random();
		if (drp < 0.1) drp = 0.9;
		else if (drp < 0.2) drp = 0.8;
	}
	else if (random() < 0.3)
	{
		drp = random();
		if (drp < 0.1) drp = 0.9;
		else if (drp < 0.2) drp = 0.8;
	}

	if (drp)
	{
// FIX: need to set eweap - really need to select
		if (self.pk_canpabammo > 0 && drp > 0.9) // heal or escape when health low
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_CANPAB;
			W_Attack();
		}
#ifdef code_pkplus_
		else if (self.pkplus_phoneammo > 0 && drp > 0.9)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PKPLUS_IT_PHONE;
			W_Attack();
		}
#endifdef
		else if (self.pk_gravitywellammo != 0 && drp > 0.8)
		{
			if (coop)
			{
				local entity pl;
				pl = find(world, classname, "player");
				while (pl != world)
				{
					if (pl.class_select == "class_player" && (vlen(self.origin - pl.origin) < 2000)) return; // dont fire one of these when real player is close by
					pl = find(pl, classname, "player");
				}
			}
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_GRAVITYWELL;
			W_Attack();
		}
		else if (self.pk_turretammo > 0 && drp > 0.7)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_TURRET;
			W_Attack();
		}
		else if (self.pk_beartrapammo > 0 && drp > 0.6)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PK_IT_BEARTRAP;
			W_Attack();
		}
#ifdef code_pkplus_
		else if (self.pkplus_egoammo > 0 && drp > 0.4) // Cataboligne - 5.8.10 - bots use pkplus artefacts items now - YAY!  (no Gir, thats bad...)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PKPLUS_IT_EGO;
			W_Attack();
		}
		else if (self.pkplus_tombammo > 0)
		{
			self.weapon = IT_AXE;
			self.pk_currentitem = PKPLUS_IT_TOMB;
			W_Attack();
		}
#endifdef
	}
};
#endifdef

 // use_bots main section
#endifdef

 
 