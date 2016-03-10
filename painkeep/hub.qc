 /* ::-::
 *
 * Cataboligne
 *
 * file: hub.qc 
 *
 * date: 016.2.29
 *
 * qc - painkeep module - hub qc
 *
 */


/*
	Hub-style level voters system

	"classname" "hub_teleport"
	"origin" "# # #"
	"target" "..."		- teleport destination to teleport to, if not specified, randomly
						chosen info_player_deathmatch is chosen
	"map" "..."		- Map to go to (@random for a random map chosen from rest of available
							maps)

	"classname" "hub_control"
	"targetname" "..."	- if specified, hub will chose map when triggered
	"wait" "#" 		- hub will chose map when this time is up
*/


/*
	hub_teleport
*/
entity theHub; // variable holding the hub

entity (string aMap) findMap;
void() hub_control_use;
void(entity e) WaitForVotes;
void(entity bt) bot_votereveal;


// Start of the hub code.

void() hub_teleport_touch =
{
	local entity spot;
//	local float temp1, temp2;
//	local string str;

	// make sure the thing is the player
	if (other.classname != "player") 
		return;

	// make sure we don't gib the last player!!!
	if (other.voteIntermission == 1)
		return;

	// if we're single player, just go to this map
	if (!deathmatch)
	{
		nextmap = self.map;
		gameover = TRUE;

		self.think = execute_changelevel;
		self.nextthink = time + 0.1;
		return;
	}

	if (!m_score_rel1)
	if (self.target1 == "score_rel1")
		return;

	if (!m_score_rel2)
	if (self.target1 == "score_rel2")
		return;

	if (self.count > 0)
	{
		if (ply_count < self.count)
		if (self.target1 == "player_count")
			return;

		if (ply_count >= self.count)
		if (self.target1 == "!player_count")
			return;
	}

	// change of vote?
	if (other.map != string_null)
	{
		// is this guy pulling a double vote?
		if (other.map == self.map)
		{
			// he's trying to vote for the same map twice
			// nuke him
			T_Damage(other, other, other, 5000);
			return;
		}
		else
		{
			// he's changing his vote
			spot = findMap(other.map);
			// decrement his old vote
			if (spot.cnt > 0)
				spot.cnt = spot.cnt - 1;
		}
	}
	// record the user's vote here
	other.map = self.map;
	if (other.class_select == "class_bot") bot_votereveal(other);
	// increment the vote count
	self.cnt = self.cnt + 1;

	// check to see if everyone has finished
	local string srch;
	spot = find(world, classname, "player");

/*
notes: might still need observer
	if (!spot)
		{
			srch = OBSERVER;
			spot = find(world, classname, srch);
		}
		if (!spot)
		{
			srch = "pk*bot";
			spot = find(world, classname, srch);
		}
*/
	local float notDone;
	srch = "player";
	notDone = 0;
	while (spot != world)
	{
		if ((spot.disconnectPlayer == 0) && spot.map == string_null)
			notDone = 1;
		spot = find(spot, classname, srch);

/*
		if (!spot)
		if (srch == "player") // atp all players should be jafo already
		{
			srch = OBSERVER;
			spot = find(world, classname, srch);
		}
		if (!spot)
		if (srch == OBSERVER) // *bot - search out bots too
		{
			srch = "pk*bot";
			spot = find(world, classname, srch);
		}
*/
	}

	if (!notDone)
	{
		// make sure we can't gib the last player!!!
		other.voteIntermission = 1;

		// let's get going to the next level
		self = theHub;
		hub_control_use();
		return;
	}
	WaitForVotes(other);
};

