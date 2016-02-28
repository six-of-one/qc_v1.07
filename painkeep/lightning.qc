/* ::-::
 *
 * Cataboligne
 *
 * file: lightning.qc 
 *
 * date: 016.2.27
 *
 * qc - painkeep module - lightning qc
 *
 */

/*
	light_lightning
	Created by Matt Houser

	Usage:

	"classname" "light_lightning"
	"origin" "x x x"	- Origin of the entity
	"style" "14"		- This is required
	"light" "#"		- Brightness of the lightning (1000 is pretty good)
	"mean" "#"		- Mean time of next event (default 5)
	"stdev" "#"		- Variation around the mean time (default 0)
*/

#define	next__		aiment
//.entity next; // for the linked list of lightning - Cataboligne - 4.29,11 - moved to pk_defs 

void() lightning_think;

// only the first lightning uses this funciton
void() lightning_stop =
{
	// stop the lightning
	lightstyle(14, "a");
	if (self.cnt == 1)
	{
		self.nextthink = time + meantime(self.mean, self.stdev);
		self.think = lightning_think;
	}
};

void(float r) lightning_flash =
{
/*
	local entity oself;
	local string pattern;
	local string soundfile;
	local float pkduration;

	// call the .next's flash
	if (self.next__ != world)
	{
		oself = self;
		self = self.next__;
		lightning_flash(r);
		self = oself;
	}
*/

#define	pattern	self.s__
#define soundfile	self.noise
#define	pkduration		self.f__

																				bprint("* lightning_flash: ");
																				bprint(ftos(self.l_hash));
																				bprint(" - ");
																				bprint(ftos(self.cnt));
																				bprint("\n");



	// depending on the random #
	if (r < 1)
	{
//		r = 1;
		pattern = "zzzzmmdzzaaazzzmmma";
		pkduration = 2.0;
		soundfile = "misc/thunder/thunder5.wav";
	}
	else if (r < 2)
	{
//		r = 2;
		pattern = "zzddzzzzmddmmmddzzddzddzzzzzmm";
		pkduration = 3.0;
		soundfile = "misc/thunder/thunder1.wav";
	}
	else if (r < 3)
	{
//		r = 3;
		pattern = "zzzzfffzzz";
		pkduration = 1.0;
		soundfile = "misc/thunder/thunder2.wav";
	}
	else if (r < 4)
	{
//		r = 4;
		pattern = "zzzdddzzzzzmmf";
		pkduration = 1.4;
		soundfile = "misc/thunder/thunder3.wav";
	}
	else
	{
//		r = 5;
		pattern = "zzzzzddzzm";
		pkduration = 1.0;
		soundfile = "misc/thunder/thunder4.wav";
	}

	// all play the sound, but only the first controls the light level
	// note: this may be wrong, as all ents have light value set ** check map ents
	sound(self, CHAN_VOICE, soundfile, 1, ATTN_NONE);
	if (self.cnt == 1)
	{
		lightstyle(14, pattern);
		self.nextthink = time + pkduration;
		self.think = lightning_stop;

		// print a message
		//bprint("Now playing lighting sequence #");
		//bprint(ftos(ceil(r)));
		//bprint("\n");
	}

	self = self.next__;
	if (self != world)
		lightning_flash(r);
};

void() lightning_think =
{
//	local float r;

	// randomly choose a thunder/lightning pattern
	self.rnd_ = random() * 5;
	lightning_flash(self.rnd_);
};

/*
void() findFirst =
{
	// ok the last frame we set determined which light_lightning was the first
	if (self.cnt == 1)
	{
		// only the first light_lightning will actually do any randomization
		self.think = lightning_think;
		self.nextthink = time + meantime(self.mean, self.stdev);
	}
};
*/

#ifdef spawn_func
void() linkLightning =
#else
void() light_lightning =
#endifdef
{
	// turn off the light
	lightstyle(14, "a");

// make sure all get spawned
	if (time < 2) return;

//	self.think = lightning_stop;
//	self.nextthink = time + 0.1;

///REMOVE
	self.l_hash = system_hash;
	syh


	// ok find the next light_lightning
	self.next__ = find(self, classname, "light_lightning");
	if (self.next__ != world)
	{
		// tell the next one that it's not the first
		self.next__.cnt = 0;
	}

// go
	lightning_stop();
};

#ifdef spawn_func
void() light_lightning =
{
/*
	if ((pk_flags & PK_TP_SPARKSFLASH) || XENV)
	{
		remove(self);
		return;
	}
*/
	// dumb error checking - made it better, just set style
#ifdef warning
	if (self.style != 14)
//	{
		if (WARNING & 128) bprint("\n*** warning:\nlight_lightning with style != 14 - fixed.\n\n");
#endifdef
		self.style = 14;
//	}

	// precache
	precache_sound("misc/thunder/thunder5.wav");
	precache_sound("misc/thunder/thunder1.wav");
	precache_sound("misc/thunder/thunder2.wav");
	precache_sound("misc/thunder/thunder3.wav");
	precache_sound("misc/thunder/thunder4.wav");

	// default mean time
	if (!self.mean)
		self.mean = 5.0;

	self.cnt = 1;
	self.think = linkLightning;
	self.nextthink = time + 0.1;
};
#endifdef
