/* ::-::
 *
 * Cataboligne
 *
 * file: use_distance.qc
 *
 * date: 5.12.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_distance.qc 
#endifdef

#ifndef use_distance

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_distance.qc 
	#endifdef
	#endifdef

#define use_distance
.float		distance;

#endifdef
 