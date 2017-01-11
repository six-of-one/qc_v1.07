/*
*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(entity e, vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;


// called by worldspawn
#ifdef nondp
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};
#endifdef

#ifndef opgrade
//replaced with define
float() crandom =
{
	return 2*(random() - 0.5);
};
#endifdef
/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood(trace_ent, org, '0 0 0', 20);
		T_Damage (trace_ent, self, self, 20);
	}
#ifdef code_xents
	else
	if (self.eweapon.grap_state == 66600)
	{
//	extra blood for fists hitting anything
		SpawnBlood (self, org, '0 0 0', 10);
		sound (self, CHAN_WEAPON, "player/axhit1.wav", 1, ATTN_NORM);
	}
#endifdef
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
#ifdef nondp
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
#else
		te_gunshot(org);
#endifdef
	}

};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
#define missile 	newmis
//	local	entity missile;//, mpuff;	// fx_warning
//	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
//	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
#undef missile
};

/*
================
SpawnBlood
================
*/
void(entity e, vector org, vector vel, float damage) SpawnBlood =
{
#ifdef code_xents
	if (spawn_particle == 73) // BLOODCHECK
	{
		if (e.solid != SOLID_SLIDEBOX || !e) spawn_particle = 248;  // dont let non slidebox or world bleed
#ifdef code_morph
		if (e.mask_x & MORPH_ARCHON) spawn_particle = 234; // dont let them see and Archon bleed
#endifdef
		if (e.classname == "func_crate") spawn_particle = 104;
	}
#endifdef
		particle (org, vel*0.1, spawn_particle, damage*2);


#ifdef warning_no
						bprint(" --- SpawnBlood: ");
						bprint(item_ident(e));
						bprint(" spt: ");
						bprint(ftos(spawn_particle));
						bprint("\n");
#endifdef

	spawn_particle = 73; // always default - dp makes this blood
};

/*
================
spawn_touchblood
================

mod: new spawnblood call with ent ref so it can be checked for non-bleeders
in the case of every call for this fn(), other is the ent
this will have to be maintained, or change this code

*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (other, self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
#ifdef unused
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

#endifdef
/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

#ifndef nomultidmg
entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

#endifdef

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
#ifdef opgrade
// no blood for non slidebox (only monsters & players are slidebox) - this fixes bleeding doors & triggers
		if (trace_ent.solid != SOLID_SLIDEBOX)
			te_gunshot(org);
		else
#endifdef
		SpawnBlood (trace_ent, org, vel*0.2, damage);
#ifdef nomultidmg
		T_Damage (trace_ent, self, self, damage);
#else
		AddMultiDamage (trace_ent, damage);
#endifdef
	}
	else
	{
#ifdef nondp
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
#else
		te_gunshot(org);
#endifdef
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/

#ifndef code_xents

void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
		{
			TraceAttack (4, direction);

#ifdef hip_bulletholes
			//JIM
local float bullet;
			if ( ( !bullet ) && ( trace_ent == world ) )
			{
				placebullethole( trace_endpos );
				bullet = 1;
			}
#endifdef

		}

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};
#endifdef

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
#ifdef code_xents
	X_FireBullets (6, 4, dir, '0.04 0.04 0');
#else
	FireBullets (6, dir, '0.04 0.04 0');
#endifdef
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
#ifdef code_xents
	X_FireBullets (14, 4, dir, '0.04 0.04 0');
#else
	FireBullets (14, dir, '0.14 0.08 0');
#endifdef
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void() GrenadeExplode;

/*
void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};
*/

framer(0, 5, s_explode1, SUB_Remove, 0.1,SUB_Null());

void(entity e) BecomeExplosion =
{
// moved here to simplify code base - these almost always come in sequence
	if (e)
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, e.origin_x);
		WriteCoord (MSG_BROADCAST, e.origin_y);
		WriteCoord (MSG_BROADCAST, e.origin_z);
	}

	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

// cant think there without the proper parm - that blows qc up

void() BecomeExplosion_thk =
{
	BecomeExplosion(world);
}

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

#ifdef opgrade

	self.origin = self.origin - 8*normalize(self.velocity);

	if (!self.dmg) self.dmg = 120;

