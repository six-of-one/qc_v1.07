/* ::-::
 *
 * Cataboligne
 *
 * file: plasma_wpn.qc
 *
 * date: 2.15.018
 *
 * qc - rogue plasma weapons module
 *
 */


// hack for now

#define		ammo_plasma		ammo_cells
 
//=============================================================================
// Plasma Gun Code
//=============================================================================
void(vector p1, vector p2, entity from, float damage) PlasmaDamage =
{
	local entity		e1, e2;
//	local vector		f;
	
	v0__ = p2 - p1;
	normalize (v0__);
	v0___x = 0 - v0___y;
	v0___y = v0___x;
	v0___z = 0;
	v0__ = v0__*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from.owner, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + v0__, p2 + v0__, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from.owner, damage);
	}
	e2 = trace_ent;

	traceline (p1 - v0__, p2 - v0__, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from.owner, damage);
	}
};

//================================
//================================
void(entity current, float doDamage) PlasmaDischarge =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, current);
	WriteCoord (MSG_BROADCAST, current.origin_x);
	WriteCoord (MSG_BROADCAST, current.origin_y);
	WriteCoord (MSG_BROADCAST, current.origin_z);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	sound (self, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);
	if (doDamage == 1)
        PlasmaDamage (self.origin, current.origin, self, 50);
};

//================================
//================================
void() PlasmaGroundOut = 
{
	local entity 	current, start;
	local float		monstersHit;
	
	monstersHit = 0;
	current = findradius ( self.origin, 320 );
	start = current;
	while ( monstersHit < 5 )
	{
		if ( current.flags & FL_MONSTER || current.classname == "player")
		{
			if ( current != self.owner )
			{
				traceline ( self.origin, current.origin, TRUE, world );
				if (trace_fraction == 1)
				{
					monstersHit = monstersHit + 1;
					PlasmaDischarge ( current, 1 );
				}
			}
		}
		current = current.chain;
		if (start == current || !current)
			return;
	}
};

//================================
//================================
void() PlasmaTouch = 
{
	if (other == self.owner)
		return;		// don't explode on owner

//	if (pointcontents(self.origin) == CONTENT_SKY)
	if (sky_touch('0 0 0', self))
	{
		remove(self);
		return;
	}

	if (!self.dmg) self.dmg = 80;

	self.ldmg_ = self.dmg + random()*20;
	sound (self, CHAN_WEAPON, "plasma/explode.wav", 1, ATTN_NORM);
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			self.ldmg_ = self.ldmg_ * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, self.ldmg_ );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, self.dmg - 10, other);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteByte (MSG_BROADCAST, 244);
	WriteByte (MSG_BROADCAST, 3);

	PlasmaGroundOut();
	remove (self);
};

//================================
//================================
void() PlasmaLaunch =
{
	self.velocity = normalize(self.velocity);
	self.velocity = self.velocity * 1250;

	self.nextthink = time + 5;
	self.think = SUB_Remove;
};

void(vector org, vector dir) launch_plasma =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "plasma";
	
// set newmis speed	
	newmis.velocity = dir * 0.01;
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = PlasmaTouch;

	if (self.eweapon) newmis.dmg = self.eweapon.dmg;

	setmodel (newmis, "progs/plasma.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, org);

	sound (newmis, CHAN_WEAPON, "plasma/flight.wav", 1, ATTN_NORM);
	if (!deathmatch && !coop)
		newmis.effects = EF_BRIGHTLIGHT;
	
// hang time till it flies
	newmis.think = PlasmaLaunch;
	newmis.nextthink = time + 0.1;
};

//================================
//================================
void() W_FirePlasma = 
{
//	local float		cells;
//	local vector 	dir;

	if (self.ammo_plasma < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		f4__ = self.ammo_plasma;
		self.ammo_plasma = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35 * f4__, world);
		return;
	}
	self.currentammo = self.ammo_plasma = self.ammo_plasma - 1;
//	UpdateAmmoCounts (self);
	sound (self, CHAN_WEAPON, "plasma/fire.wav", 0.5, ATTN_NORM);
	self.punchangle_x = -2;

	makevectors (self.v_angle);
	v1__ = aim ( self, 1000 );
#ifdef code_viswep
	v0__ = self.origin + v_forward*24 + '0 0 16';
#ifdef vwlaunch
	if (self.vwlaunch)
#endifdef
		v0__ = self.origin + v_right * VWY_THUNDER + v_forward * VWX_THUNDER + v_up * VWZ_THUNDER;
	launch_plasma (v0__, v1__);
#else
	launch_plasma (self.origin + v_forward*24 + '0 0 16', v1__);
#endifdef

// slower fire rate
	if (self.eweapon) self.attack_finished = time + self.eweapon.attack_finished;
};

