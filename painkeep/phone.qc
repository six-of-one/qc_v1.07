 /* ::-::
 *
 * Cataboligne
 *
 * file: phone.qc 
 *
 * date: 016.2.28
 *
 * qc - painkeep plus module - phone qc
 *
 */

// pk plus cellphone teleport

entity (entity caller) SelectPhoneDestination =
{
	local entity spot;
//	local entity phonedest1;
//	local entity phonedest2;
//	local entity phonedest3;
	local float selectspot;
	local float totalspots;
	local float callingdistance;

#define	phonedest1	e1__
#define	phonedest2	e2__
#define	phonedest3	e3__

	phonedest1 = caller;
	phonedest2 = caller;
	phonedest3 = caller;
	totalspots = 0;
	spot = find (world,classname,"info_player_deathmatch");
	while ( spot )
	{
		totalspots = (totalspots + 1);
		callingdistance = vlen ((caller.origin - spot.origin));
		if ( (callingdistance > vlen ((caller.origin - phonedest1.origin))) )
		{
			phonedest3 = phonedest2;
			phonedest2 = phonedest1;
			phonedest1 = spot;
		}
		else
		if ( (callingdistance > vlen ((caller.origin - phonedest2.origin))) )
		{
			phonedest3 = phonedest2;
			phonedest2 = spot;
		}
		else
		if ( (callingdistance > vlen ((caller.origin - phonedest3.origin))) )
		{
			phonedest3 = spot;
		}
		spot = find (spot,classname,"info_player_deathmatch");
	}
	if ( (totalspots > 3) )
	{
		totalspots = 3;
	}
	selectspot = floor (((totalspots * random ()) + 1));
	if ( (selectspot == 1) )
	{
		spot = phonedest1;
	}
	else
	if ( (selectspot == 2) )
	{
		spot = phonedest2;
	}
	else
	if ( (selectspot == 3) )
	{
		spot = phonedest3;
	}
	return(spot);
};

// Cataboligne - 9.3.11 - modified for holdable use

void () phone_teleport =
{
//	local entity phonedest;
//	local vector org;	self.v__
#define	phonedest	self.e__

	phonedest = SelectPhoneDestination (self.owner);
#ifdef notused
	ClearSpawnPoint (phonedest);
#endifdef

#ifndef code_xents
	makevectors (phonedest.mangle);
	self.v__ = (phonedest.origin + (32 * v_forward));
	spawn_tfog (self.v__);
	spawn_tdeath (phonedest.origin,self.owner);
// holdable teleport special
	if (self.pk_currentitem < 0)
	{
		if (self.noise3)
		{
			if (telesnd) remove(telesnd);
			telesnd = world;
			sound (self, CHAN_AUTO, self.noise3, 1, ATTN_NORM);
		}
//		spawn_tfog2 (self.owner.origin, self.noise1); // set		__holdable_teleporter_noise1		"q3_snd/teleout.wav"		""
	}

//	spawn_tfog2 (self.owner.origin, string_null);
	spawn_tfog (self.owner.origin);

	setorigin (self.owner,phonedest.origin);
//	self.owner.aiment = world; // Cataboligne - 5.4.10 - telefrag escape for admin, need to reset this
	if ( !self.owner.health )
	{
		self.owner.velocity = ((v_forward * self.owner.velocity_x) + (v_forward * self.owner.velocity_y));
	}
	else
	{
		self.owner.angles = phonedest.mangle;
		if ( (other.classname == "player") )
		{
			self.owner.fixangle = 1;
			self.owner.teleport_time = (time + 0.7);
			self.owner.bt_immune_time = (time + BT_BUFFER);
			self.owner.velocity = (v_forward * 300);
		}
	}
	self.owner.flags = (self.owner.flags - (self.owner.flags & FL_ONGROUND));
#else
	mini_teleport();
#endifdef
	remove (self);
};

void () phone_activate =
{
//	local entity ent;
	nspawn = spawn ();
	sound (self,CHAN_VOICE,"phone/phone.wav",1,ATTN_NORM);
	nspawn.owner = self;
	nspawn.think = phone_teleport;
	nspawn.nextthink = (time + 0.5);
};