// same explode code except for 8 q-unit reposition				- note: other adjust in fn call
	GrenadeExplode();

#else
	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	BecomeExplosion (self);
#endifdef
};


void(vector org, vector dir) launch_spike;
/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
//	local	entity missile;//, mpuff;	// fx_warning

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	launch_spike(self.origin + v_forward*8 + '0 0 16', aim(self, 1000));

/*
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
*/
	newmis.classname = "missile";
		
// set missile speed	

/*
	makevectors (self.v_angle);
//	newmis.velocity = aim(self, 1000);
//	newmis.velocity = newmis.velocity * 1000;
	newmis.velocity = aim(self, 1000) * 1000;
	newmis.angles = vectoangles(newmis.velocity);
*/

	newmis.touch = T_MissileTouch;
	
// set missile duration
	newmis.nextthink = time + 5;
//	newmis.think = SUB_Remove;

	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
//	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage
#ifdef hip_items
//JIM
			&& !trace_ent.wetsuit_finished
#endifdef
		)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage
#ifdef hip_items
//JIM
			&& !trace_ent.wetsuit_finished
#endifdef
		)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage
#ifdef hip_items
//JIM
			&& !trace_ent.wetsuit_finished
#endifdef
		)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};


void() W_FireLightning =
{
	local	vector		org;
	local	float		cells;

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	if (self.waterlevel > 1)
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;

#ifdef HIPNOTIC
//MED 01/05/97 added discharge flag
		discharged = 1;
		T_RadiusDamage (self, self, 35*cells, world);
		discharged = 0;
#else
		T_RadiusDamage (self, self, 35*cells, world);
 #endifdef

		W_SetCurrentAmmo ();
		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';
	
	traceline (org, org + v_forward*600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
};


//=============================================================================

void() GrenadeExplode =
{
// qc++
	if (!self.dmg) self.dmg = 50; // default

#ifdef opgrade
// missile comes here with other set to the direct damage ent, we need world for grenades
	if (self.classname == "grenade") other = world;
	T_RadiusDamage (self, self.owner, self.dmg, other);
#else
	T_RadiusDamage (self, self.owner, self.dmg, world);
#endifdef

	BecomeExplosion (self);
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity  == '0 0 0')
		self.avelocity = '0 0 0';			// this never seems to execute - yet stopped grenades get 0 avel
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
//	local	entity missile;//, mpuff;	// fx_warning

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.classname = "grenade";

	if (self.classname == "player")
	{
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
		
		self.punchangle_x = -2;

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
#ifdef code_runes
	if ((self.rune_flag & RUNE_FLG_HS) || (self.rune_flag & TECH_TEIM))
		newmis.velocity = newmis.velocity * 2;
#endifdef
// qc++
		newmis.dmg = 120;
	}
	else // monsters come here - may need to qualify individuals
	{
// ogre fires a grenade

		self.effects = self.effects | EF_MUZZLEFLASH;

		makevectors (self.angles);

		newmis.velocity = normalize(self.enemy.origin - self.origin);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;

		newmis.dmg = 40;
	}

	newmis.avelocity = '300 300 300';

	newmis.angles = vectoangles(newmis.velocity);
	
	newmis.touch = GrenadeTouch;

// set missile duration
	newmis.nextthink = time + 2.5;
	newmis.think = GrenadeExplode;

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	setorigin (newmis, self.origin);
};


//=============================================================================

void() spike_touch;

#ifdef opgrade

// recoded to replace this - on superspikes, self.dmg = 18 at launch		- self.spike_type will be set to TE_SUPERSPIKE in touch if dmg > 15
#define superspike_touch		spike_touch

#else

void() superspike_touch;

#endifdef


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
#ifdef code_runes
	if ((self.rune_flag & RUNE_FLG_HS) || (self.rune_flag & TECH_TEIM))
		newmis.velocity = newmis.velocity * 2;
#endifdef
};

#ifdef opgrade


// damage we exceed to make a super spike
#define SPIKE_DMG_SUPER		15

// recode - all in one
//					- if ox = 0, this will fire superspikes
//					  or if self.weaon = IT_SUPER_NAILGUN and self.ammo_nails > 1

