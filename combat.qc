
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

#ifdef pointless_warning
	return FALSE;
#endifdef
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;
	
	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

#ifdef hip_charmed
//MED
	if (self.charmed)
	{
		self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}
#endifdef

#ifndef code_xents
// only need if xents is not compiled - only cvar_fields set ents are protected though
#ifdef codefix
// block improperly set up killable from scuttling server
	if (!self.th_die) self.th_die = SUB_Null;
#endifdef
#endifdef


	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	monster_death_use();
	self.th_die ();

#ifdef code_viswep
	if (self.vwepent) viswep_ld(self, -2); // still have visweps
#endifdef

	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.

note: negative damage value will add health !
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
	local	vector	dir;
	local	entity	oldself;
	local	float	save;
	local	float	take;

	if (!targ.takedamage)
		return;

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
		damage = damage * 4;

#ifdef hip_items
	if (discharged && targ.wetsuit_finished )
		return;
//MED moved damage_attacker down a bit
/*
	dprint("netname = ");
	dprint(attacker.netname);
	dprint(" classname = ");
	dprint(attacker.classname);
	dprint(" classname = ");
	dprint(inflictor.classname);
	dprint("\n");
*/

//MED
//check for empathy shields
	if ((targ.items2 & HIP_IT_EMPATHY_SHIELDS) && !(inflictor.items2 & HIP_IT_EMPATHY_SHIELDS) && (targ != attacker))
		{
		empathyused = 1;
		damage = damage/2;
		T_Damage (attacker,targ,targ,damage);
		empathyused = 0;
		}
#endifdef

#ifdef HIPNOTIC
//MED
// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

//MED
// used to keep track of what hit us
	damage_inflictor = inflictor;
#endifdef

// save damage based on the target's armor level

#ifdef code_xents
	if (targ.ignorearmor != IGN_ARM)
	{
#endifdef
		save = ceil(targ.armortype * damage);
		if (save >= targ.armorvalue)
		{
			save = targ.armorvalue;
			targ.armortype = 0;	// lost all armor
			targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		}
#ifdef code_xents
	}
	else
		save = 0;
#endifdef
	
	take = ceil(damage - save);

