 /* ::-::
 *
 * Cataboligne
 *
 * file: ego.qc 
 *
 * date: 016.2.28
 *
 * qc - painkeep plus module - ego qc
 *
 */

void (entity destEnt, float radius, vector offset) ego_rotate =
{
//	local vector dir;	self.v__
//	local float dist;
#define	dist	self.f__

	if (self.orbitPosition > 3)
		self.orbitPosition = 0;
	else if (self.orbitPosition < 0)
		self.orbitPosition = 0;

	traceline (self.origin,(destEnt.origin + offset),TRUE,world);
	if (trace_fraction < 1)
	{
		setorigin (self,(destEnt.origin + offset));
		self.orbitPosition = (self.orbitPosition + 1);
		return ;
	}
	if (self.orbitPosition == 0)
	{
		self.v__ = ((destEnt.origin + offset) - self.origin);
		self.v___x = (self.v___x + radius);
	}
	else
	if (self.orbitPosition == 1)
	{
		self.v__ = ((destEnt.origin + offset) - self.origin);
		self.v___y = (self.v___y + radius);
	}
	else
	if (self.orbitPosition == 2)
	{
		self.v__ = ((destEnt.origin + offset) - self.origin);
		self.v___x = (self.v___x - radius);
	}
	else
	{
		self.v__ = ((destEnt.origin + offset) - self.origin);
		self.v___y = (self.v___y - radius);
	}

	dist = vlen (self.v__);
	if (dist < 8)
		self.orbitPosition = (self.orbitPosition + 1);
	else
	if (dist < 50)
	{
		self.velocity = normalize (self.v__);
		self.velocity = (self.velocity * 150);
	}
	else
	{
		self.velocity = normalize (self.v__);
		self.velocity = (self.velocity * 500);
	}
};
#undef	dist

void () ego_destruct =
{
	T_RadiusDamage (self,self.owner,(0.8 * self.dmg),other);
	self.origin = (self.origin - (8 * normalize (self.velocity)));
	sound (self,CHAN_VOICE,"misc/null.wav",1,ATTN_NORM);

	BecomeExplosion (self);
};

void () ego_think;

void () ego_touch =
{
//	local float f;

	self.f__ = FALSE;
#ifdef opgrade
	self.f__ = other.flags & FL_MONSTER;
#endifdef

	if (other.classname != "player") // && other.group != "pk*bot")
	if (!self.f__)
	{
		return ;
	}
	if (other == self.owner)
	{
		return ;
	}
	if ( other.health )
	{
		T_Damage (other,self,self.owner,self.dmg);
	}
	T_RadiusDamage (self,self.owner,(0.8 * self.dmg),other);
	self.origin = (self.origin - (8 * normalize (self.velocity)));
	WriteByte (MSG_BROADCAST,SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST,TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST,self.origin_x);
	WriteCoord (MSG_BROADCAST,self.origin_y);
	WriteCoord (MSG_BROADCAST,self.origin_z);

#ifdef opgrade
	if (self.f__) // ego can hit a monster(s) a few times
	if (self.cnt < 4)
	{
		self.cnt = self.cnt + 1;
		self.dmg = self.dmg - 20 - random() * 60;
		if (self.dmg > 0)
		{
			self.delay = self.delay + 10 + random() * 20;
			self.owner.dmg_inflictor = self.owner; // note: what if this happens right before a combat call?
			self.enemy = world;
			self.nextthink = (time + 0.1);
			self.think = ego_think; // go back to player
			return;
		}
	}
#endifdef

	BecomeExplosion (world);
};

/* - deprecated - unused
void (entity ownerEntity) ego_remove =
{
	local entity ent;
	ent = find (world,classname,"ego");
	while (ent != world)
	{
		if (ent.owner == self)
		{
			bprint (ent.owner.netname);
			bprint ("'s EGO has been removed\n");
			remove (ent);
			ent = find (world,classname,"ego");
		}
		else
		{
			ent = find (ent,classname,"ego");
		}
	}
};
*/

void () ego_seeker =
{
//	local vector vec1;  self.v__
//	local string hold_s;

	if (time > self.delay)
	{
		sprint (self.owner,"Losing One's EGO\n");
		ego_destruct ();
		return ;
	}
	self.v__ = (self.enemy.origin + '0 0 12');
	self.v__ = normalize ((self.v__ - self.origin));
	self.velocity = (self.v__ * 600);
	if (self.enemy.health < 1)
	{
		sprint (self.owner,"Your EGO is useless!");
		sound (self,CHAN_VOICE,"misc/null.wav",1,ATTN_NORM);
		remove (self);
		return ;
	}
	self.nextthink = (time + 0.1);
	self.think = ego_seeker;
};

void () ego_attack =
{
	self.solid = SOLID_TRIGGER;
	self.touch = ego_touch;
	self.egosoundtime = (time - 1);
	self.delay = (time + 5);
	ego_seeker ();
};

