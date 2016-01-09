/* ::-::
 *
 * Cataboligne
 *
 * file: dpext.qc
 *
 * date: 11/25/14
 *
 * qc - darkplaces extension support
 *
 */

// note: avoid adding extensions not being used - they take up global vars

#ifndef nondp

// read cvar as strings
string (string s) cvar_string = #448;

float(string name) cvar_type = #495;
#define		CVAR_TYPEFLAG_EXISTS		1
#define		CVAR_TYPEFLAG_SAVED		2
#define		CVAR_TYPEFLAG_PRIVATE		4
#define		CVAR_TYPEFLAG_ENGINE		8
#define		CVAR_TYPEFLAG_HASDESCRIPTION		16
#define		CVAR_TYPEFLAG_READONLY		32

// scale models in dp

.float scale;

// escher uses sv_user.qc
//#define escher

// used by other code
.vector movement;

#ifdef escher

//min returns the lowest of all the supplied numbers.
//max returns the highest of all the supplied numbers.
float(float a, float b, ...) min = #94;
float(float a, float b, ...) max = #95;

//bound clamps the value to the range and returns it.
float(float minimum, float val, float maximum) bound = #96;

// regrav areas of levels on a trigger
.vector vgravity;

#endifdef

// map_hack does much string manipulating

float(string s) strlen = #114; // returns how many characters are in a string
string(string s1, string s2, ...) strcat = #115; // concatenates two or more strings (for example "abc", "def" would return "abcdef") and returns as a tempstring
float(string s) stof = #81; // get numerical value from a string
//vector(string s) stov = #117; // returns vector value from a string
string(string s, ...) strzone = #118; // makes a copy of a string into the string zone and returns it, this is often used to keep around a tempstring for longer periods of time (tempstrings are replaced often)

// returns a section of a string as a tempstring - see FTE_STRINGS for enhanced version
string(string s, float start, float length) substring = #116;

//strreplace replaces all occurrences of 'search' with 'replace' in the string 'subject', and returns the result as a tempstring.
string(string search, string replace, string subject) strreplace = #484;

// for testing right now

//string(float chars, string s, ...) strpad = #225;
// effect of #nondp here

//wasfreed returns whether an entity slot is currently free (entities that have never spawned are free, entities that have had remove called on them are also free).
float(entity ent) wasfreed = #353; // same as in EXT_CSQC extension

//TESTING
//Function to get the number of an entity - a clean way.
float(entity num) num_for_edict = #512;

// load any entites contained in a file

void(string s) ent_load = #101;

// to set entity string fields in code - you cant do an assign with temp strings, you get:
// PRVM_GetString: invalid temp-string
float(float fieldnum, entity ent, string s) putentityfieldstring = #500;
string(float fieldnum) entityfieldname = #497;
float() numentityfields = #496;
string(float fieldnum, entity ent) getentityfieldstring = #499; // TESTING

float(string s) findentityfield;

//finds an entity or float field value, similar to find(), but for entity and float fields.
entity(entity start, .entity fld, entity match) findentity = #98;

void(string s) callfunction = #605;

// for testing file existence

//constants:
#define FILE_READ	 		0
#define FILE_APPEND		1
#define FILE_WRITE		 	2

float(string filename, float mode) fopen = #110; // opens a file inside quake/gamedir/data/ (mode is FILE_READ, FILE_APPEND, or FILE_WRITE), returns fhandle >= 0 if successful, or fhandle < 0 if unable to open file for any reason
void(float fhandle) fclose = #111; // closes a file

	//#define fileload

	#ifdef fileload

/// this has been dropped in favor of ent_load

string(float fhandle) fgets = #112; // reads a line of text from the file and returns as a tempstring
void(float fhandle, string s, ...) fputs = #113; // writes a line of text to the end of the file

	#endifdef

/// hipnotic using

//DP_QC_COPYENTITY in					hipsubs.qc

#endifdef
