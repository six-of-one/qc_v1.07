/*
	New sound funcs for pk

	Random sound generators:
	"classname" "func_thumpsound"      // Generate a random thumping sound
	... and many others. have a look at the src for details
*/

#define rand_time() time + 1 + random() * 30

/*
float() rand_time =
{
	return time + 1 + random() * 30;
	//return time + 1;
};
*/
void() func_thumpsound_play =
{
// plan is to use cfg to control these - these may need an update
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
	  local float r;
//local string sname;
	  self.rnd_ = random() * 8;
	  if (self.rnd_ < 1)
	    self.s__ = "random/thump/thump_1.wav";
	  else if (self.rnd_ < 2)
	    self.s__ = "random/thump/thump_2.wav";
	  else if (self.rnd_ < 3)
	    self.s__ = "random/thump/thump_3.wav";
	  else if (self.rnd_ < 4)
	    self.s__ = "random/thump/thump_4.wav";
	  else if (self.rnd_ < 5)
	    self.s__ = "random/thump/thump_5.wav";
	  else if (self.rnd_ < 6)
	    self.s__ = "random/thump/thump_6.wav";
	  else if (self.rnd_ < 7)
	    self.s__ = "random/thump/thump_7.wav";
	  else
	    self.s__ = "random/thump/thump_8.wav";
	  sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}

	if (world.model == "maps/pk6.bsp" || world.model == "maps/pk7.bsp")
	  self.nextthink = time + 1;
	else
	  self.nextthink = rand_time();
};

void() func_cygnussound_play =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//.*local float r;
//local string sname;
		self.rnd_ = random() * 7;
		if (self.rnd_ < 1)
			self.s__ = "random/cygnus/cygnus_1.wav";
		else if (self.rnd_ < 2)
			self.s__ = "random/cygnus/cygnus_2.wav";
		else if (self.rnd_ < 3)
			self.s__ = "random/cygnus/cygnus_3.wav";
		else if (self.rnd_ < 4)
			self.s__ = "random/cygnus/cygnus_4.wav";
		else if (self.rnd_ < 5)
			self.s__ = "random/cygnus/cygnus_5.wav";
		else if (self.rnd_ < 6)
			self.s__ = "random/cygnus/cygnus_6.wav";
		else
			self.s__ = "random/cygnus/cygnus_7.wav";
		sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}

	self.nextthink = rand_time();
};

void() func_birdsound_play =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//.*local float r;
//local string sname;
		self.rnd_ = random() * 10;
		if (self.rnd_ < 1)
			self.s__ = "random/bird/bird_1.wav";
		else if (self.rnd_ < 2)
			self.s__ = "random/bird/bird_2.wav";
		else if (self.rnd_ < 3)
			self.s__ = "random/bird/bird_3.wav";
		else if (self.rnd_ < 4)
			self.s__ = "random/bird/bird_4.wav";
		else if (self.rnd_ < 5)
			self.s__ = "random/bird/bird_5.wav";
		else if (self.rnd_ < 6)
			self.s__ = "random/bird/bird_6.wav";
		else if (self.rnd_ < 7)
			self.s__ = "random/bird/bird_7.wav";
		else if (self.rnd_ < 8)
			self.s__ = "random/bird/bird_8.wav";
		else if (self.rnd_ < 9)
			self.s__ = "random/bird/bird_9.wav";
		else
			self.s__ = "random/bird/bird_10.wav";
		sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}
	self.nextthink = rand_time();
};

void() func_growlsound_play =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//.*local float r;
//local string sname;
		self.rnd_ = random() * 6;
		if (self.rnd_ < 1)
			self.s__ = "random/growl/growl_1.wav";
		else if (self.rnd_ < 2)
			self.s__ = "random/growl/growl_2.wav";
		else if (self.rnd_ < 3)
			self.s__ = "random/growl/growl_3.wav";
		else if (self.rnd_ < 4)
			self.s__ = "random/growl/growl_4.wav";
		else if (self.rnd_ < 5)
			self.s__ = "random/growl/growl_5.wav";
		else
			self.s__ = "random/growl/growl_6.wav";
		sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}
	self.nextthink = rand_time();
};

