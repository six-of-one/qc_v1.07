
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

#ifdef monsters_plus__
	if (self.flags & FL_CLIENT)			// so super monsters can have full neg dmg
#endifdef
	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player			- this blocks gibbing some super monsters

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

#ifdef code_archon
	if (! self.flags & (FL_CLIENT | FL_MONSTER)) // because some elements of chaos mod mk I used movetype none
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
#ifdef code_archon
		if (self.owner.flags & FL_MONSTER) self.owner = world; // clear summoned count for limits
//		if (attacker.flags & FL_CLIENT)
			attacker.xp = attacker.xp + self.archon; // pts for monster kills
#endifdef
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}
#ifdef code_pkbots
	if (self.group == "pk*bot" || attacker.group == "pk*bot") // note: handles "player" setting for pk*bot obit fn - we NO LONGER need this
		bot_kill(self, attacker); // *bot - tie in to count bot kills / deaths
	else
#endifdef
	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

// start last man standing ops if enabled
// happens after first kill following LMS victory, which turns off counting
#ifdef code_lmst
		if (LMS < 0) LMS = 6;		// count starts
#endifdef

// TDO: do we need this when we start throwing weps on die?
//	if (self.vwepent) vw_chain(self); // re chain any vweps before death - which can throw weps

	monster_death_use();
#ifdef code_archon
	if (self.goalentity.think == de_archon_thk) // no return this vector if he got de-archoned
	{
		if (self.th_die) self.th_die ();
	}
	else
	if ((self.height == IMP_MCHAOS && self.morphy != IMP_MCHAOS) ||
		 (self.height == IMP_MORDER && self.morphy != IMP_MORDER)) // death returns to Archon form from polymorph - no pts req. for now
	{
		if (self.goalentity.classname == "archon_morph")
			self.goalentity.think();
		else
		chaos_morph_chg(self, 0); // CHECK: this for order
	}
	else
//	if (self.th_die != (void()) 0) // something got thru with 0 th_die on server test 10.28.11
	if (self.th_die) // something got thru with 0 th_die on server test 10.28.11 - fteqcc mode
#endifdef
	self.th_die ();

#ifdef code_viswep
	if (self.vwepent) viswep_ld(self, -2); // still have visweps
#endifdef
#ifdef code_archon
	if ((self.morphy != IMP_MCHAOS) && (self.morphy != IMP_MORDER))
	if (self.ishuman) // Cataboligne 9.19.11 - monsters were calling - just never saw because werent using dp cam
		dead_cam_set(); // Cataboligne 9.11.3 purify - chase cam
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
	local	float	save, pwr_save;
	local	float	take;

	if (!targ.takedamage)
		return;

#ifdef warning
									if (warnings == "tdmg")
									{
										bprint ("  *** T_Damage: ");
										bprint (ftos(damage));
										bprint (" att c: ");
										bprint (attacker.classname);
										bprint (" n: ");
										bprint (attacker.netname);
										bprint (" scale: ");
										bprint (ftos(attacker.scale));
										bprint (" targ c: ");
										bprint (targ.classname);
										bprint (" n: ");
										bprint (targ.netname);
										bprint (" hl: ");
										bprint (ftos(targ.health));
										bprint (" inf c: ");
										bprint (inflictor.classname);
										bprint (" n: ");
										bprint (inflictor.netname);
										bprint (" theown: ");
	#ifdef code_xents
									bprint (inflictor.theowner.classname);
	#endifdef
//										bprint ("\n");
									}
#endifdef

#ifdef code_painkeep_
// restore owner - was set on launch so owner can be targeted by reflect spikes, etc
// note: if .grap_owner (or .goalentity if no pk) is ever set it will poss. fsck the obit and all owned dmg stuff here
	if (inflictor.theowner) attacker = inflictor.theowner;
#else
#ifndef HIPNOTIC
// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;
#endifdef
#endifdef

