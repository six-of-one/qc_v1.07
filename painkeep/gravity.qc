 /* ::-::
 *
 * Cataboligne
 *
 * file: gravity.qc 
 *
 * date: 016.3.3
 *
 * qc - painkeep module - gravity well qc
 *
 */

/*
	gravity well
	Written by Matt Houser
	an Evolve project

	mods by
	Cataboligne
	for
	chaos mod mk II - "the Archons"
	painkeep 2.x, 3.x - "upgrades"
	04.2008+
*/

// 10.29.14 - super grav well expands as it runs

$frame cubelf01 cubelf02 cubelf03 cubelf04 cubelf05 cubelf06 cubelf07 cubelf08
$frame cubelf09 cubelf10 cubelf11 cubelf12 cubelf13 cubelf14 cubelf15 cubelf16
$frame cubelf17 cubelf18 cubelf19 cubelf20

$frame cube201 cube202 cube203 cube204 cube205 cube206 cube207 cube208
$frame cube209 cube210 cube211 cube212 cube213 cube214 cube215 cube216
$frame cube217 cube218 cube219 cube220


// check to see if ents are visible to gravity wave

float (entity targ) grav_visible =
{
	local vector	spot1, spot2, v2;
	local float f;

	v2 = '0 0 0';
	if (targ.flags & FL_CLIENT) f = TRUE;
	else
	if (targ.class_select == "class_bot") f = TRUE;
	if (targ.flags & FL_MONSTER) f = TRUE;
	if (f) v2 = targ.view_ofs;

	spot1 = self.origin;
	spot2 = targ.origin + v2;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters

// IMP: pull some liquid | lava balls with it - full chaos mod env expansion
//	if (trace_inopen && trace_inwater)
//		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;

// WATCH: keep an eye on this hack of a fix, until the "better" solution is available
// this is for grabbing low sitting items that register as in solid - but are not
	if (!f)
	if (pointcontents (targ.origin) == CONTENT_SOLID) // IDEA: qualify as x weps as well?
	if (trace_fraction > 0.65)
		return TRUE;

	if (f) return FALSE;
/*
	spot1 = self.origin + '0 0 24';
	traceline (spot1, spot2, TRUE, self);	
	if (trace_fraction == 1) return TRUE;

	spot1 = self.origin + '0 0 -16';
	traceline (spot1, spot2, TRUE, self);
	if (trace_fraction == 1) return TRUE;
*/
	return FALSE;
};

void() gravity_touch =
{
#ifdef code_soa
	if (other.classname == "sphere_annihilation") // whoopsie - make the reality bomb
	{
		if (self.frame > $cubelf20) other.scale = 2; // sgw effect
		set_annihilate(self);
		return;
	}
#endifdef

	// try to gib whatever touched the gravity centre
	if (other.takedamage && other.health > 0)
	{
		// sound

		T_Damage(other, self, self.owner, 5000);
	}

#ifdef code_morph
	if (other.flags & FL_CLIENT)
	if (other.mask_x & MORPH_ARCHON)
	if (other.AIRG_Timeout != -6)
	{
		other.AIRG_Timeout = -6;
		if (other.height == IMP_MCHAOS)
		if (random() < 0.06) return;

		other.velocity = '0 0 0';
		other.attack_finished = time + 3;
		power_drain(other);
		newmis.owner = world;
		newmis._alt_fire = archon_bouncer;
		newmis.wait = 0.1;
		newmis.archon = 20 + random() * 10;
		newmis.count = 10 * newmis.archon * ceil(0.4 + (2 * random()));
	}
#endifdef

	if (other.classname == "turret")
	if (other.delay == TRUE)
	{
		turret_KillStraker(other, 1 + random() * 5);
	}

#ifdef code_archon
	if (other.classname == "chaos_teleport_icon")
	if (other.AIRG_Timeout != -6)
	{
		dyn_remove(other, 1, chaos_tele_expire);
		other.AIRG_Timeout = -6;
	}
#endifdef
};

