/* ::-::
 *
 * Cataboligne
 *
 * file: copb.qc 
 *
 * date: 016.2.25
 *
 * qc - painkeep module - Can of Pork & Beens qc
 *
 */

// recode to use a think ent to run copb effects

#define	copb_nextFartTimeout	turret_soundtimeout
#define	copb_timeout	turret_timeout


void() copb_checkFart =
{
//	if (self.copb_nextFartTimeout < time) // Ended last fart?
//	if (self.search_time < time) // next fart time?
//	{ // farting time
//	  local float rs; // self.f__
//		local string fartNoise;
#define	fartNoise	self.noise

	if (self.owner.deadflag)
	{
		remove(self);
		return;
	}

		// sound off
	  if (random() < 0.90)
	  { // 75% of the time I'm using small farts...
		  self.f__ = rint((random() * 2) + 1);


		  fartNoise = string_null;
		  if (self.f__ == 1)
		    fartNoise = "weapons/copb/copb_1.wav";
		  else if (self.f__ == 2)
		    fartNoise = "weapons/copb/copb_2.wav";
	  	else
		    fartNoise = "weapons/copb/copb_3.wav";

//	    self.search_time = time + 0.5 + (random() * 0.25);
	  }
	  else
	  {
//		  self.f__ = 5;
	    if (random() < 0.5) //self.f__ = 4;

		    fartNoise = "weapons/copb/copb_4.wav";
		  else
	  	  fartNoise = "weapons/copb/copb_5.wav";

//	    self.search_time = time + 1 + (random() * 0.75);
	  }
//		fartNoise = strcat("weapons/copb/copb_",ftos(self.f__),".wav");

		sound (self.owner, CHAN_AUTO, fartNoise, 1, ATTN_NORM);

	  // lets raise up a little...
	  if (self.owner.flags & FL_ONGROUND)
	  {
	    // raise the bugger a bit
	    setorigin(self.owner, self.owner.origin + '0 0 1');
	  }

// IDEA: tweakable like other carys?
	  self.owner.velocity_z = self.owner.velocity_z + 200 + (random() * 200);

//	  self.copb_nextFartTimeout = time + 3 + rint(random() * 2);
	  self.nextthink = time + 3 + rint(random() * 2);
	  if (self.copb_timeout < time) remove(self);
//	}
};

#define  PK_CPB_HEAL	self.max_health

void() copb_eatCan =
{
#ifdef code_morph
//	float smax_;
	f0__ = morph_healmax(self.health_modifier, Q_MEGA_MAX);
#endifdef

	// make noise + effects
	other = spawn();
	other.owner = self;
	other.copb_timeout = time + POW_TIME;
//	self.search_time = time + (random() * 2);
	other.nextthink = time + (random() * 2);
	other.think = copb_checkFart;

	f0__ = 250;
	f1__ = 100;
	self.healtype = HEAL_BOT; // cures plague, poison, fire
	if (self.eweapon)
	{
		other.copb_timeout = time + self.eweapon.wait;
		f0__ = self.eweapon.max_health;
		f1__ = self.eweapon.volume;
		self.healtype = self.eweapon.healtype;
	}

	T_Heal(self, f1__, self.healtype);

	if (self.health > f0__) self.health = f0__;
};
