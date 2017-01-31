/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botscore.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc - NOT USED !!!
 *
 */


/// note: this code is not currently compiled

// these were removed from defs:

float NORMALSCORE				= 1;
float MYSCORE					= 2;

//.float healtype;
//.float playerkills;
//.float playerdeaths;
//.float botkills;
//.float botdeaths;
//.float suicides;

// this is the old scoring system from before bots were on the scoreboard hack

void () initscore =
{
	self.playerkills = 0;
	self.playerdeaths = 0;
	self.botkills = 0;
	self.botdeaths = 0;
	self.suicides = 0;
};

void (entity killer, entity killed) countkill =
{
	local float adj;
	if (skill == 1)
	{
		adj = 0.8;
		if ((killed.playerdeaths + killed.botdeaths) > 10)
		{
			adj = 0.4;
		}
		if ((killed.playerdeaths + killed.botdeaths) > 20)
		{
			adj = 0.150;
		}
	}
	if (killer == killed)
	{
		killer.suicides = (killer.suicides + 1);
		return ;
	}
	if (killer.classname == "player")
	{
		killed.playerdeaths = (killed.playerdeaths + 1);
		if (skill == 1)
		{
			if (killed.classname == "pk*bot")
			{
				killed.skil = (killed.skil + (adj * random ()));
				if (killed.skil > 3)
				{
					killed.skil = 3;
				}
			}
		}
	}
	else
	{
		if (killer.classname == "pk*bot")
		{
			killed.botdeaths = (killed.botdeaths + 1);
			if (skill == 1)
			{
				if (killed.classname == "player")
				{
					killer.skil = (killer.skil - (adj * random ()));
					if (killer.skil < 0)
					{
						killer.skil = 0;
					}
				}
			}
		}
	}
	if (killed.classname == "player")
	{
		killer.playerkills = (killer.playerkills + 1);
	}
	else
	{
		if (killed.classname == "pk*bot")
		{
			killer.botkills = (killer.botkills + 1);
		}
	}
};

void (float sc) FPrintScore =
{
	local string fs;
	if ((sc > -10) && (sc < 0))
	{
		sprint (self," ");
	}
	else
	{
		if (sc >= 0)
		{
			if (sc < 100)
			{
				sprint (self," ");
			}
			if (sc < 10)
			{
				sprint (self," ");
			}
		}
	}
	fs = ftos (sc);
	sprint (self,fs);
};

float (entity e) totalscore =
{
	local float sc;
	sc = ((2* ((e.playerkills + e.botkills) - e.suicides)) - (e.playerdeaths + e.botdeaths));
	return(sc);
};

void (entity e, float scoretype) PrintScoreFor =
{
	local float sc;
	FPrintScore (e.playerkills);
	sprint (self,"  ");
	FPrintScore (e.playerdeaths);
	sprint (self,"|");
	FPrintScore (e.botkills);
	sprint (self,"  ");
	FPrintScore (e.botdeaths);
	sprint (self,"|");
	FPrintScore (e.suicides);
	sprint (self," |");
	if (scoretype == MYSCORE)
	{
		sc = totalscore (e);
	}
	else
	{
		sc = e.frags;
	}
	FPrintScore (sc);
	sprint (self," ");
	sprint (self,e.teamname);
	sprint (self,e.netname);
	sprint (self,"\n");
};

entity (float scoretype) SortPlayers =
{
	local entity e;
	local entity sort;
	local entity walk;
	local float es;
	local float ss;
	e = find (world,classname,"player");
	sort = world;
	while (e)
	{
		if (!sort)
		{
			sort = e;
			e.chain = world;
		}
		else
		{
			if (scoretype == MYSCORE)
			{
				es = totalscore (e);
				ss = totalscore (sort);
			}
			else
			{
				es = e.frags;
				ss = sort.frags;
			}
			if (es > ss)
			{
				e.chain = sort;
				sort = e;
			}
			else
			{
				walk = sort;
				ss = totalscore (walk.chain);
				do
				{
					if (!walk.chain)
					{
						e.chain = world;
						walk.chain = e;
					}
					else
					{
						if (ss < es)
						{
							e.chain = walk.chain;
							walk.chain = e;
						}
						else
						{
							walk = walk.chain;
						}
					}
				} while (walk.chain != e);
			}
		}
		e = find (e,classname,"player");
	}
	e = find (world,classname,"pk*bot");
	while (e)
	{
		if (!sort)
		{
			sort = e;
			e.chain = world;
		}
		else
		{
			if (scoretype == MYSCORE)
			{
				es = totalscore (e);
				ss = totalscore (sort);
			}
			else
			{
				es = e.frags;
				ss = sort.frags;
			}
			if (es > ss)
			{
				e.chain = sort;
				sort = e;
			}
			else
			{
				walk = sort;
				do
				{
					ss = totalscore (walk.chain);
					if (!walk.chain)
					{
						e.chain = world;
						walk.chain = e;
					}
					else
					{
						if (ss < es)
						{
							e.chain = walk.chain;
							walk.chain = e;
						}
						else
						{
							walk = walk.chain;
						}
					}
				} while (walk.chain != e);
			}
		}
		e = find (e,classname,"pk*bot");
	}
	return(sort);
};

void (float scoretype) PrintTopScores =
{
	local entity sort;
	local float i;
	if (world.chain)
	{
		error ("DumpScore: world.chain is set");
	}
	sort = SortPlayers (NORMALSCORE);
	i = 0;
	while (sort)
	{
		i = (i + 1);
		sprint (self,sort.teamname);
		sprint (self,sort.netname);
		sprint (self,"  ");
		FPrintScore (sort.frags);
		sprint (self,"\n");
		sort = sort.chain;
		if (i == 3)
		{
			sort = world;
		}
	}
};

void (float scoretype) PrintScores =
{
	local entity sort;
	if (world.chain)
	{
		error ("DumpScore: world.chain is set");
	}
	sort = SortPlayers (scoretype);
	sprint (self,"Vs. Plyr|Vs. Bots|Suic|Score\n");
	sprint (self,"kill die|kill die|ides|\n");
	sprint (self,"_______________________________\n");
	while (sort)
	{
		PrintScoreFor (sort,scoretype);
		sort = sort.chain;
	}
	sprint (self,"\n");
};