// if needed - not called in original code without the qualifier in W_FireSpikes
#define W_FireSuperSpikes() W_FireSpikes(0)

void(float ox) W_FireSpikes =
{

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
	
	makevectors (self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN) ox = 0;

#ifdef noautoaim
	launch_spike (self.origin + '0 0 16' + v_right*ox, v_forward);
#else
	local vector	dir;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
#endifdef
	
// ox = 0 means super spike from SNG
	if (!ox)
	{
		sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
		self.ammo_nails = self.ammo_nails - 1;
		newmis.touch = superspike_touch;
		setmodel (newmis, "progs/s_spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
		newmis.dmg = 18;
	}

#ifdef code_runes
	if (rune_haste(0.1))
#endifdef
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;

	self.punchangle_x = -2;
};

#else

void() W_FireSuperSpikes =
{
	local vector	dir;
//	local entity	old;	// fx_warning
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
#ifdef code_runes
	if (rune_haste(0.1))
#endifdef
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.dmg = 18;
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
//	local entity	old;	// fx_warning
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
#ifdef code_runes
	if (rune_haste(0.1))
#endifdef
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;

};
#endifdef


#ifndef code_xents
//.float hit_z;	// fx_warning
void() spike_touch =
{
//local float rand;	// fx_warning
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	if (!self.dmg) self.dmg = 9;

// hit something that bleeds
// need to qualify doors / triggers and other damageables that should _not_ bleed
	if (other.takedamage)
	{
		spawn_touchblood (self.dmg);
		T_Damage (other, self, self.owner, self.dmg);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);

			/// uncomment - this code will allow per entity spike_type overrides
///		if (!self.spike_type)
///		{
			self.spike_type = TE_SPIKE;
#ifdef opgrade
			if (self.dmg > SPIKE_DMG_SUPER) self.spike_type = TE_SUPERSPIKE;
#endifdef
			if (self.classname == "wizspike") self.spike_type = TE_WIZSPIKE;
//			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
//			else
			if (self.classname == "knightspike") self.spike_type = TE_KNIGHTSPIKE;
//			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
///		}
		WriteByte (MSG_BROADCAST, self.spike_type);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};
#endifdef


#ifndef opgrade

void() superspike_touch =
{
//local float rand;	// fx_warning
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

#endifdef

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
// idea: check frame set & only do for fire frames
	player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	self.weaponframe = 0; // this always happens

// viswep needs this
#ifdef code_viswep
	if ((self.prevweapon != self.weapon) || (self.forcewchange == 1)
	#ifdef code_painkeep_
														|| (self.pkprevweapon != self.pk_currentitem)
	#endifdef
			)
	{
		self.lastweapon = self.prevweapon;
		self.prevweapon = self.weapon;
	#ifdef code_painkeep_
		self.pkprevweapon = self.pk_currentitem;
	#endifdef
		self.forcewchange = FALSE;

	#ifdef code_morph
		if (self.weapon & self.builtin) // otherwise morph cant cycle to pki
			self.eweapon = world;
	#endifdef

// x_ents
		self.chaosweptime = 0;
		ominous_hum(string_null, 1);
	}
#endifdef

	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
//		self.weaponframe = 0;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
//		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
#ifdef hip_weapons
#ifndef code_xents
//MED
	else if (self.weapon == IT_LASER_CANNON)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_laserg.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == IT_MJOLNIR)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_hammer.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == IT_PROXIMITY_GUN)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_prox.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
#endifdef
#endifdef
	else
	{
		self.currentammo = 0;
		self.weaponmodel = string_null;
//		self.weaponframe = 0;
	}

#ifdef code_xents
// extra weapons ammo setting
	if (self.eweapon)
	if (self.weapon == self.eweapon.weapon)
	{
		self.weaponframe = 0;
		self.weaponmodel = self.eweapon.weaponmodel;
		self.currentammo = self.eweapon.currentammo;

		if (self.eweapon.grap_state == 66600) // fists
		{
			self.weaponmodel = string_null;
			self.currentammo = 0;
		}
	}
#endifdef
};

#ifdef code_xents

