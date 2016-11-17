 /* ::-::
 *
 * Cataboligne
 *
 * file: bolt.qc 
 *
 * date: 016.3.5
 *
 * qc - painkeep module - chain thunderbolt qc
 *
 */

// 11.6.14 - different cells to use up when target is a monster


void() bolt_findNextTarget;
void(vector org, entity target, entity boltOwner, vector endPos, float first1, float dam) bolt_doDamage;
float(entity check, entity checkFor) bolt_checkForLoops;
void(entity boltOwner) bolt_createTimeoutEntity;
void() bolt_timeoutNextEntity;
void(entity boltTarget) bolt_removeTarget;
float(entity targetEntity) bolt_infront;


// Cataboligne - 11.4.13 - retool for con_ammo and infinite...finally

void() bolt_fire =
{
	local float cells;

	cells = self.ammo_cells;
#ifdef code_xents
	e_use_ammo();
#else
	if (cells == 0) cells = 100;
#endifdef

	if (cells < 2)
	{
		bolt_removeTarget(self.bolt_target);

		self.bolt_target = world;  // disable the firing target...
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
// already set cells val above
// note - on inifinte ammo setting this val is MAX !!!
		self.ammo_cells = 0;

		bolt_removeTarget(self.bolt_target);

	 	self.bolt_target = world;  // disable the firing target...
		W_SetCurrentAmmo ();
		discharged = 1; // wetsuit deal
		T_RadiusDamage (self, self, 35*cells, world);
		discharged = 0;
		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/clight/clight_1.wav", 1, ATTN_NORM);
		self.t_width = time + 1;
	}
	self.punchangle_x = -2;
//	cam_punch(); // Cataboligne - 5.13.10 - cam purify - nullify fire punchangle if in cam view

//	org = self.origin + '0 0 16';

	bolt_findNextTarget();

	if (self.bolt_target == world && cells >= 2)
	{ // Can't find any targets at all.
	  // fire as normal...
	  local vector org, endpos;

#ifdef code_xents
		e_use_ammo();
#else
		self.currentammo = self.ammo_cells = self.ammo_cells - 2; //ammo_con(2, self, string_null);
#endifdef

		self.punchangle_x = -2;
//		cam_punch(); // Cataboligne - 5.13.10 - cam purify - nullify fire punchangle if in cam view

#ifdef code_viswep
		org = self.origin + v_right * VWY_CHTHUNDER + v_forward * VWX_CHTHUNDER + v_up * VWZ_CHTHUNDER;
#else
		org = self.origin + '0 0 16';
#endifdef

		traceline (org, org + v_forward*600, TRUE, self);
	  endpos = trace_endpos;

	  WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	  WriteByte (MSG_BROADCAST, TE_LIGHTNING3);
	  WriteEntity (MSG_BROADCAST, self);
	  WriteCoord (MSG_BROADCAST, org_x);
	  WriteCoord (MSG_BROADCAST, org_y);
	  WriteCoord (MSG_BROADCAST, org_z);
	  WriteCoord (MSG_BROADCAST, endpos_x);
	  WriteCoord (MSG_BROADCAST, endpos_y);
	  WriteCoord (MSG_BROADCAST, endpos_z);

		traceline (self.origin,	endpos + v_forward*4, FALSE, self);

	  // if hit a entity that can take damage & can see & is not invisible, then target for next time.
	  if (trace_ent.takedamage)
	  if (!(trace_inopen && trace_inwater))
	  if (trace_ent.health > 1)
	  if (trace_ent.classname != "player" || !(trace_ent.items & IT_INVISIBILITY))
	  {
	    self.bolt_target = trace_ent;
	    self.bolt_targetTimeout = time + 0.5; // set target timeout

	    // entity conduit timeout if the entity dies & handles being a conduit
	    self.bolt_target.bolt_conduitTimeout = time + 0.5;

	    // set it as a gib conduit entity
//	    self.bolt_target.flags = self.bolt_target.flags | FL_GIBCONDUIT;
	  }

	  LightningDamage (self.origin, endpos + v_forward*4, self, 15);
	}

	// check if the conduit target is dead?
	if (self.bolt_target)
	if (self.bolt_target.health <= 0)
	{
	  // set the die timeout.
	  self.bolt_target.bolt_targetTimeout = time + 0.5;
	}

	if (self.bolt_target == world)
	if (self.weapon == IT_AXE)
	if (self.pk_currentitem == PK_IT_CLIGHT)
	if (self.bolt_targetTimeout < time + 0.2)
	{
		self.bolt_targetTimeout = time + 0.2; // set modal timeout
	}

	if (self.bolt_changeModelTimeout > time)
	{
		self.bolt_changeModelTimeout = self.bolt_changeModelTimeout + 0.21; // set the weapon model change back..
	}
	else
	{
		self.bolt_changeModelTimeout = time + 1; // set the weapon model change back..
	}
};


