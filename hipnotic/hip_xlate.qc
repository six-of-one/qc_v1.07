/* ::-::
 *
 * Cataboligne
 *
 * file: hip_xlate.qc
 *
 * date: 5.23.15
 *
 * qc - hipnotic translate file
 *
 */


// translate hip to q1

#ifdef id_include_always
#messageinclude   hipnotic/hip_xlate.qc 
#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate_item
void() item_artifact_wetsuit =
{
	item_artifact_envirosuit();
};

void() item_hornofconjuring =
{
	if (random() < 0.35)
		weapon_lightning();
	else
		item_artifact_invulnerability();	
};

void() item_artifact_empathy_shields =
{
	item_armor2();
};
#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate_weapon
void() weapon_mjolnir =
{
	if (random() < 0.35)
		weapon_supernailgun();
	else
		weapon_lightning();	
};

void() weapon_laser_gun =
{
//	if (random() < 0.4)
		weapon_lightning();	
//	else
//		weapon_rocketlauncher();	
};

void() weapon_proximity_gun =
{
		weapon_grenadelauncher();	
};
#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate_monster

void() monster_gremlin =
{
	if (random() < 0.35)
		monster_dog();
	else
		monster_army();
};

void() monster_scourge =
{
	if (random() < 0.35)
		monster_tarbaby();
	else
		monster_hell_knight();	
};

void() monster_armagon =
{
	if (random() < 0.5)
		monster_shambler();
	else
		monster_shalrath();	
};

#endifdef

