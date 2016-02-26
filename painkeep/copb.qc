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
	    if (random() < 0.5) //self.f__ = 4;`

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

void() copb_eatCan =
{
#ifdef code_morph
	float smax_;
	smax_ = morph_healmax(self.health_modifier, Q_MEGA_MAX);
#else
	#define smax_	250
#endifdef
	
// allow above 100...
	T_Heal(self, 100, 1);
	self.healtype = HEAL_BOT; // plague, poison, fire

	if (self.health > smax_) self.health = smax_; // bound to special max - 250 for human

// make noise + effects
	other = spawn();
	other.owner = self;
	other.copb_timeout = time + POW_TIME;
//	self.search_time = time + (random() * 2);
	other.nextthink = time + (random() * 2);
	other.think = copb_checkFart;
};
