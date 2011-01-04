#!/usr/bin/python

import sys
import getopt
import os
from os import linesep
from subprocess import *

def usage():
	print("Usage: command -[he]f filename")
	print("-h --help: print this help.")
	print("-e --extended: add information from git, used for printing")
	print("-f --file: file for which the header shall be print")

def getComment(extension):
	comment = None
	if extension in (".vhdl", ".vhd"):
		comment = "-- "
	elif extension == ".sv":
		comment = "// "
	elif extension == ".tcl":
		comment = "# "
	else:
		comment = "# "
	
	if (comment == None):
		print("No recognized extension found: Use a systemverilog or vhdl file.")
		sys.exit(2)

	return comment

def parseArgs(opts):
	extension = None
	extended = False
	outfile = None

	for opt, arg in opts:
			if opt in ("-h", "--help"):
				usage()
				sys.exit(2)
			if opt in ("-f", "--file"):
				(shortname, extension) = os.path.splitext(arg)
			if opt in ("-e", "--extended"):
				extended = True
			if opt == "-i":
				outfile = shortname + extension
			if opt in ("-o", "--out"):
				outfile = arg

	if extension == None:
		print("No extension found. Did you specify a file?")
		sys.exit(2)

	return (shortname,extension,extended, outfile)

def checkStaticHeader(header, content):

	for i in range(0, len(header)):
		if header[i] != content[i]:
			return False

	return True

def checkDynamicHeader(header, content):
	for i in range(0, len(header)):
		if header[i].split(':')[0] != content[i].split(':')[0]:
			return False

	return True

def addSCMExtension(newFile, filename, comment, extended):
	if extended == True:
		newFile.append(comment + "Changelog:" + linesep)
		gitlog = Popen(["git", "log", "-n 3", "--pretty=short", "--reverse", filename], stdout=PIPE)
		lines = gitlog.communicate()[0].splitlines()

		for idx in range(0, len(lines)):
			lines[idx] = comment + lines[idx] + linesep
		newFile.extend(lines)

def main(argv):
	if len(argv) == 0:
		usage()
		sys.exit(2)

	try:                                
		opts, args = getopt.getopt(argv, "hef:io:", ["help","file=", "extended", "out="]) 
	except getopt.GetoptError:           
		usage()                          
		sys.exit(2)

	(shortname, extension, extended, outfile) = parseArgs(opts);
	comment = getComment(extension)

	with open(shortname+extension) as f:
		content = f.readlines()

	staticheader = [
		  comment + "SDHC-SC-Core"+ linesep,
		  comment + "Secure Digital High Capacity Self Configuring Core"+ linesep,
		  comment+ linesep,
		  comment + "(C) Copyright 2010 Rainer Kastl"+ linesep,
		  comment+ linesep,
		  comment + "This file is part of SDHC-SC-Core."+ linesep,
		  comment+ linesep,
		  comment + "SDHC-SC-Core is free software: you can redistribute it and/or modify it"+ linesep,
		  comment + "under the terms of the GNU Lesser General Public License as published by"+ linesep,
		  comment + "the Free Software Foundation, either version 3 of the License, or (at" + linesep,
		  comment + "your option) any later version."+ linesep,
		  comment+ linesep,
		  comment + "SDHC-SC-Core is distributed in the hope that it will be useful, but" + linesep,
		  comment + "WITHOUT ANY WARRANTY; without even the implied warranty of"+ linesep,
		  comment + "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU"+ linesep,
		  comment + "General Public License for more details."+ linesep,
		  comment+ linesep,
		  comment + "You should have received a copy of the GNU Lesser General Public License"+ linesep,
		  comment + "along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/." + linesep,
		  comment + linesep,
		  comment + "File        : " + os.path.basename(shortname + extension) + linesep]

	dynamicheader = [comment + "Owner       : " + linesep,
			 comment + "Description : " + linesep,
			 comment + "Links       : " + linesep,
			 comment + linesep]

	newFile = []

	if checkStaticHeader(staticheader, content):
		newFile.extend(content[0:len(staticheader)])

		if checkDynamicHeader(dynamicheader, content[len(staticheader):]):
			newFile.extend(content[len(staticheader):len(staticheader) + len(dynamicheader)])
			content = content[len(staticheader)+len(dynamicheader):]
		else:
			dynamicheader[0] = dynamicheader[0].rstrip() + " Rainer Kastl" + linesep
			newFile.extend(dynamicheader)
			print("Header rewritten, you should check the file!")

		addSCMExtension(newFile, shortname+extension, comment, extended)
	else:
		print("Header rewritten, you should check the file!")
		newFile.extend(staticheader)
		dynamicheader[0] = dynamicheader[0].rstrip() + " Rainer Kastl" + linesep
		newFile.extend(dynamicheader)
		addSCMExtension(newFile, shortname+extension, comment, extended)
		newFile.append(linesep)

	newFile.extend(content)

	# write file
	if outfile == None:
		for line in newFile:
			line = line.rstrip()
			print(line)
	else:
		with open(outfile, mode='w') as a_file:
			for line in newFile:
				a_file.write(line)

	
if __name__ == "__main__":
	main(sys.argv[1:])

