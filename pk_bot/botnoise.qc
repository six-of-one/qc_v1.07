/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botnoise.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


entity () noisetarget =
{
	local entity targ;
	targ = spawn ();
	targ.classname = "NoiseTarget";
	targ.solid = SOLID_NOT;
	setsize (targ,'-8 -8 -8','8 8 8');
	return(targ);
};

void () removenoise =
{
	NOISEQUEUE.goalentity = world;
	NOISEQUEUE.movetarget = world;
};

void (entity noisemaker, entity noiseobject) signalnoise =
{
	if (noisemaker.classname != "player")
	{
		return ;
	}
	if (!NOISEQUEUE)
	{
		return ;
	}
	NOISEQUEUE.goalentity = noisemaker;
	NOISEQUEUE.movetarget = noiseobject;
	NOISEQUEUE.think = removenoise;
	NOISEQUEUE.nextthink = (time + 1);
};

float (entity e) hearnoise =
{
	local float rnd;
	if (self.skil < 1)
	{
		return (0);
	}
	if (self.skil < 2)
	{
		rnd = (random () + 0.9);
		if (self.skil < rnd)
		{
			return (0);
		}
	}
	if (NOISEQUEUE.goalentity == e)
	{
		dprint (self.teamname);
		dprint (self.classname);
		dprint (" heard ");
		dprint (NOISEQUEUE.goalentity.netname);
		if (NOISEQUEUE.movetarget.classname == "player")
		{
			dprint (" shoot\n");
		}
		else
		{
			dprint (" trigger ");
			dprint (NOISEQUEUE.movetarget.classname);
			dprint ("\n");
		}
		return (1);
	}
	return (0);
};

//float (entity e) heardistantnoise =
float () heardistantnoise =
{
	return (0);
};

