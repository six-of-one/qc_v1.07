/* ::-::
 *
 * Cataboligne
 *
 * file: use_copyentity.qc
 *
 * date: 5.12.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_copyentity.qc 
#endifdef

#ifndef use_copyentity

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_copyentity.qc 
	#endifdef
	#endifdef

#define use_copyentity
void(entity from, entity to) copyentity = #400;

#endifdef
