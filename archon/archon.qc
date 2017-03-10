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

The mathematically twisted power access device transferes that power to living beings.

*/

/// for now only need to support arena blocks for chv_? in PaiNKeep 3

#ifdef code_archon_a

	#ifdef message_top
	#message         			-- compile: Archon [ alpha ] (pk3 -> cm2) 
	#endifdef



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


#endifdef