void() bolt_findNextTarget =
{
	local entity boltorg, head, targetEntity;
	local	vector org, endPos;
	local float first2, dist, tempDist;
	local float maxTargets; // the lighting will only last for 20 targets..
	local float loopBlow, cellsToBlow;

	loopBlow = FALSE;

	first2 = TRUE;
	boltorg = self;
	targetEntity = boltorg.bolt_target;
	maxTargets = 20;
	cellsToBlow = 0;

	// check for a loop... if a loop blow...
	// also Check all current targets are still in line of fire.
	while(targetEntity != world && maxTargets >= 1)
	{
		// check if still a valid target..

		org = boltorg.origin + '0 0 16';

	  traceline(org, targetEntity.origin, TRUE, boltorg);

	  dist = vlen(boltorg.origin - targetEntity.origin);

	  if (trace_fraction >= 1 && // can see...
	  	!(trace_inopen && trace_inwater) && // can't see the target if it goes tho water & air.
	    dist <= 600 && // within distance
	    (!first2 || bolt_infront(targetEntity)) && // in front if the first target..
//		  (first2 || targetEntity.health > 0) &&  // not dead... (the first  target always acts as a conduit...)
			(targetEntity.solid != SOLID_NOT) && // make shore it's solid...
	  	(targetEntity.classname != "player" || !(targetEntity.items & IT_INVISIBILITY))) // not invisible..
	  {

		  // check if loop
	    if (targetEntity == self)
	    {
				loopBlow = TRUE;
	    }

	    cellsToBlow = cellsToBlow + targetEntity.ammo_cells;

	    if (first2) // reset the target timeout...
	    {
	      boltorg.bolt_targetTimeout = time + 0.5;

	      // set it as a gib conduit entity
//	      targetEntity.flags = targetEntity.flags | FL_GIBCONDUIT;
	    }
	    else
	    {
	      bolt_createTimeoutEntity(boltorg);
	    }

	    // entity conduit timeout if the entity dies & handles being a conduit
	    targetEntity.bolt_conduitTimeout = time + 0.5;

	    first2 = FALSE; // get the next target
	    boltorg = targetEntity;
	    targetEntity = boltorg.bolt_targetNext;
	    maxTargets = maxTargets - 1;
	  }
	  else
	  {
	  	// disable next target... (the rest of the path will time out if not used...)
			if (first2)
			{
				bolt_removeTarget(targetEntity);
			  boltorg.bolt_target = world;
			}
	    else
	    {
			  boltorg.bolt_targetNext = world;
	    }

	    targetEntity = world;
	  }
	}

	if (maxTargets == 19) // only one target, check if firing at each other
 	if (self.bolt_target.bolt_target == self) // & other player is firing back
	{
	  cellsToBlow = cellsToBlow + targetEntity.ammo_cells;
	  loopBlow = TRUE;
	}

	first2 = TRUE;
	boltorg = self;
	targetEntity = boltorg.bolt_target;
	maxTargets = 20;


	// do damage to current target list...
	while(targetEntity)
	{
	  // do damage...
		if (loopBlow)
		{
			// loop.. blow
	    targetEntity.ammo_cells = 0;

			self.ammo_cells = cellsToBlow;
		  bolt_doDamage(org, targetEntity, boltorg, trace_endpos, first2, cellsToBlow);
			self.ammo_cells = cellsToBlow;
		}
	  else
	  {
		  bolt_doDamage(org, targetEntity, boltorg, trace_endpos, first2, 2);
	  }

	  first2 = FALSE; // get the next target
	  boltorg = targetEntity;

	  if (targetEntity == self)
	  {
			targetEntity = world;
	  }
	  else
	  {
		  targetEntity = boltorg.bolt_targetNext;
	  }

	  maxTargets = maxTargets - 1;

	  // check to see if we have run out of ammo
//	  if (ammo_con(2, self, string_null) != 0) // not infinite
#ifdef code_xents
	  if (self.eweapon)
	  if (self.eweapon.aflag < 1)
#endifdef
	  if (self.ammo_cells < 2)
	  {
	    // remove the FL_GIBCONDUIT if on
			bolt_removeTarget(self.bolt_target);

	  	self.bolt_target = world;  // disable the firing target...
	    self.weapon = W_BestWeapon ();
	    W_SetCurrentAmmo ();
	    return;
	  }

		// if max targets reached, do no more...
		if (maxTargets < 1)
		{
			return;
		}
	}

	if (loopBlow)
	{
		if (maxTargets == 19) // only one target, check if firing at each other
		{
		  // loop.. blow
		  self.ammo_cells = cellsToBlow;
		  bolt_doDamage(org, self, self, trace_endpos, first2, cellsToBlow);
		}

 		self.ammo_cells = 0;

	  // remove the FL_GIBCONDUIT if on
	  bolt_removeTarget(self.bolt_target);

	  self.bolt_target = world;  // disable the firing target...
	  self.weapon = W_BestWeapon ();
	  W_SetCurrentAmmo ();
	  return;
	}

	// if max targets reached or if it's finding the first target, do no more...
	if (maxTargets < 1 || first2)
	{
		return;
	}

// find the closest target within the current view of the target

	// max distance that the lighting can "jump"
	dist = 600;
	org = boltorg.origin + '0 0 16';

	head = findradius(boltorg.origin, dist);

	while(head)
	{
		if (head.health > 1) // can take damage && is not dead
	  if (head.takedamage)
	  if (head != self)  // not the shotter
	  if (head != boltorg) // and not the origin
	  //if (head.classname != "beartrap")  // JON Don't target beartraps
	  if (head.classname == "player" || head.classname == "turret" || head.class_select == "class_monster")
	  if (bolt_checkForLoops(head,  boltorg)) // not already in a this fire chain...
	  {
	    tempDist = vlen(head.origin - self.origin);
	  	traceline(org, head.origin, TRUE, self);

	    if (trace_fraction >= 1) // can see the player
	    if (tempDist < dist)     // closer than the last entity
	    if (!(trace_inopen && trace_inwater))  // can see it (ie can't see if it goes tho water & air)
			if (targetEntity.solid != SOLID_NOT) // make shore it's solid...
	   	if (head.classname != "player" || !(head.items & IT_INVISIBILITY)) // & is not invisiable
	    {
	    	// this will NEVER be the first target... so we can use just bolt_targetNext
		  	boltorg.bolt_targetNext = head;

		    dist = tempDist;
	      endPos = trace_endpos;
	    }
	  }

	  head = head.chain;
	}

	// target found?
	if (boltorg.bolt_targetNext != world)
	{
	 	bolt_createTimeoutEntity(boltorg);

	  // entity conduit timeout if the entity dies & handles being a conduit
	  boltorg.bolt_targetNext.bolt_conduitTimeout = time + 0.5;

	  // do damage...
	  bolt_doDamage(org, boltorg.bolt_targetNext, boltorg, endPos, FALSE, 2);
	}
};



