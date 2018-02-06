
//entity stemp, otemp, s, old;	// fx_warning
// FIX - opgrade this
entity s; 
///in function spawn_tfog (line 7)
///triggers.qc:305: error: Unknown value "s".

void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

#define	SPAWNFLAG_NOMESSAGE 1
#define	SPAWNFLAG_NOTOUCH 1

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

// server manage spc

#ifdef code_xents
// Cataboligne - 017.1.20 - call to handle vars special condition
	if (score_cnt()) return;
#endifdef

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte(MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;

#ifdef code_pkbots
	if (activator.group == "pk*bot")
		bot_triggered (activator);
#endifdef
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove(self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
#ifdef HIPNOTIC
//MED 12/01/96 added cnt stuff
	if (self.cnt > 0)
	{
		self.cnt = self.cnt - 1;
		if (self.cnt == 0)
		{
			self.touch = SUB_Null;
			self.nextthink = time + 0.1;
			self.think = SUB_Remove;
		}
	}
#endifdef
};

void() multi_killed =
{
	self.enemy = damage_attacker;
	self.solid = SOLID_NOT; // opgrade - stop blocking when dead - Cataboligne - 11.6.12 - CHECK: find out if this borks any existing maps
	multi_trigger();
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (other.classname != "player")
		return;

#ifdef code_pkbots
	if (other.group == "pk*bot")
	{
		self.enemy = other;
		bot_touched ();
		multi_trigger ();
		return ;
	}
#endifdef
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger();
};

/*QUAKED trigger_multiple(.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
"cnt" how many times it can be triggered (infinite default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
	if (self.sounds == 1)
	{
		precache_sound("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

#ifdef code_pkbots
	self.th_weight = triggerweight; // *bot
	self.istrigger = 1;
#endifdef
	InitTrigger();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
#ifdef noobjerr
		{

	#ifdef xvars1
			if (cvar("svx_platdoorfail") < 0) // remove option - trigger_multiple
			{
				remove(self);
				return;
			}
	#endifdef
			self.spawnflags = self.spawnflags - SPAWNFLAG_NOTOUCH;
		
		}
#else
			objerror("health and notouch don't make sense\n");					//opgrade protected
#endifdef
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}
#ifdef HIPNOTIC
//MED 12/01/96 added cnt stuff
	if (self.cnt == 0)
		self.cnt = -1;
#endifdef
};


/*QUAKED trigger_once(.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = SUB_UseTargets;

#ifdef map_hack
// do this or these will have visual appearance in hacks
	self.modelindex = 0;
	self.model = string_null;
#endifdef
};


//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "You found a secret area!";
	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1)
	{
		precache_sound("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}

	trigger_multiple();
};

//=============================================================================


void() counter_use =
{
//	local string junk;	// fx_warning

	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count) // != 0)
	{
		if (activator.classname == "player"
		&& !(self.spawnflags & SPAWNFLAG_NOMESSAGE) ) // == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "player"
	&& !(self.spawnflags & SPAWNFLAG_NOMESSAGE) ) // == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger();
};

/*QUAKED trigger_counter(.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;

#ifdef map_hack
// do this or these will have visual appearance in hacks
	self.modelindex = 0;
	self.model = string_null;
#endifdef
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

#define	PLAYER_ONLY	1

// enhances
#define T_SILENT   	2
#define T_RANDOM 	4
#define T_STEALTH 	8 // use both stealh & silent for invisible tele - add nondir for a good illusion of transit
// idea: positional transit relative to a point around trigger (info_notnull) added to destination point - so walking on the left side of a hallway would stay on the left instead of centering
#define NONDIR 	16 // Note: zerstorer used this for something - ref: dd
#define T_NODEATH 	32
#define ALT_TARGET 	64
#define NOVEL 	128 // dont add velocity - archon moves especially

string sT__;

void() play_teleport =
{
//	local	float v;
//	local	string tmpstr;

#ifdef code_xents
// TDO: q2 snd
	if (self.rnd_ < 1)
	self.rnd_ = ceil(random() * 5);
	if (self.map == "Q2") self.rnd_ = 9;
/*
	if (self.rnd_ < 2)				self.noise = cvar_string("tel1");
	else if (self.rnd_ < 3)	self.noise = cvar_string("tel2");
	else if (self.rnd_ < 4)	self.noise = cvar_string("tel3");
	else if (self.rnd_ < 5)	self.noise = cvar_string("tel4");
	else		
*/
	self.noise = cvar_string(strcat("tel",sT__,ftos(self.rnd_)));

	sT__ = string_null; 		// fwd sound

#ifdef warning
																			if (warnings == "tsnd")
																			{
																				bprint(" *** telesnd: ");
																				bprint(ftos(self.rnd_));
																				bprint(", wav: ");
																				bprint(self.noise);
																				bprint(" e: ");
																				bprint(ftos(num_for_edict(self)));
																				bprint("\n");
																			}
#endifdef
#else
	self.rnd_ = random() * 5;
	if (self.rnd_ < 1)
		self.noise = "misc/r_tele1.wav";
	else if (self.rnd_ < 2)
		self.noise = "misc/r_tele2.wav";
	else if (self.rnd_ < 3)
		self.noise = "misc/r_tele3.wav";
	else if (self.rnd_ < 4)
		self.noise = "misc/r_tele4.wav";
	else
		self.noise = "misc/r_tele5.wav";
#endifdef

	sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	remove(self);
#ifdef code_painkeep_
	telesnd = world;
#endifdef
};

