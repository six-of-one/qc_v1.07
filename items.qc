

void() W_SetCurrentAmmo;
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};


// stand in for much repetitve touch code - all touch do this
// in mark 3 all touch fn will route through a master fn that will do this

// self - touched item
// other - touching ent
// tim - respawn time for dm

void(float tim) touched =
{
// tim code <= -1 is for not a player touching - note: no respawn on this
// -1 = use targets but no bf\n
// expand - future code for mark 3 if monsters can pick up items - uncomment next code to "if" -1 }
//	if (tim > -2)
//	{
//		if (tim > -1) 
			stuffcmd(other, "bf\n");
		activator = other;
		SUB_UseTargets();				// fire all targets / killtargets	
//	}

	self.solid = SOLID_NOT;
	self.model = string_null;

// note: dm > 2 rule upgrade implement later
//	if (deathmatch && deathmatch != 2 && tim > 0)
	if (deathmatch == 1 && tim > 0)
	{
		self.nextthink = time + tim;
		self.think = SUB_regen;
	}
};


/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
#ifdef debug
void() noclass =
{
#ifndef nodprint
// this does not seem to work - even with dprint on
	dprint("noclass spawned at");
	dprint(vtos(self.origin));
	dprint("\n");
#endifdef
	remove (self);
};
#endifdef



/*
w============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
#ifndef opgrade
	local float	oldz;
#endifdef

// TEST - REMOVE
#ifdef local_test

	if (autocvar_frmon != string_null) // testing monsters - no items
	{
		remove(self);
		return;
	}
	
#endifdef
// TEST - REMOVE

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
#ifndef opgrade
// stats - cost of this one line of code: strofs = 4, numstatements = 1, numfunc = 0, numglobaldef = 1, numpr_global = 1, total size+ = 24
	oldz = self.origin_z;
#endifdef
	if (!droptofloor())
	{
#ifndef nodprint
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
#endifdef
		remove(self);
//		return;
	}
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;
	if ((!ignore) && (e.health >= other.max_health))
		return 0;
	healamount = ceil(healamount);

	e.health = e.health + healamount;
	if ((!ignore) && (e.health >= other.max_health))
		e.health = other.max_health;
		
	if (e.health > 250)
		e.health = 250;
	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

#define	H_ROTTEN 1
#define	H_MEGA 2
.float	healamount, healtype;
void() health_touch;
void() item_megahealth_rot;

void() item_health =
{	
	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");
		precache_sound("items/r_item1.wav");
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}
	else
	if (self.spawnflags & H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else
	{
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


void() health_touch =
{
//	local	float amount;	// fx_warning
//	local	string	s;
	
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if (other.health >= 250)
			return;
		if (!T_Heal(other, self.healamount, 1))
			return;
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
	sprint(other, "You receive ");
//	s = ftos(self.healamount);
	sprint(other, ftos(self.healamount));
	sprint(other, " health\n");
	
// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

//	stuffcmd (other, "bf\n");
	
//	self.model = string_null;
//	self.solid = SOLID_NOT;

// note: respawn special on health
	touched(0);

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		other.items = other.items | IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}
	else
	{
		if (deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if (deathmatch)
				self.nextthink = time + 20;
			self.think = SUB_regen;
		}
	}
	
//	activator = other;
//	SUB_UseTargets();				// fire all targets / killtargets
};	

void() item_megahealth_rot =
{
	other = self.owner;
	
	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

// it is possible for a player to die and respawn between rots, so don't
// just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);
	
	if (deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
};

/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch;

void() armor_touch =
{
	local	float	type, value, bit;
	
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;

	if (self.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = IT_ARMOR1;
	}
	if (self.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = IT_ARMOR2;
	}
	if (self.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
	if (other.armortype*other.armorvalue >= type*value)
		return;
		
	other.armortype = type;
	other.armorvalue = value;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

	touched(20);

/*
	self.solid = SOLID_NOT;
	self.model = string_null;
	if (deathmatch == 1)
		self.nextthink = time + 20;
	self.think = SUB_regen;
*/

	sprint(other, "You got armor\n");
