/* ::-::
 *
 * Cataboligne
 *
 * file: archon.qc
 *
 * date: 9/29/13
 *
 * qc - support chaos mod archon being and powers
 *
 */

/*
Archon: the power

Notes:
In the original archon and adept power points did several things.
They could heal icons, protect against magic attack and in adept, increase the master power level.

The beauty of the new model design - it is from an M.C. Escher print...the one used for archon I box art.  And it was hard to make.
The eponimus power points will provide archon power, heal, protect against Archon spells and on the hub map, generate the items.


"the Story"

The power of the Archons comes from a quantum universe hidden all around us...
No one knows who made the complex 4D construct, but they were made for Archons to use.

The mathematically twisted power access device transfers that power to living beings.

*/

/// for now only need to support arena blocks for chv_? in PaiNKeep 3

#ifdef code_archon_a

	#ifdef message_top
	#message         			-- compile: Archon [ alpha ] (pk3 -> cm2) 
	#endifdef



// archon altar - map item - converts xp to archon pts

void() altar_touch =
{
	if (self.attack_finished > time) return;

	self.count = 1;
// only while the "toucher" has haste active
	if (other.rune_flag & RUNE_FLG_HS) self.count = 2;
	if (other.rune_flag & TECH_TEIM) self.count = self.count * 2;

	self.attack_finished = time + (self.delay / self.count);

	if (other.xp > self.aflag)
	{
		self.lefty = self.lefty + 1; // usage
		other.archon = other.archon + 1;

// quad powered
		if (other.super_damage_finished > time)
			other.archon = other.archon + 3;

		other.xp = other.xp - self.aflag;
		if (random() < 0.002) sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

 		if (self.goalentity) // made by an Archon, he gets some every usage
		{
			if (self.goalentity == other) return; // this might be a redundant check, as Archons cant touch altars
			self.goalentity.archon = self.goalentity.archon + 0.1;
		}
	}

// time proceeds - convert faster
	if (time > 600) self.delay = 0.015;
	else if (time > 300) self.delay = 0.03;
	else if (time > 160) self.delay = 0.06;

// conversion rate - usage based

// random spawn altars
	if (self.spawnflags & 256)
	{
		if (self.lefty > 4000) self.aflag = 64;
		else if (self.lefty > 2000) self.aflag = 32;
		else if (self.lefty > 1200) self.aflag = 16;
		else if (self.lefty > 600) self.aflag = 8;
		else if (self.lefty > 300) self.aflag = 4;
		else if (self.lefty > 100) self.aflag = 2;
		else if (time > 16) self.aflag = 1; // if we started with 0.5
	}
	else // map spawned altars - longer throw since they wont move and reset
	{
		if (self.lefty > 12800)
		{
			self.aflag = 64;
			if (self.lefty > 13800)
			if (random() < 0.05) self.aflag = self.lefty = 2;
		}
		else if (self.lefty > 6400)
		{
			self.aflag = 32;
			if (self.lefty > 7200)
			if (random() < 0.03) self.aflag = self.lefty = 2;
		}
		else if (self.lefty > 3200) self.aflag = 16;
		else if (self.lefty > 1600) self.aflag = 8;
		else if (self.lefty > 800) self.aflag = 4;
		else if (self.lefty > 200) self.aflag = 2;
		else if (time > 32) self.aflag = 1; // if we started with 0.5
	}

// conversion rate gets worse as time goes by
/*
	if (time > 240) self.aflag = 64;
	else if (time > 180) self.aflag = 32;
	else if (time > 120) self.aflag = 16;
	else if (time > 60) self.aflag = 8;
	else if (time > 30) self.aflag = 4;
	else if (time > 10) self.aflag = 2;
*/

};


// archon arena block think ops

void() th_arcarn =
{
	self.nextthink = time + self.wait + self.cnt * random();

	if (self.alpha == 0)
	{
		v1___x = self.distance * random();
		v1___y = self.distance * random();
		if (self.lip)
		if (random() < self.lip)
			v1___z = self.oldorigin_z + crandom() * self.height;

		setorigin(self, self.oldorigin + v1__);
		setmodel(self, self.mdl);
		self.nextthink = time + 0.1 + 0.2 * random();
		self.aflag = 0.1;
	}
	if (self.alpha < 1)
	{
		self.alpha = self.alpha + self.aflag;
		self.nextthink = time + 0.1 + 0.2 * random();

		if (self.alpha > 0.6 && self.aflag == 0.1)
		{
			self.solid = SOLID_BSP;
			if (self.flags)
			if (random() < 0.33)
			{
				self.effects = rnd_bit_mask(self.flags);
			}
		}
		else if (self.alpha < 0.6 && self.aflag == -0.1)
		{
			self.solid = SOLID_NOT;
			self.effects = 0;
		}

		if (self.alpha > 1)
		{
			self.nextthink = time + self.delay + self.count * random();
			if (random() < self.style) 
				self.nextthink = time + (self.delay / 0.6) + (self.count / 0.5) * random();
			self.alpha = 1;
		}
		else if (self.alpha < 0.05)
		{
			self.rnd_ = 0;
			if (self.lefty)
			if (random() < 0.1)
				self.rnd_ = self.lefty;
			self.nextthink = time + self.wait + self.cnt * random() + self.rnd_;
			self.alpha = 0;
			self.model = string_null;
			self.solid = 0;
		}
	}
	else
	{
		self.nextthink = time + 0.1 + 0.2 * random();
		self.aflag = -0.1;		
		self.alpha = self.alpha + self.aflag;
	}
	
};