#ifdef code_runes

	if ( (targ.rune_flag & RUNE_FLG_RS) || (targ.rune_flag & TECH_DSH) ) // idea: resist should do more under rules > 2, but not tech
	{
		take = floor(take / 2);
		save = floor(save / 2);
		if (
//#ifdef  - former conditional
			RUNE_TECH_RS_COMB && 
//#endifdef
			(targ.rune_flag & RUNE_FLG_RS) && (targ.rune_flag & TECH_DSH))
		{
			take = floor(take / 2);
			save = floor(save / 2);			
		}

		if (targ.invincible_sound < time)
		{
			if ( (targ.rune_flag & TECH_DSH) && !(targ.rune_flag & RUNE_FLG_RS) )
				sound (targ, CHAN_BODY, tech_dsh_sound, 1, ATTN_NORM);
			else
				sound (targ, CHAN_ITEM, rune_resist_sound, 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
	}

#endifdef

// moved because rune code can affect save
	targ.armorvalue = ceil(targ.armorvalue - save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

// figure momentum add
	if ( (inflictor) /* != world) */ && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir * damage * 8;
	}

// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

#ifdef hip_items
//MED
	if (targ.items2 & HIP_IT_EMPATHY_SHIELDS)
	{
		if (self.empathy_sound < time)
		{
			sound (targ, CHAN_ITEM, "hipitems/empathy2.wav", 1, ATTN_NORM);
			self.empathy_sound = time + 0.5;
		}
	}
#endifdef

// team play damage avoidance
#ifdef opgrade
	if ( (teamplay == 1) && (targ.team > 0) && (targ.team == attacker.team)
	&& (targ != attacker) && (attacker.classname == "player")
	&& (inflictor.classname != "door") )	// because squishing a teammate is still possible
#else
	if ( (teamplay == 1) && (targ.team > 0)&&(targ.team == attacker.team) )
#endifdef

		return;

#ifdef code_runes

// we have a suck head
   if (attacker.rune_flag & RUNE_VAMPIRE) // a bit of vampire action
#ifdef hip_items
   if (! targ.empathy_finished)
#endifdef
//#ifdef enhanced - former conditional
   if (! (targ.rune_flag & RUNE_VAMPIRE))
   if (! (targ.rune_flag & RUNE_FLG_RG)) // regen immune to feeders
   if (! (targ.rune_flag & TECH_ADOC))
//#endifdef
   if (targ.flags & (FL_CLIENT | FL_MONSTER)) // only these get vamped for now - excludes all doors, triggers, crates, etc
	{
#ifdef strict_lithium
// by organization of mk II code base this was not in use
		if (RUNES > 1) // lith code
		{
			if (attacker.health < (attacker.max_health * attacker.health_modifier * 2))
			{
				f2__ = take; // vdamage = damage;
				f3__ = ceil(targ.health - take); // targ->health
				if(f3__ < -40) f2__ = f2__ - (-40 - f3__); //if(targ->health < -40) vdamage -= -40 - targ->health;

				f3__ = rint(f2__ + 0.5); // add = (int)((float)vdamage * rune_vampire->value + 0.5);
				if (f3__ > 0)
				{
					attacker.health = attacker.health + f3__; // if(add > 0) { attacker->health += add;

					if (attacker.health > (attacker.max_health * attacker.health_modifier * 2)) // if(attacker->health > rune_vampiremax->value) attacker->health = rune_vampiremax->value;
						attacker.health = attacker.max_health * attacker.health_modifier * 2; // 200 for a human
				}
			}
		}
		else
#endifdef
		if (targ.health < take) attacker.health = attacker.health + RUNE_VAMPIRE_PER * targ.health; // only get RUNE_VAMPIRE_PER% of actual damage, excludes armor & other saves
		else attacker.health = attacker.health + RUNE_VAMPIRE_PER * take;
	}

#endifdef


// do the damage
	targ.health = ceil(targ.health - take);

#ifdef code_xents
// crate being busted open - hear it now
	if (targ.classname == "func_crate")
	if ((targ.aflag < time) || (targ.health <= 0)) // do crates use .aflag for anything?
	{
		targ.aflag = time + 1;
		self.rnd_ = random();
		if (targ.health <= 0)
			sound (targ, CHAN_AUTO, targ.CRATE_OPENED, 1, ATTN_NORM);
		else if (self.rnd_ < 0.33)
			sound (targ, CHAN_AUTO, targ.CRATE_OPEN1, 1, ATTN_NORM);
		else if (self.rnd_ < 0.66)
			sound (targ, CHAN_AUTO, targ.CRATE_OPEN2, 1, ATTN_NORM);
		else //if (r < 0.3)
			sound (targ, CHAN_AUTO, targ.CRATE_OPEN3, 1, ATTN_NORM);		
	}
#endifdef

	if (targ.health <= 0)
	{
		Killed (targ, attacker);
		return;
	}

// react to the damage
	oldself = self;
	self = targ;

	if ( (self.flags & FL_MONSTER) && attacker) // != world)
	{
	// get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy
#ifdef hip_charmed
			  && (self.charmer!=attacker)
#endifdef
			)
		{
			if ( (self.classname != attacker.classname) 
#ifdef quakemonsters
					|| (self.classname == "monster_army" ) 
#endifdef

#ifdef HIPNOTIC
					|| (self.classname == "monster_armagon" )
#endifdef
				)
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget ();
			}
		}
	}

	if (self.th_pain)
	{
		self.th_pain (attacker, take);
	// nightmare mode monsters don't go into pain frames often
		if (skill == 3)
			self.pain_finished = time + 5;		
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// shambler takes half damage from all explosions
#ifdef quakemonsters
						if (head.classname == "monster_shambler")						
							T_Damage (head, inflictor, attacker, points*0.5);
						else
#endifdef
							T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
#ifdef unused

void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
#ifdef quakemonsters
					if (head.classname == "monster_shambler")						
						T_Damage (head, attacker, attacker, points*0.5);
					else
#endifdef
						T_Damage (head, attacker, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};

#endifdef

/*
============
gibbs
============
*/

void(string gibname, float dm) ThrowGib;
void(string gibname, float dm) ThrowHead;

// base std gibs & sound												- this adds 2 globals, yet it simplifies repeated code and precedes a more complex gib function that will come later

// self.model becomes hd
//	hd = head or large chunk to throw					- note: ThrowHead re-uses self for its throw

// leroy jethro...
void(string hd) gibbs =
{
// some code needs to play other sounds - call sound() with the same channel and this will not be heard
	sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	if (hd) ThrowHead (hd, self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);
};











