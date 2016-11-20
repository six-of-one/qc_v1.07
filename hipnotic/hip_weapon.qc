/* ::-::
 *
 * Cataboligne
 *
 * file: hip_weapon.qc
 *
 * date: 5.12.15
 *
 * qc - hipnotic extruded weapon module
 *
 */

//MED 10/18/96
void(float damage) spawn_touchblood;
/*
================
HIPNOTIC WEAPONS
================
*/
#define LASER_BOUNCE			3
#define LASER_BOUNCE_RND_DIE	0.15

void() HIP_LaserTouch =
{
//	local vector org;
//	local vector spot1,spot2;
//	local vector oldvel;
//	local float mag;
//	local float r;

//	#define spot1 v0__
//	#define spot2 v1__
	#define oldvel v2__

	if (self.owner.class_select != "class_monster")
		self.owner = world;

	if (self.owner && (other == self.owner))
		return;		// don't explode on owner when its a monster that fired it

	if (other.classname == "monster_scourge") // scourge dont kill scourge
	if (self.netname == "monster_scourge")
	{
		SUB_Remove();
		return;
	}

	self.cnt = self.cnt - 1;
//	if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return;	}
	if (sky_touch(self.origin, self))
	{
		SUB_Remove();
		return;
	}

	oldvel = normalize(self.old_velocity);
//	spot1 = self.origin - (16*oldvel);
//	spot2 = self.origin + (16*oldvel);
//	traceline (spot1, spot2, FALSE, self);  // see through other monsters
	traceline (self.origin - (16*oldvel), self.origin + (16*oldvel), FALSE, self);  // see through other monsters
	self.origin = trace_endpos;

//	org = self.origin;

	if (other.takedamage)
	{
		if (self.lastvictim == other)
		{
			self.dmg = self.dmg / 2;
		}
		spawn_touchblood (self.dmg);
		T_Damage (other, self, self.lastvictim, self.dmg);
	}
	else if ((self.cnt < 1) || (random() < LASER_BOUNCE_RND_DIE))
	{
#ifdef nondp
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
#else
		te_gunshot(self.origin);
#endifdef
	}
	else
	{
//		self.dmg = 0.66 * self.dmg;
		self.dmg = 0.9 * self.dmg;
//		self.speed = 0.95 * self.speed;
		self.velocity = oldvel+(2*trace_plane_normal);
		self.velocity = normalize(self.velocity);
		self.velocity = self.speed * self.velocity;
		self.old_velocity = self.velocity;
		if (self.flags & FL_ONGROUND)
			self.flags = self.flags - FL_ONGROUND;
//		r = random();
		sound (self, CHAN_WEAPON, self.target, 1, ATTN_STATIC);
/*
		if (r<0.33)
			sound (self, CHAN_WEAPON, "weapons/ric1.wav", 1, ATTN_STATIC);
		else if (r<0.66)
			sound (self, CHAN_WEAPON, "weapons/ric2.wav", 1, ATTN_STATIC);
		else
			sound (self, CHAN_WEAPON, "weapons/ric3.wav", 1, ATTN_STATIC);
*/
		return;
	}
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	remove(self);

//#undef spot1
//#undef spot2
#undef oldvel
};

void() HIP_LaserThink =
{
//	local float delta;


	if (time>self.attack_finished)
	{
		remove(self);
		return;
	}
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	self.velocity = self.old_velocity;
	self.angles = vectoangles(self.velocity);
	self.nextthink = time + 0.1;
};

