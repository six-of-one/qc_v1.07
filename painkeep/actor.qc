 /* ::-::
 *
 * Cataboligne
 *
 * file: actor.qc 
 *
 * date: 017.2.26
 *
 * qc - painkeep plus module - actor
 *
 */
 
 void() actor_pent_activate =
{
	sprint(self,"Entering the Pentagram Stage\n");
	self.invincible_time = 1;
	self.invincible_finished = time + POW_TIME;
	self.items = self.items | IT_INVULNERABILITY;
	if ((random () * 100) < 5)
		self.pkplus_actortype = 0;
	else
		self.pkplus_actortype = PKPLUS_ACTORPENT;

	sound(self,CHAN_VOICE,"items/protect.wav",1,ATTN_NORM);
	stuffcmd(self,"bf\n");
};

void() actor_quad_activate =
{
	sprint(self,"Entering the Quad Stage\n");
	self.super_time = 1;
	self.super_damage_finished = time + POW_TIME;
	self.items = self.items | IT_QUAD;
	if ((random () * 100) < 5)
		self.pkplus_actortype = 0;
	else
		self.pkplus_actortype = PKPLUS_ACTORQUAD;

	sound(self,CHAN_VOICE,"items/damage.wav",1,ATTN_NORM);
	stuffcmd(self,"bf\n");
};
