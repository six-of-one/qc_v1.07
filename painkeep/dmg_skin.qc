 /* ::-::
 *
 * Cataboligne
 *
 * file: dmg_skin.qc 
 *
 * date: 016.2.29
 *
 * qc - painkeep plus module - damage skin qc
 *
 */

// Cataboligne - 011.10.2 - tweak: set no damage for pent, & check var on actor - if true, same treatment

// note: what about armor? - could check vw armor, nad that could have dmskin
// 016.2.29 mod: always called from player with self (for now)

// idea: quad / pent color tint here
// idea: damage overlays that work with any model

void()	pk_DmgSkin =
{
// player selectable skins like t800, c3p0, etc
//	if (self.model == "progs/plyr_skins.mdl") return; // skin support added back in

	if (self.classname == "player") // || self.classname == "pk*bot") // ignores observers, etc.
	if (self.solid != SOLID_NOT ) // Cataboligne - 5.11.10 - doent set skin for dead cam player
//	if (self.model != "progs/player_sh.mdl") // Cataboligne - 9.11.11 - q3 shell deal - diff skins
#ifdef code_morph
	if (self.mask_x & CB_HUMAN) // Cataboligne - 9.27.11 - only humans have dmgskin for now
#endifdef
	if (self.skin < 5) // Cataboligne - 9.27.11 - tweak for suits
	{
//		if (self.health > 75) - this is a default now
	  	self.skin = 0;

#ifdef code_pkplus
		if  (self.pkplus_actortype == PKPLUS_ACTORPENT) // acting as pent
		{
			if (PKPLUS_ACTOR_IGN_DMSKN) // fake it real good
			{
//				self.skin = 0;
				return;
			}
		}
		else
#endifdef
		if (self.invincible_finished)
		{
//			self.skin = 0;
			return;
		}

		if (self.health < 76)
		if (self.health > 55)
		{
			self.skin = 1;
		}
		else if (self.health > 40)
		{
			self.skin = 2;
		}
		else if (self.health > 25)
		{
			self.skin = 3;
		}
		else if (self.health > 0)
		{
			self.skin = 4;
		}
	}
};