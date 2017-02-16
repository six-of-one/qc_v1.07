/*

Bits of extensions - these get copied from dpextensions.qc as needed
We also perform checkextensions to notify if features we use are missing.

*/

// CheckExtension
float(string s) checkextension = #99;

// critical=TRUE for anything that would cause the mod to crash, or major
// rendering errors which affect gameplay. This depends on the mod - one might
// depend on DP_ENT_ALPHA for gameplay, another might use it as mere eye-candy.
void(string s, float critical) vcheckextension =
{
	if (!checkextension(s))
	{
		localcmd("echo ");
	    if (critical)
			localcmd("^1CRITICAL ");
	    localcmd("^3(client) QSG extension required but not found: ");
	    localcmd(s);
	    localcmd("\n");
	}
};

// All extensions used should be checked here.
void() Check_Extensions =
{
	localcmd("echo Checking server extensions...\n");
	vcheckextension("FRIK_FILE", TRUE); // needed for the string functions to work
	vcheckextension("FTE_STRINGS", TRUE); // required for some other graphical stuff
	localcmd("echo Extensions check ok.\n");
};

// All extensions used should define builtins, fields and globals below this
// line.
// ---------------------------------------------------------------------------

//FRIK_FILE
//idea: FrikaC
//darkplaces implementation: LordHavoc
//builtin definitions:
float(string s) stof = #81; // get numerical value from a string
float(string filename, float mode) fopen = #110; // opens a file inside quake/gamedir/data/ (mode is FILE_READ, FILE_APPEND, or FILE_WRITE), returns fhandle >= 0 if successful, or fhandle < 0 if unable to open file for any reason
void(float fhandle) fclose = #111; // closes a file
string(float fhandle) fgets = #112; // reads a line of text from the file and returns as a tempstring
void(float fhandle, string s, ...) fputs = #113; // writes a line of text to the end of the file
float(string s) strlen = #114; // returns how many characters are in a string
string(string s1, string s2, ...) strcat = #115; // concatenates two or more strings (for example "abc", "def" would return "abcdef") and returns as a tempstring
string(string s, float start, float length) substring = #116; // returns a section of a string as a tempstring
vector(string s) stov = #117; // returns vector value from a string
string(string s, ...) strzone = #118; // makes a copy of a string into the string zone and returns it, this is often used to keep around a tempstring for longer periods of time (tempstrings are replaced often)
void(string s) strunzone = #119; // removes a copy of a string from the string zone (you can not use that string again or it may crash!!!)
//constants:
float FILE_READ = 0;
float FILE_APPEND = 1;
float FILE_WRITE = 2;
//cvars:
//pr_zone_min_strings : default 64 (64k), min 64 (64k), max 8192 (8mb)
//description:
//provides text file access functions and string manipulation functions, note that you may want to set pr_zone_min_strings in the worldspawn function if 64k is not enough string zone space.
//
//NOTE: strzone functionality is partially superseded by
//DP_QC_UNLIMITEDTEMPSTRINGS when longterm storage is not needed

//FTE_STRINGS
//idea: many
//darkplaces implementation: KrimZon
//description:
//various string manipulation functions
float(string str, string sub, float startpos) strstrofs = #221;
float(string str, float ofs) str2chr = #222;
string(float c, ...) chr2str = #223;
string(float ccase, float calpha, float cnum, string s, ...) strconv = #224;
string(float chars, string s, ...) strpad = #225;
string(string info, string key, string value, ...) infoadd = #226;
string(string info, string key) infoget = #227;
float(string s1, string s2, float len) strncmp = #228;
float(string s1, string s2) strcasecmp = #229;
float(string s1, string s2, float len) strncasecmp = #230;
// strconv parameters
float CONV_SAME         = 0;
float CONV_CASE_LOWER   = 1;
float CONV_CASE_UPPER   = 2;
float CONV_WHITE        = 1;
float CONV_RED          = 2;
float CONV_REDSPECIAL   = 3;
float CONV_WHITESPECIAL = 4;
float CONV_ALTERNATE_RW = 5;
float CONV_ALTERNATE_WR = 6;