void() func_moansound_play =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//.*local float r;
//local string sname;
		self.rnd_ = random() * 5;
		if (self.rnd_ < 1)
			self.s__ = "random/moans/moan_1.wav";
		else if (self.rnd_ < 2)
			self.s__ = "random/moans/moan_2.wav";
		else if (self.rnd_ < 3)
			self.s__ = "random/moans/moan_3.wav";
		else if (self.rnd_ < 4)
			self.s__ = "random/moans/moan_4.wav";
		else
			self.s__ = "random/moans/moan_5.wav";
		sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}
	self.nextthink = rand_time();
};

void() func_swampsound_play =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//.*local float r;
//local string sname;
		self.rnd_ = random() * 10;
		if (self.rnd_ < 1)
			self.s__ = "random/swamp/swamp_1.wav";
		else if (self.rnd_ < 2)
			self.s__ = "random/swamp/swamp_2.wav";
		else if (self.rnd_ < 3)
			self.s__ = "random/swamp/swamp_3.wav";
		else if (self.rnd_ < 4)
			self.s__ = "random/swamp/swamp_4.wav";
		else if (self.rnd_ < 5)
			self.s__ = "random/swamp/swamp_5.wav";
		else if (self.rnd_ < 6)
			self.s__ = "random/swamp/swamp_6.wav";
		else if (self.rnd_ < 7)
			self.s__ = "random/swamp/swamp_7.wav";
		else if (self.rnd_ < 8)
			self.s__ = "random/swamp/swamp_8.wav";
		else if (self.rnd_ < 9)
			self.s__ = "random/swamp/swamp_9.wav";
		else
			self.s__ = "random/swamp/swamp_10.wav";
		sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}

	self.nextthink = rand_time();
};

void() func_painsound_play =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//.*local float r;
//local string sname;
		self.rnd_ = random() * 7;
		if (self.rnd_ < 1)
			self.s__ = "random/pain/pain_1.wav";
		else if (self.rnd_ < 2)
			self.s__ = "random/pain/pain_2.wav";
		else if (self.rnd_ < 3)
			self.s__ = "random/pain/pain_3.wav";
		else if (self.rnd_ < 4)
			self.s__ = "random/pain/pain_4.wav";
		else if (self.rnd_ < 5)
			self.s__ = "random/pain/pain_5.wav";
		else if (self.rnd_ < 6)
			self.s__ = "random/pain/pain_6.wav";
		else
			self.s__ = "random/pain/pain_7.wav";
		sound (self, CHAN_AUTO, self.s__ , 1, ATTN_NORM);
	}

	self.nextthink = rand_time();
};


#ifdef spawn_func
void() func_sound_thump =
{
	// precaches
	precache_sound("random/thump/thump_1.wav");
	precache_sound("random/thump/thump_2.wav");
	precache_sound("random/thump/thump_3.wav");
	precache_sound("random/thump/thump_4.wav");
	precache_sound("random/thump/thump_5.wav");
	precache_sound("random/thump/thump_6.wav");
	precache_sound("random/thump/thump_7.wav");
	precache_sound("random/thump/thump_8.wav");

	self.think = func_thumpsound_play;
	self.nextthink = rand_time();
};

// For backwards compatibility
void() func_thumpsound =
{
	func_sound_thump();
};

void() func_sound_cygnus =
{
	// precaches
	precache_sound("random/cygnus/cygnus_1.wav");
	precache_sound("random/cygnus/cygnus_2.wav");
	precache_sound("random/cygnus/cygnus_3.wav");
	precache_sound("random/cygnus/cygnus_4.wav");
	precache_sound("random/cygnus/cygnus_5.wav");
	precache_sound("random/cygnus/cygnus_6.wav");
	precache_sound("random/cygnus/cygnus_7.wav");

	self.think = func_cygnussound_play;
	self.nextthink = rand_time();
};

void() func_sound_bird =
{
	// precaches
	precache_sound("random/bird/bird_1.wav");
	precache_sound("random/bird/bird_2.wav");
	precache_sound("random/bird/bird_3.wav");
	precache_sound("random/bird/bird_4.wav");
	precache_sound("random/bird/bird_5.wav");
	precache_sound("random/bird/bird_6.wav");
	precache_sound("random/bird/bird_7.wav");
	precache_sound("random/bird/bird_8.wav");
	precache_sound("random/bird/bird_9.wav");
	precache_sound("random/bird/bird_10.wav");

	self.think = func_birdsound_play;
	self.nextthink = rand_time();
};

