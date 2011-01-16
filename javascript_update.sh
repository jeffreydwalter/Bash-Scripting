#!/usr/local/bin/bash


#####################################################################################################################
# Author: Jeff Walter
#   Date: Jan. 14, 2011
#   Desc: This script came about because I had a need to update
#         500+ php, html, js, etc. files that were using the
#         deprecated language="javascript" attribute in the script tag.
#         This script will find all occurances of the script tag and 
#         remove or replace them, ensuring that all <script> tags
#         have a valid type attribute. i.e., type="text/javascript".
#         It will handle the following:
#            - <script type="text/javascript" language="javascript"> ->becomes-> <script type="text/javascript">
#            - <script type='text/javascript' language='javascript'> ->becomes-> <script type='text/javascript'>
#            - <script langauge="javascript" type="text/javascript"> ->becomes-> <script type="text/javascript">
#            - <script langauge='javascript' type='text/javascript'> ->becomes-> <script type='text/javascript'>
#            - <script langauge="javascript">                        ->becomes-> <script type="text/javascript">
#            - <script language='javascript'>                        ->becomes-> <script type='text/javascript'>
#         It will also handle strings with escaped quotes (for script tags inside php strings.)
#          e.g. (all of the above strings are suppored) 
#            - <script type=\"text/javascript\" language=\"javascript\"> ->becomes-> <script type=\"text/javascript\">
#
#         It also makes sure all <SCRIPT> tags and their type attributes are lowercase.
#         Lastly, it also does case Insensitive matching, therefore it's a little slow.
#
#                         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
#                                 Version 2, December 2004 
#
#                       Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 
#
#                     See http://sam.zoy.org/wtfpl/COPYING for more details.
#
#             Everyone is permitted to copy and distribute verbatim or modified 
#            copies of this license document, and changing it is allowed as long 
#                                 as the name is changed. 
#
#                         DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
#               TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
#
#                         0. You just DO WHAT THE FUCK YOU WANT TO. 
#####################################################################################################################

# Set our delimiter
IFS=$'\n';

# Create a file to log all the files we worked on. 
# (just because a file is listed in this log doesn't mean it was actually modified.)
touch ~/replace_javascript.out;

# Make sure the log is empty. 
echo "" > ~/replace_javascript.out;

# Replace this with whatever dir you want. 
# TODO: Update this script to take command line args.
cd ~/trunk

# Set up our arrays.
declare -a EXPRESSIONS;
declare -a REPLACEMENTS;

# EXPRESSIONS hold the regex for the patterns we want to look for in our file. 
# For now it's just "javascript" which is enough to find all the files that
# have javascript <script> tags.
EXPRESSIONS=("javascript");

# REPLACEMENTS hold the regex for sed.
# If you wanted to clean up some other javascript, you would add that here.
# I made this verbose to be as accurate as possible. Originally, I had fewer regexes...
REPLACEMENTS=(
		"s/language=[\\][\']javascript[A-Z1-9a-z\.]*[\\][\'] \(.*type=[\\][\']text\/javascript[A-Z1-9a-z\.]*[\\][\']\)/\1/gI" 
		"s/language=[\\][\"]javascript[A-Z1-9a-z\.]*[\\][\"] \(.*type=[\\][\"]text\/javascript[A-Z1-9a-z\.]*[\\][\"]\)/\1/gI" 
		"s/language=[\']javascript[A-Z1-9a-z\.]*[\'] \(.*type=[\']text\/javascript.*[\']\)/\1/gI" 
		"s/language=[\"]javascript[A-Z1-9a-z\.]*[\"] \(.*type=[\"]text\/javascript.*[\"]\)/\1/gI" 
		"s/\(type=[\\][\']text\/javascript[\\][\'].*\) language=[\\][\']javascript[A-Z1-9a-z\.]*[\\][\']/\1/gI"
		"s/\(type=[\\][\"]text\/javascript[\\][\"].*\) language=[\\][\"]javascript[A-Z1-9a-z\.]*[\\][\"]/\1/gI"
		"s/\( type=[\']text\/javascript.*[\'].*\) language=[\']javascript[A-Z1-9a-z\.]*[\']/\1/gI" 
		"s/\( type=[\"]text\/javascript.*[\"].*\) language=[\"]javascript[A-Z1-9a-z\.]*[\"]/\1/gI" 
		"s/language=[\\][\']javascript[A-Z1-9a-z\.]*[\\][\']/type=\\\\\'text\/javascript\\\\\'/gI" 
		"s/language=[\\][\"]javascript[A-Z1-9a-z\.]*[\\][\"]/type=\\\\\"text\/javascript\\\\\"/gI" 
		"s/language=[\']javascript[A-Z1-9a-z\.]*[\']/type=\'text\/javascript\'/gI" 
		"s/language=[\"]javascript[A-Z1-9a-z\.]*[\"]/type=\"text\/javascript\"/gI" 
		"s/<\/script>/<\/script>/gI" 
		"s/<script /<script /gI"
);

# This is where all the work is done.
for EXPRESSION in ${EXPRESSIONS[@]}
do
	# grep for all the files that match our EXPRESSIONS criteria.
	FILES=`egrep -ilr "$EXPRESSION" *`; 
	
	# Loop through each file.
	for FILE in ${FILES}
	do
		# Loop through the REPLACEMENTS regex and pass them to sed for each file.
		for REPLACEMENT in ${REPLACEMENTS[@]}
		do
			# Execute sed to produce the "fixed" output.
			OUTPUT=`sed -e "$REPLACEMENT" $FILE`;
			#BASENAME=`basename $FILE`;
			#echo $BASENAME;
			# Overwrite the original file with the "fixed" output.
			echo "$OUTPUT" > $FILE;
		done
			# Write the fully quailified path to the modified file to the log.
			echo "$FILE" >> ~/replace_javascript.out;
	done
done
exit;
