/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botfight.qc
 *
 * date: Fri Apr  4 04:40:01 UTC 2008
 *
 * final qc
 *
 */


float (entity targ) botrange;
vector (vector src, vector trg, float invMvel) leadtarget =
{
	local vector tg;
	local vector lead;
	lead = (self.enemy.velocity * invMvel) * vlen ((trg - src));
	tg = (trg + lead);
	if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		if (self.skil > 2)
		{
			traceline (src,tg,TRUE,self);
			if (trace_fraction != TRUE)
			{
				tg = (tg - (lead * 0.5));
				traceline (src,tg,TRUE,self);
				if (trace_fraction != TRUE)
				{
					tg = (tg - (lead * 0.5));
				}
			}
		}
	}
	return(tg);
};

vector (vector trg) adjustgrenade =
{
	local vector tg;
	local vector tgxy;
	local vector selfxy;
	local vector lead;
	local float xypct;
	tg = trg;
	tgxy = tg;
	tgxy_z = 0;
	selfxy = self.origin;
	selfxy_z = 0;
	xypct = (vlen (tgxy - selfxy) * INVGRENADELEVELDIST);
	if (xypct > 1)
	{
		if (xypct < 12)
		{
			tg_z = (tg_z + (GRENADEMAXHEIGHT * (xypct - 1)));
		}
	}
	else
	{
		tg_z = (tg_z - (GRENADEMAXHEIGHT * (1- xypct)));
	}
	return(tg);
};

vector () botaim =
{
	local vector dir;
	local vector tg;
	local vector lead;
	local vector src;
	local float sk;
	local float rnd;
	if (REBOUND)
	{
		tg = REBOUNDSPOT;
	}
	else
	{
		src = self.origin;
		if (self.weapon & (IT_ROCKET_LAUNCHER | IT_SUPER_NAILGUN | IT_NAILGUN))
		{
			src = (src + '0 0 16');
		}
		tg = self.enemy.origin;
		traceline (src,tg,TRUE,self);
		if (trace_fraction != TRUE)
		{
			tg = (tg + self.enemy.view_ofs);
		}
		if (self.skil > 1)
		{
			if (self.weapon & IT_ROCKET_LAUNCHER)
			{
				tg = leadtarget (src,tg,0.001);
				if (self.origin_z >= self.enemy.origin_z)
				{
					rnd = ((random () * 3.5) + 1);
					if (self.skil > rnd)
					{
						tg_z = ((tg_z + self.enemy.mins_z) + 2);
						traceline (src,tg,TRUE,self);
						if (trace_fraction != TRUE)
						{
							tg_z = ((tg_z - self.enemy.mins_z) - 3);
						}
					}
				}
			}
			else
			{
				if (self.weapon & IT_GRENADE_LAUNCHER)
				{
					tg = leadtarget (src,tg,0.002);
				}
				else
				{
					if ((self.weapon & IT_SUPER_NAILGUN) || (self.weapon & IT_NAILGUN))
					{
						rnd = (random () * 0.002);
						tg = leadtarget (src,tg,rnd);
					}
				}
			}
		}
	}
	if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		tg = adjustgrenade (tg);
	}
	sk = self.skil;
	if (self.weapon == IT_LIGHTNING)
	{
		if (sk > 2.5)
		{
			sk = 2.5;
		}
	}
	if (sk < 3)
	{
		if (!coop  || !XRP)
		{
		lead = (self.enemy.origin - self.enemy.oldorigin);
		lead = (((lead * (3- sk)) * 3.5) * (random () - 0.5));
		tg = (tg + lead);
		}
		else
		{
			lead = VEC_ORIGIN;
			tg = (tg + lead);
		}
	}
	dir = normalize (tg - self.origin);
	if (sk < 3)
	{
		dir = (dir + (((3- sk) * crandom ()) * '0.060 0 0'));
		dir = (dir + (((3- sk) * crandom ()) * '0 0.060 0'));
	}
	dir = normalize (dir);
	return(dir);
};

// quakebot add
void () botSetNearLight =
{
	local entity e;
	local entity targ;
	targ = self.enemy;
	e = findradius (targ.origin,200);
	if (e.classname == "light")
	{
		nearlight = 1;
	}
};

float () CheckBotAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	targ = self.enemy;
	botSetNearLight (); // quakebot add
	if (!nearlight && (random () < 0.7))
	{
		return(0);
	}
	if (time < self.attack_finished)
	{
		return (0);
	}
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline (spot1,spot2,0,self);
	if (trace_ent != targ)
	{
		return (0);
	}
	if (trace_inopen && trace_inwater)
	{
		spot2 = targ.origin;
		traceline (spot1,spot2,0,self);
		if (trace_inopen && trace_inwater)
		{
			return (0);
		}
	}
	self.attack_state = AS_MELEE;
	return (1);
};

