### On demand executed bits:

# PHD's TC range switch (2 - 1 - 0)
# ---------------------------------
PHD_TCrange_sw = func {
	var prop = props.globals.getNode(arg[0], 1);
	var pr = prop.getValue();
	var target = props.globals.getNode("/sim/model/A-6E/instrumentation/PHD/TCrange", 1);
	if (arg[1] == 1) {
		if (pr == 0) {
			prop.setDoubleValue(1);
			target.setDoubleValue(5);
		} elsif (pr == 1) {
			prop.setDoubleValue(2);
			target.setDoubleValue(1.5);
		}
	} else {
		if (pr == 1) {
			prop.setDoubleValue(0);
			target.setDoubleValue(10);
		} elsif (pr == 2) {
			prop.setDoubleValue(1);
			target.setDoubleValue(5);
		}
	}
}



# Hard-coded flaps movement in 2 steps, 30 and 40 degrees:
# --------------------------------------------------------
controls.flapsDown = func {
    if(arg[0] == 0) { return; }
    if(props.globals.getNode("/sim/flaps") != nil) {
        stepProps("/controls/flight/flaps", "/sim/flaps", arg[0]);
        return;
    }
    current_f = getprop("/controls/flight/flaps");
	if (arg[0] == 1) {
		if (current_f == 1) {
			return;
		} elsif (current_f == 0) {
			setprop("/controls/flight/flaps", 0.75);
		} else {
			setprop("/controls/flight/flaps", 1);
		}
	} else {
		if (current_f == 0) {
			return;
		} elsif (current_f == 0.75) {
			setprop("/controls/flight/flaps", 0);
		} else {
			setprop("/controls/flight/flaps", 0.75);
		}
	}
}


# A-6 spoilers can be full open or closed:
# ----------------------------------------
controls.stepSpoilers = func {
    if(props.globals.getNode("/sim/spoilers") != nil) {
        stepProps("/controls/flight/spoilers", "/sim/spoilers", arg[0]);
        return;
    }
    if (arg[0] == 1) {
    	setprop("/controls/flight/spoilers", 1);
	} elsif (arg[0] == -1) {
		setprop("/controls/flight/spoilers", 0);
	}
}


# general 3 positions switch (2 - 1 - 0)
# --------------------------------------
three_pos_sw = func {
	var prop = props.globals.getNode(arg[0], 1);
	var pr = prop.getValue();
	if (arg[1] == 1) {
		if (pr == 0) {
			prop.setDoubleValue(1);
		} elsif (pr == 1) {
			prop.setDoubleValue(2);
		}
	} else {
		if (pr == 1) {
			prop.setDoubleValue(0);
		} elsif (pr == 2) {
			prop.setDoubleValue(1);
		}
	}
}



# general 3 positions switch variant (2 - 0 - 1)
# ----------------------------------------------
three_pos_sw_b = func {
	var prop = props.globals.getNode(arg[0], 1);
	var pr = prop.getValue();
	if (arg[1] == 1) {
		if (pr == 0) {
			prop.setDoubleValue(2);
		} elsif (pr == 1) {
			prop.setDoubleValue(0);
		}
	} else {
		if (pr == 2) {
			prop.setDoubleValue(0);
		} elsif (pr == 0) {
			prop.setDoubleValue(1);
		}
	}
}


# flood light 3 positions switch variant (1 - 0.5 - 0.25)
# -------------------------------------------------------
three_pos_sw_flood = func {
	var prop = props.globals.getNode(arg[0], 1);
	var pr = prop.getValue();
	if (arg[1] == 1) {
		if (pr == 0.25) {
			prop.setDoubleValue(0.5);
		} elsif (pr == 0.5) {
			prop.setDoubleValue(1);
		}
	} else {
		if (pr == 1) {
			prop.setDoubleValue(0.5);
		} elsif (pr == 0.5) {
			prop.setDoubleValue(0.25);
		}
	}
}



# Old Fashioned Radio Button Selector
# -----------------------------------
# where group is the parent node that contains the radio state nodes as children

radio_bt_sel = func(group, which) {
	foreach (var n; props.globals.getNode(group).getChildren()) {
		n.setBoolValue(n.getName() == which);
	}
}


### Once at start-up executed bits:

# collision lights flasher
# ------------------------
beacon = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("sim/model/A-6E/lighting/beacon_state", [0.20, 1.20], beacon);

# warning lights medium speed flasher
# -----------------------------------
warn_medium_lights_switch = props.globals.getNode("sim/model/A-6E/lighting/warn-medium-lights-switch", 1);
aircraft.light.new("sim/model/A-6E/lighting/warn-medium-lights", [0.40, 0.30], warn_medium_lights_switch);


# animation of the canopy switch and the canopy move
# --------------------------------------------------
# toggle keystroke OR 2 position switch.

var cnpy = aircraft.door.new("sim/model/A-6E/canopy", 10);
var cswitch = props.globals.getNode("sim/model/A-6E/controls/canopy/canopy-switch", 1);
var pos = props.globals.getNode("sim/model/A-6E/canopy/position-norm", 1);

canopyswitch = func(v) {
	var p = pos.getValue();
	if (v == 2 ) {
		if ( p < 1 ) {
			v = 1;
		} elsif ( p >= 1 ) {
			v = -1;
		}
	}
	if (v < 0) {
		cswitch.setIntValue(1);
		cnpy.close();

	} elsif (v > 0) {
		cswitch.setIntValue(-1);
		cnpy.open();

	}
}
