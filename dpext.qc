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

//adds a new console cvar to the server console (in singleplayer this is the player's console), the cvar exists until the mod is unloaded or the game quits.
float(string name, string value) registercvar = #93;

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


// simplify repeated code, trade for a couple globals

void(vector org) te_gunshot = #418;


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

// map_hack, x_ents do much string manipulating

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


//Versatile functions intended for storing data from specific entities between level changes, but can be customized for some kind of partial savegame.
//WARNING: .entity fields cannot be saved and restored between map loads as they will leave dangling pointers.
//numentityfields returns the number of entity fields. NOT offsets. Vectors comprise 4 fields: v, v_x, v_y and v_z.
//entityfieldname returns the name as a string, eg. "origin" or "classname" or whatever.
//entityfieldtype returns a value that the constants represent, but the field may be of another type in more exotic progs.dat formats or compilers.
// to set entity string fields in code - you cant do an assign with temp strings, you get:
// PRVM_GetString: invalid temp-string

// note: putent* used by map_hack - which is xents dependent
#ifdef code_xents
float(float fieldnum, entity ent, string s) putentityfieldstring = #500;
string(float fieldnum) entityfieldname = #497;
float() numentityfields = #496;
string(float fieldnum, entity ent) getentityfieldstring = #499;
float(float fieldnum) entityfieldtype = #498;
//constants:
//Returned by entityfieldtype
#define		FIELD_STRING  		1
#define		FIELD_FLOAT   		2
#define		FIELD_VECTOR  		3
#define		FIELD_ENTITY  		4
#define		FIELD_FUNCTION		6
//description:

	#ifdef HUD_support
// add stats to hud
// #232 void(float index, float type, .void field) SV_AddStat (EXT_CSQC)
void(float index, float type, ...) addstat = #232;
	#endifdef

#endifdef


//DP_QC_GETSURFACE
//float(entity e, float s) getsurfacenumpoints = #434;
//vector(entity e, float s, float n) getsurfacepoint = #435;
//vector(entity e, float s) getsurfacenormal = #436;
string(entity e, float s) getsurfacetexture = #437;
float(entity e, vector p) getsurfacenearpoint = #438;
//vector(entity e, float s, vector p) getsurfaceclippedpoint = #439;

//DP_QC_GETSURFACEPOINTATTRIBUTE
#define		SPA_POSITION		0
#define		SPA_S_AXIS		1
#define		SPA_T_AXIS		2
#define		SPA_R_AXIS		3 // same as SPA_NORMAL
#define		SPA_TEXCOORDS0		4
#define		SPA_LIGHTMAP0_TEXCOORDS		5
#define		SPA_LIGHTMAP0_COLOR		6
//builtin definitions:
//vector(entity e, float s, float n, float a) getsurfacepointattribute = #486;

//function to query extended information about a point on a certain surface

//DP_QC_GETSURFACETRIANGLE
//float(entity e, float s) getsurfacenumtriangles = #628;
//vector(entity e, float s, float n) getsurfacetriangle = #629;






//finds an entity or float field value, similar to find(), but for entity and float fields.
entity(entity start, .entity fld, entity match) findentity = #98;

// sv_prvm_warn if 0 will cause callfunction to error out if s is not a valid function
void(string s) callfunction = #605;
float(string s) isfunction = #607;

// for testing file existence

//constants:
#define FILE_READ	 			0
#define FILE_APPEND			1
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

	#ifdef code_viswep

#define		  EF_NODRAW      		16

.entity tag_entity; // entity this is attached to (call setattachment to set this)
.float tag_index; // which tag on that entity (0 is relative to the entity, > 0 is an index into the tags on the model if it has any) (call setattachment to set this)
//builtin definitions:
void(entity e, entity tagentity, string tagname) setattachment = #443; // attachs e to a tag on tagentity (note: use "" to attach to entity origin/angles instead of a tag)
//description:
//allows entities to be visually attached to model tags (which follow animations perfectly) on other entities, for example attaching a weapon to a player's hand, or upper body attached to lower body, allowing it to change angles and frame separately (note: origin and angles are relative to the tag, use '0 0 0' for both if you want it to follow exactly, this is similar to viewmodelforclient's behavior).
//note 2: if the tag is not found, it defaults to "" (attach to origin/angles of entity)
//note 3: attaching to world turns off attachment
//note 4: the entity that this is attached to must be visible for this to work
//note 5: if an entity is attached to the player entity it will not be drawn in first person.

.entity exteriormodeltoclient;
//description:
//the entity is visible to all clients with one exception: if the specified client is using first person view (not using chase_active) the entity will not be shown.  Also if tag attachments are supported any entities attached to the player entity will not be drawn in first person.

	#endifdef

// nondp
#endifdef