void() hub_teleport =
{
	local vector o;

	// error check
	if (!self.map)
	{
#ifdef warning
		if (WARNING & 1) bprint("\n*** warning:\nhub_teleport without map - removing, this portal will not cull votes.\n\n");
#endifdef
		remove(self);
		return;
	}

	InitTrigger ();

	self.touch = hub_teleport_touch;

	self.th_weight = triggerweight; // *bot
	self.istrigger = 1;

	// no votes
	self.cnt = 0;

	if (!(self.spawnflags & (T_SILENT | T_STEALTH)))
	{
		precache_sound ("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound (o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}
};

/*
	custom hubs
		- allow user to make any map a hub thru hub_custom ent, either adding to bsp via quark or using .ent file with custom engines
		- later - add other PK customizations such as zombies, gfx, sfx, etc
*/

// select hub map - back to plain old painkeep hub, check_custom_hub handles custom hubs now

/*
 deprecated

string() hub_select =
{
	return ("start");
};
*/

// fn(check_custom_hub) - check for return to a custom hub when in GotoNextMap or admin reseting hub

float() check_custom_hub =
{
	PK_ADMINMAP = FALSE; // always reset this

	if (custom_hub_loaded) //pk_flags & PK_HUB2)
	{
		if (!st_pk_hub) return FALSE; // turned off by cvar
//		pk_flags = pk_flags - (pk_flags & PK_HUB2);
//		admin_sv_cfg();
		if (pk_flags & PK_SF_HUB)
		{
			localcmd("hubmap\n");  // custom hub - use alias to reload
			return TRUE;
		}
	}
	return FALSE;
};

// fn(hub_custom) - implement the custom hub - portal

void() hub_custom =
{
	local entity e;

	if (!self.map) // we set arc_hub map in case this hub is non functional - i.e. no proper vote portals
	{
		bprint("*** Custom hub without map designation - setting = Archon Hub.");
		self.map = "arc_hub";
		self.message = "Archon Hub!";
	}
	if (!self.message) self.message = "Mystery Map"; // doh

	self.classname = "hub_teleport";
	hub_teleport(); // init hub portal

	PK = TRUE; // *pk - in map mode, set PK for painkeep mode

// set appearance - model has different frames & skins for variety
// IDEA: set facing in cphub? - not for now, all portals should be "directionless"
	if (self.delay < 0)
		setmodel (self, null_model);
	else
	{
		setmodel (self, "progs/hub_port.mdl");
		setsize(self, self.mins, self.maxs);
		self.frame = self.delay;
		self.skin = self.wait;
	}
	if (self.style) self.effects = EF_DIMLIGHT; // lite er up
//	if (self.frame) setorigin(self, self.origin + '0 0 -20'); // adjust on bprint

// trigger for message
	e = self;
	self = spawn();
	if (self != e)
	{
		e.enemy = self; // hub points to trigger - no more searching in admin
		self.classname = "trigger_multiple";
// bounds bigger than portal to give message
		setorigin(self, e.origin);
		setmodel(self, "progs/shambler.mdl"); // model is req. to have bounds - its never seen

		self.message = e.message;
		self.sounds = 4;
		self.speed = 100;
		self.wait = 4;
		self.lip = self.dmg = self.delay =	self.health = 0;
		self.style = 32;
		trigger_multiple();
	}
};

// fn(pk_cphub) - print custom hub portal info for current player location - just add a map descriptor, file name, model frame & skin
// - bind key to impulse 35, and set saved1 = 482 or 483
// - saved1 = 482, no comments on fields
// - saved1 = 483, add in comments for fields that need edited to add custom maps

// IDEA: turn off stat messages ("you got the shells") if  pk_chubcon == 666

float pk_chubcon;

void() pk_cphub =
{
	if (pk_chubcon != 666) // print a hub control ent to start
	{
		localcmd("exec cfg/menu/cphub.cfg");
		pk_chubcon = 666;
	}
	if (cvar("saved1") != 482)
	{
		bprint("{\n\"classname\" \"hub_custom\"\n\"targetname\" \"votes\"\n\"map\" \"start\"          // change to custom map base filespec - exclude .bsp\n\"message\" \"Start (hub)\"  // change to custom map message text\n\"delay\" \"0\"            // change to hub model custom frame number\n\"wait\" \"0\"             // change to hub model custom skin number\n\"style\" \"1\"            // change to 0 - remove light emission from hub\n\"origin\" \"");
	}
	else
	{
		bprint("{\n\"classname\" \"hub_custom\"\n\"targetname\" \"votes\"\n\"map\" \"start\"\n\"message\" \"Painkeep Hub\"\n\"delay\" \"0\"\n\"wait\" \"0\"\n\"style\" \"1\"\n\"origin\" \"");
	}
	bprint(ftos(floor(self.origin_x)));
	bprint(" ");
	bprint(ftos(floor(self.origin_y)));
	bprint(" ");
	bprint(ftos(floor(self.origin_z - 20)));
	bprint("\"\n}\n");
};

/*
	hub_control
*/

// counts the # of maps available to choose from
float() countMaps =
{
	local float c;
	local entity e;
	c = 0;

	e = find(world, classname, "hub_teleport");
	while (e != world)
	{
		if (e.map != "@random")
			c = c + 1;
		e = find(e, classname, "hub_teleport");
	}
	return c;
};

// get's the num'th map available to the calling hub
entity(float num) getMap =
{
	local entity e;
	local float c,f;
	c = 1;
	e = find(world, classname, "hub_teleport");

	// loop thru looking for the num'th guy
	while (e != world)
	{
		f = TRUE;

		if (!m_score_rel1)
		if (e.target1 == "score_rel1") // bot vote or random must block locked maps
			f = FALSE;

		if (!m_score_rel2)
		if (e.target1 == "score_rel2")
			f = FALSE;

		if (deathmatch)
		if (e.count > 0)
		{
			if (ply_count < e.count)
			if (e.target1 == "player_count")
				f = FALSE;

			if (ply_count >= e.count)
			if (e.target1 == "!player_count")
				f = FALSE;
		}
#ifdef warning
if (WARNING & 2049)
{
	bprint("\b *** warning: hub: \b");
	bprint(e.map);
	bprint(" - t1: ");
	bprint(e.target1);
	if ((e.target1 == "player_count") || (e.target1 == "!player_count"))
	{
		bprint(" - cn: ");
		bprint(ftos(e.count));
	}
	bprint(" - chose: ");
	bprint(ftos(f));
	bprint(" - sel: ");
	bprint(ftos(num));
	bprint("\n");
}
#endifdef

		if (f)
		if (e.map != "@random")
		{
			if (c > num)
				return e;
			c = c + 1;
		}
		e = find(e, classname, "hub_teleport");
	}

	return e;
};

entity(string aMap) findMap =
{
	local entity e;
	e = find(world, classname, "hub_teleport");
	// find the teleport with the given map
	while (e != world)
	{
		if (e.map == aMap)
			return e;
		e = find(e, classname, "hub_teleport");
	}
	return world;
};

entity first;
entity second;
void() getHighestScores =
{
	local entity e;

	// scan thru all the teleports with our target...
	// find the one with the larget cnt value
	first = second = find(world, classname, "hub_teleport");
	e = find(first, classname, "hub_teleport");
	while (e != world)
	{
		// set new highest
		if (e.cnt >= first.cnt)
		{
			second = first;
			first = e;
		}
		e = find(e, classname, "hub_teleport");
	}
};

entity() getHighestWithoutRandom =
{
	local entity e, highest;
	local float c, r;

	// scan thru all the teleports with our target...
	// find the one with the larget cnt value
	highest = find(world, classname, "hub_teleport");
	e = find(highest, classname, "hub_teleport");
	c = 1;
	while (e != world)
	{
		// set new highest
		if (e.cnt > highest.cnt)
		{
			highest = e;
			c = 1;
		}
		else
		{
			r = 1;
			if (!e.cnt) // no votes on this map - block locked
			{
				if (!m_score_rel1)
				if (e.target1 == "score_rel1") // bot vote or random must block locked maps
					r = FALSE;
		
				if (!m_score_rel2)
				if (e.target1 == "score_rel2")
					r = FALSE;
		
				if (deathmatch)
				if (e.count > 0)
				{
					if (ply_count < e.count)
					if (e.target1 == "player_count")
						r = FALSE;
		
					if (ply_count >= e.count)
					if (e.target1 == "!player_count")
						r = FALSE;
				}
#ifdef warning
if (WARNING & 2049)
{
	bprint("\b *** warning: hub: \b");
	bprint(e.map);
	bprint(" - t1: ");
	bprint(e.target1);
	if ((e.target1 == "player_count") || (e.target1 == "!player_count"))
	{
		bprint(" - cn: ");
		bprint(ftos(e.count));
	}
	bprint(" - not refused: ");
	bprint(ftos(r));
	bprint(" - sel: ");
	bprint(ftos(c));
	bprint("\n");
}
#endifdef
			}
// tie breaker...
// this will also choose randomly amongst 0 cnt maps (no vote condition)
			if (r)
			if (e.cnt == highest.cnt)
			{
				c = c + 1;
				r = random() * 100;
				// randomly choose new highest
				if (r < (100 / c))
					highest = e;
			}
		}
		e = find(e, classname, "hub_teleport");
	}
	return highest;
};

void() hub_control_use =
{
	local entity e;
	local entity highest;
	local float r;
	local float c; // count of highests

	// this is only called once
	self.use = SUB_Null;
	self.nextthink = time + -1;

	if (!deathmatch) // only in deathmatch
		return;

	// get highest counting map
	highest = getHighestWithoutRandom();

// there is one + bot(s) - make sure they do a level reload, may not be any humans
	if (find(world, class_select, "class_bot"))
	{
		e = spawn();
		e.classname = "bot_hubreload";
		e.think = GotoNextMap;
		e.nextthink = time + 60 + (random() * 20);
	}

	// error
	if (highest == world) // note: could be stuck on hub at this point
	{
		bprint("hub_control_use: highest vote not found\n");
		return;
	}

	if (highest.map == "@random") // map portal says "pick a random map"
	{
		// randomly choose level here
		c = countMaps();
		// error check
		if (c < 1)
		{
			bprint("hub_control_use: random map not found\n");
			return;
		}
		
		r = random() * c;
		highest = getMap(r);
		if (highest == world) // note: could be stuck on hub at this point
		{
			bprint("hub_control_use: random map not found\n");
			return;
		}
	}

	PK_ADMINMAP = TRUE; // we may be a custom hub set - do not allow re loading hub

	nextmap = highest.map;
	gameover = TRUE;

	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
	if (custom_hub_loaded) // || self.map
	{
		pk_flags = PK_HUB2 | pk_flags; // return to custom hub after this map
		admin_sv_cfg();
	}
};

//void() hub_timer_think =
//{
//	self.owner.think = hub_control_use;
//	self.owner.nextthink = time + 0.1;
//};

/// re-write with strcat & centerprint

void(float maxplayers, float votecast, float timemins, float timerel) playerVotesTimeLeft =
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_CENTERPRINT);

	// '\n\n\n\n\n\n\n\n\n\n\nVotes Cast: '
	WriteB3(MSG_ONE, 657930);
	WriteB3(MSG_ONE, 657930);
	WriteB3(MSG_ONE, 657930);
	WriteB3(MSG_ONE, 5638666);
	WriteB3(MSG_ONE, 6648943);
	WriteB3(MSG_ONE, 4399219);
	WriteB3(MSG_ONE, 7631713);
	WriteB3(MSG_ONE, 8250);

	WriteBFloat(MSG_ONE, votecast);

	// '/'
	WriteB3(MSG_ONE, 47);

	WriteBFloat(MSG_ONE, maxplayers);

	// '		 Time Left:'
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 5513248);
	WriteB3(MSG_ONE, 6647145);
	WriteB3(MSG_ONE, 6638624);
	WriteB3(MSG_ONE, 3830886);

	if (timemins < 10)
	{
		// '0'
		WriteB3(MSG_ONE, 12320);
	}
	else
	{
		// ' '
		WriteB3(MSG_ONE, 32);
	}

	WriteBFloat(MSG_ONE, timemins);

	if (timerel < 10)
	{
		// ':0'
		WriteB3(MSG_ONE, 12346);
	}
	else
	{
		// ':'
		WriteB3(MSG_ONE, 58);
	}

	WriteBFloat(MSG_ONE, timerel);
	WriteByte(MSG_ONE, 0);
};



