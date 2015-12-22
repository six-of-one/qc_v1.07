/* ::-::
 *
 * Cataboligne
 *
 * file: use_volume.qc
 *
 * date: 5.12.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_volume.qc 
#endifdef

#ifndef use_volume

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_volume.qc 
	#endifdef
	#endifdef

#define use_volume
.float		volume;

#endifdef