void(vector org, vector vec, float light) HIP_LaunchLaser =
{
	fire_missile(LASERCAN_VEL, MOVETYPE_FLYMISSILE, FL_CTHONF, 0, org, vec, "laser", "progs/laser_m.mdl", EWEAP.noise3, HIP_LaserTouch, 0, HIP_LaserThink, SUB_Null);
/*
	sound (self ,CHAN_WEAPON, "hipweap/laserg.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	newmis = spawn();
	newmis.owner = self;
	newmis.classname = "hiplaser";
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	setmodel (newmis, "progs/lasrspik.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);
	newmis.velocity = vec * newmis.speed;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.think = HIP_LaserThink;
	newmis.touch = HIP_LaserTouch;
	newmis.count = 0;
*/
	newmis.effects = newmis.effects | EF_FULLBRIGHT;
	if (light)
		newmis.effects = EF_DIMLIGHT;

	newmis.lastvictim = self;
	newmis.speed = LASERCAN_VEL;
	newmis.dmg = 18;
	newmis.old_velocity = newmis.velocity;
	newmis.avelocity = '0 0 400';

	newmis.nextthink = time;
	newmis.attack_finished = time + 5;
	newmis.cnt = LASER_BOUNCE + random() * 3; 

	newmis.skin = 3;
	newmis.frame = 4;
	newmis.target = "weapons/lasercannon/laserric.wav";

	if (EWEAP) 
	{
		newmis.cnt = EWEAP.cnt + random() * 3;
		newmis.target = EWEAP.target; // bouncy sound
		newmis.dmg = EWEAP.dmg;
		newmis.attack_finished = time + EWEAP.lefty;
	}

};

/*
=================
HIP_FireLaser
=================
*/
void(float stat) HIP_FireLaser =
{
//	local vector org;
//	local vector dir;
//	local vector out;
//	local float ofs;
//	local float aofs;
	#define org v2__
	#define dir v1__
	#define out v0__
	#define out_z v0___z
	#define ofs f0__
	#define aofs f1__

	self.effects = self.effects | EF_MUZZLEFLASH;
	if (self.class_select != "class_monster") // enhanced - monster firing a hip laser
	{
		if (!self.button0)
		{
			player_run ();
			return;
		}

		if (self.ammo_cells < 1)
		{
			self.weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
	//		eject_batt(1 + random() * 0.8 + crandom() * 1);
			return;
		}

		SuperDamageSound();
		makevectors (self.v_angle);
	}

	ofs = 6;
	out = v_forward;
	out_z = 0;
	out = normalize(out);
   org = self.origin + ((VWZ_LASERCAN - ofs) * v_up) + (VWX_LASERCAN * out);
	if (self.class_select == "class_monster")
		dir = normalize (self.enemy.origin - self.origin);
	else
//	org = self.origin + (1*v_forward);
	dir = aim (self, 1000);
	aofs = ofs * 0.707;

	if (self.class_select != "class_monster")
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	else
		sound (self ,CHAN_WEAPON, "weapons/lasercannon/laserg.wav", 1, ATTN_NORM);

	if (stat == 0)
	{
		org = org + (aofs*v_right);
		org = org - (aofs*v_up);
		HIP_LaunchLaser(org + v_right * VWY_LASERCAN, dir, 0);
		org = org - (2*aofs*v_right);
		HIP_LaunchLaser(org + v_right * VWY_LASERCAN, dir, 0);
	}
	else //if (stat == 1)
	{
		org = org + (ofs * v_up);
		if (random()<0.1)
		{
			HIP_LaunchLaser(org + v_right * VWY_LASERCAN, dir, 1);
         newmis.dmg = newmis.dmg * 1.39; // = 25 if base 18
		}
		else
			HIP_LaunchLaser(org + v_right * VWY_LASERCAN, dir, 0);
	}
	self.punchangle_x = -1;

#undef org
#undef dir
#undef out
#undef ofs
#undef aofs
};


/*
=================
HIP_HammerDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) HIP_HammerDamage =
{
	local entity		e1, e2;
//	local vector		f;

	self.v__ = p2 - p1;
	normalize (self.v__);
	self.v___x = 0 - self.v___y;
	self.v___y = self.v___x;
	self.v___z = 0;
	self.v__ = self.v__ * 16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
//JIM
	if (trace_ent.takedamage
#ifdef hip_items
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

	traceline (p1 + self.v__, p2 + self.v__, FALSE, self);
//JIM
	if (trace_ent != e1 && trace_ent.takedamage
#ifdef hip_items
		 && !trace_ent.wetsuit_finished 
#endifdef
			)
	{
		particle (trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - self.v__, p2 - self.v__, FALSE, self);
//JIM
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage
#ifdef hip_items
		 && !trace_ent.wetsuit_finished 
#endifdef
			)
	{
		particle (trace_endpos, '0 0 100', 225, damage * 4);
		T_Damage (trace_ent, from, from, damage);
	}
};

/*
void() HIP_DiversionLightningThink =
	{
	local vector	org,end;

	if (time > self.delay)
		{
		remove(self);
		return;
		}

	makevectors(self.v_angle);
	org = self.origin;
	end = org + v_forward*200;
//	end = end + (((200*random()) - 100) * v_up);
	end = end + (((400*random()) - 200) * v_right);

	traceline (org, end, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	self.nextthink = time + 0.1;
	};
*/

