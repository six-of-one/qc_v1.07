/* ::-::
 *
 * Cataboligne
 *
 * file: beartrap.qc 
 *
 * date: 016.2.25
 *
 * qc - painkeep module - beartrap qc
 *
 */


#define	PK_BT_TIMETOFOLLOW	self.button7
#define	PK_BT_DMG	self.dmg
#define PK_BT_TIME	self.button6



.entity beartrap_target;
.float beartrapdmg_time;

void(string gibname, float dm) beartrap_throwGib =
{
	local	entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.pk_currentitem = PK_IT_BEARTRAP;
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
//	new.solid = SOLID_NOT;
	new.avelocity_x = random() * 600;
	new.avelocity_y = random() * 600;
	new.avelocity_z = random() * 600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 3 + random() * 3;
//	new.frame = 0;
//	new.flags = 0;
	new.classname = "beartrap_gib";
	new.owner = self.owner;
	new.think = SUB_Remove;

	// PAINKEEP SPLASH Make this entity splash
#ifdef painkeep_splash
	AddToSplash(new);
#endifdef
};

// Remove the beartrap from play
void() beartrapDie =
{
	local float numOfGibs;

	beartrap_throwGib("progs/beargib1.mdl", -50);
	beartrap_throwGib("progs/beargib2.mdl", -50);
	beartrap_throwGib("progs/beargib3.mdl", -50);

	numOfGibs = random() * 5;

	local float dam;

	while(numOfGibs > 0)
	{
	  dam = random() * -50;
	  beartrap_throwGib("progs/beargib4.mdl", dam);
	  numOfGibs = numOfGibs - 1;
	}

	sound(self, CHAN_AUTO, "weapons/btrap/btrap_3.wav", 1, ATTN_NORM);

	remove(self);
};

$frame bear01 bear02 bear03

// Follow the trapped person around and damage them
void() beartrapFollow =
{
	// SWP: 14/05/97 - check if the player has "respawned" or dead.
	if (!(self.beartrap_target.beartrap_time) || 
#ifdef unsused
		self.beartrap_target.disconnectPlayer || 
#endifdef
		self.beartrap_target.deadflag || self.beartrap_target.health < 0) // Cataboligne - 5.20.10 - beartrap single player code - targeting monsters
	{ // player is dead or respawned...
//		remove(self);
		beartrapDie(); // die when done instead of dissapearing
		return;
	}

	if (self.origin != self.beartrap_target.origin || self.angles != self.owner.angles)
	{
		setorigin(self, self.beartrap_target.origin);
		self.dodmg = TRUE;
		if (self.angles != self.owner.angles)
			self.angles = self.owner.angles;
	}

	self.beartrap_time = self.beartrap_time + 0.1;
	self.beartrapdmg_time = self.beartrapdmg_time + 0.1;

	// Inflict damage every rel if the target has moved
	if (self.beartrapdmg_time >= 0.5)
	{
		if (self.dodmg)
		{
			T_Damage(self.beartrap_target, self, self.owner, PK_BT_DMG);
			self.dodmg = FALSE;
		}

		self.beartrapdmg_time = 0;
	}

	if (self.beartrap_time > PK_BT_TIMETOFOLLOW)
	  self.think = beartrapDie;
};

void() btf =
{
	beartrapFollow();

	self.nextthink = time + 0.1;
};

/*
void()	btf_1 =	[$bear01, btf_2 ] {beartrapFollow();};
void()	btf_2 =	[$bear02, btf_3 ] {beartrapFollow();};
void()	btf_3 =	[$bear03, btf ] {setmodel (self, "progs/bearbld.mdl");};
*/

void()	btf_1 =	[$bear02, btf_2 ] {beartrapFollow();};
void()	btf_2 =	[$bear03, btf ] {setmodel (self, "progs/bearbld.mdl");};

void() beartrapTouch =
{

	if (!deathmatch) // Cataboligne - 5.20.10 - beartrap single player code - turn off player target, allow monster target
	if (other.classname == "player")
	{
			if (cvar("sv_sp_bt_noplayer")) return;
	}

//	if (other.classname != "pk*bot") // *bot - bots get bit
	if (other.classname != "player")
//	if ((!other.flags & FL_MONSTER) || !ENHANCED) // monsters in dm now
#ifdef opgrade
	if (!(other.flags & FL_MONSTER)) // monsters in dm now
	  return;

#ifdef HIPNOTIC
	if (other.charmer && other.charmer == self.owner) // dont target owners helpers
	  return;
#endifdef
#else
	  return;
#endifdef


	// The owner of the beartrap is immune for a few rels
	if ((other == self.owner) && (self.beartrap_time > time))
		return;

	// People are immue to the bt a few rels after teleporting/spawning
	if (other.bt_immune_time > time)
	  return;

	other.beartrap_time = 1; // SWP: 14/05/97
	self.beartrap_target = other;
	self.beartrap_time = 0;
	self.beartrapdmg_time = 0;
	//self.think = beartrapFollow;
	self.think = btf_1;
	self.nextthink = time + 0.1;
	self.touch = SUB_Null;

	sound(self, CHAN_AUTO, "weapons/btrap/btrap_1.wav", 1, ATTN_NORM);
};



void() beartrap_dropBearTrap =
{
	local entity bt;

	if (self.pk_beartrapammo <= 0)
		return;

/*
	if (!self.button0)
	{
		player_run ();
	  return;
	}
*/

	bt = spawn();

// defs - pk 3.0 implement
	bt.button6 = 90;		//PK_BT_TIME = 90; // def
	bt.button7 = 15;		// PK_BT_TIMETOFOLLOW = 15;
	bt.dmg = 2;					// PK_BT_DMG = 2;
	bt.max_health = 50;
	
//		self.noise3 = "weapons/btrap/bdrop_1.wav";

	if (self.eweapon)
	{
		bt.button6 = self.eweapon.button6;
		bt.button7 = self.eweapon.button7;
		bt.dmg = self.eweapon.dmg;
		bt.max_health = self.eweapon.max_health;
//		self.noise3 = self.eweapon.noise3;
	}


	bt.owner = self;
	bt.movetype = MOVETYPE_TOSS;
	bt.solid = SOLID_TRIGGER;
	bt.classname = "beartrap";
	bt.takedamage = TRUE;
	bt.health = bt.max_health;
	bt.th_die = SUB_Null;
	if (bt.health > 0) bt.th_die = beartrapDie;
	bt.netname = "Bear Trap";

	// For the correct death messages
	bt.pk_currentitem = PK_IT_BEARTRAP;
	bt.weapon = IT_AXE;

	// Used to give a few rels go get away from the trap
	bt.beartrap_time = time + 3;

	if (bt.button6 > 0)
	{

	// Kill it after 90 rels if nobody walks over it
		bt.think = beartrapDie;
		bt.nextthink = time + bt.button6;
	}

	setmodel (bt, "progs/beartrap.mdl");
	setsize (bt, '-25 -24 -0', '25 25 8');

	setorigin (bt, self.origin);

	// Throw away from you
	makevectors (self.angles);
	bt.velocity = (v_forward * (200 + random() * 100)) + (v_up * (200 + random() * 100));

	bt.touch = beartrapTouch;

	sound(self, CHAN_AUTO, "weapons/btrap/bdrop_1.wav", 1, ATTN_NORM);

	// PAINKEEP SPLASH Make this entity splash
#ifdef painkeep_splash
	AddToSplash(bt);
#endifdef
};