float hubStartTime;
void() hub_control_status =
{
	if (self.class_select == "class_bot") return;

	// print some information
	getHighestScores();

	local string str1, str2, str3, srch;
	local float timemins, timedef, votecast, maxplayers;
	local entity pl;

	if (self.map == "painkeep")
	{
		str1 = "pk ";
	}
	else
	{
		str1 = self.map;
	}

	if (first.cnt > 0)
	{
		if (self.attack_state == 0)
		{
			if (first.map == "painkeep")
			{
				str2 = "pk ";
			}
			else
			{
				str2 = first.map;
			}

			if (self.map == string_null)
			{
				str3 = ftos(first.cnt);
				centerprint(self, "\n\n\n\n\n\n\n\n\n\n\nPlease Vote						 Lead: ", str2, " [", str3, "]");
			}
			else
			{
				str3 = ftos(first.cnt);
				centerprint(self, "\n\n\n\n\n\n\n\n\n\n\nYou Voted For: ", str1, "			 Lead: ", str2, " [", str3, "]");
			}

			self.attack_state = 1;
			return;
		}
	}

	if (first != second)
	if (second.cnt > 0)
	{
		if (self.attack_state == 1)
		{
			if (second.map == "painkeep")
			{
				str2 = "pk ";
			}
			else
			{
				str2 = second.map;
			}

			if (self.map == string_null)
			{
				str3 = ftos(second.cnt);
				centerprint(self, "\n\n\n\n\n\n\n\n\n\n\nPlease Vote						Second: ", str2, " [", str3, "]");
			}
			else
			{
				str3 = ftos(second.cnt);
				centerprint(self, "\n\n\n\n\n\n\n\n\n\n\nYou Voted For: ", str1, "		 Second: ", str2, " [", str3, "]");
			}
			self.attack_state = 2;
			return;
		}
	}

	if (first.cnt == 0 || first == second || second.cnt == 0 || self.attack_state == 2)
	{
		timemins = 0;
		if (hubStartTime > time)
		{
			timedef = (hubStartTime - time);
			timemins = timedef / 60;
			timemins = floor(timemins);
			timedef = (hubStartTime - time) - (timemins * 60);
		}
		else
		{
			timedef = 0;
		}

		// count the numbeer of votes cast
		srch = "player"; // *bot
		pl = find(world, classname, "player");
		if (!pl)
		{
			srch = OBSERVER;
			pl = find(world, classname, srch);
		}
		if (!pl) // this shouldnt ever be possible! - even on a dedicated server running only pk*s
		{
			srch = "pk*bot";
			pl = find(world, classname, srch);
		}
		maxplayers = votecast = 0;
		while (pl != world)
		{
			if (pl.disconnectPlayer == 0)
			{
				if (pl.map != string_null)
					votecast = votecast + 1;

				maxplayers = maxplayers + 1;
			}

			pl = find(pl, classname, srch);
			if (!pl)
			if (srch == "player") // find jafo now
			{
				srch = OBSERVER;
				pl = find(world, classname, srch);
			}
			if (!pl)
			if (srch == OBSERVER) // *bot - search out bots too
			{
				srch = "pk*bot";
				pl = find(world, classname, srch);
			}
		}
		playerVotesTimeLeft(maxplayers, votecast, timemins, timedef);

		self.attack_state = 0;
	}
};