float () W_BestBotWeapon =
{
	local float it;
	local float rng;
	local float wlevel;
	it = self.items;
	rng = botrange (self.enemy);
	if (rng != RANGE_MELEE)
	{
		if ((self.ammo_rockets >= TRUE) && (it & IT_ROCKET_LAUNCHER))
		{
			return(IT_ROCKET_LAUNCHER);
		}
	}
	if (XRP)
	if ((rng == RANGE_MELEE) && (self.enemy.health < 20)) // Cataboligne --- NOTE: find out if this is part of endless axe war problem
	{
		return(IT_AXE);
	}
	if ((self.ammo_cells >= TRUE) && (it & IT_LIGHTNING))
	{
		if ((rng == RANGE_MELEE) || (rng == RANGE_NEAR))
		{
			wlevel = CheckWaterLevel ();
			if (wlevel < 2)
			{
				return(IT_LIGHTNING);
			}
			if (self.items & IT_INVULNERABILITY)
			{
				return(IT_LIGHTNING);
			}
		}
	}
	if ((self.ammo_nails >= 2) && (it & IT_SUPER_NAILGUN))
	{
		return(IT_SUPER_NAILGUN);
	}
	if (rng == RANGE_NEAR)
	{
		if ((self.ammo_rockets >= TRUE) && (it & IT_GRENADE_LAUNCHER))
		{
			if (self.enemy.origin_z < (self.origin_z + 175))
			{
				return(IT_GRENADE_LAUNCHER);
			}
		}
	}
	if ((rng == RANGE_NEAR) || (rng == RANGE_MELEE))
	{
		if ((self.ammo_shells >= 2) && (it & IT_SUPER_SHOTGUN))
		{
			return(IT_SUPER_SHOTGUN);
		}
	}
	if ((self.ammo_nails >= TRUE) && (it & IT_NAILGUN))
	{
		return(IT_NAILGUN);
	}
	if ((self.ammo_shells >= TRUE) && (it & IT_SHOTGUN))
	{
		return(IT_SHOTGUN);
	}
	return(IT_AXE);
};

float () W_BestHeldWeapon =
{
	local float it;
	local float wlevel;
	it = self.items;
	if ((self.ammo_rockets >= TRUE) && (it & IT_ROCKET_LAUNCHER))
	{
		return(IT_ROCKET_LAUNCHER);
	}
	if ((self.ammo_cells >= TRUE) && (it & IT_LIGHTNING))
	{
		wlevel = CheckWaterLevel ();
		if (wlevel < 2)
		{
			return(IT_LIGHTNING);
		}
		if (self.items & IT_INVULNERABILITY)
		{
			return(IT_LIGHTNING);
		}
	}
	if ((self.ammo_nails >= 2) && (it & IT_SUPER_NAILGUN))
	{
		return(IT_SUPER_NAILGUN);
	}
	if ((self.ammo_rockets >= TRUE) && (it & IT_GRENADE_LAUNCHER))
	{
		if (self.enemy.origin_z < (self.origin_z + 175))
		{
			return(IT_GRENADE_LAUNCHER);
		}
	}
	if ((self.ammo_shells >= 2) && (it & IT_SUPER_SHOTGUN))
	{
		return(IT_SUPER_SHOTGUN);
	}
	if ((self.ammo_nails >= TRUE) && (it & IT_NAILGUN))
	{
		return(IT_NAILGUN);
	}
	if ((self.ammo_shells >= TRUE) && (it & IT_SHOTGUN))
	{
		return(IT_SHOTGUN);
	}
	return(IT_AXE);
};

