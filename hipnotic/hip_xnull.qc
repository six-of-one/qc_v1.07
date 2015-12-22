/* ::-::
 *
 * Cataboligne
 *
 * file: hip_xnull.qc
 *
 * date: 5.23.15
 *
 * qc - hipnotic translate file
 *
 */


// remove hip items

#ifdef id_include_always
#messageinclude   hipnotic/hip_xnull.qc 
#endifdef

/// NOTE: fire off targets

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate_item
void() item_artifact_wetsuit =
{
	remove(self);
};

void() item_hornofconjuring =
{
	remove(self);
};

void() item_artifact_empathy_shields =
{
	remove(self);
};
#endifdef

// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate_weapon
void() weapon_mjolnir =
{
	remove(self);
};

void() weapon_laser_gun =
{
	remove(self);
};

void() weapon_proximity_gun =
{
	remove(self);
};
#endifdef


// --------------------------------------------------------------------------------------------------------------------------
#ifdef hipitem_xlate_monster

void() monster_gremlin =
{
	remove(self);
};

void() monster_scourge =
{
	remove(self);
};

void() monster_armagon =
{
	remove(self);
};

#endifdef