void() hub_control =
{
//	local entity timer;
	local float temp1;

	// if we're not in deathmatch, then we remove this thing
	if (!deathmatch)
	{
		remove(self);
		return;
	}

	if (theHub)
	{
// Cataboligne 10.2.8 - improvment:
// already have a hub - why not remove and continue?
#ifdef warning
		if (WARNING & 1) bprint("\n*** warning:\nMap tried to create a second hub - removing.\n\n");
#endifdef
		remove(self);
		return;
	}
	theHub = self;

//	pk_map =  // deprecated - now indicates a true (recognized) pk map
	PK = TRUE; // *pk - in case its not an official pk hub

// either triggered to by time
	if (self.targetname)
	{
		self.use = hub_control_use;
	}
	// activated or timeout?
	else 
	{
		if (!self.wait) self.wait = 120; // Cataboligne - if no self.wait, why not just pick a default?
		self.think = hub_control_use;
		// create timer
//		timer = spawn();
//		timer.classname = "hub_control_timer";
//		timer.think = hub_timer_think;
//		timer.owner = self;

		// let server override this time
		temp1 = (pk_flags & PK_TP_TIMEMASK) * 60;
		if (temp1 > 0)
			hubStartTime = self.nextthink = time + temp1;
//			timer.nextthink = time + temp1;
		else
			hubStartTime = self.nextthink = time + self.wait;
//			timer.nextthink = time + self.wait;
	}

//	self.think = hub_control_status;
//	self.nextthink = time + 30.0;

// custom hub check - set alias if map is defined
	if (world.model == "maps/hub2.bsp") // allow renamed start.bsp from expansion pack & pk artifacts to work thru custom hub
	{
		self.map = "hub2";
	}
	else if (world.model == "maps/hub3.bsp")
	{
		self.map = "hub3";
	}
	else if (world.model == "maps/arc_hub.bsp") // Cataboligne - 10.25.11 - added archon hub
	{
		self.map = "arc_hub";
	}
	if (self.map)
	{
		custom_hub_loaded = TRUE;
		localcmd("alias hubmap \"changelevel ");
		localcmd(self.map);
		localcmd("\"\n");
	}

	// so later levels know about it...
	pk_flags = pk_flags | PK_SF_HUB;
	inHubMap = 1;
	admin_sv_cfg();
};

