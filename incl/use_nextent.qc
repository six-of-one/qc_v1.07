/* ::-::
 *
 * Cataboligne
 *
 * file: use_nextent.qc
 *
 * date: 5.19.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_nextent.qc 
#endifdef

#ifndef use_nextent

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_nextent.qc 
	#endifdef
	#endifdef

#define use_nextent
entity(entity e) nextent = #47;					// for looping through all ents

#endifdef
