 /* ::-::
 *
 * Cataboligne
 *
 * file: motd.qc 
 *
 * date: 016.3.9
 *
 * qc - painkeep module - message of the day qc
 *
 */

// ConnectMessage - display a message on connect.
void() connectmessage =
{
	local string Line3,Line5,Line7;

// web site promo & id
// = http://www.moddb.com/mods/chaos-archon/
	
	Line3 = vmotd;
	Line5 = "\nsee:           \nhttp://www.moddb.com/mods/";
//	Line5 = "\nsee:           \nhttp://www.moddb.com/downloads/";
	Line7 = "\n              for details";
//	\b_-=\b* \bC\bataboligne\n

if (self.classname == "player" && self.ishuman) // self.class_select != "class_bot")
{
	// The welcome message
	if (self.msgcount == 0)
	{
	  pk_centerprint(self, "\n", "\n\n", Line3,"\b*\n","\nsee:           \nthe following website",string_null,Line7);
	}
	else if (self.msgcount == 1)
	{
	  // Anti client side bots messges.
	  if (DONTALLOWBOTS == 1)
	  {
	    sprint(self,"No Bots\n");
	    sprint(self,"No Bots Please\n");
	    sprint(self,"Humans Only Please\n");
	  }

	  pk_centerprint(self, "W\n", "\n#\n", Line3,"\b=*\n",Line5,"\b*\b",Line7);
	}
	else if (self.msgcount == 2)
	{
	  pk_centerprint(self, "We\n", "\n# \n", Line3,"\b-=*\n",Line5,"\bc*\b",Line7);
	}
	else if (self.msgcount == 3)
	{
	  pk_centerprint(self, "Wel\n", "\n# 6\n", Line3,"\b_-=*\n",Line5,"\bch*\b",Line7);
	}
	else if (self.msgcount == 4)
	{
	  pk_centerprint(self, "Welc\n", "\n# 6 \n", Line3,"\b_-=\b*\n",Line5,"\bcha*\b",Line7);
	}
	else if (self.msgcount == 5)
	{
	  pk_centerprint(self, "Welco\n", "\n# 6 P\n", Line3,"\b_-=\b* \n",Line5,"\bchao*\b",Line7);
	}
	else if (self.msgcount == 6)
	{
	  pk_centerprint(self, "Welcom\n", "\n# 6 Pr\n", Line3,"\b_-=\b* C\n",Line5,"\bchaos*\b",Line7);
	}
	else if (self.msgcount == 7)
	{
	  pk_centerprint(self, "Welcome\n", "\n# 6 Pro\n", Line3,"\b_-=\b* Ca\n",Line5,"\bchaos|\b",Line7);
	}
	else if (self.msgcount == 8)
	{
	  pk_centerprint(self, "Welcome \n", "\n# 6 Prod\n", Line3,"\b_-=\b* Cat\n",Line5,"\bchaos/\b",Line7);
	}
	else if (self.msgcount == 9)
	{
	  pk_centerprint(self, "Welcome t\n", "\n# 6 Produ\n", Line3,"\b_-=\b* Cata\n",Line5,"\bchaos-\b",Line7);
	}
	else if (self.msgcount == 10)
	{
	  pk_centerprint(self, "Welcome to\n", "\n# 6 Produ\n", Line3,"\b_-=\b* Catab\n",Line5,"\bchaos\\\b",Line7);
	}
	else if (self.msgcount == 11)
	{
	  pk_centerprint(self, "Welcome to \n", "\n# 6 Produc\n", Line3,"\b_-=\b* Catabo\n",Line5,"\bchaos|\b",Line7);
	}
	else if (self.msgcount == 12)
	{
	  pk_centerprint(self, "Welcome to A\n", "\n# 6 Produc\n", Line3,"\b_-=\b* Catabol\n",Line5,"\bchaos*\b",Line7);
	}
	else if (self.msgcount == 13)
	{
	  pk_centerprint(self, "Welcome to Ar\n", "\n# 6 Product\n", Line3,"\b_-=\b* Cataboli\n",Line5,"\bchaos-*\b",Line7);
	}
	else if (self.msgcount == 14)
	{
	  pk_centerprint(self, "Welcome to Arc\n", "\n# 6 Product\n", Line3,"\b_-=\b* Catabolig\n",Line5,"\bchaos-a*\b",Line7);
	}
	else if (self.msgcount == 15)
	{
	  pk_centerprint(self, "Welcome to ArcH\n", "\n# 6 Producti\n", Line3,"\b_-=\b* Catabolign\n",Line5,"\bchaos-ar*\b",Line7);
	}
	else if (self.msgcount == 16)
	{
	  pk_centerprint(self, "Welcome to ArcHo\n", "\n# 6 Productio\n", Line3,"\b_-=\b* Cataboligne\n",Line5,"\bchaos-arc*\b",Line7);
	}
	else if (self.msgcount == 17)
	{
	  pk_centerprint(self, "Welcome to ArcHon\n", "\n# 6 Productio\n", Line3,"\b_-=*\b Cataboligne\n",Line5,"\bchaos-arch*\b",Line7);
	}
	else if (self.msgcount == 18)
	{
	  pk_centerprint(self, "Welcome to  ArcHon\n", "\n# 6 Production\n", Line3,"\b_-=\b* Cataboligne\n",Line5,"\bchaos-archo*\b",Line7);
	}
	else if (self.msgcount == 19)
	{
	  pk_centerprint(self, "Welcome to ArcHon\n", "\n# 6 Production\n", Line3,"\b_-=*\b Cataboligne\n",Line5,"\bchaos-archon*\b",Line7);
	}
//	else if (self.msgcount == 19)
//	{
//	  pk_centerprint(self, "Welcome to ArcHon!\n", "\nTeam Evolve\n", Line3,"\b_-=\b* Cataboligne\n",Line5,"\bchaos-archon/\b",Line7);
//	}
	else if (self.msgcount <= 20)
	{
	  pk_centerprint(self, "Welcome to ArcHon!\n", "\n# 6 Production\n", Line3,"\b_-=*\b Cataboligne\n",Line5,"chaos-archon/",Line7);
	}
	else if (self.msgcount > 20 && (time & 1))
	  pk_centerprint(self, "Welcome to ArcHon!\n", "\n# 6 Production\n", Line3,"\b_-=\b* Cataboligne\n",Line5,"\bchaos-archon/\b",Line7);
	else
	  pk_centerprint(self, "Welcome to ArcHon!\n", "\n# 6 Production\n", Line3,"\b_-=*\b Cataboligne\n",Line5,"chaos-archon/",Line7);
}

	if ((time & 3) == 3) self.msgcount = self.msgcount + 1;
};




