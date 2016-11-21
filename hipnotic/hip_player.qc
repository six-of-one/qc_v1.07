/* ::-::
 *
 * Cataboligne
 *
 * file: hip_player.qc
 *
 * date: 5.12.15
 *
 * qc - hipnotic extruded player module
 *
 */


/*
==============================================================================

PLAYER

==============================================================================
*/

#ifdef hip_weapons
void(float stat) HIP_FireLaser;
void() HIP_FireMjolnir;


//MED 10/18/96 added HIPWEAPONS
//============================================================================

/*
void()   player_hammer1 =  [32, player_hammer2   ] {self.weaponframe=1;};
void()   player_hammer2 =  [33, player_hammer3   ] {self.weaponframe=2;};
void()   player_hammer3 =  [34, player_hammer4   ] {self.weaponframe=3;};
void()   player_hammer4 =  [35, player_hammer5   ] {self.weaponframe=4;HIP_FireMjolnir();};
void()   player_hammer5 =  [36, player_hammer6   ] {self.weaponframe=4;};
void()   player_hammer6 =  [37, player_run ] {self.weaponframe=4;};
*/

framer(32, 37, player_hammer1, player_run, 0.1,

	frame_arb(35,HIP_FireMjolnir());
	frame_arb(32,self.weaponframe=0);
	self.weaponframe = self.weaponframe + 1;
	if (self.frame > 35) self.weaponframe=4;
);

/*
void()   player_mjolnir1 =  [38, player_mjolnir2   ] {self.weaponframe=1;};
void()   player_mjolnir2 =  [39, player_mjolnir3   ] {self.weaponframe=2;};
void()   player_mjolnir3 =  [40, player_mjolnir4   ] {self.weaponframe=3;};
void()   player_mjolnir4 =  [41, player_mjolnir5   ] {self.weaponframe=4;HIP_FireMjolnir();};
void()   player_mjolnir5 =  [42, player_mjolnir6   ] {self.weaponframe=4;};
void()   player_mjolnir6 =  [43, player_run ] {self.weaponframe=4;};
*/

framer(38, 43, player_mjolnir1, player_run, 0.1,

	frame_arb(41,HIP_FireMjolnir());
	frame_arb(38,self.weaponframe=0);
	self.weaponframe = self.weaponframe + 1;
	if (self.frame > 41) self.weaponframe=4;
);


//============================================================================

//MED 10/18/96 added HIPSWEAPONS
/*
void() player_laser1   =[$nailatt1, player_laser2  ] {self.attack_finished = time + 0.1;self.weaponframe=1;self.nextthink = time + 0.09;HIP_FireLaser(0);};
void() player_laser2   =[$nailatt2, player_laser4  ] {self.attack_finished = time + 0.1;self.weaponframe=2;self.nextthink = time + 0.09;};
void() player_laser3   =[$nailatt1, player_laser4  ] {self.attack_finished = time + 0.1;self.weaponframe=3;self.nextthink = time + 0.09;};
void() player_laser4   =[$nailatt2, player_laser5  ] {self.attack_finished = time + 0.1;self.weaponframe=4;self.nextthink = time + 0.09;HIP_FireLaser(1);};
void() player_laser5   =[$nailatt1, player_laser1  ] {self.attack_finished = time + 0.1;self.weaponframe=5;self.nextthink = time + 0.09;};
void() player_laser6   =[$nailatt2, player_laser1  ] {self.attack_finished = time + 0.1;self.weaponframe=6;self.nextthink = time + 0.09;};

void() player_laser1   =[$nailatt1, player_laser3  ] {self.attack_finished = time + 0.1;self.weaponframe=1;self.nextthink = time + 0.1;HIP_FireLaser(0);};
// check this	  -----v^			------v^
void() player_laser2   =[$nailatt2, player_laser3  ] {self.attack_finished = time + 0.1;self.weaponframe=2;self.nextthink = time + 0.1;};
void() player_laser3   =[$nailatt2, player_laser1  ] {self.attack_finished = time + 0.1;self.weaponframe=4;self.nextthink = time + 0.1;HIP_FireLaser(1);};
void() player_laser4   =[$nailatt1, player_laser1  ] {self.attack_finished = time + 0.1;self.weaponframe=5;self.nextthink = time + 0.1;};
*/

void() player_laser1   =[$nailatt1, player_laser1  ] 
{
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe >= 6)
		self.weaponframe = 1;

	self.attack_finished = time + 0.1;
	self.nextthink = time + 0.09;

	if (!(self.weaponframe & 1)) self.frame = $nailatt2;
	if (self.weaponframe  == 1) HIP_FireLaser(0);
	if (self.weaponframe  == 4) HIP_FireLaser(1);
};

/*
framer(38, 42, player_laser1, player_run, 0.1,

	frame_arb(41,HIP_FireMjolnir());
	frame_arb(38,self.weaponframe=0);
	self.weaponframe = self.weaponframe + 1;
	if (self.frame > 41) self.weaponframe=4;
);
*/

//============================================================================

/*
void()   player_hampain1 =  [  18,   player_hampain2 ] {PainSound();self.weaponframe=0;};
void()   player_hampain2 =  [  19,   player_hampain3 ] {};
void()   player_hampain3 =  [  20,   player_hampain4 ] {};
void()   player_hampain4 =  [  21,   player_hampain5 ] {};
void()   player_hampain5 =  [  22,   player_hampain6 ] {};
void()   player_hampain6 =  [  23,   player_run  ] {};
*/

framer(18, 23, player_hampain1, player_run, 0.1,

	frame_arb(18,
	
		PainSound();
		self.weaponframe=0;
	);
);


void() player_die_ham1;


/*
void()   player_die_ham1 =  [ 24 ,   player_die_ham2 ] {};
void()   player_die_ham2 =  [ 25 ,   player_die_ham3 ] {};
void()   player_die_ham3 =  [ 26 ,   player_die_ham4 ] {};
void()   player_die_ham4 =  [ 27 ,   player_die_ham5 ] {};
void()   player_die_ham5 =  [ 28 ,   player_die_ham6 ] {};
void()   player_die_ham6 =  [ 29 ,   player_die_ham7 ] {};
void()   player_die_ham7 =  [ 30 ,   player_die_ham8 ] {};
void()   player_die_ham8 =  [ 31 ,   player_die_ham8 ] {PlayerDead();};
*/

framer(24, 31, player_die_ham1, PlayerDead, 0.1,SUB_Null());

#endifdef

//MED
void() HeadThink =
{
	self.nextthink = -1;
	if (world.worldtype != 2)
	{
		if (random()<0.1)
			sound (self, 6, "misc/flys.wav", 0.7, ATTN_STATIC);
	}
};