// IDEA: reality bomb - chaos effects while active

void() gravity_pull =
{
	local entity e;
	local float d, i, gp;
//	local float sgl;
	local vector org, v1;
	local float gPercent;
	local float gDist, gExt, gFal;
	local float gPower;

	gDist = 960;		// range of the weapon
	gPower = 512;	// ideal speed of pull
	gExt = 0; // extra dist - only super gravwell
	gp = GRAV_PULL; // rune pull test %

// either banished & went grav or grav + sphere
#ifdef code_soa
	if (self.classname == "sphere_annihilation") // reality bomb - these are a bit more powerfull
	{
		gDist = 1290 + random() * 200;
		gPower = 640 + random() * 100;		
		gExt = 360; // laser beam range out to 1600
		sgl = TFL_HEAL | TFL_TKDMG | TFL_TRACE | TFL_INVIS;		// all hittable things for lazer
		gp = SGRAV_PULL * 1.1; // rune pull test %
	}
	else
#endifdef
	if (self.frame > $cubelf20) // super grav well = sgw
	{
		gDist = 1280;
		gPower = 640;
		gExt = 320; // laser beam range out to 1600
//		sgl = TFL_HEAL | TFL_TKDMG | TFL_TRACE | TFL_INVIS;		// all hittable things for lazer
		gp = SGRAV_PULL; // rune pull test %
	}

// idea: sgw -  phantom zone effect with 6 sides flying off, catching vars ents, & sweeping from level - players watch this - time out & allow respawn / return
	if (time > self.attack_finished)
	{
		// turn of rb sound
		sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
		// turn off bright light
		if (self.effects & EF_BRIGHTLIGHT)
			self.effects = self.effects - EF_BRIGHTLIGHT;

		// do an explosion
		T_RadiusDamage(self, self.owner, 80, world);

		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		BecomeExplosion();
		return;
	}

	org = (self.absmin + self.absmax) * 0.5;
	e = findradius(self.origin, gDist + gExt);


	while (e)
	{

		gFal = TRUE; // fail check for ext dist items
		if (gExt) // sgw - laser range test
		{
			if (vlen(e.origin - self.origin) > gDist)
			{
// idea: sgw - chance to teleport out of range in range
//if (e != self.owner) // idea: should not target owner ?

// rune pull _beyond_ grab range test
#ifdef code_runes
				if (vlen(e.origin - self.origin) < (gDist * 1.333))
				if (random() < 0.2) // only 2o% to try test (curr 5o%) for things past pull range
					// chance to knock a rune loose
					rune_pull(e, GRAV_PULL); // not a super pull yet
#endifdef

// kill tele balls in range
				self.cnt = 0;
				if (e.classname == "chaos_teleport_icon") self.cnt = 1;

				if (vlen(e.origin - self.origin) < (gDist * 1.6))
// makes periodic beams that strike random targets
				if  ((random() <  0.01) || self.cnt)
					//self.cnt = 1;
// or 36% chance to find a valid target - this method never fired lasers - now redacted
//				if (random() < 0.366 || self.cnt)
//				if (can_has_target(e, self, self.origin, 0, sgl) || self.cnt) // check LOS to grav
				{
					T_Damage (e,self,self.owner,10); // fired black laser

// remove detected tele ball
#ifdef code_archon
					if (self.cnt) dyn_remove(e, 1, chaos_tele_expire); // cant call tele_exp directly
#endifdef

					v1 = e.origin - self.origin;
#ifdef code_xents
					self.aiment = chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 0, 0, self.origin, '0 0 0', '0 0 0', vectoangles(v1), '0 0 0', string_null, "progs/lzrbm_seg.mdl", SUB_Remove, 0.2, SUB_Remove, SUB_Null, self, world);
#else
					self.aiment = spawn();
					setorigin(self.aiment, self.origin);
					setmodel(self, "progs/lzrbm_seg.mdl");
					self.angles = vectoangles(v1);
					self.think = SUB_Remove;
					self.touch = SUB_Remove;
					self.nextthink = time + 0.2;
#endifdef
					i = vlen(v1);
					i = floor(i / 32);
					if (i > 63) i = 63;
					self.aiment.frame = i + 64; // larger size
					self.aiment.skin = 3; // black beam
				}
				gFal = FALSE; // laser beam range item only
			}
			else // in range - other tests
			{
// idea: sgw - grim flakes

				if (random() < 0.45)
				{
#ifdef code_archon
					v1 = '0 0 0';
					v1_x = crandom() * 25;
					v1_y = crandom() * 25;
					v1_z = crandom() * 25;
					chaos_particle(e.origin + v1, 0, 0.8, 0);
#endifdef

					if (random() < 0.16)
						sound (e, CHAN_VOICE, "misc/thunder/thunder5.wav", 1, ATTN_NORM); 
				}
#ifdef code_xents
				if (e.hook & HOOK_ON)
				if (random() < 0.28) // heh heh - strong enough to release hooks
					DropHook(e);
#endifdef
			}
		}

// idea: sgw - check for players / bots moving & lift if not - e.g. stuck behind brush, or just pull through solid

		if (gFal)
		if (grav_visible(e))
		if (e.classname != "gravity") // don't yank on any other gravity wells
		if (e.classname != "beartrap")
		if (e.model != "progs/boss.mdl" && e.model != "progs/oldone.mdl" && e.model != "progs/cthon.mdl") // dont pull bosses or cthon morph
#ifdef code_pkplus
		if (pk_art_movshot_ck(e, "grav")) // Cataboligne 8.12.9 purify - pk artifacts
#endifdef
		if (e != self.goalentity) // archon cast grav, wont grab caster
		if (e.map != "nonmove") // 7.22.13 - func_models we should not suck
		//if (e != self.owner)
		if (e.AIRG_Timeout != -6)
//		if ((e.classname == OBSERVER && random() < 0.001666) || e.classname != OBSERVER)
		if (e.movetype != MOVETYPE_NONE) // anything that can move
		if (e.movetype != MOVETYPE_PUSH)
		if (e.movetype != MOVETYPE_NOCLIP)
		{
			d = vlen(e.origin - org);
			if (e.flags & FL_ONGROUND)
			{
				// raise the object a bit
				setorigin(e, e.origin + '0 0 1');
				e.flags = e.flags - FL_ONGROUND;
			}
// it seems the grav well will not suck flying monsters
			if (e.flags & FL_MONSTER)
			{
				if (e.movetype != MOVETYPE_TOSS) // _STEP seems to avoid gravity pull period
					e.movetype = MOVETYPE_TOSS;
			}
			//dprint(e.classname);
			gPercent = 1 - (d / gDist);

			// modify the velocity
			e.velocity = e.velocity + normalize(self.origin - e.origin) * gPower * gPercent;

//			if (random() < 0.1) // only 1o% to try test (curr 5o%) for things getting pulled every 0.1 rels - prob be dead before this ever factored in
				// chance to knock a rune loose
#ifdef code_runes
				rune_pull(e, gp);

			if (e.map  == "rune" && e.classname == "item_sigil") // relocate runes sucked by wells
				e.hook = TRUE;
#endifdef

		}
		e = e.chain;
	}
};

