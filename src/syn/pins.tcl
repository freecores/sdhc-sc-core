if [info exists pins] {
	foreach {signal pin pull} $pins {
		set_location_assignment PIN_$pin -to $signal
		if {$pull == 1} {
			set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to $signal
		}
	}
}