float() W_BestWeapon =
{

// this is the cube fix
	if (self.eweapon.distance > 100) return(self.weapon);
// check rating in viswep set
	f0__ = 9;
	f1__ = IT_AXE;
	e0__ = self.vwepent;
	while (e0__)
	{
		if (self.waterlevel <= 1 || e0__.distance != 75) // lg test
		if (e0__.distance > f0__)
		if (e0__.currentammo || e0__.aflag > 0)	// NOTE: currentammo has to be set for *all* vwepent somewhere (viswep_post)			aflag on eweap - inf ammo wep
		{
			e1__ = e0__;
			f0__ = e0__.distance;
			f1__ = e0__.weapon;
		}
		e0__ = e0__.vwepent;
	}
/// TDO: find out if we need the next line
	self.eweapon = e1__.eweapon; // set this for all self.weapon = W_BestWeapon() - simplifies other select code
#ifdef code_painkeep_
	if (e1__.weapon == IT_AXE) self.pk_currentitem = e1__.pk_currentitem;
#endifdef
	return(f1__);
};
#else
#ifndef hip_weapons
float() W_BestWeapon =
{
// new code - will not auto switch to anything with a rank < 10 - the axe
	local	float	it;
	
	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
			return IT_LIGHTNING;
	if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;
	return IT_AXE;
};
#endifdef
#endifdef

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;

#ifdef code_xents
	if (self.eweapon)
	if (self.eweapon.aflag > 0) // see if its inf ammo wep
		return TRUE;
 #endifdef

// NOTE: make this aflag wep
#ifdef hip_weapons
#ifndef code_xents
//MED
	if (self.weapon == IT_MJOLNIR)
	{
		return TRUE;
	}
#endifdef
#endifdef

	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
#ifdef pointless_warning
	return FALSE;
#endifdef
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;