/*
void() gravity_pulse1 = [ $cubelf01, gravity_pulse2 ] { gravity_pull(); };
void() gravity_pulse2 = [ $cubelf02, gravity_pulse3 ] { gravity_pull(); };
void() gravity_pulse3 = [ $cubelf03, gravity_pulse4 ] { gravity_pull(); };
void() gravity_pulse4 = [ $cubelf04, gravity_pulse5 ] { gravity_pull(); };
void() gravity_pulse5 = [ $cubelf05, gravity_pulse6 ] { gravity_pull(); };
void() gravity_pulse6 = [ $cubelf06, gravity_pulse7 ] { gravity_pull(); };
void() gravity_pulse7 = [ $cubelf07, gravity_pulse8 ] { gravity_pull(); };
void() gravity_pulse8 = [ $cubelf08, gravity_pulse9 ] { gravity_pull(); };
void() gravity_pulse9 = [ $cubelf09, gravity_pulse10 ] { gravity_pull(); };
void() gravity_pulse10 = [ $cubelf10, gravity_pulse11 ] { gravity_pull(); };
void() gravity_pulse11 = [ $cubelf11, gravity_pulse12 ] { gravity_pull(); };
void() gravity_pulse12 = [ $cubelf12, gravity_pulse13 ] { gravity_pull(); };
void() gravity_pulse13 = [ $cubelf13, gravity_pulse14 ] { gravity_pull(); };
void() gravity_pulse14 = [ $cubelf14, gravity_pulse15 ] { gravity_pull(); };
void() gravity_pulse15 = [ $cubelf15, gravity_pulse16 ] { gravity_pull(); };
void() gravity_pulse16 = [ $cubelf16, gravity_pulse17 ] { gravity_pull(); };
*/
void() gravity_pulse17 = [ $cubelf16, gravity_pulse18 ] { gravity_pull(); };
void() gravity_pulse18 = [ $cubelf16, gravity_pulse19 ] { gravity_pull(); };
void() gravity_pulse19 = [ $cubelf16, gravity_pulse20 ] { gravity_pull(); };
void() gravity_pulse20 = [ $cubelf16, gravity_pulse1 ] { gravity_pull(); };

