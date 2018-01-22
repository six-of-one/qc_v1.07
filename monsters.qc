/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink;
//		<code>
// };


/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
//	local entity 	ent, otemp, stemp;	// fx_warning

// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

/*

qc++ monster_start

	unified start routine - 1 call does it all

	sub replace the old calls like this
*/

#define walkmonster_start 		monster_start(0)
#define flymonster_start 			monster_start(FL_FLY)
#define swimmonster_start 		monster_start(FL_SWIM)

void() monster_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	self.view_ofs = '0 0 25';

#ifndef nodprint
	if (self.flags & FL_FLY)
	{
		if (!walkmove(0,0))
		{
			dprint ("flymonster in wall at: ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
	}
	else
#endifdef	
	if (self.flags & FL_SWIM)
	{
		self.view_ofs = '0 0 10';
	}
	else // walkers
	{
		self.origin_z = self.origin_z + 1;	// raise off floor a bit
		droptofloor();

		if (!self.yaw_speed)
			self.yaw_speed = 20;

#ifndef nodprint
		if (!walkmove(0,0))
		{
			dprint ("walkmonster in wall at: ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
#endifdef
	}

	if (!self.yaw_speed)
		self.yaw_speed = 10;

	self.use = monster_use;
	self.flags = self.flags | FL_MONSTER;
#ifdef code_xents
	self.max_health = self.health;
#endifdef
	
	self.pausetime = 99999999;
	self.th_stand();

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!(self.flags & FL_FLY))
			self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
#ifndef nodprint
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
#endifdef

		if ((self.flags & FL_SWIM) ||
// this used to be an objerror
			self.movetarget.classname == "path_corner")
		{
			self.pausetime = 0;
			self.th_walk();
		}
	}

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};


// a think() to this will default to walkmonster - self.flags will have to be set as specced below for fly or swim
// flg - FL_SWIM or FL_FLY

#ifdef local_test
void() remove_monster;
#endifdef

void(float flg) monster_start =
{

// this fires specific code in monster_go
	self.flags = self.flags | flg
#ifdef HIPNOTIC
					| FL_MONSTER
#endifdef
	;

// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = monster_go;
	total_monsters = total_monsters + 1;

/// NOT for frame testing !!! - remove when resuming frd1
#ifdef local_test
//	self.think = remove_monster;
#endifdef

// IMP: monster DM override goes here - use overload on norm monsters
#ifdef code_xents
	if (self.classname == "monster_start")
	{
		self.classname = self.classvn;
//		setmodel(self, self.model); // pre load now sets these
//		if (self.pos2) setsize(self, self.pos1, self.pos2); // if defined pos{1,2} used for size override
	}
#endifdef

};

//============================================================================

// some monster modules may not be compiled in - or map monsters may be removed by xvar
// we need to fire all monster targets or SP maps may fail

void() remove_monster =
{
	monster_death_use(); // in case monster has triggers & we are in SP
	remove(self);	
};

//============================================================================

/*

qc++	Monster_JumpTouch

Jump handle for demon and dog is same codes

vars:

self.jump_vel - do damage when vlen(velocity) > this value
self.dmg - damage to do when touching a thing that takes damage
					- default 10 health pts
'
also uses:

self.dmg_take			"ldmg_"
self.jump_flag			"jump_vel"

Multi here with:

*/

#ifdef quakemonsters

void() dog_leap1;
void() dog_run1;
void() demon1_jump1;
void() demon1_jump11;

#endifdef

#ifdef xmonsters

void() blarg_leap1;
void() blarg_run1;
void() raptor1_jump1;
void() raptor1_run1;

#endifdef

#define jumptouch_rep(jumpclass,jumpthinkone,jumpthinktwo) if (self.classname == #jumpclass) { if (!checkbottom(self)) { if (self.flags & FL_ONGROUND) self.think = jumpthinkone; return; } self.think = jumpthinktwo; }

void()	Monster_JumpTouch =
{
//	local	float	ldmg;

	if (self.health <= 0)
		return;

	if (!self.dmg) self.dmg = 10;

	if (other.takedamage)
	{
		if ( vlen(self.velocity) > self.jump_vel)
		{
			self.ldmg_ = self.dmg + 10*random();
			T_Damage (other, self, self, self.ldmg_);	
		}
	}

	self.touch = SUB_Null;
	self.nextthink = time + 0.1;

#ifdef quakemonsters

	jumptouch_rep(monster_demon1, demon1_jump1, demon1_jump11);
	jumptouch_rep(monster_dog, dog_leap1, dog_run1);

#endifdef

#ifdef xmonsters

// check these 2 vs. demon jump sequence
	jumptouch_rep(monster_blarg, blarg_leap1, blarg_run1);
	jumptouch_rep(monster_raptor, raptor1_jump1, raptor1_run1);

#endifdef

/*
	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.think = demon1_jump1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.think = demon1_jump11;
*/

};

//============================================================================

/*

qc++ fr_stand9

a few monsters have $stand1 - $stand9 as the first nine frames - this does that

*/

$frame	stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

framerloop($stand1, $stand9, fr_stand9, 0.1,

	ai_stand();
	if (self.classname == "monster_ogre") frame_arb($stand5,if (random() < 0.2) sound(self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE));
);


#ifdef monsters_plus__
/*
================
SummonMonster

Badder monsters (super & super extra mad) have a chance to summon help

mark I - Super Shalrath could summon up to 3 spike mines when idle
		 - 0.1 - gave deathknight, 6 spike wizard same power
mark II - added more monsters (wizard & fluffy) and extended to calling for various help while on the move
		  - 0.2 - tfog & tdeath added for non spike mines, better random away from summoner
================
*/

// NOTE: called by other monsters
// set spike mines, or summon other monsters

// ms - if not null, summon this - must be a valid spawn func classname

// - if null, uses spike mine limit - 2 + skill
// - if non null, limit is not checked here

void(string ms) SummonMonster =
{

	local entity e;
	local vector v;

// mine limit in aflag for mine makers
// can make 3 mines on skill 1

	if (ms == string_null) // default to spike mine & check limits
	{
		ms = "trap_spike_mine";

		if (self.aflag >= 2 + skill) // SV_MINELIM
		{
// count them - some could have exploded
			self.aflag = cnt_ent(world, classname,  ms);

// fail - he has made max number of mines
			if (self.aflag >= 2 + skill) return; // SV_MINELIM - 3 mines
		}
	}

// luck was not his this time, go back
	if (skill > 2) if (random() > 0.5) return;
	else if (random() > 0.15) return; // SV_SETMINE - 0.15 % chance

// make a new mine - YAY!

	e = spawn();
	e.classname = e.wad = ms; //monster_id(CB_M_SPIKEMINE, MON_FUNC_REG); // get spawn func
	item_call_save(e, e.classname);

	if (self.charmer) // charmed monsters that summon make minons charmed as well
	{
		e.charmer = self.charmer;
		e.charmed = 1;
		e.effects = e.effects | self.effects; // copy dimlight or other effects if on
	}
	e.owner = self; // so we can count them

// IMP: when gathering all random loc fn(), nearby in a radius & not in solid, monster or player
	v = self.origin;
	v_z = v_z + 32;
	v_x = v_x + crandom() * 60;
	if (v_x < self.origin_x) v_x = v_x - 50; // make sure we clear the summoner
	else v_x = v_x + 40;
	v_y = v_y + crandom() * 60;
	if (v_y < self.origin_y) v_y = v_y - 50;
	else v_y = v_y + 40;
	setorigin(e, v);
//	random_monster_location(v); // no good - this moves self

	if (ms != "trap_spike_mine")
	{
		spawn_tfog (e.origin);
		spawn_tdeath(e.origin, e); // test - make sure he doesnt telefrag his summoner!
	}

	self.aflag = self.aflag + 1;
	self.count = self.count + 1;
};
#endifdef
