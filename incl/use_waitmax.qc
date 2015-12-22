/* ::-::
 *
 * Cataboligne
 *
 * file: use_waitmax.qc
 *
 * date: 5.12.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_waitmax.qc 
#endifdef

#ifndef use_waitmax

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_waitmax.qc 
	#endifdef
	#endifdef

#define use_waitmax
.float		waitmax;	

#endifdef
