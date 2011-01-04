#!/usr/bin/python

import sys
import getopt
import os
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

	for opt, arg in opts:
			if opt in ("-h", "--help"):
				usage()
				sys.exit(2)
			if opt in ("-f", "--file"):
				(shortname, extension) = os.path.splitext(arg)
			if opt in ("-e", "--extended"):
				extended = True

	if extension == None:
		print("No extension found. Did you specify a file?")
		sys.exit(2)

	return (shortname,extension,extended)

def main(argv):
	if len(argv) == 0:
		usage()
		sys.exit(2)

	try:                                
		opts, args = getopt.getopt(argv, "hef:", ["help","file=", "extended"]) 
	except getopt.GetoptError:           
		usage()                          
		sys.exit(2)

	(shortname, extension, extended) = parseArgs(opts);
	comment = getComment(extension)

	print(comment + "SDHC-SC-Core")
	print(comment + "Secure Digital High Capacity Self Configuring Core")
	print(comment)
	print(comment + "(C) Copyright 2010 Rainer Kastl")
	print(comment)
	print(comment + "This file is part of SDHC-SC-Core.")
	print(comment)
	print(comment + "SDHC-SC-Core is free software: you can redistribute it and/or modify it")
	print(comment + "under the terms of the GNU Lesser General Public License as published by")
	print(comment + "the Free Software Foundation, either version 3 of the License, or (at")
	print(comment + "your option) any later version.")
	print(comment)
	print(comment + "SDHC-SC-Core is distributed in the hope that it will be useful, but")
	print(comment + "WITHOUT ANY WARRANTY; without even the implied warranty of")
	print(comment + "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU")
	print(comment + "General Public License for more details.")
	print(comment)
	print(comment + "You should have received a copy of the GNU Lesser General Public License")
	print(comment + "along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.")
	print(comment)
	print(comment + "File        : " + shortname + extension)
	print(comment + "Owner       : Rainer Kastl")
	print(comment + "Description : ")
	print(comment + "Links       : ")
	print(comment)

	if extended == True:
		print(comment + "Changelog:")
		gitlog = Popen(["git", "log", "-n 3", "--pretty=short", "--reverse", shortname+extension], stdout=PIPE)
		output = gitlog.communicate()[0]
		lines = output.splitlines()

		for line in lines:
			print(comment + line)

if __name__ == "__main__":
	main(sys.argv[1:])

