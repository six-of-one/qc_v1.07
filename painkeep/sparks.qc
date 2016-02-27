/* ::-::
 *
 * Cataboligne
 *
 * file: sparks.qc 
 *
 * date: 016.2.27
 *
 * qc - painkeep module - sparks qc
 *
 */

/*
	light_sparks
	Written by Matt Houser

	"classname" 	"light_sparks"
	"origin" 		"# # #" 	- Usual
	"angle" 		"#"		- Direction sparks fly
	"light" 		"#"		- Usual (good value is 100)
	"mean"		"#" 		- Mean time before sparks (default 5)
	"stdev" 		"#"		- Variation around the mean time (default 0)
*/

$frame spark1 spark2

// for maximum # of sparks in a level at any given time
#define MAXSPARKS		50
float currentSparks;

void() spark_die =
{
	remove(self);
	currentSparks = currentSparks - 1;
};

void() light_spark_emit =
{
//	if ((! pk_flags & PK_TP_SPARKSFLASH) || !XENV)
	{
//		local float numSparks;
//		local entity spark;

#define	numSparks	self.f__
#define spark_		self.e__

#ifndef spawn_func
		if (self.targetname) return;
#endifdef

		// emit anywhere's from 3 to 17 sparks
		numSparks = 10 + crandom() * 7;

		if (numSparks + currentSparks > MAXSPARKS)
		{
			numSparks = MAXSPARKS - currentSparks;
		}

		// play sound
		if (numSparks > 0)
//			numSparks = 0;
//		else 
		if (numSparks < 7)
			sound (self, CHAN_VOICE, "misc/spark/spark_4.wav", 1, ATTN_NORM);
		else if (numSparks < 12)
			sound (self, CHAN_VOICE, "misc/spark/spark_5.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "misc/spark/spark_6.wav", 1, ATTN_NORM);

		while (numSparks > 0)
		{
			// create a new spark
			spark_ = spawn();

			// spark lasts from 0 to 1/2 rel
			spark_.nextthink = time + random() * 0.5;
			spark_.think = spark_die;
//			spark_.solid = SOLID_NOT;
			spark_.movetype = MOVETYPE_BOUNCE;

			// TODO get a real spark model sprite
			setmodel(spark_, "progs/sparks.spr");
			if (random() < 0.5)
				spark_.frame = $spark1;
			else
				spark_.frame = $spark2;
			setorigin(spark_, self.origin);
			makevectors(self.angles);
			// give a little randomability to the direction
			spark_.velocity = v_forward * random() * 384 +
						v_right * crandom() * 128 +
						v_up * crandom() * 128;
			spark_.effects = spark_.effects | EF_MUZZLEFLASH;
			numSparks = numSparks - 1;
			currentSparks = currentSparks + 1;
		}
	}

	self.nextthink = time + meantime(self.mean, self.stdev);
};

void() light_spark_use =
{
	self.cnt = 1 - self.cnt;
	if (self.cnt)
		light_spark_emit();
};

/*
	spawn function
*/

#ifdef spawn_func
void() light_sparks =
{
	if (!self.mean)
		self.mean = 5.0;

	self.cnt = 0;

	// precaches
	precache_model ("progs/sparks.spr");
	precache_sound ("misc/spark/spark_4.wav");
	precache_sound ("misc/spark/spark_5.wav");
	precache_sound ("misc/spark/spark_6.wav");

	// glow at the origin as well makes it look a bit more realistic
	//setmodel(self, "progs/sparks.spr");
	//self.frame = $spark2;
	self.use = light_spark_use;

	// we're not targeted to let's start sparking
	if (!self.targetname)
	{
		self.nextthink = time + meantime(self.mean, self.stdev);
		self.think = light_spark_emit;
	}

	// initialize to no sparks currently
	currentSparks = 0;
};
#endifdef