void() GoBack =
{
	local entity spot;

	// get rid of any dcam
	if (self.oldenemy)
	if (self.oldenemy.classname == "deadcam")
	{
		remove(self.oldenemy);
		self.oldenemy = world;
	}

	// teleport someplace and then die
	self.takedamage = DAMAGE_AIM;
	self.voteIntermission = 0;

	// he's changing his vote
	spot = findMap(self.map);
	// decrement his old vote
	if (spot.cnt > 0)
		spot.cnt = spot.cnt - 1;

	self.map = string_null;
	T_Damage(self, self, self, 5000);

	// JON: Tell them that they have cancled their vote
	self.revotemsg = -1;
	self.hubstartupmessage = time + 10;
};


void(string mapName) findAndPrintMapName =
{
	local entity e;
	if (first.map == mapName) e = first;
	else e = second;

	if (mapName == "painkeep")
	{
		// 'PainKeep'
		WriteB3(MSG_ONE, 6906192);
		WriteB3(MSG_ONE, 6638446);
		WriteB3(MSG_ONE, 28773);

	}
	else if (mapName == "pk0")
	{
		// 'pk0'
		WriteB3(MSG_ONE, 3173232);
	}
	else if (mapName == "pk1")
	{
		// 'pk1'
		WriteB3(MSG_ONE, 3238768);
	}
	else if (mapName == "pk2")
	{
		// 'pk2'
		WriteB3(MSG_ONE, 3304304);
	}
	else if (mapName == "pk3")
	{
		// 'pk3'
		WriteB3(MSG_ONE, 3369840);
	}
	else if (mapName == "pk4")
	{
		// 'pk4'
		WriteB3(MSG_ONE, 3435376);
	}
	else if (mapName == "pk5")
	{
		// 'pk5'
		WriteB3(MSG_ONE, 3500912);
	}
	else if (mapName == "pk6")
	{
		// 'pk6'
		WriteB3(MSG_ONE, 3566448);
	}
	else if (mapName == "pk7")
	{
		// 'pk7'
		WriteB3(MSG_ONE, 3631984);
	}
	else if (mapName == "pk8")
	{
		// 'pk8'
		WriteB3(MSG_ONE, 3697520);
	}
	else if (mapName == "pk9")
	{
		// 'pk9'
		WriteB3(MSG_ONE, 3763056);
	}
	else if (mapName == "pk10")
	{
		// 'pk10'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 48);
	}
	else if (mapName == "pk11")
	{
		// 'pk11'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 49);
	}
	else if (mapName == "pk12")
	{
		// 'pk12'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 50);
	}
	else if (mapName == "pk13")
	{
		// 'pk13'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 51);
	}
	else if (mapName == "pk14")
	{
		// 'pk14'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 52);
	}
	else if (mapName == "pk15")
	{
		// 'pk15'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 53);
	}
	else if (mapName == "pk16")
	{
		// 'pk16'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 54);
	}
	else if (mapName == "pk17")
	{
		// 'pk17'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 55);
	}
	else if (mapName == "pk18")
	{
		// 'pk18'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 56);
	}
	else if (mapName == "pk19")
	{
		// 'pk19'
		WriteB3(MSG_ONE, 3238768);
		WriteB3(MSG_ONE, 57);
	}
	else if (mapName == "pk20")
	{
		// 'pk20'
		WriteB3(MSG_ONE, 3304304);
		WriteB3(MSG_ONE, 48);
	}
	else if (e.model == "progs/hub_port.mdl")
	{
		if (e.mangle != '0 0 0')
		{
			WriteB3(MSG_ONE, e.mangle_x); // vector stored float for 9 char of map name
			WriteB3(MSG_ONE, e.mangle_y);
			WriteB3(MSG_ONE, e.mangle_z);
			WriteB3(MSG_ONE, 32);
		}
		else
		{
			WriteB3(MSG_ONE, 7566691); // 'custom map' - hub admin didnt supply a vector xlate msg
			WriteB3(MSG_ONE, 7171956);
			WriteB3(MSG_ONE, 6384928);
		}
	}
	else
	{
//		if (PK_ART)
			if (pk_art_hubmapmsg(mapName)) // Cataboligne 8.19.9 purify - pk artifacts
				return;

		// 'Unknown Map, Please Extend Print Routine'
		WriteB3(MSG_ONE, 7040597);
		WriteB3(MSG_ONE, 7827310);
		WriteB3(MSG_ONE, 5054574);
		WriteB3(MSG_ONE, 2912353);
		WriteB3(MSG_ONE, 7098400);
		WriteB3(MSG_ONE, 7561573);
		WriteB3(MSG_ONE, 4530277);
		WriteB3(MSG_ONE, 6648952);
		WriteB3(MSG_ONE, 2122862);
		WriteB3(MSG_ONE, 6910544);
		WriteB3(MSG_ONE, 2126958);
		WriteB3(MSG_ONE, 7696210);
		WriteB3(MSG_ONE, 7235956);
		WriteB3(MSG_ONE, 101);
	}
};

