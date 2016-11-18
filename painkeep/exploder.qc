/* ::-::
 *
 * Cataboligne
 *
 * file: exploder.qc 
 *
 * date: 016.2.25
 *
 * qc - painkeep module - explode shells qc
 *
 */
 
 // FIX: dont allow with non q1 shot guns
 
 // exploding shotgun shells - brilliant really, who thought this up?	and would it really work - I think this needs to be on mythbusters

/*
void()	es_explode1	=	[0,		es_explode2] {};
void()	es_explode2	=	[1,		es_explode3] {};
void()	es_explode3	=	[2,		es_explode4] {};
void()	es_explode4	=	[3,		es_explode5] {};
void()	es_explode5	=	[4,		SUB_Remove] {};
*/

framer(0, 4, es_explode1, SUB_Remove, 0.1,SUB_Null);

void() BecomeShellExplosion =
{
// these fields were never set to anything
//	self.movetype = MOVETYPE_NONE;
//	self.velocity = '0 0 0';
//	self.touch = SUB_Null;
//	self.solid = SOLID_NOT;

	if (random() < 0.5)
	{
		setmodel (self, "progs/x_explo1.spr");
	}
	else
	{
		setmodel (self, "progs/x_explo2.spr");
	}

	es_explode1 ();
};

void() explodeAttack =
{
//	local float damg;, i;  f0__ self.f__
//	local vector dir; self.v__

	f0__ = 12 + random() * 16;

	if (self.enemy.health)
	{
		T_Damage (self.enemy, self, self.owner, f0__);
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 28, self.enemy);

	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	self.f__ = (random() * 15) + 1;

	while(self.f__ > 0)
	{
		self.v___x = -50 + (random() * 100);
		self.v___y = -50 + (random() * 100);
		self.v___z = -25 + (random() * 50);
// moved to spawnblood fn code
//		spawn_particle = 225;
//		if (!self.enemy) spawn_particle = 248; 	// dont "bleed" world - this uses fire color
		SpawnBlood (self.enemy, self.origin, self.v__ * 10, 1.5);
		self.f__ = self.f__ - 1;
	}

	BecomeShellExplosion ();
};

void(vector dir) TraceExplodeAttack =
{
//	local entity explode;

	newmis = spawn();

	newmis.origin = trace_endpos - dir * 4;
	newmis.owner = self;
	newmis.enemy = trace_ent;
	newmis.classname = "ExplodeShellsAttack";
	newmis.weapon = self.weapon;
	newmis.nextthink = time + 0.10 + (random() * 0.75);
	newmis.think = explodeAttack;
};

#ifndef code_xents

void(float shotcount, vector dir, vector spread) FireExplodeShells =
{
//	local	vector direction; v0__
//	local	vector	src; v1__

//* - deprecated - unused
	local float damage;

	if (shotcount >= 2)
	{
		damage = 2;
	}
	else
	{
		damage = 1;
	}

	makevectors(self.v_angle);

	v1__ = self.origin + v_forward*10;
	v1___z = self.absmin_z + self.size_z * 0.7;

	while (shotcount > 0)
	{
		v0__ = dir + crandom() * spread_x * v_right + crandom() * spread_y * v_up;

		traceline (v1__, v1__ + v0__ * 2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceExplodeAttack (v0__);

		shotcount = shotcount - 1;
	}
};

#endifdef

// called from W_FireShotgun && W_FireSuperShotgun - fire a shotgun with exploding shot
// shots is number of shots - 1 for shotgun & 2 for SS

void(float shots) W_FireShotgunExploder =
{
	local vector dir;

	self.punchangle_x = -2 * shots;

#ifdef code_pkbots
	if (self.classname == "pk*bot")
		dir = botaim ();
	else
#endifdef
	dir = aim (self, 100000);

// FIX: detect dbl barrel here
	if (shots == 2)
	{
		sound (self, CHAN_WEAPON, "weapons/explode/expfire2.wav", 1, ATTN_NORM);
#ifdef code_xents
		X_FireBullets((random() * 4) + 6, PK_EXPL_DMG, dir, '0.14 0.08 0');
#else
		FireExplodeShells((random() * 4) + 6, dir, '0.14 0.08 0');
#endifdef
	}
	else
	{
		sound (self, CHAN_WEAPON, "weapons/explode/expfire1.wav", 1, ATTN_NORM);
#ifdef code_xents
		X_FireBullets((random() * 3) + 3, PK_EXPL_DMG, dir, '0.09 0.06 0');
#else
		FireExplodeShells((random() * 3) + 3, dir, '0.09 0.06 0');
#endifdef
	}

#ifdef code_xents
	e_use_ammo();
#else
	self.currentammo = self.pk_explode_ammo = self.pk_explode_ammo - shots; // no inf for this! ammo_con(shots, self, null_string);
#endifdef

// if we run of out explode, switch to normal shells.
	if (self.pk_explode_ammo < 1)
	{
		self.weapon = 1;
		self.currentammo = self.ammo_shells;
		W_SetCurrentAmmo();
	}
};
