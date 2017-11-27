/* ::-::
 *
 * Cataboligne
 *
 * file: _defs.qc 
 *
 * date: 017.5.19
 *
 * qc - archon module
 *
 */

// spawn flag values for archon points
#define  NOITEM 1
#define  NOHEAL 1
#define  NOSPRAY 2
#define  P_RELOAD 4

// points added per touch on power point if power_act does not spec it on map
#define ARCHON_POINT	1

// point item rnd stuff


#define MC_SUPER_SHOTGUN  		102
#define MC_ASHELLS_LG  		121
#define MC_ANAILS_LG  		123
#define MC_AROCKETS_LG  		125
#define MC_ACELLS_LG  		127
#define MC_AEXPLSH  		143


.float archon; // accumulates power

.float xp; // experience points