void() func_sound_growl =
{
	// precaches
	precache_sound("random/growl/growl_1.wav");
	precache_sound("random/growl/growl_2.wav");
	precache_sound("random/growl/growl_3.wav");
	precache_sound("random/growl/growl_4.wav");
	precache_sound("random/growl/growl_5.wav");
	precache_sound("random/growl/growl_6.wav");

	self.think = func_growlsound_play;
	self.nextthink = rand_time();
};

void() func_sound_moan =
{
	// precaches
	precache_sound("random/moans/moan_1.wav");
	precache_sound("random/moans/moan_2.wav");
	precache_sound("random/moans/moan_3.wav");
	precache_sound("random/moans/moan_4.wav");
	precache_sound("random/moans/moan_5.wav");

	self.think = func_moansound_play;
	self.nextthink = rand_time();
};

void() func_sound_swamp =
{
	// precaches
	precache_sound("random/swamp/swamp_1.wav");
	precache_sound("random/swamp/swamp_2.wav");
	precache_sound("random/swamp/swamp_3.wav");
	precache_sound("random/swamp/swamp_4.wav");
	precache_sound("random/swamp/swamp_5.wav");
	precache_sound("random/swamp/swamp_6.wav");
	precache_sound("random/swamp/swamp_7.wav");
	precache_sound("random/swamp/swamp_8.wav");
	precache_sound("random/swamp/swamp_9.wav");
	precache_sound("random/swamp/swamp_10.wav");

	self.think = func_swampsound_play;
	self.nextthink = rand_time();
};

void() func_sound_pain =
{
	// precaches
	precache_sound("random/pain/pain_1.wav");
	precache_sound("random/pain/pain_2.wav");
	precache_sound("random/pain/pain_3.wav");
	precache_sound("random/pain/pain_4.wav");
	precache_sound("random/pain/pain_5.wav");
	precache_sound("random/pain/pain_6.wav");
	precache_sound("random/pain/pain_7.wav");

	self.think = func_painsound_play;
	self.nextthink = rand_time();
};
#endifdef


/*
 *
 * Cataboligne - added for remix dm4 lava grate flow
 * hipnotic sound fn - play sounds when triggered
 *
 */
#eof

// TDO: something with this later, code needs cleaned up, maybe ifdef against hip stuff

void() play_sound_use =
   {
   if (self.spawnflags & 1)
      {
      if (self.state == 0)
         {
         self.state = 1;
         sound (self, self.impulse, self.noise, self.volume, self.speed);
         }
      else
         {
         self.state = 0;
         sound (self, self.impulse, "misc/null.wav", self.volume, self.speed);
         }
      }
   else
      {
      sound (self, self.impulse, self.noise, self.volume, self.speed);
      }
   };

void() PlaySoundThink =
   {
   local float t;
   t = self.wait * random();
   if (t < self.delay)
      t = self.delay;
   self.nextthink = time + t;
   play_sound_use();
   };

/*QUAKED play_sound_triggered (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) toggle
play a sound when it is used
"toggle" determines whether sound should be stopped when triggered again
"volume" how loud (1 default full volume)
"noise" sound to play
"impulse" channel on which to play sound (0-7) (0 automatic is default)
"speed" attenuation factor
   -1 - no attenuation
    1 - normal
    2 - idle
    3 - static
*/
void() play_sound_triggered =
   {
   precache_sound (self.noise);
   precache_sound ("misc/null.wav");
   if (self.volume == 0)
      self.volume = 1;
   if (self.speed == 0)
      self.speed = 1;
   if (self.speed == -1)
      self.speed = 0;
   if (self.spawnflags & 1)
      if (self.impulse == 0)
         self.impulse = 7;
   self.use = play_sound_use;
   };

/*QUAKED play_sound (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
play a sound on a periodic basis
"volume" how loud (1 default full volume)
"noise" sound to play
"wait" random time between sounds (default 20)
"delay" minimum delay between sounds (default 2)
"impulse" channel on which to play sound (0-7) (0 automatic is default)
"speed" attenuation factor
   -1 - no attenuation
    1 - normal
    2 - idle
    3 - static
*/
void() play_sound =
   {
   local float t;

   play_sound_triggered();
   if (self.wait == 0)
      self.wait = 20;
   if (self.delay == 0)
      self.delay = 2;
   self.think = PlaySoundThink;
   t = self.wait * random();
   if (t < self.delay)
      t = self.delay;
   self.nextthink = time + t;
   };