void() updateStatusDisplay =
{
	local string Line3,Line5;

	if (!self.ishuman)
//	if (self.class_select == "class_bot") // bots dont get status update
		return;

	if (inHubMap) // Cataboligne - 8.22.9 - custom hubs can cause this message on non pk / non hub maps
	if (self.msgcount <= MOTDTIME)
	{
		if (!self.hubstartupmessage) self.hubstartupmessage = time + 15;
	  connectmessage();
	  return;
	}

	if (self.messagetimeout > time)
	{
	  return;
	}

	if (inHubMap)
	if (self.hubstartupmessage > time)
	{
// web site promo
		Line3 = motd2;
// heh heh - scroll wheel of pain!
		if ((time & 3) == 0) Line5 = "|";
		else if ((time & 3) == 1) Line5 = "\\";
		else if ((time & 3) == 2) Line5 = "-";
		else if ((time & 3) == 3) Line5 = "/";

		if (self.revotemsg < 0)
			pk_centerprint(self, "Vote Cancelled.\n\nYou must recast your vote");
		else
			pk_centerprint(self, "To cast your vote, enter the \nteleporter for the level you \nwish to play. Once all players have \nvoted, the winning level will begin.\n\n",Line3,Line5);
		self.messagetimeout = time + 1;
	}
	
	if (self.laststattime > time)
	{
		return;
	}


	if (inHubMap)
	{
		self.laststattime = time + 10;
	  
		// display the HubMap data...
		hub_control_status();
	}
	else
	{
		self.laststattime = time + 10;
	}
};




// functions to create centreprint network packets
void(float to, float f) WriteB3	=
{
	local float o;

	o = f & 255;
	if (!o)
		return;

	WriteByte(to, o);

	o = (f / 256) & 255;
	if (!o)
		return;

	WriteByte(to, o);

	o = (f / 65536) & 255;
	if (!o)
		return;

	WriteByte(to, o);
};


void(float to, float f) WriteBDigit =
{
	if (f < 1)
	{
		// '0'
		WriteByte(to, 48);
	}
	else if (f < 2)
	{
		// '1'
		WriteByte(to, 49);
	}
	else if (f < 3)
	{
		// '2'
		WriteByte(to, 50);
	}
	else if (f < 4)
	{
		// '3'
		WriteByte(to, 51);
	}
	else if (f < 5)
	{
		// '4'
		WriteByte(to, 52);
	}
	else if (f < 6)
	{
		// '5'
		WriteByte(to, 53);
	}
	else if (f < 7)
	{
		// '6'
		WriteByte(to, 54);
	}
	else if (f < 8)
	{
		// '7'
		WriteByte(to, 55);
	}
	else if (f < 9)
	{
		// '8'
		WriteByte(to, 56);
	}
	else
	{
		// '9'
		WriteByte(to, 57);
	}
};


void(float to, float f) intWriteBFloat =
{
	local float p, d;

	if (f <= 0)
		return;

	p = floor(f / 10);

	// mod(f, 10);
	d = f - (p * 10);

	intWriteBFloat(to, p);
	WriteBDigit(to, d);
};

void(float to, float f) WriteBFloat =
{
	local float p, d;

	f = floor(f);
	p = floor(f / 10);

	// mod(f, 10);
	d = f - (p * 10);

	intWriteBFloat(to, p);
	WriteBDigit(to, d);
};


