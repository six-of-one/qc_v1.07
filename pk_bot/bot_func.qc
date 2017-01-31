/* ::-::
 *
 * conscript: by Cataboligne v1.3 - (3.31.8)
 *
 * file: bot_func.qc
 *
 * date: Fri Apr  4 04:40:01 UTC 2008
 *
 * final qc
 *
 */


// xrp added file
void () ChangePitch;
.float ideal_pitch;
float current_pitch;
float () CheckWaterLevel;
float (entity targ) visible;
//float (entity targ) infront;
void () fix_thud =
{
	local float tol;
	tol = -80;
	tol = ((tol * cvar ("sv_gravity")) / 800);
	if (self.flags & FL_ONGROUND)
	{
		if (self.velocity_z < tol)
		{
			self.flags = (self.flags - (self.flags & FL_ONGROUND));
			self.velocity_z = tol;
		}
	}
};

void () fix_watertype_bug =
{
	local entity bot;
	bot = find (world,classname,"pk*bot");
	while (bot)
	{
		bot.watertype = 0;
		bot = find (bot,classname,"pk*bot");
	}
};

entity () find_bot =
{
	local float dist;
	local float best_dist;
	local entity head;
	local entity selected;
	selected = world;
	best_dist = 9999;
	head = find (world,classname,"pk*bot");
	while (head)
	{
		dist = vlen (self.origin - head.origin);
		infront (head, 0, v0, v0);
		if ((visible (head) && visible (head)) && (dist < best_dist))
		{
			best_dist = dist;
			selected = head;
		}
		head = find (head,classname,"pk*bot");
	}
	return(selected);
};

entity () find_monster =
{
	local float dist;
	local float best_dist;
	local entity head;
	local entity selected;
	selected = world;
	best_dist = 9999;
	head = findradius (self.origin,SEARCH_RADIUS);
	while (head)
	{
		dist = vlen (self.origin - head.origin);
		infront (head, 0, v0, v0);
		if (((visible (head) && visible (head)) && (dist < best_dist)) && (head.flags & FL_MONSTER))
		{
			best_dist = dist;
			selected = head;
		}
		head = head.chain;
	}
	return(selected);
};

void (entity me) set_bot_suicide_frame =
{
	if (me.model != "progs/player.mdl") // CHECK:
	{
		return ;
	}
	me.frame = 60;
	me.solid = SOLID_NOT;
	me.movetype = MOVETYPE_TOSS;
	me.deadflag = DEAD_DEAD;
	me.nextthink = -1;
};

