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

// Cataboligne - 10.2.11 - tweak: set no damage for pent, & check var on actor - if true, same treatment

// note: what about armor? - could check vw armor, nad that could have dmskin

void(entity targ)	pk_setDamageSkin =
{
// player selectable skins like t800, c3p0, etc
//	if (targ.model == "progs/plyr_skins.mdl") return; // skin support added back in

	if (targ.classname == "player") // || targ.classname == "pk*bot") // ignores observers, etc.
	if (targ.solid != SOLID_NOT ) // Cataboligne - 5.11.10 - doent set skin for dead cam player
//	if (targ.model != "progs/player_sh.mdl") // Cataboligne - 9.11.11 - q3 shell deal - diff skins
#ifdef code_morph
	if (targ.mask_x & CB_HUMAN) // Cataboligne - 9.27.11 - only humans have dmgskin for now
#endifdef
	if (targ.skin < 5) // Cataboligne - 9.27.11 - tweak for suits
	{
#ifdef code_pkplus
		if  (targ.pkplus_actortype == PKPLUS_ACTORPENT) // acting as pent
		{
			if (PKPLUS_ACTOR_IGN_DMSKN) // fake it real good
			{
				targ.skin = 0;
				return;
			}
		}
		else
#endifdef
		if (targ.invincible_finished)
		{
			targ.skin = 0;
			return;
		}

		if (targ.health > 75)
	  {
	  	targ.skin = 0;
	  }
	  else if (targ.health > 55)
	  {
	  	targ.skin = 1;
	  }
	  else if (targ.health > 40)
	  {
	  	targ.skin = 2;
	  }
	  else if (targ.health > 25)
	  {
	  	targ.skin = 3;
	  }
	  else if (targ.health > 10)
	  {
	  	targ.skin = 4;
	  }
	  else
	  {
	  	targ.skin = 4;
	  }
	}
};