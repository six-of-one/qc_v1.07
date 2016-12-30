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


//- NOTE: cfg/map/{hubmap}.cfg  _must_ call  cfg/motd.cfg


void() updateStatusDisplay =
{
//	local string Line5;

	if (!self.ishuman) // bots dont get status update
		return;

	if (inHubMap) // Cataboligne - 8.22.9 - custom hubs can cause this message on non pk / non hub maps
	{
		if (!self.messagetimeout)			// let the motd fly for X secs
		{
			self.messagetimeout = time + 7;
//			self.laststattime = time + 17;
			self.message = string_null;
		}

		if (self.messagetimeout > time)
		{
			return;
		}

// heh heh - scroll wheel of pain!
		s0__ = "|";
		if ((time * 5 & 3) == 1) s0__ = "\\";
		else if ((time * 5 & 3) == 2) s0__ = "-";
		else if ((time * 5 & 3) == 3) s0__ = "/";

		if (self.messagetimeout > 0)
		{
			if (self.revotemsg < 0)
				pk_centerprint(self, "Vote Cancelled.\n\nRecast your vote\n",motd2,s0__, self.message);
			else
				pk_centerprint(self, "Vote - enter the portal for the level you want\nOnce all players vote, the winning level loads.\n\nфире - clear this message",motd2,s0__, self.message);


			self.messagetimeout = time + 0.2;
		}
	
		if (self.laststattime > time)
		{
			return;
		}

		if (self.messagetimeout < 0) // fire button moves message to infobar
		{
			stuffcmd(self, strcat("infobar 3 \"",s0__,strreplace("\n", " ", self.message), "\"\n"));
		}

		self.laststattime = time + 1;

		// display the HubMap data...
		hub_control_status();
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


