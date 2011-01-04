# Usage: programname

# use an error code which is not used by modelsim
set errcode 88
set errors 0
onerror "quit -code $errcode"
onbreak {incr errors; cont}

# run the script and exit afterwards
do $script

if {$errors == 0} {
	exit
} else {
	quit -code $errcode
}


