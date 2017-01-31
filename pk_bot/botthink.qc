/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botthink.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


void (entity e) clearCache;
float () CheckWaterLevel =
{
	local float pnt;
	if (self.waterlevel < 1)
	{
		return (0);
	}
	pnt = pointcontents (self.origin + self.view_ofs);
	if (pnt != CONTENT_EMPTY)
	{
		return (3);
	}
	pnt = pointcontents (self.origin);
	if (pnt != CONTENT_EMPTY)
	{
		return (2);
	}
	return (1);
};

void () BotWaterMove =
{
	local float wlevel;
	local float wtype;
	local float pnt;
	local vector bt;
	wlevel = CheckWaterLevel ();
	if (self.health < 0)
	{
		return ;
	}
	if (wlevel != 3)
	{
		if (self.air_finished < time)
		{
			sound (self,CHAN_VOICE,"player/gasp2.wav",TRUE,ATTN_NORM);
		}
		else
		{
			if (self.air_finished < (time + 9))
			{
				sound (self,CHAN_VOICE,"player/gasp1.wav",TRUE,ATTN_NORM);
			}
		}
		self.air_finished = (time + 20);
		self.dmg = 2;
	}
	else
	{
		if (self.air_finished < time)
		{
			if (self.pain_finished < time)
			{
				self.dmg = (self.dmg + 2);
				if (self.dmg > 15)
				{
					self.dmg = 10;
				}
				T_Damage (self,world,world,self.dmg);
				self.pain_finished = (time + 1);
			}
		}
	}
	wtype = self.watertype;
	if (wlevel < 1)
	{
		bt = ((self.absmin + self.absmax) * 0.5);
		bt_z = (self.absmin_z + 1);
		pnt = pointcontents (bt);
		if (pnt != CONTENT_EMPTY)
		{
			wlevel = 1;
			wtype = pnt;
		}
	}
	if (self.waterlevel < 1)
	{
		if (self.flags & FL_INWATER)
		{
			sound (self,CHAN_BODY,"misc/outwater.wav",TRUE,ATTN_NORM);
			self.flags = (self.flags - FL_INWATER);
		}
		if (self.flags & FL_SWIM)
		{
			self.flags = (self.flags - FL_SWIM);
		}
		if (wlevel < 1)
		{
			return ;
		}
	}
	if (wtype == CONTENT_LAVA)
	{
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
			{
				self.dmgtime = (time + 1);
			}
			else
			{
				self.dmgtime = (time + 0.2);
			}
			T_Damage (self,world,world,(10* wlevel));
		}
	}
	else
	{
		if (wtype == CONTENT_SLIME)
		{
			if ((self.dmgtime < time) && (self.radsuit_finished < time))
			{
				self.dmgtime = (time + 1);
				T_Damage (self,world,world,(4* wlevel));
			}
		}
	}
	if (self.waterlevel < 1)
	{
		return ;
	}
	if (!(self.flags & FL_INWATER))
	{
		if (self.watertype == CONTENT_LAVA)
		{
			sound (self,CHAN_BODY,"player/inlava.wav",TRUE,ATTN_NORM);
		}
		if (self.watertype == CONTENT_WATER)
		{
			sound (self,CHAN_BODY,"player/inh2o.wav",TRUE,ATTN_NORM);
		}
		if (self.watertype == CONTENT_SLIME)
		{
			sound (self,CHAN_BODY,"player/slimbrn2.wav",TRUE,ATTN_NORM);
		}
		self.flags = (self.flags + FL_INWATER);
		if (!(self.flags & FL_SWIM))
		{
			self.flags = (self.flags + FL_SWIM);
		}
		self.dmgtime = 0;
	}
};

