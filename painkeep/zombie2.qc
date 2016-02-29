 /* ::-::
 *
 * Cataboligne
 *
 * file: zombie2.qc 
 *
 * date: 016.2.28
 *
 * qc - painkeep plus module - zombie2 qc
 *
 */

// * Dan's new "hanging" zombie.
// this is decor, not a monster

void() zombie_hang =
{
	self.think = zombie_hang;
	self.frame = self.frame + 1;

	if (self.frame > 21)
	{
		self.frame = 0;

		self.flags = rint(random() * 2);

//	  local float rs;
//	  rs = rint ((random() * 2) + 1);

	  if (self.flags == 1)
	    sound (self, CHAN_VOICE, "misc/zombie/swing_1.wav", 1, ATTN_NONE);
	  else if (self.flags == 2)
	    sound (self, CHAN_VOICE, "misc/zombie/swing_2.wav", 1, ATTN_NONE);
	  else
	    sound (self, CHAN_VOICE, "misc/zombie/swing_3.wav", 1, ATTN_NONE);
	}

	if (self.flags == 1)
	{
		self.nextthink = time + 0.1;
	}
	else if (self.flags == 2)
	{
		self.nextthink = time + 0.15;
	}
	else
	{
		self.nextthink = time + 0.2;
	}
};


void() monster_zombie2 =
{
#ifdef nondp
	precache_model ("progs/zombie2.mdl");

	precache_sound ("misc/zombie/swing_1.wav");
	precache_sound ("misc/zombie/swing_2.wav");
	precache_sound ("misc/zombie/swing_3.wav");
#endifdef

//	if (pk_flags & PK_TP_SPARKSFLASH)
/*
	if ((pk_flags & PK_TP_SPARKSFLASH) || XENV)
	{
		remove(self);
		return;
	}
*/

	self.solid = SOLID_NOT;
//	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/zombie2.mdl");

//	setsize (self, '-4 -16 -93', '7 2 1');

	self.movetype = MOVETYPE_NONE;
	self.frame = 22;

//	self.think = zombie_hang;
//	self.nextthink = time + 0.1;

	zombie_hang ();
};



void() zombie_twist =
{
	self.think = zombie_twist;
	self.frame = self.frame + 1;

	if (self.frame > 45)
	{
		self.frame = 0;
	}

	self.nextthink = time + 0.1;
};


void() monster_zombie3 =
{
#ifdef nondp
	precache_model ("progs/zombie3.mdl");
#endifdef

/*
	if ((pk_flags & PK_TP_SPARKSFLASH) || XENV)
	{
		remove(self);
		return;
	}
*/
	self.solid = SOLID_NOT;
//	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/zombie3.mdl");

//	setsize (self, '-4 -16 -93', '7 2 1');

	self.movetype = MOVETYPE_NONE;
	self.frame = 46;

//	self.think = zombie_twist;
//	self.nextthink = time + 0.1;

	zombie_twist ();
};

