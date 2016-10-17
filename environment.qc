/* ::-::
 *
 * Cataboligne
 *
 * file: environment.qc 
 *
 * date: 016.2.10
 *
 * qc - environment effects
 *
 */

// fn(move_stop) halt a moving entity, play looped sound ns

void (entity e, string ns) move_stop =
{
	e.velocity = '0 0 0';
	e.movetype = MOVETYPE_NONE; // fails blast_move - removing fails shell casings in lava
	if (ns) sound(e, CHAN_WEAPON, ns, 1, ATTN_NORM);
};


// fn(sky_touch) - new sky tex missile / object strike test - called by touch fns, as touch or think fn
// fn(sky_touch_pointer) - touch / think fn redirect - if called as touch or think does remove if RM_SKY set in content flags

// operation
// - 2 tests for origin v or entity e.origin + norm(e.velocity) * 10 - pointcontents and surface (darkplaces)
// - if surf non blank its value will be tested and disregard all other info

// return - TRUE if object is touching (near?) sky
// sets global string last texture for other code to reference

// e - passed entity, if world, try self, if self == world return FALSE

// IDEA: limit re-entry

/* sky list - so far

sky1, sky4 - quake 1 default skies
sky6 - chaos maps, black was also used for castle arioch - needs to be sky_black
sky2 - gallery map
sky0 - doom e1m1 q1 map, latest
skydark - stonehenge (thick enough for content check)

texture/ * skies - q3 maps
*/
#define	last_texture		s0__
#define	surfnum2		f1__


float(vector v, entity e) sky_touch =
{
//	if (!DARKPLACES) return(FALSE); // Cat - 8.14.11 - fix fteqw bug

	f0__ = FALSE;
	if (v == '0 0 0')
	{
		if (!e) e = self;
		v = e.origin + normalize(e.velocity) * 10;
	}
// this is prob the easiest way to do this, as well
	if (v == '0 0 0'
#ifdef map_hack
					|| cvar("__biome_")
#endifdef
										) return(f0__);

	if (pointcontents(v) == CONTENT_SKY) f0__ = TRUE;

#ifndef nondp
	last_texture = string_null;
	surfnum2 = getsurfacenearpoint(world, v);

// new sky contents code
// __sky{n} cvars must be sequential - first not found ends loop

	if (surfnum2 >= 0)
	{
		last_texture = getsurfacetexture(world, surfnum2);
		f5__ = 1;
		while (f5__ > 0)
		{
			s5__ = strcat("__sky",ftos(f5__));
			f5__ = f5__ + 1;
			if (! (cvar_type(s5__) & CVAR_TYPEFLAG_EXISTS))
				f5__ = 0;
			else if (last_texture == cvar_string(s5__)) f0__ = TRUE;
		}
	}
#endifdef

	return(f0__);
};

// fn(T_FireDamage) - damage from fires & hot stuff, will heal lavablobs!

void (entity targ, entity inflictor, entity attacker, float damage) T_FireDamage =
{
//	if ((targ.morphy == IMP_MCTHON) || (targ.morphy == IMP_MCHAOS) || (targ.classname == "monster_tarbaby" || targ.classname == "monster_lavabomb")) // lava capable ents wont get burned...often
#ifdef code_morph
	if (IS_LAVA(targ)) 
	{

#ifdef warning
																						if (! WARNING & 262144) // block this warning
																						if (WARNING & 128)
																						{
																						bprint("*** warning: T_FireDamage ( ");
																						item_ident(targ);
																						bprint(" ) - possible heal: ");
																						bprint(ftos(damage));
																						bprint("\n");
																						}
#endifdef

		if (targ.morphy == IMP_MCTHON) T_Heal(targ, damage, 0); // LOL - lava is "healed" by fire - such a horta situation...
/*

 deprecate - Archons take no damage or healing
//
		else if (targ.morphy == IMP_MCHAOS) // chaos here
		{
			if (targ.watertype == CONTENT_LAVA)
			{
				if (random() < 0.05) T_Heal(targ, damage * random(), 0); // CHAOS_LEVEL ph
				else if (random() < 0.015) T_Damage (targ, inflictor, attacker, damage * random()); // even less chance of damage
			}
			else
				if (random() < 0.02) T_Damage (targ, inflictor, attacker, damage * random());
		}
*/
		else //if (targ.classname == "monster_tarbaby" || targ.classname == "monster_lavabomb") 
		{
			if (random() < 0.2) T_Heal(targ, damage, 0);  // tarbabys too...
		}
	}
	else 
#endifdef
		T_Damage (targ, inflictor, attacker, damage);
};


// relocation code - called by ip_checkForMovement & from splash.qc
// 016.7.26 - temp put in for runes module

// could move anything, effect should prob be client sided

void() fade_relocate =
{
	if (!self.alpha) self.alpha = 1.03; // make sure the fade doesnt hit 0 and fire this again

	self.think = fade_relocate;
	self.nextthink = time + 0.1;

	if (self.alpha < 0.6) self.touch = SUB_Null;
//	else self.touch = painkeep_touch;

	self.alpha = self.alpha + self.lip;

	if (self.lip < 0)
	if (self.alpha < 0.05)
	{
		self.lip = 0.05;
#ifdef code_runes
		setorigin(self, self.ip_orgOrigin);
#endifdef
#ifdef code_xents
		item_eject(self, MED_BOUNCE);		
#endifdef
	}

	if (self.lip > 0)
	if (self.alpha > 1)
	{
		self.alpha = 1.03;
		self.lip = 0;
//		self.revotemsg = 0; // used to block removal tests in splash.qc

// runes is using this - might be able to remove		
#ifdef code_runes
		if (self.event == "dyn_item")
			self.ip_orgOrigin = '0 0 0'; // clear for out of bounds ***
#endifdef
		self.think = self.th_stand; // done - back to the usual
		self.th_stand = SUB_Null;
		self.nextthink = self.lefty;
	}
};