// armor touch sound
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
//	stuffcmd (other, "bf\n");
	
//	activator = other;
//	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

// this code does not lend itself to map author overrides

void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 0;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor2 =
{
/*
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
	item_armor1();
	self.skin = 1;
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armorInv =
{
/*
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
	item_armor1();
	self.skin = 2;
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

/// NOTE: logic change in touch code has changed other to self in this call - *** any mod code that calls this must take into account

void() bound_other_ammo =
{
	if (self.ammo_shells > 100)
		self.ammo_shells = 100;
	if (self.ammo_nails > 200)
		self.ammo_nails = 200;
	if (self.ammo_rockets > 100)
		self.ammo_rockets = 100;		
	if (self.ammo_cells > 100)
		self.ammo_cells = 100;		
};

#ifndef hip_weapons

float(float w) RankForWeapon =
{
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_SUPER_NAILGUN)
		return 3;
	if (w == IT_GRENADE_LAUNCHER)
		return 4;
	if (w == IT_SUPER_SHOTGUN)
		return 5;
	if (w == IT_NAILGUN)
		return 6;
	return 7;
};
#endifdef

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
#ifdef unused
// really - what was old going to do here ?
// it is the pass parm of .items before adding the new weapon bit
void(float old, float new) Deathmatch_Weapon =
{
	local float or, nr;

// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);
	if ( nr < or )
#else
void(float new) Deathmatch_Weapon =
{
// change self.weapon if desired
	if ( RankForWeapon(new) < RankForWeapon(self.weapon) )
#endifdef
		self.weapon = new;
};

/*
=============
weapon_touch
=============
*/
float() W_BestWeapon;

void() weapon_touch =
{
#ifdef unused
// what was hadammo's intended purpose?
	local	float	hadammo;
	local	float old;
#endifdef
	local	float	best, new;
//	local	entity	stemp;
#define stemp 	newmis
	local	float	leave;

	if (!(other.flags & FL_CLIENT))
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();

// logic change to eliminate extra statements - use "stemp" as weapon ent, "self" is player
//	self = stemp;

	if (deathmatch == 2 || (coop
#ifdef map_hack
// hack to make coop play like sp for qone / quake-hack
	 &&  (!cvar("mh_sp_coop_hack"))
#endifdef
		))
		leave = 1;
	else
		leave = 0;
	
	if (stemp.classname == "weapon_nailgun")
	{
		if (leave && (self.items & IT_NAILGUN) )
			return;
#ifdef unused
		hadammo = self.ammo_nails;			
#endifdef
		new = IT_NAILGUN;
		self.ammo_nails = self.ammo_nails + 30;
	}
	else if (stemp.classname == "weapon_supernailgun")
	{
		if (leave && (self.items & IT_SUPER_NAILGUN) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;			
#endifdef
		new = IT_SUPER_NAILGUN;
		self.ammo_nails = self.ammo_nails + 30;
	}
	else if (stemp.classname == "weapon_supershotgun")
	{
		if (leave && (self.items & IT_SUPER_SHOTGUN) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;			
#endifdef
		new = IT_SUPER_SHOTGUN;
		self.ammo_shells = self.ammo_shells + 5;
	}
	else if (stemp.classname == "weapon_rocketlauncher")
	{
		if (leave && (self.items & IT_ROCKET_LAUNCHER) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;			
#endifdef
		new = IT_ROCKET_LAUNCHER;
		self.ammo_rockets = self.ammo_rockets + 5;
	}
	else if (stemp.classname == "weapon_grenadelauncher")
	{
		if (leave && (self.items & IT_GRENADE_LAUNCHER) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;			
#endifdef
		new = IT_GRENADE_LAUNCHER;
		self.ammo_rockets = self.ammo_rockets + 5;
	}
	else if (stemp.classname == "weapon_lightning")
	{
		if (leave && (self.items & IT_LIGHTNING) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;			
#endifdef
		new = IT_LIGHTNING;
		self.ammo_cells = self.ammo_cells + 15;
	}


#ifdef hip_weapons

//MED
	else if (stemp.classname == "weapon_laser_gun")
	{
		if (leave && (self.items & IT_LASER_CANNON) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;
#endifdef
		new = IT_LASER_CANNON;
		self.ammo_cells = self.ammo_cells + 30;
	}
//MED
	else if (stemp.classname == "weapon_mjolnir")
	{
		if (leave && (self.items & IT_MJOLNIR) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;
#endifdef
		new = IT_MJOLNIR;
		self.ammo_cells = self.ammo_cells + 30;
	}
//MED
	else if (stemp.classname == "weapon_proximity_gun")
	{
		if (leave && (self.items & IT_PROXIMITY_GUN) )
			return;
#ifdef unused
		hadammo = self.ammo_rockets;
#endifdef
		new = IT_PROXIMITY_GUN;
		self.ammo_rockets = self.ammo_rockets + 6;
	}

#endifdef


	else
#ifdef noobjerr
	{
		remove(stemp);
		return;
	}
#else
		objerror ("weapon_touch: unknown classname");					//opgrade protected
#endifdef

	sprint (self, "You got the ");
	sprint (self, stemp.netname);
	sprint (self, "\n");
// weapon touch sound
	sound (self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (self, "bf\n");

	bound_other_ammo ();

// change to the weapon
#ifdef unused
	old = self.items;
#endifdef
	self.items = self.items | new;

// logic change eliminates
//	stemp = self;
//	self = other;

	if (!deathmatch)
		self.weapon = new;
	else
		Deathmatch_Weapon(
#ifdef unused
														old, 
#endifdef
																new);
//


	W_SetCurrentAmmo();

	self = stemp; // back to item ent

	if (leave)
		return;

// note: causes a double bf\n
	touched(30);

/*
// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
*/

#undef stemp
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

// note: this can be overriden like item_shells, but has little advantage besides sticking in other map models & netnames that transform to q1 stuff in 1pv

void() weapon_supershotgun =
{
	if (!self.model) // allow next 5 functions to come here & not run this set
	{
		precache_model ("progs/g_shot.mdl");
		setmodel (self, "progs/g_shot.mdl");
		self.weapon = IT_SUPER_SHOTGUN;
		self.netname = "Double-barrelled Shotgun";
	}
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	precache_model ("progs/g_nail.mdl");
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	self.netname = "nailgun";
	weapon_supershotgun();
/*
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
	precache_model ("progs/g_nail2.mdl");
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	weapon_supershotgun();
/*
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
	precache_model ("progs/g_rock.mdl");
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = 3;
	self.netname = "Grenade Launcher";
	weapon_supershotgun();
/*
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
	precache_model ("progs/g_rock2.mdl");
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = 3;
	self.netname = "Rocket Launcher";
	weapon_supershotgun();
/*
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
	precache_model ("progs/g_light.mdl");
	setmodel (self, "progs/g_light.mdl");
	self.weapon = 3;
	self.netname = "Thunderbolt";
	weapon_supershotgun();
/*
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
*/
};


/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
//local entity	stemp;
#define stemp 	newmis
local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
// logic change eliminates - run the code till self back to stemp with stemp as self and self as other
//	self = stemp;


// shotgun
	if (stemp.weapon == 1)
	{
		if (self.ammo_shells >= 100)
			return;
		self.ammo_shells = self.ammo_shells + stemp.aflag;
	}

// spikes
	if (stemp.weapon == 2)
	{
		if (self.ammo_nails >= 200)
			return;
		self.ammo_nails = self.ammo_nails + stemp.aflag;
	}

//	rockets
	if (stemp.weapon == 3)
	{
		if (self.ammo_rockets >= 100)
			return;
		self.ammo_rockets = self.ammo_rockets + stemp.aflag;
	}

//	cells
	if (stemp.weapon == 4)
	{
		if (self.ammo_cells >= 100)
			return;
		self.ammo_cells = self.ammo_cells + stemp.aflag;
	}

	bound_other_ammo ();
	
	sprint (self, "You got the ");
	sprint (self, stemp.netname);
	sprint (self, "\n");
// ammo touch sound
	sound (self, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
//	stuffcmd (self, "bf\n");

// change to a better weapon if appropriate

	if ( self.weapon == best )
	{
// logic change eliminates
//		stemp = self;
//		self = other;
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo ();
//		self = stemp;
	}

// if changed current ammo, update it
// logic change eliminates
//	stemp = self;
//	self = other;
	W_SetCurrentAmmo();
	self = stemp;

	touched(30);

/*
// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
*/
#undef stemp
};




#define WEAPON_BIG2 1

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big

generic entry:

"model" - bsp box model - size MUST be '0 0 0', '32 32 56'
- model must be set or this will be a regular shell box
"aflag" - ammo count
"weapon" - this determines where aflag will be added !
- 1 = shells
- 2 = nails
- 3 = rockets / grenades
- 4 = cells

*/

void() item_shells =
{
	self.touch = ammo_touch;

	if (!self.model) // allow next 3 functions to come here & not run this set
	{
		if (self.spawnflags & WEAPON_BIG2)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_spikes =
{
//	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_nail1.bsp");
		setmodel (self, "maps/b_nail1.bsp");
		self.aflag = 50;
	}
	else
	{
		precache_model ("maps/b_nail0.bsp");
		setmodel (self, "maps/b_nail0.bsp");
		self.aflag = 25;
	}
	self.weapon = 2;
	self.netname = "nails";
	item_shells();
/*
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
*/
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_rockets =
{
//	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_rock1.bsp");
		setmodel (self, "maps/b_rock1.bsp");
		self.aflag = 10;
	}
	else
	{
		precache_model ("maps/b_rock0.bsp");
		setmodel (self, "maps/b_rock0.bsp");
		self.aflag = 5;
	}
	self.weapon = 3;
	self.netname = "rockets";
	item_shells();
/*
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
*/
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_cells =
{
//	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_batt1.bsp");
		setmodel (self, "maps/b_batt1.bsp");
		self.aflag = 12;
	}
	else
	{
		precache_model ("maps/b_batt0.bsp");
		setmodel (self, "maps/b_batt0.bsp");
		self.aflag = 6;
	}
	self.weapon = 4;
	self.netname = "cells";
	item_shells();
/*
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
*/
};


/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

#define WEAPON_SHOTGUN 1
#define WEAPON_ROCKET 2
#define WEAPON_SPIKES 4
#define WEAPON_BIG 8
void() item_weapon =
{
	self.touch = ammo_touch;

// detect items
	self.f__ = self.spawnflags;
// make bit 1 big setting for sub calls
	self.spawnflags = (self.spawnflags & WEAPON_BIG) / 8;

	if (self.f__ & WEAPON_SHOTGUN)
	{
		item_shells();
/*
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
*/
	}

	if (self.f__ & WEAPON_SPIKES)
	{
		item_spikes();
/*
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_nail1.bsp");
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_nail0.bsp");
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 20;
		}
		self.weapon = 2;
*/
		self.netname = "spikes";
	}

	if (self.f__ & WEAPON_ROCKET)
	{
		item_rockets();
/*
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_rock1.bsp");
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			precache_model ("maps/b_rock0.bsp");
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		self.netname = "rockets";
*/
	}

#ifndef codefix
// if no spawnflags & 7 - this causes a "You got the" message	with no inventory change
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
#endifdef
};


/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
//local entity	stemp;	// fx_warning
//local float		best;	// fx_warning

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	if (!coop
#ifdef map_hack
// hack to make coop play like sp for qone / quake-hack
	 || cvar("mh_sp_coop_hack")
#endifdef
	)
	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
// if a player dies in lava or gets blast launched, etc, a key might be left in an in-accessible place
// notes: prob dont want in QH
#ifdef map_hack
		if (self.oh)
		if (cvar("mh_sp_coop_hack") == 2)
		{
			self.nextthink = time + 360; // wait 6 mins
			self.think = SUB_regen;
		}
#endifdef
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

// Number 6 - mod to allow map author to override world.worldtype and have various worldtype keys on the same map
//							 future mod - make all 6 keys unique for doors - the issue with this is that the player ent only has 2 key bits

void() key_setsounds =
{
	if (self.worldtype < 1)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}
	if (self.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}
	if (self.worldtype >= 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work you MUST set your maps world.worldtype to one of the
following:
0: medieval
1: metal
2: base
(see worldspawn).

-------- QC++ --------
Key local override:
"worldtype" - set this on key & override the map setting
- use "-1" for a 0 override
- allow all 6 keys on 1 map
note: gold and silver keys all do the same thing, open the appropriate door
*/

void() item_key1 =
{
// if no override was provided on map, set to world value
	if (!self.worldtype) self.worldtype = world.worldtype;

	if (!self.model) // allow next function to come here & not run this set
	{
		if (self.worldtype < 1) // a negative value on local key ent will override world.worldtype as self.worldtype == 0
		{
			precache_model ("progs/w_s_key.mdl");
			setmodel (self, "progs/w_s_key.mdl");
			self.netname = "silver key";
		}
		if (self.worldtype == 1) // bounds checking - > 1 and < 2 will still fail
		{
			precache_model ("progs/m_s_key.mdl");
			setmodel (self, "progs/m_s_key.mdl");
			self.netname = "silver runekey";
		}
		if (self.worldtype >= 2) // note: failsafe on bogus worldtype now
		{
			precache_model2 ("progs/b_s_key.mdl");
			setmodel (self, "progs/b_s_key.mdl");
			self.netname = "silver keycard";
		}
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work you MUST set your maps world.worldtype to one of the
following:
0: medieval
1: metal
2: base
(see worldspawn).

-------- QC++ --------
Key local override:
"worldtype" - set this on key & override the map setting
- use "-1" for a 0 override
- allow all 6 keys on 1 map
note: gold and silver keys all do the same thing, open the appropriate door
*/

void() item_key2 =
{
// if no override was provided on map, set to world value
	if (!self.worldtype) self.worldtype = world.worldtype;

	if (self.worldtype < 1)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}
	if (self.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}
	if (self.worldtype >= 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}
	item_key1();
//	key_setsounds();
//	self.touch = key_touch;
	self.items = IT_KEY2;
//	setsize (self, '-16 -16 -24', '16 16 32');
//	StartItem ();
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
//local entity	stemp;	// fx_warning
//local float		best;	// fx_warning

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	touched(0);

//	stuffcmd (other, "bf\n");
//	self.solid = SOLID_NOT;
//	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = string_null;		// so rune doors won't find it

//	activator = other;
//	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
#ifdef noobjerr
	{
		self.spawnflags = 1;
		self.button1 = rint(random() * 3);
		while (self.button1 > 0)
		{
			self.button1 = self.button1 - 1;
			self.spawnflags = self.spawnflags * 2;
		}
#ifdef xvars2
// future add cvar("svx_rndsigil") - random bit mask selector via rnd_bit
		if (cvar("svx_defsigil") & 15) self.spawnflags = cvar("svx_defsigil");
#endifdef
	}
#else
		objerror ("no spawnflags");					//opgrade protected
#endifdef

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{
//local entity	stemp;	// fx_warning
//local float		best;	// fx_warning

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	if (deathmatch)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") ||
			(self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	touched(0);

//	stuffcmd (other, "bf\n");
//	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
//	self.model = string_null;

// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}	

//	activator = other;
//	SUB_UseTargets();				// fire all targets / killtargets
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/

// generic wont work - again because above code goes by classname
// the most you would get is an invulnerable that is different in looks and sounds

void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;

	if (!self.model) // allow next 3 functions to come here & not run this set
	{
		precache_model ("progs/invulner.mdl");
		precache_sound ("items/protect.wav");
		precache_sound ("items/protect2.wav");
		precache_sound ("items/protect3.wav");
		self.noise = "items/protect.wav";
		setmodel (self, "progs/invulner.mdl");
		self.netname = "Pentagram of Protection";
		self.items = IT_INVULNERABILITY;
	}
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
//	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	item_artifact_invulnerability();
/*
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
*/
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
//	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	item_artifact_invulnerability();
/*
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
*/
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void() item_artifact_super_damage =
{
//	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	item_artifact_invulnerability();
/*
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
*/
};



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
//	local string	s;
#ifdef unused
	local	float	old;
#endifdef
	local	float	best, new;
//	local		entity	stemp;
//	local	float	acount;
#define stemp 	newmis
#define acount 	self.f__
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	acount = 0;
	sprint (other, "You get ");

	if (self.items)
		if (!(other.items & self.items)) // == 0)
		{
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
// moving because logic change changed bound_other_ammo()
//	self = stemp;

// change weapons
	self.ammo_shells = self.ammo_shells + stemp.ammo_shells;
	self.ammo_nails = self.ammo_nails + stemp.ammo_nails;
	self.ammo_rockets = self.ammo_rockets + stemp.ammo_rockets;
	self.ammo_cells = self.ammo_cells + stemp.ammo_cells;

	new = stemp.items;
	if (!new)
		new = self.weapon;
#ifdef unused
	old = self.items;
#endifdef
	self.items = self.items | new;
	
	bound_other_ammo ();

// moved for logic change
	self = stemp;

	if (self.ammo_shells)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
//		s = ftos(self.ammo_shells);
		sprint (other, ftos(self.ammo_shells));
		sprint (other, " shells");
	}
	if (self.ammo_nails)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
//		s = ftos(self.ammo_nails);
		sprint (other, ftos(self.ammo_nails));
		sprint (other, " nails");
	}
	if (self.ammo_rockets)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
//		s = ftos(self.ammo_rockets);
		sprint (other, ftos(self.ammo_rockets));
		sprint (other, " rockets");
	}
	if (self.ammo_cells)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
//		s = ftos(self.ammo_cells);
		sprint (other, ftos(self.ammo_cells));
		sprint (other, " cells");
	}
	
	sprint (other, "\n");
// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// remove the backpack, change self to the player
	remove(self);
	self = other;

// change to the weapon
	if (!deathmatch)
		self.weapon = new;
	else
		Deathmatch_Weapon(
#ifdef unused
														old, 
#endifdef
																new);
//
	W_SetCurrentAmmo ();

#undef stemp
#undef acount
};

/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
//	local entity	item;
#define item 	newmis

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	item.items = self.weapon;
	if (item.items == IT_AXE)
		item.netname = "Axe";
	else if (item.items == IT_SHOTGUN)
		item.netname = "Shotgun";
	else if (item.items == IT_SUPER_SHOTGUN)
		item.netname = "Double-barrelled Shotgun";
	else if (item.items == IT_NAILGUN)
		item.netname = "Nailgun";
	else if (item.items == IT_SUPER_NAILGUN)
		item.netname = "Super Nailgun";
	else if (item.items == IT_GRENADE_LAUNCHER)
		item.netname = "Grenade Launcher";
	else if (item.items == IT_ROCKET_LAUNCHER)
		item.netname = "Rocket Launcher";
	else if (item.items == IT_LIGHTNING)
		item.netname = "Thunderbolt";

#ifdef hip_weapons
	else if (item.items == IT_LASER_CANNON)
		item.netname = "Laser Cannon";
	else if (item.items == IT_PROXIMITY_GUN)
		item.netname = "Proximity Gun";
	else if (item.items == IT_MJOLNIR)
		item.netname = "Mjolnir";
#endifdef

	else
		item.netname = string_null;

	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;

#undef item
};