#ifdef code_archon
// Archons dont use health - no damage & no additive - 9.19.13
	if (targ.flags & FL_CLIENT)
	if (targ.mask_x & MORPH_ARCHON)
	{
// runes take portion of damage & reduce archon power of an attacked Archon - before multipliers
		save = 0;
		take = 0;
		if ((attacker.rune_flag & RUNE_FLG_DM) || (attacker.rune_flag & TECH_AMP))
		{
			save = 0.25;
			take = 2; // possibly amplify next rune
			if (targ.rune_flag & RUNE_FLG_RS) save = 0.125;
		}

		if (attacker.rune_flag & RUNE_VAMPIRE)
		{
			if (take) save = save * take;
			take = damage * save;
			if ((targ.archon - take) < 0) // cant add negative pts
			{
				take = (targ.archon);// - take) + take;
			}
			if (targ.armorvalue <= 0) attacker.archon = attacker.archon + take; // add points to attackers
		}

// magic shield goes here - prevent archon power loss but reduce shield power

		if (targ.armorvalue > 0)
		{
			targ.armorvalue = targ.armorvalue - (damage * save);
			if (targ.armorvalue < 0) targ.armorvalue = 0; // shield gone
		}
		else
		{
			if ((damage * save) > 1)
			if ((time & 3) == 3)
				stuffcmd(targ, "hud_message \"WARNING: Archon power loss ***\"\n");

			targ.archon = targ.archon - (damage * save);
		}
		if (targ.archon < 0) de_archon(targ);
		return;
	}

#endifdef

// check for quad damage powerup on the attacker
#ifdef code_runes
	if (!( (RUNES > 1) && ( (attacker.rune_flag & RUNE_FLG_DM) || (attacker.rune_flag & TECH_AMP) ) ) || RUNE_QUAD_COMB ) // rune overpowers quad on higher rule sets 
#endifdef

	if (attacker.super_damage_finished > time)
#ifdef code_painkeep_actor
	if (attacker.pkplus_actortype != PKPLUS_ACTORQUAD) // pk art code here
#endifdef
#ifdef code_archon
	if ((attacker.group != "Berserk rage...nearly over...Hulk sad") || (attacker.eweapon.grap_state == 66600)) // fists only *4
#endifdef
	{
		damage = damage * 4;
#ifdef warning_no
// test for berserk pack + fists
			if (WARNING & 64) bprint(" ------------ ***          damage * 4\n");
#endifdef
	}

#ifdef hip_items
	if (discharged && targ.wetsuit_finished )	//&& (targ.items & IT_SUIT)) // lightning underwater & wearing suit
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
#endifdef

#ifdef code_runes
//	r = cvar("sv_c_rune");
	if (attacker.rune_flag & RUNE_FLG_DM) // dmg rune - idea: could do more under rules > 2
	{
		if (RUNES > 1)
		if (targ == attacker) return; // lith rules - note: this blocks rocket jump push

		damage = damage * 2;

		if (attacker.rune_flag & TECH_AMP) // combind with dmg tech!
		if (RUNE_TECH_DMG_COMB)
			damage = damage * 2;
	}
	else
	if (attacker.rune_flag & TECH_AMP) // dmg tech
		damage = damage * 2;
#endifdef

#ifdef hip_items
//MED
//check for empathy shields
//	if ((targ.items2 & HIP_IT_EMPATHY_SHIELDS) && !(inflictor.items2 & HIP_IT_EMPATHY_SHIELDS) && (targ != attacker))
	if ((targ.empathy_finished) && !(inflictor.empathy_finished) && (targ != attacker))
	{
		empathy_dmg = 1;
		damage = damage/2;
		T_Damage (attacker,targ,targ,damage);

#ifdef code_archon
		if (attacker.mask_x & MORPH_ARCHON) // empathy shield drains archon pts when Archon attacks a player protected by it
		{
			empathy_dmg = 0.25;
			if (attacker.rune_flag & RUNE_FLG_RS) empathy_dmg = 0.125;
// IMP: magic shield goes here - prevent archon power loss but reduce shield power
			attacker.archon = attacker.archon - (damage * empathy_dmg); // reduce by 1/4 of the 1/2 damage just set
		}
#endifdef
		empathy_dmg = 0;
	}
#endifdef

#ifdef HIPNOTIC
//MED
// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

//MED
// used to keep track of what hit us
	damage_inflictor = inflictor;
#else
#ifdef code_painkeep_
	damage_inflictor = inflictor;
#endifdef
#endifdef

// save damage based on the target's armor level

#ifdef code_xents
	if (targ.ignorearmor != IGN_ARM)
	{
		pwr_save = power_armor(targ, inflictor, damage); // calc damage taken by power armor

		if (pwr_save < damage)
#endifdef
		save = ceil(targ.armortype * (damage
#ifdef code_xents
					 - pwr_save
#endifdef
						));

		if (save >= targ.armorvalue)
			save = targ.armorvalue;

#ifdef code_xents
	}
	else
		save = 0;
#endifdef
	
	take = ceil(damage - save
#ifdef code_xents
				 - pwr_save
#endifdef
				);