// check for target path loops...
float(entity check, entity checkFor) bolt_checkForLoops =
{
//	local string str;

	while(check.bolt_targetNext)
	{
		if (check.bolt_targetNext == checkFor)
	  {
	  	return FALSE;
	  }

	  check = check.bolt_targetNext;
	}

	return TRUE;
};

// how many cells to use when target is a monster
var float autocvar_sv_pk_chainlt_ptspermonster = 0.5;

void(vector org, entity boltTarget, entity boltOwner, vector endPos, float first1, float dam) bolt_doDamage =
{
	local entity lightEntity;
	local vector vangle;

	if (boltTarget.class_select == "class_monster")
	{
#ifdef code_xents
		if (self.eweapon.aflag < 1)
#endifdef
			self.currentammo = self.ammo_cells = self.ammo_cells - autocvar_sv_pk_chainlt_ptspermonster;				/// FIX: this
	}
	else
	// use uyp ammo - note - ammo_con is being given loop blow cell cnts
#ifdef code_xents
	e_use_ammo();
#else
	self.currentammo = self.ammo_cells = self.ammo_cells - 2;//ammo_con(dam, self, string_null);
#endifdef

	dam = ((dam / 2) * 15);
	dam = floor(dam);

	// display & do damage
//	particle(endPos, '0 0 100', 225, dam * 4);
	spawn_particle = 225;
	SpawnBlood (boltTarget, endPos, '0 0 100' * 10, dam * 2);

	// only do damage if the target is not dead...
	if (boltTarget.health > 0)
	{
	  T_Damage(boltTarget, self, self, dam);
	}

	if (boltOwner != boltTarget)
	{
	  if (first1)
	  {
	    lightEntity = boltOwner;
	  }
	  else
	  {
	    if (!boltOwner.bolt_lightningFire)
	    {
	      boltOwner.bolt_lightningFire = spawn();
	      boltOwner.bolt_lightningFire.solid = SOLID_NOT;
	      boltOwner.bolt_lightningFire.movetype = MOVETYPE_NONE;
	    }

	    boltOwner.bolt_lightningFire.origin = boltOwner.origin;
	    vangle = normalize(boltTarget.origin - org);
	    boltOwner.bolt_lightningFire.angles = vectoangles(vangle);

	    lightEntity = boltTarget.bolt_lightningFire;
	  }

	  // display the bolt
	  WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	  WriteByte (MSG_BROADCAST, TE_LIGHTNING3);
	  WriteEntity (MSG_BROADCAST, lightEntity);
	  WriteCoord (MSG_BROADCAST, org_x);
	  WriteCoord (MSG_BROADCAST, org_y);
	  WriteCoord (MSG_BROADCAST, org_z);
	  WriteCoord (MSG_BROADCAST, boltTarget.origin_x);
	  WriteCoord (MSG_BROADCAST, boltTarget.origin_y);
	  WriteCoord (MSG_BROADCAST, boltTarget.origin_z);
	}
};


