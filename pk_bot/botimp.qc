/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botimp.qc
 *
 * date: Fri Apr  4 04:40:01 UTC 2008
 *
 * final qc
 *
 */


void (entity e, float newskin) skinChange =
{
	local entity b;
	if (!SKINSMODE)
	{
		e.skin = 0;
		return ;
	}
	if (newskin < 0)
	{
		newskin = 15;
	}
	if (newskin > 15)
	{
		newskin = 0;
	}
	e.skin = newskin;
	if (teamplay)
	if (e.classname == "player")
	{
		b = find (world,classname,"pk*bot");
		while (b)
		{
			if (b.team == e.team)
			{
				b.skin = e.skin;
			}
			b = find (b,classname,"pk*bot");
		}
	}
};

void () removeSkins =
{
	local entity e;
	SKINSMODE = 0;
	e = find (world,classname,"player");
	while (e)
	{
		e.skin = 0;
		e = find (e,classname,"player");
	}
	e = find (world,classname,"pk*bot");
	while (e)
	{
		e.skin = 0;
		e = find (e,classname,"pk*bot");
	}
};

void () setSkinsMode =
{
	if (SKINSMODE == 2)
	{
		removeSkins ();
		bprint ("Skins mode turned off\n");
		return ;
	}
	SKINSMODE = (SKINSMODE + 1);
	if (SKINSMODE == 1)
	{
		bprint ("Skins mode activated\n");
	}
	else
	{
		bprint ("Skill-based skins mode activated\n");
	}
};



void () setVerboseMode =
{
	VERBOSEBOT = !VERBOSEBOT;
};

void () setNamingMode =
{
	NAMEBOTS = !NAMEBOTS;
};

/*

 11.6.13 - removed impulse admin commands fully

void () botControl =
{
	local string tmp;
	if (self.impulse == 202)
	{
		setSkinsMode ();
	}
	else if (self.impulse == 205)
	{
		AddAnotherBot(-1);
	}
	else if ((self.impulse > 99) && (self.impulse < 116))
	{
		if (teamplay)
		{
			SetTeamBots (self.impulse - 100);
		}
		else
		{
			SetMaxBots (self.impulse - 100);
		}
	}
	else if (self.impulse == 208)
	{
		AddAnotherBot(-1);
		AddAnotherBot(-1);
		AddAnotherBot(-1);
		AddAnotherBot(-1);
	}
	else if (self.impulse == 211)
	{
		removeAllBots();
	}
	else if (self.impulse == 214)
	{
		setBotGravity();
	}
	else if (self.impulse == 215)
	{
		setVerboseMode();
	}
	else if (self.impulse == 217)
	{
		tmp = ftos (NUMPATHS);
		dprint (tmp);
		dprint (" botpaths placed\n");

		tmp = ftos (NUMPATHERS);
		dprint (tmp);
		dprint (" botpathers\n");

		tmp = ftos (NUMBOTS);
		dprint (tmp);
		dprint (" active bots\n");

		tmp = ftos (serverflags);
		dprint (tmp);
		dprint (" server flags\n");
	}
/ *
	else if (self.impulse == 218)
	{
//		serverflags = serverflags - (serverflags & UNRESTRICTED);
		bprint ("Unrestricted mode cleared\n");
	}
* /
};

void () botImpulseCommand =
{
	if (self.impulse == 200)
	{
		skinChange (self,(self.skin + 1));
	}
	else if (self.impulse == 201)
	{
		skinChange (self,(self.skin - 1));
	}
	else if (self.impulse == 204)
	{
		if (!PK) printIntro ();
	}
	else if (self.impulse == 221)
	{
		UpdateTeamColors (); // NOTE: is this something we need later ?
	}
};
*/