void(float maxplayers, float votecast, float timemins, float timerel) playerIntermissionVotesTimeLeft =
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_CENTERPRINT);

	// '\n\nCurrent voting statistics: \n\nTotal players: '
	WriteB3(MSG_ONE, 4393482);
	WriteB3(MSG_ONE, 7500405);
	WriteB3(MSG_ONE, 7630437);
	WriteB3(MSG_ONE, 7304736);
	WriteB3(MSG_ONE, 7235956);
	WriteB3(MSG_ONE, 7544935);
	WriteB3(MSG_ONE, 7627124);
	WriteB3(MSG_ONE, 7631721);
	WriteB3(MSG_ONE, 7562089);
	WriteB3(MSG_ONE, 663610);
	WriteB3(MSG_ONE, 7296010);
	WriteB3(MSG_ONE, 7102836);
	WriteB3(MSG_ONE, 7106592);
	WriteB3(MSG_ONE, 6650209);
	WriteB3(MSG_ONE, 3830642);
	WriteB3(MSG_ONE, 32);

	WriteBFloat(MSG_ONE, maxplayers);

	// '										 '
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);

	// '\nRemaining to vote: '
	WriteB3(MSG_ONE, 6640138);
	WriteB3(MSG_ONE, 6906221);
	WriteB3(MSG_ONE, 7235950);
	WriteB3(MSG_ONE, 7610471);
	WriteB3(MSG_ONE, 7741551);
	WriteB3(MSG_ONE, 6648943);
	WriteB3(MSG_ONE, 8250);

	votecast = maxplayers - votecast;
	WriteBFloat(MSG_ONE, votecast);

	// '										 '
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);

	if (first.cnt > 0)
	{
		// '\nLeading level: '
		WriteB3(MSG_ONE, 6638602);
		WriteB3(MSG_ONE, 6906977);
		WriteB3(MSG_ONE, 2123630);
		WriteB3(MSG_ONE, 7759212);
		WriteB3(MSG_ONE, 3828837);
		WriteB3(MSG_ONE, 32);

		findAndPrintMapName(first.map);

		// ', '
		WriteB3(MSG_ONE, 8236);

		WriteBFloat(MSG_ONE, first.cnt);

		// '										 '
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);
		WriteB3(MSG_ONE, 2105376);

		if (first != second)
		if (second.cnt > 0)
		{
			// '\nSecond place: '
			WriteB3(MSG_ONE, 6640394);
			WriteB3(MSG_ONE, 7237475);
			WriteB3(MSG_ONE, 7348324);
			WriteB3(MSG_ONE, 6513004);
			WriteB3(MSG_ONE, 2112101);

			findAndPrintMapName(second.map);

			// ', '
			WriteB3(MSG_ONE, 8236);

			WriteBFloat(MSG_ONE, second.cnt);

			// '										 '
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
			WriteB3(MSG_ONE, 2105376);
		}
	}

	// '\nTime Remaining: '
	WriteB3(MSG_ONE, 6902794);
	WriteB3(MSG_ONE, 2123117);
	WriteB3(MSG_ONE, 7169362);
	WriteB3(MSG_ONE, 7235937);
	WriteB3(MSG_ONE, 6778473);
	WriteB3(MSG_ONE, 8250);

	if (timemins < 10)
	{
		// '0'
		WriteB3(MSG_ONE, 12320);
	}
	else
	{
		// ' '
		WriteB3(MSG_ONE, 32);
	}

	WriteBFloat(MSG_ONE, timemins);

	if (timerel < 10)
	{
		// ':0'
		WriteB3(MSG_ONE, 12346);
	}
	else
	{
		// ':'
		WriteB3(MSG_ONE, 58);
	}

	WriteBFloat(MSG_ONE, timerel);

	// '										 '
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);
	WriteB3(MSG_ONE, 2105376);

	// '\n\nTo cancel your current vote \nand vote again, hit FIRE to re-enter.'
	WriteB3(MSG_ONE, 5507594);
	WriteB3(MSG_ONE, 6496367);
	WriteB3(MSG_ONE, 6516321);
	WriteB3(MSG_ONE, 2124901);
	WriteB3(MSG_ONE, 7696249);
	WriteB3(MSG_ONE, 6496370);
	WriteB3(MSG_ONE, 7500405);
	WriteB3(MSG_ONE, 7630437);
	WriteB3(MSG_ONE, 7304736);
	WriteB3(MSG_ONE, 2123124);
	WriteB3(MSG_ONE, 7233802);
	WriteB3(MSG_ONE, 7741540);
	WriteB3(MSG_ONE, 6648943);
	WriteB3(MSG_ONE, 6775072);
	WriteB3(MSG_ONE, 7235937);
	WriteB3(MSG_ONE, 6823980);
	WriteB3(MSG_ONE, 2126953);
	WriteB3(MSG_ONE, 5392710);
	WriteB3(MSG_ONE, 7610437);
	WriteB3(MSG_ONE, 7479407);
	WriteB3(MSG_ONE, 6630757);
	WriteB3(MSG_ONE, 6648942);
	WriteB3(MSG_ONE, 11890);

	WriteByte(MSG_ONE, 0);
};