//void(entity prev, entity owner, float dst) HIP_SpawnMjolnirLightning;
void() HIP_LightningThink =
{
	local vector org;
	local vector dst;
	local entity head;
	local entity selected;
	local float cur_dist;
	local float head_dist;
	local vector vec;
	local float dot;
	local float oldstate;
	local float dam;


	if (time > self.delay)
	{
		if (self.enemy != world)
			self.enemy.struck_by_mjolnir = 0;
		remove(self);
		return;
	}
	oldstate = self.state;
	if (self.state==0)
	{
		// look in our immediate vicinity
		self.enemy = world;
		selected = world;
		cur_dist = self.distance;
		head = findradius(self.owner.origin, self.distance);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && ((head.flags & FL_MONSTER) || (head.flags & FL_CLIENT)))
			{
//				if (visible(head) && (head!=self.owner.owner) && (head.health>0))
				if ((visible(head)) && (head!=self.owner.owner) && (head.health>0))
				{
					head_dist = vlen(head.origin - self.lastvictim.origin);
					if ((head_dist<cur_dist) && (head.struck_by_mjolnir==0))
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}
		if (selected != world)
		{
			self.state = 1;
			self.enemy = selected;
			self.enemy.struck_by_mjolnir = 1;
		}
		else
		{
			local vector  end;

			makevectors(self.v_angle);
			org = self.owner.origin;
			end = org + v_forward * 200;
			end = end + (((400 * random()) - 200) * v_right);

			traceline (org, end, TRUE, self);

			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
			WriteEntity (MSG_BROADCAST, self);
			WriteCoord (MSG_BROADCAST, org_x);
			WriteCoord (MSG_BROADCAST, org_y);
			WriteCoord (MSG_BROADCAST, org_z);
			WriteCoord (MSG_BROADCAST, trace_endpos_x);
			WriteCoord (MSG_BROADCAST, trace_endpos_y);
			WriteCoord (MSG_BROADCAST, trace_endpos_z);

			self.nextthink = time + 0.1;
//			self.think = HIP_DiversionLightningThink;
//			self.nextthink = time;
//			self.delay = time + 0.30;
//			self.origin = self.owner.origin;
//			self.think();
			return;
		}
	}
	org = self.lastvictim.origin;
	dst = self.enemy.absmin + 0.25 * (self.enemy.absmax-self.enemy.absmin);
	dst = dst + (random() * 0.5 * (self.enemy.absmax-self.enemy.absmin));
	traceline (org, dst, TRUE, self.owner.owner);

	if (trace_fraction != 1.0 || self.enemy.health<=0)
	{
		self.enemy.struck_by_mjolnir = 0;
		self.state = 0;
		self.nextthink = time + 0.1;
		return;
	}
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	vec = normalize(self.enemy.origin - self.owner.origin);
	dot = vec * self.owner.movedir;
	head = self;
	self = self.owner.owner;
	if (oldstate==0)
		dam = 80;
	else
		dam = 30;
	if (dot>0.3)
		HIP_HammerDamage (org, trace_endpos, self, dam);
	else
		HIP_HammerDamage (org, trace_endpos, self, dam*0.5);
	self = head;

	self.nextthink = time + 0.2;
};

// check prev & own
void(entity prev, entity own, float dst) HIP_SpawnMjolnirLightning =
{
//	local entity light;
	// spawn actual lightning
	newmis = spawn();
	newmis.delay = time + 0.8;
//	newmis.state = 0;
	newmis.lastvictim = prev;
	newmis.distance = dst;
	newmis.owner = own;
	newmis.v_angle = self.angles;
	newmis.v_angle_x = 0;
	newmis.v_angle_z = 0;
	newmis.origin = own.origin;
	newmis.think = HIP_LightningThink;
	newmis.nextthink = time;
};

