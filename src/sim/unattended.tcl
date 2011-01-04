# Usage: programname

# use an error code which is not used by modelsim
set errcode 88
onerror "quit -code $errcode"

# run the script and exit afterwards
do $script
exit