void () ego_think =
{
	local float f;

#ifdef unsused
	if ( self.disconnectPlayer )
	{
		sound (self,CHAN_VOICE,"misc/null.wav",1,ATTN_NORM);
		remove (self);
		return ;
	}
#endifdef
	if (time > self.delay)
	{
		sprint (self.owner,"Losing One's EGO\n");
		sound (self,CHAN_VOICE,"misc/null.wav",1,ATTN_NORM);
		remove (self);
		return ;
	}
	if (self.egosoundtime < time)
	{
		self.egosoundtime = (time + 4);
		if ( (self.egosoundtime <= self.delay) )
		{
			sound (self,CHAN_VOICE,"ego/ego.wav",1,ATTN_NORM);
		}
	}

	f = FALSE;
	if (self.owner.dmg_inflictor.classname == "player") f = TRUE;
//	else if (self.owner.dmg_inflictor.group == "pk*bot") f = TRUE;
#ifdef opgrade
//	else if ((self.owner.dmg_inflictor.flags & FL_MONSTER) && ENHANCED) f = TRUE;
	else if (self.owner.dmg_inflictor.flags & FL_MONSTER) f = TRUE;
#endifdef
	
	if ( (self.owner.dmg_inflictor != self.owner) ) // direct damage
	{
		if ( f )
		{
			if ( visible (self.owner.dmg_inflictor) )
			{
				if ( !((self.owner.dmg_inflictor.items & IT_INVULNERABILITY) 
#ifdef code_pkplus
							&& (self.owner.dmg_inflictor.pkplus_actortype == PKPLUS_ACTORPENT)
#endifdef
									) )
				{
					self.enemy = self.owner.dmg_inflictor;
					ego_attack ();
					return ;
				}
			}
		}

		f = FALSE;
		if (self.owner.dmg_inflictor.owner.classname == "player") f = TRUE;
//		else if (self.owner.dmg_inflictor.owner.group == "pk*bot") f = TRUE;
#ifdef opgrade
//		else if ((self.owner.dmg_inflictor.owner.flags & FL_MONSTER) && ENHANCED) f = TRUE;
		else if (self.owner.dmg_inflictor.owner.flags & FL_MONSTER) f = TRUE;
#endifdef

		if ( (self.owner.dmg_inflictor.owner != self.owner) ) // damage by proxy (missile, nail, etc.)
		{
			if ( f )
			{
				if ( visible (self.owner.dmg_inflictor.owner) )
				{
					if ( !((self.owner.dmg_inflictor.owner.items & IT_INVULNERABILITY)
#ifdef code_pkplus
								&& (self.owner.dmg_inflictor.owner.pkplus_actortype == PKPLUS_ACTORPENT)
#endifdef
										) )
					{
						self.enemy = self.owner.dmg_inflictor.owner;
						ego_attack ();
						return ;
					}
				}
			}
		}
	}
	if (self.owner.health < 1)
	{
		ego_destruct ();
		return ;
	}
	ego_rotate (self.owner,16,'0 0 48');
	self.nextthink = (time + 0.1);
};

#define	PKPLUS_EGO_TIME	newmis.dmgtime
#define	PKPLUS_EGO_DMG	newmis.button6

void () ego_activate =
{
//	local entity ent;

	newmis = spawn ();
	newmis.movetype = MOVETYPE_FLYMISSILE;
//	newmis.solid = SOLID_NOT;
	newmis.classname = "ego";
	newmis.owner = self;
//	newmis.weapon = 0;
	newmis.egosoundtime = (time - 1);
	newmis.avelocity = '30 30 30';
	setmodel (newmis,"progs/v_ego.mdl");
	setorigin (newmis,(self.origin + '0 0 8'));
	sound (self,CHAN_VOICE,"ego/ego.wav",1,ATTN_NORM);
	newmis.pk_currentitem = PKPLUS_IT_EGO;
	newmis.weapon = IT_AXE;
	self.dmg_inflictor = self;
	newmis.think = ego_think;
	newmis.nextthink = (time + 0.1);

	newmis.delay = (time + POW_TIME);
	newmis.dmg = 250 + (50 * random ());
	if (self.eweapon)
	{
		newmis.delay = self.eweapon.dmgtime + time;
		newmis.dmg = self.eweapon.button6+ (50 * random ());
	}
/*
	PKPLUS_EGO_TIME = POW_TIME;
	PKPLUS_EGO_DMG = 250;

	if (self.eweapon)
	{
		PKPLUS_EGO_TIME = self.eweapon.dmgtime;
		PKPLUS_EGO_DMG = self.eweapon.button6;
	}

	newmis.delay = (time + PKPLUS_EGO_TIME);
	newmis.dmg = PKPLUS_EGO_DMG+ (50 * random ());
*/
};

