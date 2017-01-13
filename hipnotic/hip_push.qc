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

//	delta = self.origin - self.oldorigin;
	setorigin (self.owner, self.owner.oldorigin + (self.origin - self.oldorigin) );	//delta );
};

/*QUAKED func_pushable (0 .5 .8) ?
Pushable walls.
*/

// something wrong where these fall from the level

void() func_pushable =
{
//	local entity new;
//	local vector newsize;

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
	nspawn.owner = self;
	nspawn.mangle = self.mangle;
	nspawn.angles = self.angles;

	nspawn.classname = "pushablewallproxy";
	nspawn.solid = SOLID_BBOX;
//	nspawn.movetype = MOVETYPE_STEP;
	nspawn.movetype = MOVETYPE_NONE;
	nspawn.origin = ( self.mins + self.maxs ) * 0.5 + '0 0 1';
	self.v__ = ( self.maxs - self.mins ) * 0.5;
	nspawn.mins = '-1 -1 0' - self.v__;
	nspawn.maxs = '1 1 -2' + self.v__;
	if (self.spawnflags)
	{
		setmodel (self, self.mdl);
		nspawn.origin = self.origin;
		nspawn.maxs = self.maxs;
		nspawn.mins = self.mins;
	}
	setsize( nspawn, nspawn.mins, nspawn.maxs );
	setorigin( nspawn, nspawn.origin );
	nspawn.oldorigin = nspawn.origin;
 	nspawn.touch = push_use;
};
