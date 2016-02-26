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
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;

	if (random() < 0.5)
	{
		setmodel (self, "progs/x_explo1.spr");
	}
	else
	{
		setmodel (self, "progs/x_explo2.spr");
	}

	self.solid = SOLID_NOT;
	es_explode1 ();
};

void() explodeAttack =
{
	local float damg, i;
	local vector dir;

	damg = 12 + random() * 16;

	if (self.enemy.health)
	{
		T_Damage (self.enemy, self, self.owner, damg);
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 28, self.enemy);

	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	i = (random() * 15) + 1;

	while(i > 0)
	{
		dir_x = -50 + (random() * 100);
		dir_y = -50 + (random() * 100);
		dir_z = -25 + (random() * 50);
//		particle(self.origin, dir, 225, 3);
		spawn_particle = 225;
#ifdef enhanced
		if (!self.enemy) spawn_particle = 248; // dont "bleed" world - this uses fire color
#endifdef
		SpawnBlood (self.enemy, self.origin, dir * 10, 1.5);
		i = i - 1;
	}

	BecomeShellExplosion ();
};

void(vector dir) TraceExplodeAttack =
{
	local entity explode;

	explode = spawn();

	explode.origin = trace_endpos - dir * 4;
	explode.owner = self;
	explode.enemy = trace_ent;
	explode.classname = "ExplodeShellsAttack";
	explode.weapon = self.weapon;
	explode.nextthink = time + 0.10 + (random() * 0.75);
	explode.think = explodeAttack;
};

void(float shotcount, vector dir, vector spread) FireExplodeShells =
{
//	local	vector direction; v0__
//	local	vector	src; v1__

/* - deprecated - unused
	local float damage;

	if (shotcount >= 2)
	{
		damage = 2;
	}
	else
	{
		damage = 1;
	}
*/
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

// called from W_FireShotgun && W_FireSuperShotgun - fire a shotgun with exploding shot
// shots is number of shots - 1 for shotgun & 2 for SS

void(float shots) W_FireShotgunExploder =
{
	local vector dir;

	self.punchangle_x = -2 * shots;

	e_use_ammo();
//	self.currentammo = self.pk_explode_ammo = self.pk_explode_ammo - shots; // no inf for this! ammo_con(shots, self, null_string);

#ifdef code_pkbots
	if (self.classname == "pk*bot")
		dir = botaim ();
	else
#endifdef
	dir = aim (self, 100000);

	if (shots == 2)
	{
		sound (self, CHAN_WEAPON, "weapons/explode/expfire2.wav", 1, ATTN_NORM);
		FireExplodeShells((random() * 4) + 6, dir, '0.14 0.08 0');
	}
	else
	{
		sound (self, CHAN_WEAPON, "weapons/explode/expfire1.wav", 1, ATTN_NORM);
		FireExplodeShells((random() * 3) + 3, dir, '0.09 0.06 0');
	}

// if we run of out explode, switch to normal shells.
	if (self.pk_explode_ammo == 0)
	{
		self.currentammo = self.ammo_shells;
		W_SetCurrentAmmo();
	}
};