void () bot_axe1;
void () bot_axeb1;
void () bot_axec1;
void () bot_axed1;
void () bot_shot1;
void () bot_nail1;
void () bot_light1;
void () bot_rocket1;
void () W_BotAttack =
{
	local float r;
	local float addt;
	if (!W_CheckNoAmmo ())
	{
		return ;
	}
	if (time < self.attack_finished)
	{
		return ;
	}
	addt = 0;
	if (self.skil < 3)
	{
		addt = (((3- self.skil) * random ()) * 0.350);
	}
	if (self.skil < 1)
	{
		addt = (addt + (random () * 0.3));
	}
	makevectors (self.v_angle);
	self.show_hostile = (time + 1);
	if (self.weapon == IT_AXE)
	{
		sound (self,CHAN_WEAPON,"weapons/ax1.wav",TRUE,ATTN_NORM);
		r = random ();
		if (r < 0.250)
		{
			bot_axe1 ();
		}
		else
		{
			if (r < 0.5)
			{
				bot_axeb1 ();
			}
			else
			{
				if (r < 0.750)
				{
					bot_axec1 ();
				}
				else
				{
					bot_axed1 ();
				}
			}
		}
		if (rune_haste(0.28))
		self.attack_finished = ((time + 0.5) + addt);
	}
	else
	{
		if (self.weapon == IT_SHOTGUN)
		{
			bot_shot1 ();
			W_FireShotgun ();
			if (rune_haste(0.28))
			self.attack_finished = ((time + 0.5) + addt);
		}
		else
		{
			if (self.weapon == IT_SUPER_SHOTGUN)
			{
				bot_shot1 ();
				W_FireSuperShotgun ();
				if (rune_haste(0.38))
				self.attack_finished = ((time + 0.7) + addt);
			}
			else
			{
				if (self.weapon == IT_NAILGUN)
				{
					self.think = bot_nail1;
				}
				else
				{
					if (self.weapon == IT_SUPER_NAILGUN)
					{
						self.think = bot_nail1;
					}
					else
					{
						if (self.weapon == IT_GRENADE_LAUNCHER)
						{
							bot_rocket1 ();
							W_FireGrenade ();
							if (rune_haste(0.3))
							self.attack_finished = ((time + 0.6) + addt);
						}
						else
						{
							if (self.weapon == IT_ROCKET_LAUNCHER)
							{
								bot_rocket1 ();
								W_FireRocket ();
								if (rune_haste(0.4))
								self.attack_finished = ((time + 0.8) + addt);
							}
							else
							{
								if (self.weapon == IT_LIGHTNING)
								{
									self.think = bot_light1;
									self.attack_finished = (time + 0.1);
									sound (self,CHAN_AUTO,"weapons/lstart.wav",TRUE,ATTN_NORM);
								}
							}
						}
					}
				}
			}
		}
	}

// Cataboligne 4.17.11 - saver fn tie in
	if (self.aiment)
	if (self.aiment.classname == "saver")
		self.aiment.button0 = TRUE;
};

void () bot_rebound1;
float () CheckReboundAttack =
{
	local vector spot1;
	local vector spot2;
	local vector dir;
	local float dist;
	local float mel;
	if (self.skil < 1)
	{
		return (0);
	}
	if (self.attack_finished > time)
	{
		return (0);
	}
	if (!(self.items & (IT_ROCKET_LAUNCHER + IT_GRENADE_LAUNCHER)))
	{
		return (0);
	}
	if (self.ammo_rockets < 3)
	{
		return (0);
	}
	spot1 = self.origin;
	spot2 = self.goalentity.origin;
	traceline (spot1,spot2,0,self);
	if (trace_fraction < 1)
	{
		return (0);
	}
	dir = normalize (self.goalentity.origin - self.origin);
	spot2 = (spot2 + (200 * dir));
	traceline (spot1,spot2,TRUE,self);
	if (trace_fraction == 1)
	{
		if (self.origin_z < self.goalentity.origin_z)
		{
			return (0);
		}
		spot2 = self.goalentity.origin;
		spot2_z = (dropline (spot2) + 3);
		traceline (spot1,spot2,TRUE,self);
		if (trace_fraction != TRUE)
		{
			return (0);
		}
	}
	else
	{
		spot2 = (self.goalentity.origin + ((200 * dir) * trace_fraction));
	}
	dist = vlen (self.enemy.origin - spot2);
	mel = 200;
	if (self.items & IT_QUAD)
	{
		mel = (2* mel);
	}
	if (dist > mel)
	{
		return (0);
	}
	dist = vlen (self.origin - spot2);
	mel = ((280 - (self.health * 0.5)) - (self.armorvalue * self.armortype));
	if (self.items & IT_QUAD)
	{
		mel = (2* mel);
	}
	if (dist < mel)
	{
		return (0);
	}
	REBOUNDSPOT = spot2;
	REBOUND = 1;
	self.ideal_yaw = vectoyaw (spot2 - self.origin);
	ChangeYaw ();
	bot_rebound1 ();
	if (self.items & IT_ROCKET_LAUNCHER)
	{
		W_FireRocket ();
	}
	else
	{
		REBOUNDSPOT = (spot2 + (random () * '12 12 12'));
		W_FireGrenade ();
	}
	self.attack_finished = (time + 1);
	if (self.skil < 2)
	{
		self.attack_finished = (time + 1.5);
	}
	REBOUND = 0;
		return (0);
};

// xrp code- where is it callded?
void () ChangePitch =
{
	local float ideal;
	local float move;
	current_pitch = self.angles_x;
	ideal = self.ideal_pitch;
	if (ideal > 45)
	{
		ideal = 45;
	}
	else
	{
		if (ideal < -45)
		{
			ideal = -45;
		}
	}
	if (current_pitch == ideal)
	{
		return ;
	}
	move = (ideal - current_pitch);
	if (move > 0)
	{
		if (move > 6)
		{
			move = 6;
		}
	}
	else
	{
		if (move < -6)
		{
			move = -6;
		}
	}
	current_pitch = (current_pitch + move);
	self.angles_x = current_pitch;
};