void() WaitForVotesThink =
{
	// if intermission mode finished abnormally
	if (self.voteIntermission == 0)
		return;

// NOTE: bots only come here if they touched a vote portal
	if (self.class_select == "class_bot") // bots dont get status update
	{
		self.model = string_null; // went thru a vote portal - clear body

		self.nextthink = time + 0.333;
		if (random() < 0.85) // dont let them exit vote often
		{
			self.button0 = self.button1 = self.button2 = 0;
			return;
		}

		if (!self.button0 && !self.button1 && !self.button2)
			return;

		GoBack ();
		return;
	}

	dead_cam_set(); // Cataboligne - 5.12.10 - dead cam while voted

	// next think
	self.nextthink = time + 0.1;

	if (self.messagetimeout < time)
	{
		sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM); // turn off walk sounds
		stuffcmd(self, "cl_bob 0\n"); // stop bob so voted view isnt borked

		if (self.attack_state)
		{
			if (self.laststattime < time)
			{
				self.attack_state = 0;
			}

		centerprint(self, "You have just voted for ", self.map, ".\n\nPlease wait here while all other \nplayers finish voting.	Once all votes \nhave been cast, the winning \nlevel will start.\n");

			return;
		}
		else
		{
			// print some information
			getHighestScores();

			local float timemins, timedef, votecast, maxplayers, novote;
			local entity pl;

			timemins = 0;
			if (hubStartTime > time)
			{
				timedef = (hubStartTime - time);
				timemins = timedef / 60;
				timemins = floor(timemins);
				timedef = (hubStartTime - time) - (timemins * 60);
			}
			else
			{
				timedef = 0;
			}

			// count the numbeer of votes cast
			local string srch;
			local entity e;
			srch = "player";
			pl = find(world, classname, "player");
			if (!pl)
			{
				srch = OBSERVER;
				pl = find(world, classname, srch);
			}
			if (!pl) // this shouldnt ever be possible! - even on a dedicated server running only pk*s
			{
				srch = "pk*bot";
				pl = find(world, classname, srch);
			}
			maxplayers = votecast = 0;
			while (pl != world)
			{
				if (pl.disconnectPlayer == 0)
				{
					if (pl.map != string_null)
						votecast = votecast + 1;
					else if (pl.classname == OBSERVER) novote = novote + 1; // non voting observer
					else
					{
						e = pl; // save for the 1 bot scenario
					}

					maxplayers = maxplayers + 1;
				}

				pl = find(pl, classname, srch);

				if (!pl)
				if (srch == "player") // find jafo now
				{
					srch = OBSERVER;
					pl = find(world, classname, srch);
				}
				if (!pl)
				if (srch == OBSERVER) // *bot - search out bots too
				{
					srch = "pk*bot";
					pl = find(world, classname, srch);
				}
			}

			playerIntermissionVotesTimeLeft(maxplayers, votecast, timemins, timedef);

// trick when 1 bot is left to vote
			if ((maxplayers - votecast - novote) == 1)
			if (e.class_select == "class_bot")
			if (random() < 0.2)
			{
				pl = self;
				self = e;
				if (bot_vote(0.5))  // if voted, bounce dog
				{
					self.voteIntermission = 1;
					self = theHub;
 					hub_control_use();
					return;
				}
				self = pl;
			}

		}

		self.messagetimeout = time + 1;
	}
	else if (self.attack_state)
	{
		return;
	}

	if (!self.button0 && !self.button1 && !self.button2)
		return;

	GoBack ();
};

