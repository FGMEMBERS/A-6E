# Simple script moving a ballast from one Yasim weight point to another
# depending on the airspeed of the a/c. 



var UPDATE_PERIOD = 0.2;

var kts = nil;
var new_aft = nil;
var new_fwd = nil;

update_loop = func {
	kts = getprop("velocities/airspeed-kt");
	aft_ballast = getprop("sim/model/A-6E/controls/flight/CG-trim-aft");
	fwd_ballast = getprop("sim/model/A-6E/controls/flight/CG-trim-fwd");
	if (kts < 150) {
		new_fwd = 0;
	} else {
		new_fwd = 30*(kts-150);
	}
	if (new_fwd > 7000) { new_fwd = 7000 }
	new_aft = 7000 - new_fwd;
	
	setprop("sim/model/A-6E/controls/flight/CG-trim-aft", new_aft);
	setprop("sim/model/A-6E/controls/flight/CG-trim-fwd", new_fwd );
	settimer(update_loop, UPDATE_PERIOD);
}




wait_for_fdm = func {
	if (getprop("/position/altitude-agl-ft")) {
		update_loop();
	} else {
		settimer(wait_for_fdm, 1);
	}
}


settimer(wait_for_fdm, 0);