#ifdef code_runes

	if ( (targ.rune_flag & RUNE_FLG_RS) || (targ.rune_flag & TECH_DSH) ) // idea: resist should do more under rules > 2, but not tech
	{
		take = floor(take / 2);
		save = floor(save / 2);
//		if (( RUNE_TECH_RS_COMB || !ENHANCED ) && (targ.rune_flag & RUNE_FLG_RS) && (targ.rune_flag & TECH_DSH))
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

	if (targ.armorvalue < 1)
	{
		targ.armortype = 0;	// lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}

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
	if ( (inflictor) /* != world) */ && ((targ.movetype == MOVETYPE_WALK)  || targ.group == "pk*bot"))
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
		if (targ.invincible_sound < time) // Cataboligne - 10.1.11 - the targ was self
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
#ifdef code_painkeep_actor
		if (targ.pkplus_actortype != PKPLUS_ACTORPENT) // pk art code here
#endifdef
#ifdef warning
									if (warnings == "tdmg")
									{
										bprint ("\n");
									}
#endifdef
		return;
	}

#ifdef hip_items
//MED
//	if (targ.items2 & HIP_IT_EMPATHY_SHIELDS)
   if (targ.empathy_finished)
	{
      if (targ.empathy_sound < time) // Cataboligne - 10.1.11 - the targ was self
		{
			sound (targ, CHAN_ITEM, "hipitems/empathy2.wav", 1, ATTN_NORM);
         		targ.empathy_sound = time + 0.5;
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

#ifdef warning
									if (warnings == "tdmg")
									{
										bprint (" taken: ");
										bprint (ftos(take));
										bprint ("\n");
									}
#endifdef

// do the damage
	targ.health = ceil(targ.health - take);

#ifdef code_pkbots
	ax_dmg = take; // Cataboligne - 10.11.11 - bot endless axe war preventative deal
#endifdef

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
#ifdef code_pkbots
	if (self.group == "pk*bot")
	{
		if (attacker != world && inflictor != world)
		{
// xrp code - looks good
			if ((attacker != self) && !coop)
			{
				if (self.enemy)
				{
					secondEnemy (attacker);
				}
				else
				{
					self.enemy = attacker;
					BotFoundTarget ();
				}
			}
		}
	}
	else
#endifdef

	if ( (self.flags & FL_MONSTER) && attacker) // != world)
	{
	// get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy
#ifdef hip_charmed
			  && (self.charmer != attacker)
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

#ifdef code_painkeep_actor
	if (self.pkplus_actortype != PKPLUS_ACTORPENT || random() < 0.1) // pk art code here - fake it for pent acting most of the time
#endifdef
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
				if (head == attacker
#ifdef code_archon
						 || inflictor.classname == "chaos_prox"
#endifdef
							)
					points = points * 0.5;
//				if (head.morphy == IMP_MCHAOS) points = 0; // Cat - imp 9.19.13 - so chaos proxmines dont hurt chaos - archon takes no damage

				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// shambler takes half damage from all explosions
#ifdef quakemonsters
						if (head.classname == "monster_shambler")						
							T_Damage (head, inflictor, attacker, points*0.5);	//  * BlastProof(head)); //0.5);
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
					if (head.classname == "monster_shambler"
#ifdef code_archon
							 || head.morphy == IMP_MSHAMBLR
#endifdef
											)
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

	s1__ = "progs/gib1.mdl";
	s2__ = "progs/gib2.mdl";
// PK expand - extra gib parts
#ifdef code_painkeep_
	if (cvar("PK") > 0 && self.classname == "player")
	{
		if (random() < 0.5) hd = "progs/qtgib3.mdl";
		if (random() < 0.5) s1__ = "progs/qtgib1.mdl";
		if (random() < 0.5) s2__ = "progs/qtgib2.mdl";

	ThrowGib ("progs/g_arm.mdl", self.health);
	//ThrowGib ("progs/g_arm.mdl", self.health);
	ThrowGib ("progs/g_boot.mdl", self.health);
	ThrowGib ("progs/g_eye.mdl", self.health);
	//ThrowGib ("progs/g_eye.mdl", self.health);
	//ThrowGib ("progs/g_fore.mdl", self.health);
	ThrowGib ("progs/g_fore.mdl", self.health);
	ThrowGib ("progs/g_leg.mdl", self.health);
	}
#endifdef
	if (hd) ThrowHead (hd, self.health);
	ThrowGib (s1__, self.health);
	ThrowGib (s2__, self.health);
	ThrowGib ("progs/gib3.mdl", self.health);
};









