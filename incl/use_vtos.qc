/* ::-::
 *
 * Cataboligne
 *
 * file: use_vtos.qc
 *
 * date: 5.19.15
 *
 * qc - unused define modules
 *
 */

#ifdef id_include_always
#messageinclude   incl/use_vtos.qc 
#endifdef

#ifndef use_vtos

	#ifndef id_include_always
	#ifdef id_include
	#messageinclude   incl/use_vtos.qc 
	#endifdef
	#endifdef

#define use_vtos
string(vector v) vtos				= #27;
vector(string s) stov = #117; // returns vector value from a string

#endifdef