framer($cubelf01, $cubelf16, gravity_pulse1, gravity_pulse17, 0.1,gravity_pull());

// sgw animate
/*
void() gravity_pulsex1 = [ $cube201, gravity_pulsex2 ] { gravity_pull(); };
void() gravity_pulsex2 = [ $cube202, gravity_pulsex3 ] { gravity_pull(); };
void() gravity_pulsex3 = [ $cube203, gravity_pulsex4 ] { gravity_pull(); };
void() gravity_pulsex4 = [ $cube204, gravity_pulsex5 ] { gravity_pull(); self.scale = self.scale + self.aflag; };
void() gravity_pulsex5 = [ $cube205, gravity_pulsex6 ] { gravity_pull(); };
void() gravity_pulsex6 = [ $cube206, gravity_pulsex7 ] { gravity_pull(); };
void() gravity_pulsex7 = [ $cube207, gravity_pulsex8 ] { gravity_pull(); };
void() gravity_pulsex8 = [ $cube208, gravity_pulsex9 ] { gravity_pull(); self.scale = self.scale + self.aflag; };
void() gravity_pulsex9 = [ $cube209, gravity_pulsex10 ] { gravity_pull(); };
void() gravity_pulsex10 = [ $cube210, gravity_pulsex11 ] { gravity_pull(); };
void() gravity_pulsex11 = [ $cube211, gravity_pulsex12 ] { gravity_pull(); };
void() gravity_pulsex12 = [ $cube212, gravity_pulsex13 ] { gravity_pull(); self.scale = self.scale + self.aflag; };
void() gravity_pulsex13 = [ $cube213, gravity_pulsex14 ] { gravity_pull(); };
void() gravity_pulsex14 = [ $cube214, gravity_pulsex15 ] { gravity_pull(); };
void() gravity_pulsex15 = [ $cube215, gravity_pulsex16 ] { gravity_pull(); };
void() gravity_pulsex16 = [ $cube216, gravity_pulsex17 ] { gravity_pull(); self.scale = self.scale + self.aflag; };
*/
void() gravity_pulsex17 = [ $cube216, gravity_pulsex18 ] { gravity_pull(); };
void() gravity_pulsex18 = [ $cube216, gravity_pulsex19 ] { gravity_pull(); };
void() gravity_pulsex19 = [ $cube216, gravity_pulsex20 ]
{
	gravity_pull();
	self.maxs_x = 12 * self.scale;
	self.maxs_y = 12 * self.scale;
	self.maxs_z = 12 * self.scale;
	self.mins_x = -12 * self.scale;
	self.mins_y = -12 * self.scale;
	self.mins_z = -12 * self.scale;
	setsize(self, self.mins, self.maxs);
};
void() gravity_pulsex20 = [ $cube216, gravity_pulsex1 ] { gravity_pull(); self.aflag = 0.04; };