// Used to timeout the targets, called from PlayerPostThink
void() bolt_checkTargets =
{
	if (self.bolt_target)
	if (self.bolt_targetTimeout < time)
	{
	  bolt_removeTarget(self.bolt_target);
	  self.bolt_target = world;
	}

	if (self.weapon == IT_AXE)
	if (self.pk_currentitem == PK_IT_CLIGHT)
	if (self.bolt_changeModelTimeout < time)
	{
	// Cataboligne 9.11.3 purify - chase cam
	// disable model in chase view
//		if ( !(self.cam_x & CHSCAM_ON) )
		self.weaponmodel = "progs/v_cl_off.mdl";
	}

	if (self.bolt_targetNext)
	if (self.bolt_targetNextTimeout < time)
	{
		self.bolt_targetNext = world;
	}
};


void(entity boltOwner) bolt_createTimeoutEntity =
{
	if (boltOwner.classname == "player")
	{
	  boltOwner.bolt_targetNextTimeout = time + 0.5; // set the target timeout
	}

	if (boltOwner.bolt_targetTimeoutEntity == world)
	{
		boltOwner.bolt_targetTimeoutEntity = spawn();
		boltOwner.bolt_targetTimeoutEntity.think = bolt_timeoutNextEntity;
	  boltOwner.bolt_targetTimeoutEntity.owner = boltOwner;
	}

	boltOwner.bolt_targetTimeoutEntity.nextthink = time + 0.5;
};