// e is the player / bot
void(entity e) WaitForVotes =
{
	local entity	pos;

	//intermission_running = 1;

	pos = SelectSpawnPoint ();
	ClearSpawnPoint(pos);

	e.view_ofs = '0 0 0';
	e.angles = e.v_angle = pos.angles;
	e.fixangle = TRUE;		// turn this way immediately
	e.takedamage = DAMAGE_NO;
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	e.invincible_finished = 0;
	e.modelindex = 0;
	e.attack_state = 1;
 	e.aflag = 0;
	e.laststattime = time + 8.0;
	setorigin (e, pos.origin);

	e.currentammo = 0;
	e.weaponmodel = string_null;
	e.weaponframe = 0;

	// wait a rel before allowing coming back
	e.nextthink = time + 0.1;
	e.think = WaitForVotesThink;
	e.voteIntermission = 1;
};


// Cataboligne - 5.12.10 - special, bot voting

// fn(bot_votereveal) - id bot vote
// fn(bot_vote) - chance for bot to vote
// cn - random 0 - 1 for bot to vote - .12 of this for copy cat
// returns true if bot voted - so ai can stop other stuff

void(entity bt) bot_votereveal =
{
	bprint("\b");
	bprint(bt.netname);
	bprint(": I just voted for ");
	bprint(bt.map);
	bprint("\n");

// fixed bots leaving "live" body behind
// here for common area - means we cant get rid of this fn if we dont want to reveal bot votes
// bots still seem to leave posed bodys somehow?
	if (!bt.deadflag)
		bt.model = string_null;
};

// Cataboligne - 10.30.12 - should not have a live body hanging around after voting - set frames for pk*bots that voted

void(entity bt) pk_voteframe =
{
//		if (bt.model != string_null) bt.model = string_null; 
	if (bt.model != string_null && bt.deadflag)
	if (bt.frame != $axdeth9)
	if (bt.frame != $deathb9)
	if (bt.frame != $deathc15)
	if (bt.frame != $deathd9)
	if (bt.frame != $deathe9)
	if (bt.frame != $deatha11)
	{
		local float r;
		r = random();
		if (r < 0.2) bt.frame = $deatha11; 
		if (r < 0.4) bt.frame = $deathb9; 
		if (r < 0.6) bt.frame = $deathc15; 
		if (r < 0.8) bt.frame = $deathd9; 
		if (r < 0.9) bt.frame = $deathe9; 
		else bt.frame = $axdeth9; 
	}
}

// Cataboligne - 5.12.10 - sneak in bot votes (yep, this is labor union heavy handedness - since they dont seem to be real keen on going to the polls...)

// despite my best efforts bots dont like to jump thru vote portals - so just cheat em' in when the bot dies

// NOTE: if not going to do this while bot is dead, find way to hide bot disappearance from players view

float(float cn) bot_vote =
{
	local entity e;
	local string mpv;
	local float f, r;

	if (self.map != string_null) return(TRUE); // voted
	if (self.classname != "player") return(FALSE); // not eligible
	if (self.netname == string_null) return(FALSE); // who are you?
//	if (!inHubMap) return(FALSE); // not on hub

	if (random() < (0.12 * cn))													// copy cat - bot copies some players vote
	{
		e = find(world, classname, "player");
		while (e)
		{
			if (e.map != string_null)
			{
				if (mpv == string_null) mpv = e.map; // take first we find
				else if (random() < 0.5) mpv = e.map; // randomly take others
			}
			e = find(e, classname, "player");
		}
		if (mpv != string_null)
		{
			e = findMap (mpv);
			if (e)
			{
				e.cnt = e.cnt + 1;
				self.map = mpv;
				bot_votereveal(self);
//				WaitForVotes(self);
				self.stack1 = "botvoted"; // Cataboligne - 10.30.12 - let death frames finish out - frikbot
				if (self.class_select == "class_pk*bot") pk_voteframe(self);
//				self.nextthink = -1;
				return(TRUE);
			}
		}
	}
	if (random() < cn)													// bot has unique vote
	{
		f = countMaps();
		if (f > 0)
		{
			r = random() * f;
			e = getMap(r);
			if (e)
			{
				e.cnt = e.cnt + 1;
				self.map = e.map;
				bot_votereveal(self);
//				WaitForVotes(self);
				self.stack1 = "botvoted"; // Cataboligne - 10.30.12 - let death frames finish out - frikbot
				if (self.class_select == "class_pk*bot") pk_voteframe(self);
//				self.nextthink = -1;
				return(TRUE);
			}
		}
	}
	return(FALSE);
};
