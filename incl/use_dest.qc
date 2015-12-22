/* ::-::
 *
 * Cataboligne
 *
 * file: use_dest.qc
 *
 * date: 5.12.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_dest.qc 
#endifdef

#ifndef use_dest

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_dest.qc 
	#endifdef
	#endifdef

#define use_dest
.vector dest;

#endifdef
 