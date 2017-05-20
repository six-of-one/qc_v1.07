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


#ifdef spawn_func
void() archon_altar =
{
	self.netname = "\bArchon Altar\b";
	if (!self.model)
	{
		setmodel (self,"progs/flag.mdl");
		if (!self.skin) self.skin = rint(2.7 + random());
	}
	else
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);

	if (!self.noise) self.noise = "items/r_item2.wav";

	self.mask_x = MORPH_ALL;
	self.class_select = "chaos_item";
	self.touch = altar_touch;

	if (!self.aflag) self.aflag = 0.5; // conversion ratio start
	if (!self.delay) self.delay = 0.125; // allow retouch every

	StartItem ();
};


// archon nodule - map item - gives archon pts

void() archon_nodule =
{
	if (!self.netname) self.netname = "Nodule";
	if (!self.model) setmodel (self,"progs/nodule1.mdl");
	if (!self.noise) self.noise = "items/r_item2.wav";
	if (!self.archon) self.archon = 20 + crandom() * 5;

	setmodel (self, self.model);
	setsize (self,'-8 -8 -8','8 8 8');
	self.mins_z = self.mins_z - floor(random() * 4) * 4;
	self.mask_x = MORPH_ALL + MORPH_ARCHON;
	self.class_select = "x_item";
	self.touch = x_item_touch;

	StartItem ();
};


void() archon_ppp =
{
	archon_nodule(); // made from a nodule

	if (random() < 0.3) self.modelflags = self.modelflags | 128; // purple light

	self.netname = "Portable power point";
	self.mask_x = MORPH_ALL;
	setmodel (self,"progs/arc_pp.bsp");
	self.scale = 0.2;
	self.x_items = X_PP;
};
#endifdef



// archon varmpire power & other power drains

// spawnflags & 1 - no test for end of vampire, just take pts

// .archon - pts to take every rel
// .owner - give pts to this ent
// .enemy - take pts from this ent

void() archon_drain_thk =
{
	self.aflag = 0;
	if (self.count <= 0) self.aflag = 1;
	if (self.enemy.archon <= 0) self.aflag = 1;
	if (self.enemy.solid == SOLID_NOT) self.aflag = 1;
	if (self.enemy.takedamage == DAMAGE_NO) self.aflag = 1;

	if (self.spawnflags & 1) // for vampire
	{
		if (self.enemy.bolt_target) self.aflag = 1; // note: bolt_target your own drain & he's free
#ifdef code_morph
		if ((self.enemy.rune_flag & RUNE_FLG_RS) && (self.enemy.mask_x & MORPH_ARCHON)) self.aflag = 1;
#endifdef
		if (! (self.owner.rune_flag & RUNE_VAMPIRE)) self.aflag = 1;

		if (self.aflag)
		{
			stuffcmd(self.owner, "hud_vampire_target \"");
			stuffcmd(self.owner, "\"\n");
			remove(self);
			return;
		}
	}

	if (self.aflag)
	{
		if (self._alt_fire) self._alt_fire(self.enemy); // special cases
		remove(self);
		return;
	}

	self.nextthink = time + self.wait;

	self.owner.archon = self.owner.archon + self.archon;
	self.enemy.archon = self.enemy.archon - self.archon;
	self.count = self.count - self.archon;

#ifdef warning
if (WARNING & 4096)
{
	bprint(" *** warning: \bdrain: \b");
	bprint(self.netname);
	bprint(" - owner: ");
	bprint(ftos(self.owner.archon));
	bprint(" - target: ");
	bprint(ftos(self.enemy.archon));
	bprint(" - this time: ");
	bprint(ftos(self.archon));
	bprint("\n");
}
#endifdef

};

// power drain - take ents archon pts

