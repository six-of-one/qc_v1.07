float(string s) strlennocol = #476;

const float true	= 1;
const float false	= 0;

float (float statnum)							getstatf = #330;
float (float statnum)							getstati = #331;
string (float statnum)							getstats = #332;

float g_nVideoWidth;
float g_nVideoHeight;

#define HUDEFFECT_STATE_NONE							0
#define HUDEFFECT_STATE_STARTING						1
#define HUDEFFECT_STATE_ENDING						2

.string		message;

float			g_bPreviousFrameFluidContents;
// Map Name Display
float			g_fMapNameDisplayState;
vector			g_vMapNameDisplaySize;
float			g_fMapNameDisplayAlpha;
string			g_strMapDisplayName;

vector			g_vMapNameDisplayLocation;



#define HUD_MAPINFO_POS_X								25
#define HUD_MAPINFO_POS_Y								75



void HUD_PrepareMapDisplayName()
{ // HUD - Prepare Map Display Name
	local float nLength;
	local string strNameWithoutBSP;
	// Acquire Filename + .bsp
	g_strMapDisplayName = substring(mapname, 5, 100);
	// Cull .bsp
	nLength = strlen(g_strMapDisplayName);
	strNameWithoutBSP = substring(g_strMapDisplayName, 0, nLength - 4);
	// Append Name
	g_strMapDisplayName = strcat(world.message, " (", strNameWithoutBSP, ")");
	
	// Zone String
	g_strMapDisplayName = strzone(g_strMapDisplayName);
}


void HUD_UpdateMapNameDisplay()
{ // Update Map Name Display
	if(g_fMapNameDisplayState == HUDEFFECT_STATE_STARTING)
	{
		g_fMapNameDisplayAlpha += (frametime * 0.25);
		
		if(g_fMapNameDisplayAlpha > 1)
		{
			g_fMapNameDisplayState = HUDEFFECT_STATE_ENDING;
			g_fMapNameDisplayAlpha = 1;
		}
	}
	else
	{
		g_fMapNameDisplayAlpha -= (frametime * 0.38);
		
		if(g_fMapNameDisplayAlpha < 0)
		{
			g_fMapNameDisplayState = HUDEFFECT_STATE_NONE;
			g_fMapNameDisplayAlpha = 0;
		}
	}
	
	if( random() < 0.03)
	{ // Jiggle It Around
		local vector vLocation;
		vLocation = g_vMapNameDisplayLocation;
		vLocation_x += random() * 4;
		vLocation_y += random() * 4;
		
		// Draw Map Name
		drawstring(vLocation, world.message, g_vMapNameDisplaySize, '1 0 0', g_fMapNameDisplayAlpha, 0);
	}
	else
		// Draw Map Name
		drawstring(g_vMapNameDisplayLocation, world.message, g_vMapNameDisplaySize, '1 0 0', g_fMapNameDisplayAlpha, 0);
}

/*
void HUD_UpdateMapNameDisplay2()
{ // Update Map Name Display
	if(g_fMapNameDisplayState == HUDEFFECT_STATE_STARTING)
	{
		g_fMapNameDisplayAlpha += (frametime * 0.25);
		
		if(g_fMapNameDisplayAlpha > 1)
		{
			g_fMapNameDisplayState = HUDEFFECT_STATE_ENDING;
			g_fMapNameDisplayAlpha = 1;
		}
	}
	else
	{
		g_fMapNameDisplayAlpha -= (frametime * 0.38);
		
		if(g_fMapNameDisplayAlpha < 0)
		{
			g_fMapNameDisplayState = HUDEFFECT_STATE_NONE;
			g_fMapNameDisplayAlpha = 0;
		}
	}
	
	// Draw Map Name
	drawstring(g_vMapNameDisplayLocation, world.message, g_vMapNameDisplaySize, '1 0 0', g_fMapNameDisplayAlpha, 0);
}
*/

void HUD_BeginMapNameDisplay()
{ // Begin Map Name Display
	if(g_fMapNameDisplayState == HUDEFFECT_STATE_NONE)
	{
		// Calculate Location (do it here, instead of in the update)
		// Calculate Pixel Width of Display
		local float nWidth;
			nWidth = strlen(world.message) * 20;
			if(nWidth > g_nVideoWidth)
			{ // Too Large; Shrink it Big Time
				g_vMapNameDisplaySize_x = 13;
				nWidth = strlen(world.message) * 13;
			}
			else
				g_vMapNameDisplaySize_x = 20;
			g_vMapNameDisplaySize_y = g_vMapNameDisplaySize_x;
			g_vMapNameDisplaySize_z = 0;
			
		// Determine Center Point
		g_vMapNameDisplayLocation_x = (g_nVideoWidth - nWidth) / 2;
		
		// Assign Relative Coords
		g_vMapNameDisplayLocation_y = g_nVideoHeight / 3.7;
		g_vMapNameDisplayLocation_z = 0;
		// Assign State
		g_fMapNameDisplayState = HUDEFFECT_STATE_STARTING;
		// Assign Alpha
		g_fMapNameDisplayAlpha = 0;
	}
}


void UpdateFluidContents(float bForceUpdate)
{ // Update Fluid Contents
	local string strCommand;
	local string strCDTrack;
	// Determine Origin Location
	vector vOrigin;
		vOrigin = pmove_org;
		vOrigin_z += getstati(STAT_VIEWHEIGHT);
	// Acquire Current Contents
	local float nContents;
		nContents = pointcontents(vOrigin);
		
	if(nContents != g_bPreviousFrameFluidContents || bForceUpdate)
	{ // New Contents
		strCommand = "fog ";
		
		switch(nContents)
		{
			case CONTENT_WATER:
				strCommand = strcat(strCommand, "2.3 0.12 0.12 0.11 0.97\n");
				strCDTrack = "Underwater";
				break;
			case CONTENT_SLIME:
				strCommand = strcat(strCommand, "1.9 0.1 0.24 0.1 0.8\n");
				strCDTrack = "Underwater";
				break;
			case CONTENT_LAVA:
				strCommand = strcat(strCommand, "0.8 0.35 0.1 0.0 1\n");
				strCDTrack = "Underwater";
				break;
			default:
				// No Fluid
				strCommand = strcat(strCommand, "0\n");
				strCDTrack = "";
				break;
		}
		
		/*if(strCDTrack != "")
		{ // Append CD Track
			if(strCDTrack == g_strActiveCDTrack)
				strCommand = strcat(strCommand, "cd resume\n");
			else
			{
				strCommand = strcat(strCommand, "cd loop ", strCDTrack, "\n");
				// Update Active CD Track
				g_strActiveCDTrack = strCDTrack;
			}
		}
		else
		{ // Pause CD Track
			strCommand = strcat(strCommand, "cd pause\n");
		}*/
		
		// Execute Command
		localcmd(strCommand);
	}
	
	// Update Previous Frame Fluid Contents
	g_bPreviousFrameFluidContents = nContents;
}