void() W_Attack =
{
	local	float	r;

#ifdef code_painkeep_
	if (self.messagetimeout > time)
	{
		self.messagetimeout = -1; // *pk - clear hub message
		pk_centerprint(self, string_null);
	}
#endifdef

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

#ifdef code_morph
	if (self.morphy != IMP_MENF) // m-enf has an internal ewa, and always uses his frames
	if (self.eweapon)
	{
		e_weap_Attack();
		return;
	}

	if (self._attack != SUB_Null) // morph built in weapons
	{
#ifdef code_painkeep__fix
// pki have changed, but we still have to handle with builtins
		if ( (self.pk_currentitem != PK_IT_AXE) && (self.builtin & self.weapon) ) // fire a pk item
		{
			self.call__ = self._attack;
			self._attack = SUB_Null;
			r = self.weapon;
			self.weapon = IT_AXE;
			PK_Attack();
			self._attack = self.call__;			
			self.weapon = r;
		}
		else
#endifdef
			self._attack();
		return;
	}
#else
#ifdef code_xents
	if (self.eweapon)
	{
		e_weap_Attack();
		return;
	}
#endifdef
#endifdef

	if (self.weapon == IT_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
#ifdef code_runes
		if (rune_haste(0.28))
#endifdef
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
#ifdef code_runes
		if (rune_haste(0.28))
#endifdef
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
#ifdef code_runes
		if (rune_haste(0.38))
#endifdef
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
#ifdef code_runes
		if (rune_haste(0.3))
#endifdef
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
#ifdef code_runes
		if (rune_haste(0.4))
#endifdef
		self.attack_finished = time + 0.8;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
#ifdef hip_weapons
#ifndef code_xents
//MED
	else if (self.weapon == IT_LASER_CANNON)
	{
		player_laser1();
	}
//MED
	else if (self.weapon == IT_MJOLNIR)
	{
		if (self.ammo_cells < 30)
			player_hammer1();
		else
			player_mjolnir1();
#ifdef code_runes
		if (rune_haste(0.4))
#endifdef
		self.attack_finished = time + 0.8;
	}
//MED
	else if (self.weapon == IT_PROXIMITY_GUN)
	{
		player_rocket1();
		W_FireProximityGrenade();
#ifdef code_runes
		if (rune_haste(0.3))
#endifdef
		self.attack_finished = time + 0.6;
	}
#endifdef
#endifdef
};

/*
============
W_ChangeWeapon

============
*/
void() CycleWeaponCommand;

void() W_ChangeWeapon =
{
	local	float	was;

	was = self.weapon;

// select a new wep
	if (self.impulse == 1) 
	{
#ifdef code_painkeep_
// select pki
		if (self.weapon == IT_AXE)
		{	
// NOTE: this needs to "cycle" till a new wep is selected or it goes full circle to 1
			e0__ = self.vwepent;
			self.eweapon = world;
			self.pk_currentitem = self.pk_currentitem * 2;
			while (e0__)
			{
				if (e0__.pk_currentitem == self.pk_currentitem
						&& e0__.weapon == IT_AXE) e0__ = world;
				else
				{					
					e0__ = e0__.vwepent;
					if (!e0__)
					{
						self.pk_currentitem = self.pk_currentitem * 2;
						if (!(self.pk_currentitem & PK_ITEM_MASK)) self.pk_currentitem = 1;
						else e0__ = self.vwepent;
					}
				}
			}
		}
#endifdef
		self.weapon = IT_AXE;
	}
	if (self.impulse == 2) self.weapon = IT_SHOTGUN;
	if (self.impulse == 3) self.weapon = IT_SUPER_SHOTGUN;
	if (self.impulse == 4) self.weapon = IT_NAILGUN;
	if (self.impulse == 5) self.weapon = IT_SUPER_NAILGUN;
	if (self.impulse == 6)
	{
#ifdef hip_weapons
#ifndef code_xents
//MED
		if (self.weapon == IT_GRENADE_LAUNCHER)
			self.weapon = IT_PROXIMITY_GUN;
		else
#endifdef
#endifdef
			self.weapon = IT_GRENADE_LAUNCHER;
	}
	if (self.impulse == 7) self.weapon = IT_ROCKET_LAUNCHER;
	if (self.impulse == 8) self.weapon = IT_LIGHTNING;

#ifdef hip_weapons
#ifndef code_xents
//MED
	if (self.impulse == 225) self.weapon = IT_LASER_CANNON;
	if (self.impulse == 226) self.weapon = IT_MJOLNIR;
#endifdef
#endifdef

	self.f__ = 1; // so logic doesnt change weapon
// use logic test here
	CycleWeaponCommand();

// failed
	if (self.impulse)
	{
		self.impulse = 0;

		if (!(self.items & self.weapon))
// don't have the weapon
			sprint (self, "no weapon.\n");
		else
//  or the ammo				- this is an either or fail, so if its not no wep, it must be this
			sprint (self, "not enough ammo.\n");

// we were here
		self.weapon = was;
	}

};

/*
============
CheatCommand
============
*/
#ifdef debug
// only for testing, so only enabled in debug mode
void() CheatCommand =
{
	if (deathmatch
// note: opgrade has this cheat DISabled in coop
	#ifndef opgrade
						|| coop
	#endifdef
									)		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;

	#ifdef hip_weapons
	#ifndef code_xents
//MED
	self.items = self.items | IT_LASER_CANNON;
	self.items = self.items | IT_PROXIMITY_GUN;
	#endifdef
	self.items = self.items | IT_MJOLNIR;
	#endifdef

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

// debug qual
#endifdef

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	am;

// note: no loop protection! - this code assumes the player _always_ has an axe
	while (1)
	{
		am = 0;

// since these are bit flags, * 2 selects next and * 0.5 selects previous - for single select set this to 1
		self.weapon = self.weapon * self.f__;

// coming from axe on this system - arg!  why couldnt the axe have been 1?
		if (self.weapon == 8192 ) self.weapon = IT_SHOTGUN;
#ifdef code_xents
		if (self.weapon == 2048 ) self.weapon = 128;
#else
#ifdef hip_weapons
// these are worse than the axe
		if (self.weapon == 2048 ) self.weapon = IT_MJOLNIR;
// up from hammer - thru prox / laser then to shotgun
		if (self.weapon == 256 ) self.weapon = IT_PROXIMITY_GUN;
#else
		if (self.weapon == 2048 ) self.weapon = IT_LIGHTNING;
#endifdef
#endifdef

// going to the axe
		if (!(self.weapon & 255)) self.weapon = IT_AXE;

// weapon select logic
#ifdef hip_weapons
#ifndef code_xents
		if (self.weapon == IT_LASER_CANNON && self.ammo_cells < 1) am = 1;
		if (self.weapon == IT_PROXIMITY_GUN && self.ammo_rockets < 1) am = 1;
#endifdef
#endifdef
		if (self.weapon == IT_LIGHTNING && self.ammo_cells < 1) am = 1;
		if (self.weapon == IT_ROCKET_LAUNCHER && self.ammo_rockets < 1) am = 1;
		if (self.weapon == IT_GRENADE_LAUNCHER && self.ammo_rockets < 1) am = 1;
		if (self.weapon == IT_SUPER_NAILGUN && self.ammo_nails < 2) am = 1;
		if (self.weapon == IT_NAILGUN && self.ammo_nails < 1) am = 1;
		if (self.weapon == IT_SUPER_SHOTGUN && self.ammo_shells < 2) am = 1;
		if (self.weapon == IT_SHOTGUN && self.ammo_shells < 1) am = 1;
// hack, but need to reject clg with no ammo
		if (self.weapon == IT_AXE && (self.pk_currentitem == PK_IT_CLIGHT) && self.ammo_cells < 1)
		{
			am = 1;
			self.pk_currentitem = PK_IT_AXE; // note: clg could be set inf ammo by cmd - this fails that if cells are zeroed by another wep
		}

#ifdef code_morph
		if (self.weapon & self.builtin) am = 0; // can always select morph builtins
#endifdef

// check to see if an eweapon is being selected
#ifdef code_xents
		e0__ = self.vwepent;
		while (e0__)
		{
			if (e0__.weapon == self.weapon)
// needs an alternate set for weps (like tallball that use pk settings)
#ifdef code_painkeep_
			if (self.weapon != IT_AXE || e0__.pk_currentitem == self.pk_currentitem)
#endifdef
			if (e0__.currentammo || e0__.aflag)
			{
				self.eweapon = e0__.eweapon;
				self.forcewchange = 1;
				am = 0;
			}
			else			// fix x_weps not having ammo, but slot they are in having ammo & allowing select
				am = 1;
			e0__ = e0__.vwepent;
		}
#endifdef

		if ( (self.items & self.weapon) && ! am)
		{
			W_SetCurrentAmmo ();
			self.impulse = 0;
			return;
		}

// dont cycle single select
		if (self.f__ == 1) return;
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*
void() CycleWeaponReverseCommand =
{
//	local	float	it, am;
	local	float	am;
	
//	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if ( (self.items & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};
*/
/*
============
ServerflagsCommand

Just for development
============
*/
#ifdef debug

void() ServerflagsCommand =
{
// opgrade blocks this cheat in DM - which only affects the start hub 4 rune floor gate
	#ifdef opgrade
	if (deathmatch)
		return;
	#endifdef
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch
// note: opgrade has this cheat DISabled in coop
	#ifndef opgrade
						|| coop
	#endifdef
									)		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	#ifndef nodprint
	dprint ("quad cheat\n");
	#else
	bprint ("quad cheat\n");
	#endifdef
};

// debug qual
#endifdef

/*
============
ImpulseCommands

============
*/

void() ImpulseCommands =
{
#ifdef code_xents
	if (self.impulse == ALT_FIRE_IMP)
	{
		if (self.eweapon)
		{
			if (self.eweapon._alt_fire) self.eweapon._alt_fire(self.eweapon);
		}
#ifdef code_morph
		else // no eweapon - give morph builtins alternate fire
			if (self._attack) self._attack();
#endifdef
		self.impulse = 0;
		return;
	}

// note: as coded, beacon must be started by a __spawn_? cfg set
	e0__ = find(world,classname,"beacon");
	if (e0__)
	{
		if (self.impulse == IMP_SETBEAC)			// set beacon - #: 53
		{
			e0__.origin = self.origin;
			e0__.mangle = self.angles;
		}

// IDEA: DM protect - dont fire if another player is close
// IDEA: SP protect - dont fire for delay secs if player just touched an ent
		if ((self.impulse == IMP_TELEBEAC) && (e0__.teleport_time < time))			// teleport beacon - #: 54
		{
			e0__.owner = self;
			e0__.think = mini_teleport;
			e0__.nextthink = (time + 0.3);
			e0__.teleport_time = time + e0__.delay;
		}
		if (self.impulse == IMP_SHOWBEAC)			// show beacon - #: 55
		{
			e0__.effects = (e0__.effects + 1) & 1;
		}
	}
#endifdef

// runes
#ifdef code_runes
	if (self.impulse == IMP_RUNEID)
		rune_id(self, self);
	else if (self.impulse == IMP_RUNEDROP)
		rune_drop(self);
#endifdef

	if (self.impulse >= 1 && self.impulse <= 8
#ifdef hip_weapons
#ifndef code_xents
		|| (self.impulse >= 225 && self.impulse <= 226)
#endifdef
#endifdef
		)
		W_ChangeWeapon ();

	if (self.impulse == 10)
	{
		self.f__ = 2;
		CycleWeaponCommand();
	}
	if (self.impulse == 12)
	{
		self.f__ = 0.5;
		CycleWeaponCommand();
	}
//		CycleWeaponReverseCommand();

#ifdef hooks
	else if (self.impulse >= 94 && self.impulse <= 98) // Cataboligne 8.29.11 purify - hook - this is only the vector for give-away hook, item hooks vector via fire code
	{
		if (HOOK
#ifdef code_morph
						|| (self.mask_x & MORPH_HOOK) // morphs with hooks too
#endifdef
							)
			hook_impulse_check();

		if (self.eweapon)
		if (self.eweapon.netname == "Grappling hook") // holding a hook - check impulses
			hook_impulse_check();

//		return;
	}
#endifdef

																																														/// ARG: bad nested __ifdef below

// GRAPPLING_START
#ifdef code_painkeep_
	else if (self.impulse == 50)
	{
		grap_releaseHarpoon();

#ifdef code_morph
		if (!self.mask_x & MORPH_NOCUBE) // dont change this for internal morphers
		if (self.state) self.state = 0;
		else self.state = self.morphy;
#endifdef
	}
#endifdef


#ifdef debug
/// cheat impulses are now only active in debug mode - which should *** NEVER *** (EVER!) be on in live server / released game code
	if (self.impulse == 9)
		CheatCommand ();
	if (self.impulse == 11)
		ServerflagsCommand ();
	if (self.impulse == 255)
		QuadCheat ();
	#ifdef hip_items
//JIM
	if ( self.impulse == 200 )
		WetsuitCheat();
//MED
	if ( self.impulse == 201 )
		EmpathyShieldsCheat();
	#endifdef

	#ifdef HIPNOTIC
	if ( self.impulse == 205 )
		Genocide();
	if ( self.impulse == 206 )
		ToggleDump();
	if ( self.impulse == 202 )
		DumpEntities();
	if ( self.impulse == 203 )
		DumpLiveEntities();
	if (dump_coord == 1)
		DumpCoordinates();
	#endifdef
#endifdef

#ifdef code_xents
// allow weps to be switched on touch
	if (self.impulse == 29) self.aflag = IGN_INV;
#endifdef

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
#ifdef hooks
	if (self.button2)
		CheckGrapHookJump (); // cataboligne - 8.29.11 - hook check
#endifdef

#ifdef code_xents
	if (WEPHUM)
	if (self.eweapon)
	if (self.eweapon.fly_sound != HUMLOCAL)
	if (self.eweapon.noise2 != string_null)
	if (self.chaosweptime < time)
//		if (self.eweapon.weapon != MC_AIRGUN)
		ominous_hum(self.eweapon.noise2, self.eweapon.chaosweptime);

#ifdef code_painkeep_
	// If it's air blast time, blow entity's
	if (self.AIRG_BlastTimeout > time)
	{
		horn_airblast(FALSE);
	}
#endifdef

#endifdef

	if (time < self.attack_finished)
		return;

#ifdef opgrade
	if (self.impulse)
#endifdef
		ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}

#ifdef code_runes
	rune_dmg_sound();
#endifdef
};


