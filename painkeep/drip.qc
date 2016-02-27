/* ::-::
 *
 * Cataboligne
 *
 * file: drip.qc 
 *
 * date: 016.2.25
 *
 * qc - painkeep module - func_drip qc
 *
 */

/*
	func_drip
	Written by Matt Houser
	19:14GMT-5:01/01/96

	016.1.25 - Cataboligne - add acid damage - TODO - new frame, skin, override for acid drops, hiss sounds

	"classname" "func_drip"
	"style" "#"	- not implemented yet
	"sounds" "#"	- not implemented yet
	"mean" "#" 	- Mean time between drips (default is 5)
	"stdev" "#" 	- Variation around the mean time (default is 0)
	"dmg" "#"		- acid drop damage -- [ 1 - 4 ] suggested (default 0)
	"noise3"	"{snd}"	- hiss sound when acid drop hits
*/

void() func_drip_touch =
{
//	local float r;
	// play sound
	if (other.classname == "worldspawn")
	{
		// random sound
		self.rnd_ = random() * 3;
		if (self.rnd_ < 1)
		{
			sound (self, CHAN_AUTO, "misc/drip/drip_1.wav", 1, ATTN_NORM);
		}
		else if (self.rnd_ < 2)
		{
			sound (self, CHAN_AUTO, "misc/drip/drip_3.wav", 1, ATTN_NORM);
		}
		else
		{
			sound (self, CHAN_AUTO, "misc/drip/drip_4.wav", 1, ATTN_NORM);
		}
	}
	else if (other.classname == "drop")
		return;
	else
		// muffled sound
		sound (self, CHAN_AUTO, "misc/drip/drip_2.wav", 1, ATTN_NORM);

// Cataboligne - add acid damage, sound
	if (self.dmg)
	{
		T_Damage(other, self, self, self.dmg);
		sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	}
	SUB_Remove();
};

void() func_drip_drop =
{
//	local entity drop;

// new ops will remove this with cfg update
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
		// create new drop
		self.e__ = spawn();
		self.e__.classname = "drop";
		self.e__.solid = SOLID_TRIGGER;
		self.e__.movetype = MOVETYPE_BOUNCE;
		self.e__.touch = func_drip_touch;
		self.e__.dmg = self.dmg;		// Cataboligne - add acid damage
// TODO: assign frame / skin / etc
		setorigin(self.e__, self.origin);
		setmodel(self.e__, "progs/s_drip.spr");

	  // PAINKEEP SPLASH Not for splashing, but so we can remove it if it hits the water
#ifdef painkeep_splash
	  AddToSplash(self.e__);
#endifdef
	}

	self.nextthink = time + meantime(self.mean, self.stdev);
};


#ifdef spawn_func
vvoid() func_drip =
{
	//precaches
	precache_model("progs/s_drip.spr");
	precache_sound("misc/drip/drip_1.wav");
	precache_sound("misc/drip/drip_2.wav");
	precache_sound("misc/drip/drip_3.wav");
	precache_sound("misc/drip/drip_4.wav");

	// default wait
	if (!self.mean)
		self.mean = 5.0;

	// default style - not implemented
//	if (!self.style)
//		self.style = 1;

	// default sound - not implemented
//	if (!self.sounds)
//		self.sounds = 1;

	self.think = func_drip_drop;
	self.nextthink = time + meantime(self.mean, self.stdev);
};
#endifdef