void () BotCheckPowerups =
{
	if (self.health <= 0)
	{
		return ;
	}
	if (self.invisible_finished)
	{
		if (self.invisible_sound < time)
		{
			sound (self,CHAN_AUTO,"items/inv3.wav",0.5,ATTN_IDLE);
			self.invisible_sound = (time + ((random () * 3) + 1));
		}
		if (self.invisible_finished < (time + 3))
		{
			if (self.invisible_time == 1)
			{
				sound (self,CHAN_AUTO,"items/inv2.wav",TRUE,ATTN_NORM);
				self.invisible_time = (time + 1);
			}
			if (self.invisible_time < time)
			{
				self.invisible_time = (time + 1);
			}
		}
		if (self.invisible_finished < time)
		{
			self.items = (self.items - IT_INVISIBILITY);
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		self.frame = 0;
		if (self.mask_x & CB_HUMAN)
			self.modelindex = modelindex_eyes;
		else
			self.modelindex = 0;
	}
	else
	{
		self.modelindex = self.modelindex_morph;
	}
	if (self.invincible_finished)
	{
		if (self.invincible_finished < (time + 3))
		{
			if (self.invincible_time == 1)
			{
				sound (self,CHAN_AUTO,"items/protect2.wav",TRUE,ATTN_NORM);
				self.invincible_time = (time + 1);
			}
			if (self.invincible_time < time)
			{
				self.invincible_time = (time + 1);
			}
		}
		if (self.invincible_finished < time)
		{
			self.items = (self.items - IT_INVULNERABILITY);
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
		{
			self.effects = (self.effects | EF_DIMLIGHT);
		}
		else
		{
			self.effects = (self.effects - (self.effects & EF_DIMLIGHT));
		}
	}
	if (self.super_damage_finished)
	{
		if (self.super_damage_finished < (time + 3))
		{
			if (self.super_time == 1)
			{
				sound (self,CHAN_AUTO,"items/damage2.wav",TRUE,ATTN_NORM);
				self.super_time = (time + 1);
			}
			if (self.super_time < time)
			{
				self.super_time = (time + 1);
			}
		}
		if (self.super_damage_finished < time)
		{
			self.items = (self.items - IT_QUAD);
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
		{
			self.effects = (self.effects | EF_DIMLIGHT);
		}
		else
		{
			self.effects = (self.effects - (self.effects & EF_DIMLIGHT));
		}
	}
	if (self.radsuit_finished)
	{
		self.air_finished = (time + 12);
		if (self.radsuit_finished < (time + 3))
		{
			if (self.rad_time == 1)
			{
				sound (self,CHAN_AUTO,"items/suit2.wav",TRUE,ATTN_NORM);
				self.rad_time = (time + 1);
			}
			if (self.rad_time < time)
			{
				self.rad_time = (time + 1);
			}
		}
		if (self.radsuit_finished < time)
		{
			self.items = (self.items - IT_SUIT);
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}
};

void () BotDead;
void () BotPostThink =
{
	local float fraglimit;
	if (self.pather)
	{
		if (CheckDropPath ())
		{
			DropBotPath ();
		}
	}
	self.movetarget.flags = self.flags;
	setorigin (self.movetarget,self.origin);
	if (self.deadflag != DEAD_NO)
	{
		dprint ("Bot should be dead!\n");
		GibPlayer ();
		BotDead ();
		return ;
	}
	BotCheckPowerups ();
	BotWaterMove ();
	fraglimit = cvar ("fraglimit");
	if (fraglimit && (self.frags >= fraglimit))
	{
		NextLevel (); // Cat - 4.5.10 - NOTE: is it just me or does it seem like the bot doesnt even have to reach the exit...
		self.button0 = 1;
		self.think = IntermissionThink;
		self.nextthink = (time + 5);
		return ;
	}

// fix pk*bot viswep item sync - we hope

	if (!self.items & IT_INVISIBILITY)
	if (self.vwepent)
	{
		if ((self.vwepent.origin) != self.origin || self.vwepent.angles != self.angles || self.vwepent.weaponframe != self.frame) // WATCH: monitor vofs in viswep for use
		viswep_post();
	}

// fix get item issue with rndize
	if (self.classname != "pk*bot")	self.classname = "pk*bot";

// bot post think checks
		if (self.copb_timeout)
		{
			if (self.copb_timeout >= time)
			{
				copb_checkFart();
			}
			else
			{
				self.copb_timeout = 0;
			}
		}

// runes
	if (self.rune_flag & RUNE_FLG_RG) rune_regen();
};

