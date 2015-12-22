/* ::-::
 *
 * Cataboligne
 *
 * file: use_writelong.qc
 *
 * date: 5.12.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_writelong.qc 
#endifdef

#ifndef use_WriteLong

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_writelong.qc 
	#endifdef
	#endifdef

#define use_WriteLong
void(float to, float f) WriteLong		= #55;

#endifdef
