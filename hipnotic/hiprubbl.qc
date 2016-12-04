/* Rubble QuickC program 
	By Jim Dose'  9/15/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

// oblong (arm gib) irr block (torso gib) tetra (tetra gib) 0 1 2
$frame hiprubl1 hiprubl2 hiprubl3
// smaller block (cube) small block (rectangle) small block (odd) 3 4 5
$frame blockrubl1 blockrubl2 blockrubl3
// small beveled block, med beveled block, large beveled block 6 7 8
$frame bevelrubl1 bevelrubl2 bevelrubl3
// torso twists = 4, largest last 9 10 11 12
$frame blocktwist1 blocktwist2 blocktwist3 blocktwist4
// trapeziod solids - smaller, flat tile, odd, med, large, larger 13 14 15 16 17 18
$frame blocktrapez1 flattile1  blocktrodd1 blocktrapez2 blocktrapez3 blocktrapez4
// minis 19 20 21 22
$frame bevelmini blockmini trapezmini twistmini
// micro 23 24 25 26
$frame bevelmicro blockmicro trapezmicro twistmicro
// menhir - 4 sided monument - pyramid top sm, med, lg
$frame menhirm1 menhirm2 menhirm3
// menhir - 4 sided crystal oblong sm, med, lg
$frame menhirco1 menhirco2 menhirco3
// menhir - odd oblong sm, med, lg
$frame menhiro1 menhiro2 menhiro3
// length down from origin for punch up effect
float menhir1_LEN = 40, menhir2_LEN = 82, menhir3_LEN = 140;
// basalt column - skin 7
$frame basalt1 basalt2 basalt3

// rubble skin support - original hip & dm4 so far

// 0 1 2 -- brown splotch, dark coppery, light coppery
$skin hipskin1 hipskin2 hipskin3
// 3 4 5 -- dm4 cieling, dm4 skygrate, dm4walls
$skin metal1_6 metal1_3 mmetal1_3
// 6 -- lava rubble skin
$skin aa_lava

void() hipRubbleTouch =
{
	if ( self.ltime < self.pausetime )
		return;
		
	if (other.takedamage)
	{
		T_Damage(other, self, self.owner, 10 );
		sound(self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
		self.pausetime = self.ltime + 0.1;
	}
};

void(string rubblename) hipThrowRubble =
{
//	local	entity new;
	
	newmis = spawn();
	newmis.origin = self.origin;
	setmodel(newmis, rubblename);
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.velocity_x = 70 * crandom();
	newmis.velocity_y = 70 * crandom();
	newmis.velocity_z = 140 + 70 * random();
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;
	newmis.avelocity_x = random() * 600;
	newmis.avelocity_y = random() * 600;
	newmis.avelocity_z = random() * 600;
	newmis.think = SUB_Remove;
	newmis.touch = hipRubbleTouch;
	newmis.ltime = time;
	newmis.nextthink = time + 13 + random() * 10;
	self.pausetime = time;
//	newmis.frame = 0;
//	newmis.flags = 0;
};

void() rubble_use =
{
//	local float which;
	local float index;
	
//	index = 0;
	
	do 
	{
//		which = self.cnt;
		if ( !self.cnt )//== 0 )
		{
// NOTE: taking out which fails here
			self.cnt = floor (1 + 3*random());
//			which = floor( which );
		}
		if ( self.cnt == 1 )
		{
			hipThrowRubble( "progs/rubble_m.mdl" );
			newmis.frame = $hiprubl1;
			newmis.skin = $hipskin2;
		}
		else if ( self.cnt == 2 )
		{
			hipThrowRubble( "progs/rubble_m.mdl" );
			newmis.frame = $hiprubl3;
			newmis.skin = $hipskin1;
		}
		else
		{
			hipThrowRubble( "progs/rubble_m.mdl" );
			newmis.frame = $hiprubl2;
			newmis.skin = $hipskin1;
		}
		index = index + 1;
	}
	while ( index < self.count );
};

/*QUAKED func_rubble (0.4 0.4 0.2) (0 0 0) (32 32 32)
  Spawns random sized rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
void() func_rubble =
{
	precache_model ("progs/rubble1.mdl");
	precache_model ("progs/rubble2.mdl");
	precache_model ("progs/rubble3.mdl");
	precache_sound ("zombie/z_hit.wav");
	self.classname = "rubble";
//	self.cnt = 0;
	self.use = rubble_use;
};
	
/*QUAKED func_rubble1 (0.4 0.4 0.2) (0 0 0) (8 8 8)
  Spawns small rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
void() func_rubble1 =
{
	func_rubble();
/*
	precache_model ("progs/rubble1.mdl");
	precache_sound ("zombie/z_hit.wav");
	self.classname = "rubble1";
	self.use = rubble_use;
*/
	self.cnt = 1;
};
	
/*QUAKED func_rubble2 (0.4 0.4 0.2) (0 0 0) (16 16 16)
  Spawns medium rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/

// NOTE: check classname

void() func_rubble2 =
{
	func_rubble();
/*
	precache_model ("progs/rubble3.mdl");
	precache_sound ("zombie/z_hit.wav");
	self.classname = "rubble2";
	self.use = rubble_use;
*/
	self.cnt = 2;
};
	
/*QUAKED func_rubble3 (0.4 0.4 0.2) (0 0 0) (32 32 32)
  Spawns large rubble when triggered.  
  
  "count" is the number of pieces of rubble to spawn.  Default is 1.
*/
void() func_rubble3 =
{
	func_rubble();
/*
	precache_model ("progs/rubble2.mdl");
	precache_sound ("zombie/z_hit.wav");
	self.classname = "rubble3";
	self.use = rubble_use;
*/
	self.cnt = 3;
};
	