framer($cube201, $cube216, gravity_pulsex1, gravity_pulsex17, 0.1,

	frame_arb($cube201,self.f__ =0);
	self.f__ = self.f__ + 1;
	if (self.f__ == 4)
	{
		self.scale = self.scale + self.aflag;
		self.f__ =0;
	}
	gravity_pull();
);


void() gravity_explode =
{
	//if (time > self.attack_finished)
	//{
		// TODO something funky in the water?

		setmodel(self, "progs/cubel.mdl");
		self.nextthink = time + 0.1;

		if (self.alpha < 1)
		{
			setsize(self, '-8 -8 -8', '8 8 8');
			if (self.frame < $cube201)
			{
				self.frame = $cube201;
				self.skin = 1;
			}
			self.alpha = self.alpha + 0.05;
			self.frame = self.frame + 0.5;
			return;
		}

		if (self.frame > $cubelf20)
		{
			sound (self, CHAN_BODY, "misc/grav/grav_new.wav", 1, ATTN_NORM);
			self.attack_finished = time + PK_GRV_TIME + random() + random() + random();	// duration of sgw
			self.think = gravity_pulsex1;
			self.aflag = 0.1;
		}
		else
		{
			self.attack_finished = time + PK_GRV_TIME;	// duration of gravity well
			self.think = gravity_pulse1;
		}

		self.touch = gravity_touch;
		self.effects = self.effects | EF_BRIGHTLIGHT;
	  self.pk_currentitem = PK_IT_GRAVITYWELL;
	//	return;
	//}

	//sound (self, CHAN_BODY, "misc/gravsp_3.wav", 1, ATTN_NORM);
	//self.nextthink = time + 1.0;
};

// idea: sgw - move sphere up 200 units, or 1/2 dist bot to top if  < 400 units

void() drop_gravity =
{
	if (!PK_GRV_SET)
	{
		PK_GRV_SET = TRUE;

		PK_GRV_TIME = 3.2; // def

/*
		if (DARKPLACES || chaos)
		{
			PK_GRV_TIME = cvar("pk_grv_time");
		}
*/
	}

	// create a gravity object
	newmis = spawn();
	newmis.classname = "gravity";
	newmis.owner = self;
	newmis.solid = SOLID_TRIGGER;
	newmis.movetype = MOVETYPE_TOSS;

	// set it's placement and velocity
	setorigin(newmis, self.origin + self.view_ofs);
	newmis.velocity = self.velocity * 0.5;
	setmodel(newmis, "progs/cube.mdl");
	// TODO get acurate sizing
	setsize(newmis, '-32 -32 -32', '32 32 32');
	newmis.alpha = 1; // has to be set for norm ops to work right
	newmis.scale = 1;

	/*
	newmis.think = gravity_explode;
	newmis.nextthink = time + 1.0;
	newmis.attack_finished = time + 2.1;
	*/
	newmis.think = gravity_explode;
	newmis.nextthink = time + 2.0;
	sound (self, CHAN_BODY, "misc/grav/grav_new.wav", 1, ATTN_NORM);

	// Throw away from you
	makevectors (self.angles);
	newmis.velocity = (v_forward * (200 + random() * 100)) + (v_up * (200 + random() * 100));

	// For the correct death messages
	newmis.pk_currentitem = PK_IT_GRAVITYWELL;
	newmis.weapon = IT_AXE;

	// PAINKEEP SPLASH Make this entity splash
#ifdef painkeep_splash
	AddToSplash(newmis);
#endifdef
};

void() drop_gravity_sups =
{
	drop_gravity();
	sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
	newmis.frame = 1;
	newmis.alpha = 0.1;
};

