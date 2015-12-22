/* Bullet holes QuickC program
	By Jim Dose'  11/20/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

/*QUAKED wallsprite (0 1 0) (-8 -8 -8) (8 8 8)
Places a sprite on a wall.  Angles should be opposite of face.

"model" sprite to place on wall.  Default is "progs/s_blood1.spr".
*/
void() wallsprite =
{
	if ( !self.model )
	{
		self.model = "progs/s_blood1.spr";
	}

	precache_model( self.model );
	setmodel (self, self.model );

	// QuakeEd doesn't save up and down angles properly.
	if (self.angles == '0 -1 0')
		self.angles = '-90 0 0';
	else if (self.angles == '0 -2 0')
		self.angles = '90 0 0';

	// Pull the sprite away from the wall slightly to
	// get rid of z sort errors.
	makevectors(self.angles);
	setorigin( self, self.origin - ( v_forward * 0.2 ) );
	makestatic (self);
};

// Six - not using with darkplaces - it has better bullet splash damage on the world
//			- you can still use wallsprite detailed above
#ifdef hip_bulletholes

void() InitBulletHoles =
{
	precache_model ("progs/s_bullet.spr");

	bulletholes = nullentity;
	lastbullet = nullentity;
	numbulletholes = 0;
};

void() remove_bullethole =
{
	local entity ent;

	// There is a possibility that this is not the first bullet
	// in the list, but it doesn't really matter.  All that
	// matters is there is one less bullet.  Just make sure
	// we don't remove the world!
	if ( bulletholes == nullentity )
	#ifdef noobjerr
	{
		numbulletholes = 0;
		return;
	}
	#else
		objerror("remove_bullethole: bulletholes == nullentity! " );		//opgrade protected
	#endifdef

	ent = bulletholes;
	if ( ent.classname != "bullethole" )
	#ifdef noobjerr
	{
		numbulletholes = 0;
		bulletholes = nullentity;
		return;
	}
	#else
		objerror("remove_bullethole: Tried to remove non-bullethole!" );		//opgrade protected
	#endifdef

	bulletholes = bulletholes.lastvictim;
	remove( ent );
	if ( lastbullet == ent )
	{
		lastbullet = nullentity;
	}
	numbulletholes = numbulletholes - 1;
};

void( vector pos ) placebullethole =
{
//	local entity new;
//	local entity ent;
//	local vector norm;

	nspawn = spawn();
	nspawn.owner = nspawn;
//	nspawn.movetype = MOVETYPE_NONE;
//	nspawn.solid = SOLID_NOT;
	nspawn.classname = "bullethole";
	setmodel( nspawn, "progs/s_bullet.spr" );
	setsize (nspawn, '0 0 0', '0 0 0');

//	norm = trace_plane_normal;
	trace_plane_normal_x = 0 - trace_plane_normal_x;
	trace_plane_normal_y = 0 - trace_plane_normal_y;
	nspawn.angles = vectoangles( trace_plane_normal );
	makevectors(self.angles);
	setorigin( nspawn, pos - ( v_forward * 0.2 ) );

	nspawn.think = remove_bullethole;
	nspawn.nextthink = time + 300;

	numbulletholes = numbulletholes + 1;
	if ( numbulletholes > 10 )
	{
		remove_bullethole();
	}

	if ( lastbullet != nullentity )
	{
		lastbullet.lastvictim = nspawn;
	}
	else
	{
		bulletholes = nspawn;
	}
	nspawn.lastvictim = nullentity;
	lastbullet = nspawn;
};

#endifdef
