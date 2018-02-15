/* ::-::
 *
 * Cataboligne
 *
 * file: lava_wpn.qc
 *
 * date: 1.25.018
 *
 * qc - rogue lava weapons module
 *
 */

// play that funky music

void() lavaGunFired =
{
	sound (self, CHAN_WEAPON, "lavagun/snail.wav", 1, ATTN_NORM);	
};

void(float ox) W_FireLavaSpikes =
{
//	local vector	dir;
//	local entity	old;
	
//	makevectors (self.v_angle);

/*
			TDO: make lava nails happen

	if (self.ammo_lava_nails >= 2 && self.weapon == IT_LAVA_SUPER_NAILGUN)
	{
		W_FireSuperLavaSpikes ();
		return;
	}

	if (self.ammo_lava_nails < 1)
	{
		sprint (self, "Out of Lava Nails\n");
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	self.currentammo = self.ammo_lava_nails = self.ammo_lava_nails - 1;
*/


	W_FireSpikes(ox);

// make it hot
	newmis.classname = "lava_spike";
	setmodel (newmis, "progs/lspike.mdl");	
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);	
	if (self.eweapon)
	{
		newmis.armortype = self.eweapon.armortype;
		self.eweapon.think = lavaGunFired;
		self.eweapon.nextthink = time + 0.7;
	}

};