void(entity e) power_drain =
{
	newmis = spawn();
	newmis.owner = self;
	newmis.enemy = e;
	newmis.think = archon_drain_thk;
	newmis.nextthink = time + 1;

	newmis.wait = 1;
	newmis.lefty = 0.2 + random() * 0.4; // percent to drain this time
	newmis.count = e.archon * newmis.lefty;
	newmis.archon = 1 + random() * 5; // points drained per rel
	newmis.netname = e.netname;
	if (newmis.netname == string_null) newmis.netname = "Unknown target";

#ifdef warning
if (WARNING & 4096)
{
	bprint(" *** warning: \bdrain: \b");
	bprint(item_ident(e));
	bprint(" - %: ");
	bprint(ftos(newmis.lefty));
	bprint(" - pts: ");
	bprint(ftos(newmis.count));
	bprint(" - /sec: ");
	bprint(ftos(newmis.archon));
	bprint("\n");
}
#endifdef

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



// touching a point when it activates

// touching ent does not have a healtype - set one at random

// enhanced - change max health a bit, if not > 1.2 (most morphs)
// NOTE: wont bump h_m more than once per map, and wont really affect morphs

void(entity e) archon_point_heal =
{
// heal level
	e.healtype = 2;
#ifdef enhanced
	e.health_modifier = e.health_modifier + 0.16;
#endifdef
	if (random() < 0.5)
	{
#ifdef enhanced
		if (e.health_modifier < 1.2) e.health_modifier = 0.8;
#endifdef
		e.healtype = 3 + rint(0.33 + random());
	}
	else
	if (random() < 0.15)
	{
#ifdef enhanced
		if (e.health_modifier < 1.2) e.health_modifier = e.health_modifier + 0.16;
#endifdef
		e.healtype = 4 + rint(0.33 + random());
	}
	
};


// TDO: move to m-chaos.qc

// clear archon target reticles

// e - entity that was targeted

void(entity e) archon_target_clear =
{
	if (!e) return;

	if (e.bolt_target)
	{
		if (e.bolt_target.classname == "gfx/reticle.spr")
		{
			remove(e.bolt_target); // IMP: fade remove this later
			e.bolt_target = world;
		}
	}
};


// IMP: other effects - proof against magic spell attack too - this touch will have to be detected live

// when touch fired by trigger - heal ent that touched, add points
// trigger timing controls freq. of touch

void() archon_power_touch =
{
	if (self.wad == "archon_power") // archon made points need debounced
	{
#ifdef code_morph
		if (activator.mask_x & MORPH_ARCHON) return;
#endifdef
		if (self.rad_time > time) return;
		self.rad_time = time + 1;
		activator = other; // because this was a regular touch
	}

	if (self.goalentity) // made by an Archon, he gets some every usage
	{
		if (self.goalentity == other) return; // this might be a redundant check, as Archons are sent back above
		self.goalentity.archon = self.goalentity.archon + 0.333;
	}

	if (! (self.spawnflags & NOHEAL))
	{
		if (!activator.healtype) archon_point_heal(activator);

		if (activator.health < (activator.max_health * activator.health_modifier * activator.health_modifier)) // health < points mod
			T_Heal(activator,activator.healtype + rint(0.33 + random()), 0);
	}

	if (! self.archon) self.archon = ARCHON_POINT;

#ifdef code_morph
	if (activator.mask_x & MORPH_ARCHON)
		activator.archon = activator.archon + (self.archon) * 5;
#endifdef

	activator.archon = activator.archon + self.archon;

// quad pts
	if (activator.super_damage_finished > time)
		activator.archon = activator.archon + (self.archon * 3);

#ifdef code_morph
	if (activator.mask_x & MORPH_ARCHON) return;
#endifdef

// magic protection
	if (activator.bolt_target)
	{
		if (activator.bolt_target == self)
		{
			activator.bolt_targetTimeout = time + 10;
			return;
		}
		if (activator.bolt_target.classname == "gfx/reticle.spr") // was targeted - clear it
		{
			archon_target_clear(activator);
		}
	}

	if (!activator.bolt_target) // set protection
	{
		activator.bolt_target = self;
		activator.bolt_targetTimeout = time + 10;		
	}
};

// power point activator - must be targeted by multi trigger
// calls *_touch when trigger is fired

/*QUAKED archon_power_act (.8 .1 .8) (-8 -8 -8) (8 8 8) NOHEAL
*/

void() archon_power_act =
{
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.use = archon_power_touch;
};


#endifdef