void(vector org) spawn_tfog =
{
#ifdef code_painkeep_
// Cataboligne - 9.3.11 - let holdable kill this sound.
	telesnd = 
#endifdef
	s = spawn();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;
	s.map = self.map;			// adv. telesound
#ifdef code_painkeep_
	s.rnd_ = self.rnd_;			// allow pk tele sound to link fwd & rev sounds
#endifdef

#ifdef code_pkbots
	signalnoise (other,s); // *bot
#endifdef
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

#ifdef xmonsters
// dont let generators get fragged by monsters they make
	if (self.owner.flags & FL_MONSTER)
	if (self.owner.owner.classname == "monster_generator") return ;
#endifdef

// TDO: solid escape in coop
#ifdef map_hack
	if (other.classname == "player") // we still want to BOOM a monster that wanders on the pad
	if (cvar("mh_coop_nospf"))
		return;
#endifdef

// frag anyone who teleports in on top of an invincible player
	if (other.classname == "player")
	{
		if (other.invincible_finished > time)
			self.classname = "teledeath2";
		if (self.owner.classname != "player")
		{	// other monsters explode themselves
			if (self.owner.health)	// opgrade - not ifdefed
			T_Damage(self.owner, self, self, 50000);
			return;
		}
		
	}
/* maybe an archon thing
	if (other.classname == OBSERVER)
	{
//		other.takedamage = DAMAGE_NO;
		return;
	}
*/
#ifdef code_painkeep_
	if (other.classname == "beartrap") // *pk - dont telefrag beartraps
		return;
#endifdef

	if (other.health)
	{
		T_Damage(other, self, self, 50000);
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

// Archon: newmis = 
	death = spawn();
	death.classname = "teledeath";
//	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
//	death.angles = '0 0 0';
	setsize(death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin(death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
};

void() teleport_touch =
{
local entity	t;
local vector	org;

	if (self.targetname)
	{
		if (self.nextthink < time)
		{
			return;		// not fired yet
		}
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

#ifdef code_archon
	if (self.aflag != -6) // archon forced teleport, but only once
#endifdef
// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;


#ifdef map_hack
// this is a mh converted teleport that leads back to the start map
// read intermission options - skip, q1, ibar
	if (!mh)
	if (self.map == "start")
	if (other.classname == "player") // only players can exit
	{
		self.target = "ostart2"; // go back to the start2 position
		if (cvar("sv_intermis") > 0)
		{
	#ifdef has_issues
			if (cvar("sv_intermis") == 1)
			{
				mh = self.oh;
				other.aiment = self; // save teleporter here
				execute_changelevel();
				return;
			}
	#endifdef
			nspawn = spawn();
			nspawn.think = eoe_scroll;
			nspawn.nextthink = time;
			nspawn.oh = self.oh;
			nspawn.owner = other;
		}
	}
#endifdef

	SUB_UseTargets ();

#ifdef code_painkeep_
// pk mode - select a random matched fwd / rev tele sound
	if (cvar("PK"))
	{
		self.rnd_ = ceil(random() * 4);
		sT__ = "r"; 		// rev sound
	}
#endifdef

// put a tfog where the player was
#ifdef code_xents
	if (!(self.spawnflags & T_STEALTH))
#endifdef
	spawn_tfog (other.origin);

#ifdef code_xents
	if (self.classname == "chaos_teleport") // chaos teleport sets movetarget - Cataboligne 1.23.8
	{
		if (self.aflag == -6)
		{
			other = self.enemy; // forced - must have correct target
			self.touch = SUB_Null;
		}
		t = self.movetarget;
		if (random() < self.aflag) self.movetarget = find_tdest(0);
		if (!t) return;
	}
//	else

	if (self.spawnflags & ALT_TARGET) // Cataboligne - 11.2.12 - alternate target teleport, for the Castle
	{
		e0__ = find (world,targetname,self.path);
		if (e0__)
		{
			if (self.group == "origin")
			if (e0__.origin == '0 0 0') t = find (world,targetname,self.target1);
		}
	}
	if (!t)
#endifdef

//#ifdef opgrade // note - we cannot block this off
	if (self.target) // fix for no target issue
//#endifdef

	t = find(world, targetname, self.target);
	if (!t)
#ifdef noobjerr
	{

	#ifdef xvars1
		if (cvar("svx_platdoorfail") < 0) // remove option - teleport_touch
		{
			remove(self);
			return;
		}
	#endifdef

#ifdef code_xents
		t = find_tdest(0);
#else
		t = find(world, classname, "info_player_deathmatch");
		if (!t) t = find(world, classname, "info_player_start");
#endifdef
		if (!t) return; // total fail

	}
#else
		objerror("couldn't find target");					//opgrade protected
#endifdef

#ifdef map_hack
// locate an "r" or "p" target (once)
	ltarget();
	if (self.movetarget) t = self.movetarget;
// + t.view_ofs - for dest that are offset from mh owner
	if (t.oh)
	if (! (t.oh.spawnflags & 16)) // NOTRIG flag
	{
		chaos_spawn(MOVETYPE_NONE, SOLID_NOT, 1, 0,  t.oh.origin + t.view_ofs, '-8 -8 -8', '8 8 8', '0 0 0', '0 0 0', "maphack_trigger", string_null, SUB_Null, 0.05, maphack_trigger, SUB_Null, t.oh, world);
		t.oh.hack_pdist = 0; // tell engine to display this right now
	}
#endifdef

// once we start using random dest, some ents have angles set
#ifdef opgrade
	if (t.classname != "misc_teleporttrain")			// dont inherit angles from this
	if (!t.mangle_y)
	if (t.angles_y)
		t.mangle = t.angles;
#endifdef

#ifdef code_painkeep_
			ClearSpawnPoint(t);
#endifdef
// spawn a tfog flash in front of the destination
#ifdef code_xents
	if (self.classname == "chaos_teleport" && t.classname != "info_teleport_destination") // - Cataboligne 1.23.8 - because chaos going to non tdest has no mangle
		makevectors (other.angles);
	else
#endifdef
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

#ifdef code_xents
	if (self.classname == "chaos_teleport") // chaos teleport attemp to avoid fallen into void - Cataboligne 9.23.13
	{
		org_z = org_z + other.mins_z;
		gsf = 250;
		while ((pointcontents(org) == CONTENT_SOLID) && gsf > 0)
		{
			org_z = org_z + 2;
			gsf = gsf - 1;
		}
	}

	if (!(self.spawnflags & T_STEALTH))
#endifdef
	spawn_tfog (org);
#ifdef code_xents
	if (!(self.spawnflags & T_NODEATH))
#endifdef
	spawn_tdeath(t.origin, other);

#ifdef code_painkeep_
	self.rnd_ = 0;			// clear for next
#endifdef

#ifdef code_pkbots
	if (other.enemy.group == "pk*bot")
	{
		enemy_touched ();
	}
#endifdef

// move the player and lock him down for a little while
	if (!other.health)
	{
		other.origin = t.origin;
#ifdef code_xents
		if (!(self.spawnflags & NOVEL))
#endifdef
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}

	setorigin(other, t.origin);
#ifdef code_xents
// Cataboligne - 10.31.12 - non directional landing - keep current facing, great with stealth
	if (! (self.spawnflags & NONDIR))
#endifdef
	other.angles = t.mangle;

#ifdef code_pkbots
	if (other.group == "pk*bot")
	{
		bot_touched ();
	}
#endifdef

	if ((other.classname == "player") || (other.class_select == "class_monster"))		// fix monster teleport issues
	{
#ifdef code_xents
		if (! (self.spawnflags & NONDIR))
#endifdef
		other.fixangle = 1;		// turn this way immediately
		other.teleport_time = time + 0.7;
		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;
#ifdef code_xents
		if (!(self.spawnflags & NOVEL))
#endifdef
		other.velocity = v_forward * 300;

#ifdef code_painkeep_
		other.bt_immune_time = time + BT_BUFFER;
#endifdef
	}
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination(.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = string_null;
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
#ifdef noobjerr
	{

	#ifdef xvars1
		if (cvar("svx_platdoorfail") < 0) // remove option - info_teleport_destination
		{
			remove(self);
			return;
		}
	#endifdef
// later - set a random targetname from some ?
// for now do nothing
	}
#else
		objerror("no targetname");					//opgrade protected
#endifdef
};

void() teleport_use =
{
	self.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.

Flags:
"player_only"		 		only players will teleport
"silent"				 		silences teleporting - still has flash & tele sound
"random" (Zerstorer)		sent to a random desination (info_teleport_random).  Must set
"count"						flag to number of  info_teleport_random in map.
"stealth" (Zerstorer)  	eliminates the particle flash and noise when an entity is teleported (still has hum)
"nondir" (chaos)			dont change direction, works well with stealth
"nodeath"					dont spawn a tele death - no telefrag (this could have issues!)

to make a teleport give the appearance of contiguous map space in 2 different areas use:
silent, stealth, nondir, nodeath
going both ways
*/
void() trigger_teleport =
{
	local vector o;

	InitTrigger();
	self.touch = teleport_touch;
	// find the destination 
	if (!self.target)
#ifdef noobjerr
	{

	#ifdef xvars1
		if (cvar("svx_platdoorfail") < 0) // remove option - trigger_teleport
		{
			remove(self);
			return;
		}
	#endifdef
// later - pick random target, but it has to be find-able - may have to make a target
// for now teleport_touch can handle no target
	}
#else
		objerror("no target");					//opgrade protected
#endifdef
	self.use = teleport_use;

	if (!self.noise) self.noise = "ambience/hum1.wav";		// allow sound override

	if (!(self.spawnflags & T_SILENT))
	{
		precache_sound("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
#ifdef code_xents
// q2 mode is a point ent - no location on maxs
	if (self.map == "Q2") o = self.origin;
#endifdef

		ambientsound(

#ifdef map_hack
		mh.origin +
#endifdef
		
			o, self.noise,0.5 , ATTN_STATIC);
	}
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	InitTrigger();
	self.touch = trigger_skill_touch;
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = string_null;
		SUB_UseTargets ();
		remove(self);
	}
	else
	{
		if (self.message != string_null)
		{
			centerprint (other, self.message);
			sound(other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered(.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound("misc/talk.wav");
	InitTrigger();
	self.touch = trigger_onlyregistered_touch;
#ifdef code_pkbots
	self.istrigger = 1;
	self.th_weight = triggerweight; // *bot
#endifdef
};

//============================================================================

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (other.takedamage)
	{
#ifdef code_xents
// falling water test
		if (self.aflag == -666)
		{
			if (self.attack_finished < time) self.attack_finished = time + self.delay;
			else return;
		}
		else
#endifdef
		{
		self.solid = SOLID_NOT;
		self.think = hurt_on;
		self.nextthink = time + 1;
		}
#ifdef code_xents
		if (self.deathtype) other.deathtype = self.deathtype; // Cataboligne - 10.19.12 - obit message special
		if (self.deathtype == "lavadead")  // Cataboligne - 10.28.12 - handle lava beings when trigger damage is lava
			T_FireDamage (other,self,self,self.dmg);
		else
#endifdef
		T_Damage(other, self, self, self.dmg);
#ifdef HIPNOTIC
//MED 12/01/96 added count stuff
		if (self.cnt > 0)
		{
			self.cnt = self.cnt - 1;
			if (self.cnt == 0)
			{
				self.touch = SUB_Null;
				self.nextthink = time + 0.1;
				self.think = SUB_Remove;
			}
		}
#endifdef
	}

//	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
"cnt" default infinite, how many times to trigger
*/
void() trigger_hurt =
{
	InitTrigger();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
#ifdef HIPNOTIC
//MED 12/01/96 added count stuff
	if (self.cnt == 0)
		self.cnt = -1;
#endifdef
};

//============================================================================

#define PUSH_ONCE 1

void() trigger_push_touch =
{
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound(other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
			}
		}
#ifdef code_pkbots
		else
		{
			if (other.group == "pk*bot")
			{
				if ((self.movedir_x < 0.1) && (self.movedir_y < 0.1))
				{
					other.velocity_x = ((other.velocity_x + (80 * random ())) - 40);
					other.velocity_y = ((other.velocity_y + (80 * random ())) - 40);
				}
				if (other.fly_sound < time)
				{
					other.fly_sound = (time + 1.5);
					sound (other,CHAN_AUTO,self.noise,TRUE,ATTN_NORM);
				}
			}
		}
		if (other.enemy.group == "pk*bot")
		{
			enemy_touched ();
		}
#endifdef
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
void() trigger_push =
{
	InitTrigger();
	precache_sound("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (!self.speed)
		self.speed = 1000;
	if (!self.noise) self.noise = "ambience/windfly.wav"; // override sound allow
#ifdef code_pkbots
	self.istrigger = 1;
	self.th_weight = trigpushweight; // *bot
#endifdef
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;

#ifdef HIPNOTIC
//MED 12/01/96 added count stuff
	if (self.cnt>0)
	{
		self.cnt = self.cnt - 1;
		if (self.cnt == 0)
		{
			self.touch = SUB_Null;
			self.nextthink = time + 0.1;
			self.think = SUB_Remove;
		}
	}
#endifdef
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
"cnt" default infinite, how many times to trigger
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
#ifdef HIPNOTIC
//MED 12/01/96 added count stuff
   if (self.cnt == 0)
      self.cnt = -1;
#endifdef
	InitTrigger();
	self.touch = trigger_monsterjump_touch;
};


#ifdef code_xents
// Archon expanded triggers


#endifdef
/*QUAKED trigger_hurt_switch (.5 .5 .5) ? START_OFF
Switchable - when target is called .touch will toggle
wait - time between toggles, if -1 switch is disabled after 1 call
delay - time elapse before toggle when target called
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
frags - take away this many upon death, default 0
noise*  - custom death messages to give

spawnflags & 1 - start off
deadflag & 2 - use noenvcide if enabled - frags must be set, default is 1

custom message = self.noise - one obituary string
deadflag & 1 - print target name first
random:
noise2, noise3, noise4 - string for obituary
cnt = rnd chance of 2 vs 3 - default 50%
style = separate rnd chance of 4 if set - default 10%
*/

void() hurt_switch =
{
	if (self.classname == "hurt_trigger_delay") // delayed effect
	{
		if (self.enemy)
		if (self.enemy.touch == hurt_touch)
			self.enemy.touch = SUB_Null;
		else
			self.enemy.touch = hurt_touch;
		remove(self);
		return;
	}

	if (self.attack_finished > time) return; // cant toggle right now

// convert from old method - REMOVE - hurt_switch is not on any maps
/*
	if (self.noise) self.stack4 = self.noise;
	if (self.noise1) self.stack1 = self.noise1;
	if (self.noise2) self.stack2 = self.noise2;
	if (self.noise3) self.stack3 = self.noise3;
*/

// setup msg - done in map ent
// this selects amongst the possible messages when first loading on map
//	self.deadflag = self.deadflag | 1;
/*
	TDO: hurt_switch 	generic obit msg from trigger strings - redo as cdt

	if (self.stack2 != string_null && self.stack3 != string_null)
	{
		if (self.button1 <= 0) self.button1 = 0.5;
		if (self.button2 <= 0) self.button2 = 0.1;
		if (random() < self.button1)
			self.stack16 = self.stack2; //" turned into hot slag";
		else
			self.stack16 = self.stack3; // " visits the Volcano God";
		if (self.stack4 != string_null)
		if (random() < self.button2)
			self.stack16 = self.stack4; // " is playing geologist again";
	}
	else
	if (self.stack16 == string_null && self.stack2 != string_null || self.stack3 != string_null)
	{
		if (self.stack2 != string_null) self.stack16 = self.stack2;
		if (self.stack3 != string_null) self.stack16 = self.stack3;
	}
	if (self.stack16 != string_null)
		self.class_select = "CDM"; // custom death msg
*/

	if (self.wait)
	{
		if (self.wait < 0)
			self.use = SUB_Null;
		else
			self.attack_finished = time + self.wait;
	}

	if (self.delay)
	{
		local entity e;
		e = spawn();
		e.classname = "hurt_trigger_delay";
		e.think = hurt_switch;
		e.nextthink = time + self.delay;
		e.enemy = self;
		return;
	}

	if (self.touch == hurt_touch)
		self.touch = SUB_Null;
	else
		self.touch = hurt_touch;
};

void () trigger_hurt_switch =
{
	InitTrigger ();
	if ((self.spawnflags & 1) && self.targetname != string_null) // if no targetname is given this becomes a regular hurt trigger!
		self.touch = SUB_Null;
	else
		self.touch = hurt_touch;

	if (!self.dmg)
		self.dmg = 5;

	if (self.deadflag & 2)
	if (!self.frags)
		self.frags = 1;

	if (self.targetname)
		self.use = hurt_switch;
};