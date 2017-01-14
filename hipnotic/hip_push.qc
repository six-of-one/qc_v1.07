/* Pushable walls QuickC program
	By Jim Dose'  9/16/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

void() push_use =
{
//	local vector delta;
//	local float x;
//	local float y;

//	walkmove (other.angles_y, 16 * frametime);
/*
	if ( (other.angles_y >= 315) || (other.angles_y < 45))
	{
		walkmove ( 0, 16 * frametime);
	}
	else if ( (other.angles_y >= 45) && (other.angles_y < 135))
	{
		walkmove ( 90, 16 * frametime);
	}
	else if ( (other.angles_y >= 135) && (other.angles_y < 225))
	{
		walkmove ( 180, 16 * frametime);
	}
	else if ( (other.angles_y >= 225) && (other.angles_y < 315))
	{
		walkmove ( 270, 16 * frametime);
	}
	else
	{
		return;
	}
*/
// fallout fix - and fails
	self.movetype = MOVETYPE_STEP;
	self.owner.movetype = MOVETYPE_PUSH;

	makevectors(other.angles);
	
//	x = fabs( v_forward_x );
//	y = fabs( v_forward_y );
	self.v___x = fabs( other.velocity_x );
	self.v___y = fabs( other.velocity_y );

#ifndef nodprint
	dprint( ftos( self.v___x ) );
	dprint( ", " );
	dprint( ftos( self.v___y ) );
#endifdef

	if ( self.v___x > self.v___y )
	{
#ifndef nodprint
		dprint( " x move\n\n\n\n" );
#endifdef
		if ( other.velocity_x > 0 )
		{
			walkmove ( 0, 16 * frametime);
		}
		else
		{
			walkmove( 180, 16 * frametime );
		}
	}
	else
	{
#ifndef nodprint
		dprint( " y move\n\n\n\n" );
#endifdef
		if ( other.velocity_y > 0 )
		{
			walkmove ( 90, 16 * frametime);
		}
		else
		{
			walkmove( 270, 16 * frametime );
		}
	}

// this makes blocks un-pushable
// and some blocks still went thru floor, just slower
//	self.velocity_z = 0;
//	self.owner.velocity_z = 0;

//	delta = self.origin - self.oldorigin;
	setorigin (self.owner, self.owner.oldorigin + (self.origin - self.oldorigin) + self.view_ofs );	//delta );
};

/*QUAKED func_pushable (0 .5 .8) ?
Pushable walls.
*/

// something wrong where these fall from the level
// initial MOVETYPE_NONE fixes this, but still fsck on ops with these
// fall from level is a result of bottom of proxy being embedded in floor

void() func_pushable =
{
//	local entity new;
//	local vector newsize;

	if (self.target != "")
	{
		if (time < 3)		// cant find target before it spawns
		{
			self.think = func_pushable;
			self.nextthink = time + 2;
			return;
		}
		nspawn = self;
		self = find (world, targetname, nspawn.target);
		if (!self) return;		// reload may correct this asp
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_NONE;
		self.oldorigin = self.origin;
		self.targetname = nspawn.targetname;		// in case of a remove target on pushable
//		nspawn.origin = self.origin; // does not relocate pushable
	}
	else
	{
		self.mangle = self.angles;
		self.angles = '0 0 0';

		self.classname = "pushablewall";
		self.solid = SOLID_BSP;
	//	self.movetype = MOVETYPE_PUSH;
		self.movetype = MOVETYPE_NONE;
		setmodel (self, self.model);
		setorigin( self, self.origin );
		setsize (self, self.mins, self.maxs );
		self.oldorigin = self.origin;

		nspawn = spawn();
		nspawn.targetname = self.targetname;		// in case pushable is targeted
	}
	nspawn.owner = self;
	nspawn.mangle = self.mangle;
	nspawn.angles = self.angles;

	nspawn.classname = "pushablewallproxy";
	nspawn.solid = SOLID_BBOX;
//	nspawn.movetype = MOVETYPE_STEP;
	nspawn.movetype = MOVETYPE_NONE;
	nspawn.origin = ( self.mins + self.maxs ) * 0.5 + '0 0 1';
	self.v__ = ( self.maxs - self.mins ) * 0.5;
	nspawn.mins = '-1 -1 0' - self.v__ + nspawn.view_ofs;
	nspawn.maxs = '1 1 -2' + self.v__;
	if (nspawn.spawnflags & 1) setmodel (self, self.mdl);		// _only_ works with target ent!
	if (nspawn.spawnflags & 2)
	{
		nspawn.origin = self.origin;
		nspawn.maxs = self.maxs + '1 1 -2';
		nspawn.mins = '-1 -1 0' + self.mins + nspawn.view_ofs;
	}
	setsize( nspawn, nspawn.mins, nspawn.maxs );
	setorigin( nspawn, nspawn.origin );
	nspawn.oldorigin = nspawn.origin;
 	nspawn.touch = push_use;
};
