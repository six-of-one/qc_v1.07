/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: botsignl.qc
 *
 * date: Fri Apr  4 04:40:02 UTC 2008
 *
 * final qc
 *
 */


void () t_botmovetarget;
entity (entity chaser, entity en) BestChaseRoute;
entity () botmovetarget =
{
	local entity targ;
	targ = spawn ();
	targ.classname = "BotTarget";
	targ.solid = SOLID_TRIGGER;
	targ.movetarget = world;
	targ.touch = t_botmovetarget;
	setsize (targ,'-4 -4 0','4 4 8');
 //  targ.entOwner = self; // xrp - not using yet
	return(targ);
};

void () t_botmovetarget =
{
//	local vector in;
	local entity tmp;
	local entity pth;
	local float rnd;
	if (other.goalentity != self)
	{
		return ;
	}
	if (self.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_touch.\n\n"); // 1
#endifdef
		ai_botstand();
		return;
	}
	if (self.goalentity.classname != "player")
	{
		if (VERBOSEBOT)
		{
			dprint (other.teamname);
			dprint (other.netname);
			dprint (" got to ");
			dprint (self.goalentity.classname);
			dprint ("\n");
		}
		other.lefty = (other.lefty - (other.lefty & LOCAL_TIME));
		if (self.goalentity.classname == "door")
		{
			if (self.goalentity.use == fd_secret_use)
			{
				return ;
			}
		}
		if (self.goalentity.classname == "train")
		{
			if (!(other.lefty & ONTRAIN))
			{
				other.lefty = (other.lefty | ONTRAIN);
				other.search_time = (time + 1);
			}
			return ;
		}
		if (self.goalentity.classname != "func_button")
		{
			if (other.lefty & GETGOODY)
			{
				other.goody_time = time;
			}
			else
			{
				other.search_time = time;
			}
			return ;
		}
		tmp = self;
		self = self.goalentity;
		button_touch ();
		self = tmp;
		clearCache (other);
		other.search_time = (time + 3);
		other.nextthink = (time + 0.3);
		return ;
	}
	if (VERBOSEBOT)
	{
		dprint (other.teamname);
		dprint (other.netname);
		dprint ("tracking ");
		dprint (self.goalentity.teamname);
		dprint (self.goalentity.netname);
		dprint ("\n");
	}
	pth = BestChaseRoute (other,self.goalentity);
	rnd = ((2000 + (random () * 1000)) + (other.skil * SEARCH_RADIUS));
	rnd = (rnd - vlen (other.origin - pth.origin));
	if (rnd < pth.enemylen)
	{
		other.search_time = (time - 1);
		return ;
	}
	random ();
	random ();
	rnd = (random () * (other.skil + 1));
	if (rnd < 0.1)
	{
		other.search_time = (time - 1);
		return ;
	}
	if (self.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_touch.\n\n"); // 2
#endifdef
		ai_botstand();
		return;
	}
	setorigin (self,pth.origin);
	other.search_time = (time + 4);
};

void () bot_toucheditem =
{
	if (other.goalentity.goalentity == self)
	{
		if (VERBOSEBOT)
		{
			dprint (other.teamname);
			dprint (other.netname);
			dprint (" got to ");
			dprint (self.classname);
			dprint ("\n");
		}
		other.lefty = (other.lefty - (other.lefty & LOCAL_TIME));
		other.search_time = (time - 1);
	}
};

void (entity bot) bot_triggered =
{
	local vector org;
	local entity Botgoal;
	Botgoal = bot.goalentity;
	if (Botgoal.goalentity != self)
	{
		return ;
	}
	Botgoal.goalentity = find (world,targetname,self.target);
	if (Botgoal.goalentity.classname == "light")
	{
		bot.search_time = time;
		return ;
	}
	if (Botgoal.goalentity)
	{
		bot.search_time = (time + 3);
		org = ((Botgoal.goalentity.absmax + Botgoal.goalentity.absmin) * 0.5);
		org_z = (Botgoal.goalentity.absmin_z + 1);
		if (Botgoal.classname != "BotTarget")
		{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_touch.\n\n"); // 3
#endifdef
			ai_botstand();
			return;
		}
		setorigin (Botgoal,org);
		Botgoal.goalentity.lastbot = bot;
		Botgoal.goalentity.lasttime = time;
		if (VERBOSEBOT)
		{
			dprint ("now Bot will go after the triggered ");
			dprint (Botgoal.goalentity.classname);
			dprint ("\n");
		}
	}
};

void () aibot_setupchase;
void () bot_touched =
{
	local entity tmp;
	tmp = self;
	self = other.goalentity;
	if (self.classname != "BotTarget")
	{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_touch.\n\n"); // 4
#endifdef
		ai_botstand();
		return;
	}
	if (self.goalentity == tmp)
	{
		t_botmovetarget ();
	}
	else
	{
		if (self.goalentity.classname == "door")
		{
			if (tmp.classname == "door")
			{
				t_botmovetarget ();
			}
		}
	}
	self = tmp;
};

void () enemy_touched =
{
	local entity tmp;
	local vector org;
	if (VERBOSEBOT)
	{
		dprint (other.enemy.teamname);
		dprint (other.enemy.netname);
		dprint (" chasing ");
		dprint (other.teamname);
		dprint (other.netname);
		dprint (" through ");
		dprint (self.classname);
		dprint ("!\n");
	}
	org = ((self.absmax + self.absmin) * 0.5);
	org_z = (self.absmin_z + 1);
	if (self.classname == "door")
	{
		org = other.origin;
	}
	tmp = self;
	self = other.enemy;
	if (self.enemy != other)
	{
		self = tmp;
		return ;
	}
	if (tmp.classname == "trigger_push")
	{
		endEnemy ();
		self.search_time = (time + 4);
		if (self.goalentity.classname != "BotTarget")
		{
#ifdef warning
		if (WARNING & 8) bprint("\n*** warning:\nbad bot target in bot_touch.\n\n"); // 5
#endifdef
			ai_botstand();
			return;
		}
		setorigin (self.goalentity,org);
		self = tmp;
		return ;
	}
	if (self.goalentity.classname != "BotTarget")
	{
#ifdef warning
			if (WARNING & 8) bprint("\n*** warning:\nbad bot target.\n\n");
#endifdef
			ai_botstand();
			return;
	}
	setorigin (self.goalentity,org);
	self.goalentity.goalentity = self.enemy;
	self.search_time = (time + 4);
	if (self.lefty & GETGOODY)
	{
		self.lefty = (self.lefty - GETGOODY);
	}
	aibot_setupchase ();
	self = tmp;
};