void() HIP_SpawnMjolnirBase =
{
//	local entity light;
	// spawn lightning base
	newmis = spawn();
//	newmis.origin = self.origin - '0 0 24' + (32*v_forward);
	newmis.origin = trace_endpos;
//	newmis.flags = 0;
	newmis.owner = self;
	newmis.struck_by_mjolnir = 1;
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 1;
	sound (newmis, CHAN_AUTO, "hipweap/mjolslap.wav", 1, ATTN_NORM);
	sound (newmis, CHAN_WEAPON, "hipweap/mjolhit.wav", 1, ATTN_NORM);
	makevectors(self.v_angle);
	newmis.movedir = v_forward;
	HIP_SpawnMjolnirLightning( newmis, newmis, 350 );
	HIP_SpawnMjolnirLightning( newmis, newmis, 350 );
	HIP_SpawnMjolnirLightning( newmis, newmis, 350 );
	HIP_SpawnMjolnirLightning( newmis, newmis, 350 );
};

void() HIP_FireMjolnirLightning =
{
//	local vector	org;
	local	float		cells;

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		discharged = 1;
		T_RadiusDamage (self, self, 35*cells, world);
		discharged = 0;
		W_SetCurrentAmmo ();
		return;
	}

//	if (self.t_width < time)
//	{
//		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
//		self.t_width = time + 0.6;
//	}
//	self.punchangle_x = 12;

	self.currentammo = self.ammo_cells = self.ammo_cells - 15;

	HIP_SpawnMjolnirBase();
};

void() HIP_FireMjolnir =
{
//
//	local vector	org;
	local	float		cells;
	local float	 damage;
	local vector	source;
	local vector	ang;


	self.attack_finished = time + 0.4;
	source = self.origin + '0 0 16';
//	ang = self.angles;
//	ang_x = 0;
//	ang_y = 0;
	makevectors(self.v_angle);
	traceline (source, source + v_forward * 32, FALSE, self);
	if (trace_fraction == 1.0 && (self.ammo_cells >= 15))
	{
		source = source + v_forward * 32;
		traceline (source , source - v_up*50, FALSE, self);
//		dprint("fraction = ");
//		dprint(ftos(trace_fraction));
//		dprint("\n");
		if (trace_fraction > 0.3 && trace_fraction< 1.0)
		{
			HIP_FireMjolnirLightning();
			self.attack_finished = time + 1.5;
			return;
		}
	}
	self.v__ = trace_endpos - v_forward * 4;

	if (trace_ent.takedamage)
	{
		damage = 50;
		if (trace_ent.classname == "monster_zombie")
			damage = 70;
		trace_ent.axhitme = 1;
		SpawnBlood (trace_ent, self.v__, v_forward, damage);
		T_Damage (trace_ent, self, self, damage);
	}
	else
	{  // hit wall
		if (trace_fraction != 1.0)
		{
			sound (self, CHAN_WEAPON, "hipweap/mjoltink.wav", 1, ATTN_NORM);
#ifdef nondp
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord (MSG_BROADCAST, self.v___x);
			WriteCoord (MSG_BROADCAST, self.v___y);
			WriteCoord (MSG_BROADCAST, self.v___z);
#else
		te_gunshot(self.v__);
#endifdef
		}
		else
		{
			sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
		}
	}
	self.attack_finished = time + 0.4;

};

// called by worldspawn
#ifdef nondp
void() HIP_Precache =
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
//MED
	precache_sound ("enforcer/enfstop.wav");	// laser cannon
//MED 11/06/96
	precache_sound ("knight/sword1.wav");	// laser cannon
	precache_sound ("hipweap/laserg.wav");	// laser cannon
	precache_sound ("hipweap/laserric.wav");	// laser cannon ricochet
	precache_sound ("hipweap/proxwarn.wav");	// proximity bomb
	precache_sound ("hipweap/proxbomb.wav");	// proximity bomb
