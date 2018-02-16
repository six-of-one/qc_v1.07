/* ::-::
 *
 * Cataboligne
 *
 * file: mult_wpn.qc
 *
 * date: 1.25.018
 *
 * qc - rogue multi weapons module
 *
 */

// pmack
// sept 96

// Cat - just use rockets for now

#define 		ammo_multi_rockets		ammo_rockets


//=============================================================================
// Multi Grenade Code
//=============================================================================
#define	MultiGrenadeTouch	GrenadeTouch

//================================
//================================
void() MiniGrenadeExplode =
{
	if (!self.dmg)
	if ( self.owner.classname == "player") self.dmg = 90;
	else self.dmg = 60;

	T_RadiusDamage (self, self.owner, self.dmg, world);

//	te_explosion2(self.origin, 230, 5);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteByte (MSG_BROADCAST, 230);
	WriteByte (MSG_BROADCAST, 5);

	BecomeExplosion (world);
};

//================================
//================================
void(float offsetAngle) MiniGrenadeLaunch =
{
	newmis = spawn ();
	newmis.owner = self.owner;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.dmg = self.dmg;
	newmis.classname = "MiniGrenade";
		
// set missile speed	
	newmis.v_angle = self.v_angle;
	newmis.v_angle_y = newmis.v_angle_y + offsetAngle;
	makevectors (newmis.v_angle);
		
		newmis.velocity = v_forward*100 + v_up*400;
		self.rnd_ = (crandom()*60) - 30;
		newmis.velocity = newmis.velocity + self.rnd_ * v_forward;
		self.rnd_ = (crandom()*40) - 20;
		newmis.velocity = newmis.velocity + self.rnd_ * v_right;
		self.rnd_ = (crandom()*60) - 30;
		newmis.velocity = newmis.velocity + self.rnd_ * v_up;

	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = MultiGrenadeTouch;
	
	setmodel (newmis, "progs/mervup.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin);

// set missile duration
	newmis.nextthink = time + 1 + (crandom() * 0.5);
	newmis.think = MiniGrenadeExplode;
};

//================================
//================================
void() MultiGrenadeExplode =
{
	MiniGrenadeLaunch(0);
	MiniGrenadeLaunch(72);
	MiniGrenadeLaunch(144);
	MiniGrenadeLaunch(216);
	MiniGrenadeLaunch(288);

	remove (self);
};

//================================
//================================
/*
void() MultiGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		if (self.classname == "MiniGrenade")
			MiniGrenadeExplode();
		else
		{
			if (self.owner.classname == "player")
				GrenadeExplode();
			else
				MiniGrenadeExplode();
		}
		return;
	}
	// bounce sound
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};
*/
//================================
//================================
void() W_FireMultiGrenade =
{
	W_FireGrenade();

	newmis.touch = MultiGrenadeTouch;
	newmis.dmg = 60;
	if (self.classname == "player") newmis.dmg = 90;
	if (self.eweapon) newmis.dmg = self.eweapon.dmg;
	newmis.nextthink = time + 2.5;			// 1; // rogue orig
	newmis.think = MultiGrenadeExplode;
	setmodel (newmis, "progs/mervup.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	newmis.classname = "MultiGrenade";
/*
// Cat - just use rockets for now
	
NOTE: if ammo_multi_rockets is restored use of W_FireGrenade needs fixed !

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
//	self.currentammo = self.ammo_multi_rockets = self.ammo_multi_rockets - 1;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "MultiGrenade";
		
// set missile speed	
	makevectors (self.v_angle);
	if (self.v_angle_x)
		newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}

	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.touch = MultiGrenadeTouch;
	
// set missile duration
	newmis.nextthink = time + 1;
	newmis.think = MultiGrenadeExplode;

	setmodel (newmis, "progs/mervup.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin);
*/
};

//=============================================================================
// Multi Rocket Code
//=============================================================================

//================================
//================================
void() MultiRocketExplode = 
{

//	Stock Single Rocket Damage...
//	damg = 100 + random()*20;

	if (!self.dmg) self.dmg = 60;

	self.ldmg_ = self.dmg + random()*15;

	if (other.health)
	{
		if (other.classname == "monster_shambler")
			self.ldmg_ = self.ldmg_ * 0.5;	// mostly immune
		if (other.classname == "monster_dragon")
			self.ldmg_ = self.ldmg_ * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, self.ldmg_ );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
//	Stock single rocket damage.
//	T_RadiusDamage (self, self.owner, 120, other);

	T_RadiusDamage (self, self.owner, self.dmg + 15, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (world);
};

//================================
//================================
void() MultiRocketTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

//	if (pointcontents(self.origin) == CONTENT_SKY)
	if (sky_touch('0 0 0', self))
	{
		remove(self);
		return;
	}

	MultiRocketExplode ();
};


//================================
//================================
void() HomingMissileThink =
{
	if (self.enemy.health < 1)
	{
		remove(self);
		return;
	}

	self.velocity = normalize(self.enemy.origin - self.origin) * 1000;
	self.nextthink = time + 0.1;
	self.think = HomingMissileThink;	
};


//================================
//================================
void() HomingMissileAcquire =
{
	if ( self.delay < time )
	{
		MultiRocketExplode ();
		return;
	}

	self.v__ = self.velocity;
	makevectors (self.v_angle);
	self.velocity = aim (self, 1000);
	self.velocity = self.velocity * 1000;

	self.v__ = self.origin + self.velocity;	
	traceline ( self.origin, self.v__, FALSE, self );
	if (trace_fraction < 1)
	{
		if (trace_ent.flags & FL_MONSTER)
		{
			self.enemy = trace_ent;
			HomingMissileThink();
			return;
		}
	}
	
	self.velocity = self.v__;
	self.v_angle = vectoangles ( self.velocity );
	self.angles = self.v_angle;
	self.think = HomingMissileAcquire;
	self.nextthink = time + 0.2;
};

//================================
//================================
void(float offset, float frameNum) MultiRocketLaunch = 
{
	launch_spike('0 0 0', v_forward);

//	newmis = spawn ();
//	newmis.owner = self;
//	newmis.movetype = MOVETYPE_FLYMISSILE;
//	newmis.solid = SOLID_BBOX;
	newmis.classname = "MultiRocket";
	newmis.delay = time + 4;
	newmis.frame = frameNum;
	newmis.touch = MultiRocketTouch;

	if (deathmatch || coop)
		setmodel (newmis, "progs/rockup_d.mdl");
	else
		setmodel (newmis, "progs/rockup.mdl");

	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');

	if (self.eweapon) newmis.dmg = self.eweapon.dmg;

	if ( coop || deathmatch)
	{
		self.v__ = self.v_angle;
		self.v___y = self.v___y + (offset * 0.66);
		makevectors (self.v__);
		newmis.velocity = aim(self, 1000);
		newmis.velocity = newmis.velocity * 1000;
		newmis.angles = vectoangles(newmis.velocity);

		newmis.think = MultiRocketExplode;
		newmis.nextthink = time + 4;
	}
	else
	{
		makevectors (self.v_angle);
		newmis.velocity = v_forward * 1000 - v_right*offset*8;
		newmis.angles = vectoangles(newmis.velocity);
		newmis.v_angle = self.v_angle;	

		self.v__ = newmis.origin + newmis.velocity;
		traceline ( newmis.origin, self.v__, FALSE, self );
		if (trace_fraction < 1)
		{
			if (trace_ent.flags & FL_MONSTER)
			{
				newmis.enemy = trace_ent;
				newmis.think = HomingMissileThink;
				return;
			}
		}

		newmis.think = HomingMissileAcquire;
		newmis.nextthink = time + 0.1;
	}
#ifdef code_runes
	if ((self.rune_flag & RUNE_FLG_HS) || (self.rune_flag & TECH_TEIM))
		newmis.velocity = newmis.velocity * 2;
#endifdef

#ifdef painkeep_splash
			AddToSplash(newmis);
#endifdef
};

//================================
//================================
void() W_FireMultiRocket =
{
	self.currentammo = self.ammo_multi_rockets = self.ammo_multi_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;
	
	MultiRocketLaunch ( -10, 2 );
	MultiRocketLaunch ( -5, 3 );
	MultiRocketLaunch ( 5, 0 );
	MultiRocketLaunch ( 10, 1 );
};