// func_arcarn - archon arena blocks

// mdl = model to use
// following all have defaults (*)
// distance (64) - randomizing dist around center
// height (32) - possible height randomizer
// lip (0.25) - chance of variable height

// wait (20) - time to appear
// cnt (30) - randomizer on appear time
// lefty (rnd) - start time pause, random pauses

// delay (30) - time to hang
// count (40) - randomizer on hang time
// style (0) - chance of very short hangs

// flags (12) - bit map of allowed effects - EF_*

void() func_arcarn =
{
	self.rnd_ = random();
	if (self.mdl == string_null)
	if (self.rnd_ < 0.33)
		self.mdl = "maps/aarn1.bsp";
	else if (self.rnd_ < 0.66)
		self.mdl = "maps/aarn2.bsp";
	else
		self.mdl = "maps/aarn3.bsp";

	if (self.wait < 1) self.wait = 20; // appear time
	if (self.cnt < 1) self.cnt = 30;
	if (random() < 0.2)
	{
		self.rnd_ = random();
		if (self.rnd_ < 0.25) self.lefty = 30;
		else if (self.rnd_ < 0.5) self.lefty = 60;
		else if (self.rnd_ < 0.6) self.lefty = 80;
	}

	if (self.delay < 1) self.delay = 30; // hang time
	if (self.count < 1) self.count = 40;

	self.think = th_arcarn;
	self.nextthink = time + self.wait + self.cnt * random() + self.lefty;

	if (self.lefty) // small chance of fast starts
	if (random() < 0.1)
		self.nextthink = time + self.wait * random();

	self.oldorigin = self.origin;
	if (self.distance < 1) self.distance = 64;
	if (self.height< 1) self.height = 32;
	if (!self.lip) self.lip = 0.24;

	self.alpha = 0;
	if (self.flags < 1) self.flags = 12;
};


// archon_fader - fade archon colors for floor

void() archon_fader =
{
	self.e__ = find (world, targetname, self.target);

	if (self.delay <= 0) self.delay = 0.05; // default - 20 steps - note: really all need to be the same
	if (self.wait <= 0) self.wait = 10; // default - 60 rels per color
	if (self.cnt <= 0) self.cnt = 0.1; // default - tenth per alpha seq

	if (self.e__.delay <= 0) self.e__.delay = 0.05;
	if (self.e__.wait <= 0) self.e__.wait = 10;
	if (self.e__.cnt <= 0) self.e__.cnt = 0.1;

	if ((self.alpha >= 1) && !self.e__) // cycle 1 color
	{
		self.alpha = 0.98;
		self.nextthink = time + self.wait;
		self.delay = 0 - self.delay;
	}
	else
	if (self.alpha < 0.01)
	{
//		self.alpha = 0.001; // cant set alpha at 0 - engine displays full tex

		if (self.e__)
		{
			self.alpha = 0;
			self.mdl = self.model;
			self.model = string_null;

			self.e__.model = self.e__.mdl;
			self.e__.alpha = 1;
			self.e__.nextthink = time + self.e__.wait;
			self.e__.think = archon_fader;
		}
		else // no targets - cycle this color
		{
			self.alpha = 0.01;
			self.nextthink = time + self.wait;
			self.delay = 0 - self.delay;
		}
	}
	else
	{
		if (self.e__)
		{
			if (self.e__.model == string_null)
			{
				self.e__.alpha = 0.01;
				self.e__.model = self.e__.mdl;
			}
			self.e__.alpha = self.e__.alpha + self.delay;
		}
		self.alpha = self.alpha - self.delay;
		self.nextthink = time + self.cnt;
	}
};


// was cause the map load wouldnt set alpha correctly
// changed because near 0 alpha was mega slowdown

void() archon_fadeinit =
{
	self.mdl = self.model;
	self.model = string_null;
};


// spawn for archon power point color spray & create think
// power point id is used to detect point created items
// a good bit of fields loaded by .cfg now -- see cm2 code


/*QUAKED archon_power (.8 .1 .8) (-8 -8 -8) (8 8 8) NOITEM NOSPRAY P_RELOAD
*/

#define		NOITEM			1
//#define		NOSPRAY		2			done earlier

void() archon_power =
{

	if (self.spawnflags & NOITEM) self.search_time = MAXFL;
	else
// dont always make items instantly
	if (random() < 0.4)
		self.search_time = time + 3 + random() * 5;

// wait for target to spawn
	if (time < 4) return;
	self.th_die = SUB_Null;		// archon_power_fn;

// unique id for each point
	self.button14 = system_hash;
	syh

	if (self.target)
	{
		self.aiment = find (world, targetname, self.target);
		if (self.aiment)
		{
			self.movetype = 12; //MOVETYPE_FOLLOW;
			self.solid = SOLID_NOT; // always non-solid
			self.punchangle = self.aiment.angles; // the original angles of bmodel
			self.view_ofs = self.origin - self.aiment.origin; // relative origin
			self.v_angle = self.angles - self.aiment.angles; // relative angles
		}
		else
			self.target = string_null;
	}
// IMP: sounds, powers
};

#endifdef