//MED 11/19/96
	precache_sound ("hipweap/mjolhit.wav");	// mjolnir
	precache_sound ("hipweap/mjolslap.wav");	// mjolnir
	precache_sound ("hipweap/mjoltink.wav");	// mjolnir
};
#endifdef


//============================================================================

void() ProximityExplode =
{
	T_RadiusDamage (self, self.owner, 95, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

//MED 10/31/96
float NumProximityGrenades;
/*
================
ProximityGrenadeExplode
================
*/
void() ProximityGrenadeExplode =
	{
	self.takedamage = DAMAGE_NO;
	NumProximityGrenades = NumProximityGrenades - 1;
	self.deathtype = "exploding";
	self.nextthink = time + 0.1;
	self.owner = self.lastvictim;
	self.think = ProximityExplode;
	};

/*
================
ProximityGrenadeTouch
================
*/
void() ProximityGrenadeTouch =
	{
	if (other == self)
		return;
	if (other.classname == self.classname)
		return;
	self.movetype = MOVETYPE_TOSS;
	if (self.state == 1)
		return;
	if (vlen(other.velocity) > 0)
		{
		ProximityGrenadeExplode();
		self.think();
		return;
		}
	if (other.takedamage == DAMAGE_AIM)
		{
		ProximityGrenadeExplode();
		self.think();
		return;
		}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound
	self.movetype = MOVETYPE_NONE;
	setsize (self, '-8 -8 -8', '8 8 8');
	self.state = 1;
#ifdef hip_spawn
	self.spawnmaster = other;
#else
	self.movetarget = other;
#endifdef
	};

/*
================
ProximityBomb
================
*/
void() ProximityBomb =
{
	local entity	head;
	local float	 blowup;

	if ((time > self.delay) || (NumProximityGrenades > 15) 
#ifdef hip_spawn
		|| (vlen(self.spawnmaster.velocity)>0) 
#else
		|| (vlen(self.movetarget.velocity)>0) 
#endifdef
			)
		{
		ProximityGrenadeExplode();
		self.think();
		return;
		}
	self.owner = world;
	self.takedamage = DAMAGE_YES;
	head = findradius(self.origin, 140);
	blowup = 0;

	while (head)
		{
		if ((head != self) && (head.health > 0) && (head.flags & (FL_CLIENT|FL_MONSTER)) && (head.classname!=self.classname))
			blowup = 1;
		if ((head.classname == self.classname) && (head.state==0))
			blowup = 1;
		traceline(self.origin,head.origin,TRUE,self);
		if (trace_fraction != 1.0)
			blowup = 0;
		if (blowup==1)
			{
			sound (self, CHAN_WEAPON, self.target, 1, ATTN_NORM);
			ProximityGrenadeExplode();
			self.nextthink = time + 0.5;
			return;
			}
		head = head.chain;
		}
	self.nextthink = time + 0.25;
};

/*
================
W_FireProximityGrenade
================
*/
#define	PROX_TIMER		EWEAP.cnt

void() W_FireProximityGrenade =
{
	v0__ = self.origin + v_up * 16 + v_forward * 4; // scourge tail shot, chaos, no eweap def
	if (EWEAP) v0__ = self.origin + v_up * VWZ_PROXMINE+ v_forward * VWX_PROXMINE + v_right * VWY_PROXMINE;
	NumProximityGrenades = NumProximityGrenades + 1;

	fire_missile(GRENADE_VEL, MOVETYPE_TOSS, FL_GRN | FL_USEAMMO | FL_PUNCH , 0, v0__, '0 0 0', "proximity_grenade", "progs/proxbomb.mdl", self.eweapon.noise3, ProximityGrenadeTouch, 2.0, ProximityBomb, ProximityGrenadeExplode);

// prox specific stuff
//	newmis.mode_x = IV_PROX; // for det
	if (EWEAP) newmis.target = EWEAP.target;
	else newmis.target = "weapons/prox/proxwarn.wav";
//	newmis.firecontrol = EXPLOSIVE;
	newmis.takedamage = DAMAGE_NO;
	newmis.health = 5;
	newmis.state = 0;
	newmis.avelocity = '100 600 100';
	newmis.delay = 20;
	if (EWEAP) newmis.delay = time + PROX_TIMER + (PROX_TIMER*random());  // time fuse - orig = time + 15 + (10*random());
	setsize (newmis, '-1 -1 -1', '1 1 1');

/*
	local entity missile, mpuff;

	NumProximityGrenades = NumProximityGrenades + 1;
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, CHAN_WEAPON, EWEAP.noise3, 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.lastvictim = self;
	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;
	missile.classname = "proximity_grenade";
	missile.takedamage = DAMAGE_NO;
	missile.health = 5;
	missile.state = 0;

// set missile speed

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '100 600 100';

	missile.angles = vectoangles(missile.velocity);

	missile.touch = ProximityGrenadeTouch;

// set missile duration
	missile.nextthink = time + 2;
	missile.delay = time + 15 + (10*random());
	missile.think = ProximityBomb;
	missile.th_die = ProximityGrenadeExplode;

	setmodel (missile, "progs/proxbomb.mdl");
	setorigin (missile, self.origin);
	setsize (missile, '-1 -1 -1', '1 1 1');
*/
};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

#ifndef code_xents
float() W_BestWeapon =
{
	local	float	it;

	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
		return IT_LIGHTNING;
//MED
	else if(self.ammo_cells >= 1 && (it & IT_LASER_CANNON) )
		return IT_LASER_CANNON;
	else if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	else if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;
//MED
	else if( it & IT_MJOLNIR )
		return IT_MJOLNIR;

	return IT_AXE;
};
#endifdef



/*
============
Cheats etc
============
*/
#ifdef debug
//MED
void() WetsuitCheat =
{
	if (deathmatch || coop)
		return;
	self.items2 = self.items2 | HIP_IT_WETSUIT;
	self.wetsuit_time = 1;
	self.wetsuit_finished = time + 30;
	bprint( "wetsuit cheat\n" );
};

//MED
void() EmpathyShieldsCheat =
{
	if (deathmatch || coop)
		return;
	self.items2 = self.items2 | HIP_IT_EMPATHY_SHIELDS;
	self.empathy_time = 1;
	self.empathy_finished = time + 30;
	bprint( "empathy shields cheat\n" );
};

// darkplaces and advanced engine commands do this and better
void() DumpEntities =
{
	local entity	head;
	local float i;

	i = 1;
	head = nextent(world);
	while (head!=world)
	{
#ifndef nodprint
		dprint(ftos(i));
		dprint(" ");
		dprint(head.classname);
		dprint("\n");
#else
		bprint(ftos(i));
		bprint(" ");
		bprint(head.classname);
		bprint("\n");
#endifdef
		head = nextent(head);
		i = i + 1;
	}
};

void() DumpLiveEntities =
{
	local entity	head;
	local float i;

	i = 1;
	head = nextent(world);
	while (head!=world)
	{
		if (head.health > 0)
		{
#ifndef nodprint
			dprint(ftos(i));
			dprint(" ");
			dprint(head.classname);
			dprint(" ");
			dprint(vtos(head.origin));
			dprint("\n");
			dprint("--------------------\n");
#else
			bprint(ftos(i));
			bprint(" ");
			bprint(head.classname);
			bprint(" ");
			bprint(vtos(head.origin));
			bprint("\n");
			bprint("--------------------\n");
#endifdef
		}
		head = nextent(head);
		i = i + 1;
	}
};

void() Genocide =
{
	local entity	head;

	if (deathmatch || coop)
		return;
	bprint("Genocide!\n");
	head = nextent(world);
	while (head!=world)
	{
		if ((head.health > 0) && (head.flags & FL_MONSTER))
		{
			T_Damage(head,world,world,head.health+10);
		}
		head = nextent(head);
	}
};

//float dump_coord;
void () ToggleDump =
{
	dump_coord = 1 - dump_coord;
	if (dump_coord == 1)
		bprint("Dumping Player Location\n");
};

void () DumpCoordinates =
{
	local entity pl;
	pl = checkclient();
	if (pl)
	{
		bprint("Player: ");
		bprint(vtos(pl.origin));
		bprint("\n");
	}
};

#endifdef
