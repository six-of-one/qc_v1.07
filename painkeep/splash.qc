 /* ::-::
 *
 * Cataboligne
 *
 * file: splash.qc 
 *
 * date: 017.1.21
 *
 * qc - painkeep module - splash qc
 *
 */


// NOTE: pk 2.0 module used for relocating ents in solids & such
//				  prob not doing that here

#define	 NOT_IN_WATER		0
float pc;								// The content type the last entity to be checked just entered
float splash_count;			// The amout of splashes around. Used to keep the number down so we do'nt get any "No Free Edicts" messages

.float inwater;					// The water type the entity was in at last check
.string water_notify;		// Set to "yes" to make a splash
.void() splash_func;		// The function to call to make the splash
void() beartrapDie;	  // So we can remove bt's when in lava
void() turret_deathAnim;	 // So we can remove turrents whon in lava


// Remove a splash entity
void() Remove_Splash =
{
	splash_count = splash_count - 1;
	remove(self);
};

$frame splash1 splash2 splash3 splash4 splash5

void()	do_small_splash1 = [$splash1, do_small_splash2	] {};
void()  do_small_splash2 = [$splash1, do_small_splash3  ] {};
void()  do_small_splash3 = [$splash2, do_small_splash4  ] {};
void()  do_small_splash4 = [$splash2, do_small_splash5  ] {};
void()  do_small_splash5 = [$splash3, do_small_splash1  ] {Remove_Splash();};

/*
void()	do_large_splash1 = [$splash1, do_large_splash2	] {};
void()	do_large_splash2 = [$splash2, do_large_splash3	] {};
void()	do_large_splash3 = [$splash3, do_large_splash4	] {};
void()  do_large_splash4 = [$splash4, do_large_splash5  ] {};
void()  do_large_splash5 = [$splash5, do_large_splash1  ] {Remove_Splash();};
*/

framer($splash1, $splash5, do_large_splash1, Remove_Splash, 0.1,SUB_Null());

// All lava splashes are big splashes, so they can be seen easily

/*
void()	do_lava_splash1 = [$splash1, do_lava_splash2	] {};
void()	do_lava_splash2 = [$splash2, do_lava_splash3	] {};
void()	do_lava_splash3 = [$splash3, do_lava_splash4	] {};
void()	do_lava_splash4 = [$splash4, do_lava_splash1	] {Remove_Splash();};
*/

framer($splash1, $splash4, do_lava_splash1, Remove_Splash, 0.1,SUB_Null());

/*
void()	do_lava_splash1 = [$splash1, do_lava_splash2	] {};
void()	do_lava_splash2 = [$splash1, do_lava_splash3	] {};
void()	do_lava_splash3 = [$splash2, do_lava_splash4	] {};
void()	do_lava_splash4 = [$splash2, do_lava_splash5	] {};
void()	do_lava_splash5 = [$splash3, do_lava_splash6	] {};
void()	do_lava_splash6 = [$splash3, do_lava_splash7	] {};
void()	do_lava_splash7 = [$splash4, do_lava_splash8	] {};
void()	do_lava_splash8 = [$splash4, do_lava_splash1	] {Remove_Splash();};
*/


// Make a splash at entity e
void(entity e) MakeSplash =
{
	if (splash_count < 20)
	{
//		local entity nspawn;

		nspawn = spawn();

		setorigin(nspawn, e.origin);
		nspawn.solid = SOLID_NOT;
		nspawn.movetype = MOVETYPE_NONE;

		nspawn.nextthink = time + 0.1;

		if (pc == CONTENT_LAVA || e.inwater == CONTENT_LAVA)
		{
			setmodel(nspawn, "progs/s_splava.spr");
			nspawn.think = do_lava_splash1;
		}
		else
		{
			setmodel(nspawn, "progs/s_splash.spr");
			nspawn.think = e.splash_func;
		}

		splash_count = splash_count + 1;
	}
};

// Used to tell if an entity is in water
float(entity e) inWater =
{
	pc = pointcontents(e.origin);

	if (!(pc == CONTENT_WATER || pc == CONTENT_SLIME || pc == CONTENT_LAVA))
		pc = NOT_IN_WATER;

  return pc;
};

// Makes splashes of an entity has meved in / out of water. Called in PlayerPreThink
void() CheckWaterLevels =
{
//	local entity e;

	e0__ = find(world, water_notify, "yes");

	while (e0__ != world)
	{
		if (inWater(e0__) != e0__.inwater)
		{
		if (e0__.classname == "drop")
		{
		  sound(self, CHAN_AUTO, "misc/drip/drip_1.wav", 1, ATTN_NORM);
		  remove(e0__);
		}
		else
		{
//		  if (!(cvar("temp1") & PK_TP_SPARKSFLASH))
			 MakeSplash(e0__);

		  e0__.inwater = pc;

		  // Remove turrets and beartraps if they fall into the lava
		  if (pc == CONTENT_LAVA)
		  {
			 if (e0__.classname == "beartrap")
			 {
				e0__.think = beartrapDie;
				e0__.nextthink = time + 0.1;
			 }
			 else if (e0__.classname == "turret")
			 {
				e0__.think = turret_deathAnim;
				e0__.nextthink = time + 0.1;
			 }
		else if ( (e0__.classname == "tomb") )
		{
			e0__.think = SUB_Remove; //tombdie;
			e0__.nextthink = (time + 0.1);
		}
		  }
		}
		  
		}

		e0__ = find(e0__, water_notify, "yes");
	}
};

// Make the entity splash when it enteres / exits the water

void(entity e) AddToSplash =
{
	e.inwater = inWater(e);
	e.water_notify = "yes";
	e.splash_func = do_small_splash1;
};

void(entity e) AddToSplashBig =
{
	e.inwater = inWater(e);
	e.water_notify = "yes";
	e.splash_func = do_large_splash1;
};