void() bolt_timeoutNextEntity =
{
	bolt_removeTarget(self.owner);

	// remove the target pointers
	self.owner.bolt_targetNext = world;
	self.owner.bolt_targetTimeoutEntity = world;

	// remove timeout entity.
	remove(self);
};



void(entity boltTarget) bolt_removeTarget =
{
	// remove the FL_GIBCONDUIT if on
//	if (boltTarget)
//	if (boltTarget.flags & FL_GIBCONDUIT)
//	if (boltTarget.health > 0)
//	{
//	  boltTarget.flags = boltTarget.flags - FL_GIBCONDUIT;
//	}


	if (boltTarget.bolt_lightningFire)

	{

		remove(boltTarget.bolt_lightningFire);

	  boltTarget.bolt_lightningFire = world;

	}

};




$frame fryguy1 fryguy2 fryguy3 fryguy4


void() player_conduitJerk =[ $fryguy1, player_conduitJerk ]
{
	// check if conduit times up
	if (self.bolt_conduitTimeout < time) // it's the conduit time for this monster...
	{
		// blow the fuck up!!!
//		if (self.flags & FL_GIBCONDUIT)
//		{
			self.health = -99;
//	  }
		PlayerDie ();
		return;
	}

	// choose the next frame
	if (self.frame >  2)
	{
		self.frame = $fryguy1;
	}
	else
	{
		self.frame = self.frame + 1;
	}
};


float(entity targetEntity) bolt_infront =
{
	local vector	vec;
	local float		dot;

	makevectors (self.angles);
	vec = normalize (targetEntity.origin - self.origin);
	dot = vec * v_forward;

	if (dot > 0.85)
	{
		return TRUE;
	}
	return FALSE;
};



void()	bolt_s_explode1	=	[0,		bolt_s_explode2] {};
void()	bolt_s_explode2	=	[0,		bolt_s_explode3] {};
void()	bolt_s_explode3	=	[0,		bolt_s_explode4] {};
void()	bolt_s_explode4	=	[1,		bolt_s_explode5] {};
void()	bolt_s_explode5	=	[1,		bolt_s_explode6] {};
void()	bolt_s_explode6	=	[1,		bolt_s_explode7] {};
void()	bolt_s_explode7	=	[2,		bolt_s_explode8] {};
void()	bolt_s_explode8	=	[2,		bolt_s_explode9] {};
void()	bolt_s_explode9	=	[2,		bolt_s_explode10] {};
void()	bolt_s_explode10	=	[3,		bolt_s_explode11] {};
void()	bolt_s_explode11	=	[3,		bolt_s_explode12] {};
void()	bolt_s_explode12	=	[3,		bolt_s_explode13] {};
void()	bolt_s_explode13	=	[4,		bolt_s_explode14] {};
void()	bolt_s_explode14	=	[4,		bolt_s_explode15] {};
void()	bolt_s_explode15	=	[4,		bolt_s_explode16] {};
void()	bolt_s_explode16	=	[5,		SUB_Remove] {};


// chain thunderbolt fire frames

void() player_bolt1	 =[$light1, player_bolt1  ]
{
	self.effects = self.effects | EF_MUZZLEFLASH;

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;

	if (!(self.weaponframe & 1)) self.frame = $light2;

/// note: should this be encoded in cfg data?
	self.weaponmodel = "progs/v_cl_on.mdl"; // change to fire model...

	SuperDamageSound();
	bolt_fire();
#ifdef code_runes
	if (rune_haste(0.1))
#endifdef
	self.attack_finished = time + 0.2;

#ifdef code_morph
	if (self.morphy == IMP_MENF) self.frame = 33;
#endifdef
};
