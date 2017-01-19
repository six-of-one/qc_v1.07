 /* ::-::
 *
 * Cataboligne
 *
 * file: train2d.qc 
 *
 * date: 017.1.18
 *
 * qc - painkeep module - 2d trains qc
 *
 */

/*
func_train_2d
Version 1.01

Written by Matt Houser
fisty@canweb.net

Based on id softwares func_train

Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

2d changes:
* on use (n), train will progress to targetn
* stops at all path_corners

use "cnt" "..." in the trigger to tell which dir (1 or 2) the button tells
the train to go

path_corners need a "target1" "..." and "target2" "..." instead of the single
"target" "..."

*/


void(float n) func_train_2d_next;
void() func_train_2d_find;
void() func_train_2d_wait;

void() func_train_2d_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
};

void() func_train_2d_use =
{
	   if (!other.cnt)
		{
#ifdef warning
																		if (WARNING & 128) bprint("\n*** warning:\nfunc_train_2d_use: button does not specify direction in cnt\n\n");
#endifdef

	#ifdef xvars1
			if (cvar("svx_platdoorfail") < 0) // remove option
				remove(self);
	#endifdef
			return;
		}

	   if (self.think == func_train_2d_find)
	        func_train_2d_next(other.cnt);
	   else if (self.wait)
	        func_train_2d_next(other.cnt);
};

void() func_train_2d_wait =
{
	   self.nextthink = self.ltime + -1;
	   self.wait = -1;
	   sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
};

void(float n) func_train_2d_next =
{
//	local entity	targ;

	   // find the one we're at
	   e0__ = find (world, targetname, self.target);
	   if (n == 1)
	   {
	        if (e0__.target1)
	             self.target = e0__.target1;
	        else
			  {
#ifdef warning
																		if (WARNING & 128) bprint("\n*** warning:\nfunc_train_2d_next: target? fail\n\n");
#endifdef

	#ifdef xvars1
					if (cvar("svx_platdoorfail") < 0) // remove option
						remove(self);
	#endifdef
					return;
			  }
	   }
	   else if (n == 2)
	   {
	        if (e0__.target2)
	             self.target = e0__.target2;
	        else
			  {
#ifdef warning
																		if (WARNING & 128) bprint("\n*** warning:\nfunc_train_2d_next: target? fail\n\n");
#endifdef
	#ifdef xvars1
					if (cvar("svx_platdoorfail") < 0) // remove option
						remove(self);
	#endifdef
					return;
			  }
	   }

	   // find the next one in sequence
	   e0__ = find (world, targetname, self.target);

	   if (!self.target)
			{
#ifdef warning
																		if (WARNING & 128) bprint("\n*** warning:\nfunc_train_2d_next: target? fail\n\n");
#endifdef
	#ifdef xvars1
					if (cvar("svx_platdoorfail") < 0) // remove option
						remove(self);
	#endifdef
					return;
			}

	   self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	   SUB_CalcMove (e0__.origin - self.mins, self.speed,
	        func_train_2d_wait);
};

void() func_train_2d_find =
{
//	local entity	targ;

	   e1__ = find (world, targetname, self.target);
	   //self.target = targ.target;
	setorigin (self, e1__.origin - self.mins);
};

void() func_train_2d =
{	
	   if (!self.speed)
		self.speed = 100;
	if (!self.target)
			{
#ifdef warning
																		if (WARNING & 128) bprint("\n*** warning:\nfunc_train_2d_next: target? fail\n\n");
#endifdef
	#ifdef xvars1
					if (cvar("svx_platdoorfail") < 0) // remove option
						remove(self);
	#endifdef
					return;
			}
	if (!self.dmg)
		self.dmg = 2;

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.cnt = 1;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	   self.blocked = func_train_2d_blocked;
	   self.use = func_train_2d_use;
	self.classname = "train";

	setmodel (self, self.model);


// Cataboligne - 6.3.14 - prelim for altarbeta floaty rock clouds deal
	if (self.spawnflags & 16)
		setmodel (self,self.mdl);

	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	   self.think = func_train_2d_find;
};
