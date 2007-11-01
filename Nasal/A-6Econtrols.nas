# Custom controls for the A-6

# PHD's TC range switch (hard coded range in nautical miles)
# ----------------------------------------------------------
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


# Canopy switch animation and canopy move
# ---------------------------------------
# Toggle keystroke and 2 positions switch.
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


# Landing gear handle animation 
# -----------------------------
setlistener( "controls/gear/gear-down", func { ldg_hdl_main(); } );

var ld_hdl = props.globals.getNode("sim/model/A-6E/controls/gear/ld-gear-handle-anim", 1);

ldg_hdl_main = func {
	var pos = ld_hdl.getValue();
	if ( getprop("controls/gear/gear-down") == 1 ) {
		if ( pos > -1 ) {
			ldg_hdl_anim(-1, pos);
		}
	} elsif ( pos < 0 ) {
		ldg_hdl_anim(1, pos);
	}
}

ldg_hdl_anim = func {
  	var incr = arg[0]/10;
	var pos = arg[1] + incr;

	if ( ( arg[0] = 1 ) and ( pos >= 0 ) ) {    
		ld_hdl.setDoubleValue(0);
	} elsif ( ( arg[0] = -1 ) and ( pos <= -1 ) ) {
		ld_hdl.setDoubleValue(-1);
	} else {
		ld_hdl.setDoubleValue(pos);
		settimer( ldg_hdl_main, 0.05 );
	}
}


# General 3 positions switch (2 - 1 - 0)
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


# General 3 positions switch variant (2 - 0 - 1)
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


# Flood light 3 positions switch variant (1 - 0.5 - 0.25)
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
# Where group is the parent node that contains the radio state nodes as children.

radio_bt_sel = func(group, which) {
	foreach (var n; props.globals.getNode(group).getChildren()) {
		n.setBoolValue(n.getName() == which);
	}
}


# TACAN XY Switch
# ---------------
tacan_XYtoggle = func {
	var xy_sign = props.globals.getNode("instrumentation/tacan/frequencies/selected-channel[4]");
	var xy_switch = props.globals.getNode("sim/model/A-6E/controls/instrumentation/tacan/xy-switch");
	var s = xy_sign.getValue();
	if ( s == "X" ) {
		xy_sign.setValue( "Y" );
		xy_switch.setValue( 1 );
	} else {
		xy_sign.setValue( "X" );
		xy_switch.setValue( 0 );
	}
}


# AFCS (Auto Flight Control System) Panel
# ---------------------------------------
var alt_button = props.globals.getNode("sim/model/A-6E/controls/autopilot/alt-button");
var mach_button = props.globals.getNode("sim/model/A-6E/controls/autopilot/mach-button");
var cmd_switch = props.globals.getNode("sim/model/A-6E/controls/autopilot/cmd-switch");
var afcs_auto = props.globals.getNode("sim/model/A-6E/controls/autopilot/auto-stab-augm-switch");
var afcs_on_off = props.globals.getNode("sim/model/A-6E/controls/autopilot/on-off-switch");
var vdi_alt_marker = props.globals.getNode("sim/model/A-6E/controls/autopilot/vdi-alt-marker");
var vdi_hdg_marker = props.globals.getNode("sim/model/A-6E/controls/autopilot/vdi-roll-marker");
var press_alt_ft = props.globals.getNode("instrumentation/altimeter/pressure-alt-ft");
var alt_ref = props.globals.getNode("autopilot/settings/target-altitude-ft");
var ap_alt_lock = props.globals.getNode("autopilot/locks/altitude");
var ap_hdg_lock = props.globals.getNode("autopilot/locks/heading");
var roll_deg = props.globals.getNode("orientation/roll-deg");
var target_roll_deg = props.globals.getNode("autopilot/internal/target-roll-deg");
afcs_power = func(n) {
	if ( n ){
		afcs_on_off.setBoolValue( 1 );
	} else {
		afcs_on_off.setBoolValue( 0 );
		afcs_auto.setBoolValue( 0 );
		afcs_disengage();
	}
}
afcs_alt = func {
	var alt = alt_button.getValue();
	var engage = afcs_auto.getValue();
	if ( alt ){
		alt_button.setBoolValue( 0 );		
		afcs_auto.setBoolValue( 0 );
		if ( engage ) {
			afcs_disengage();
		}
	} else {
		alt_button.setBoolValue( 1 );
		mach_button.setBoolValue( 0 );
		if ( engage ) {
			afcs_engage();
		}
	}	
}
afcs_mach = func {
	var mach = mach_button.getValue();
	var engage = afcs_auto.getValue();
	if ( mach ){
		mach_button.setBoolValue( 0 );		
	} else {
		mach_button.setBoolValue( 1 );
		alt_button.setBoolValue( 0 );
		ap_alt_lock.setValue("");
		vdi_alt_marker.setBoolValue( 0 );
		if ( engage ) {
			afcs_disengage();
		}
	}
}
afcs_cmd = func(c) {
	var engage = afcs_auto.getValue();
	if ( c ) {
		cmd_switch.setBoolValue( 1 );
		if ( engage ) {
			afcs_engage();
		}
	} else {
		cmd_switch.setBoolValue( 0 );
		ap_hdg_lock.setValue("");
		vdi_hdg_marker.setBoolValue( 0 );
	}
}
afcs_engage = func() {
	var power = afcs_on_off.getValue();
	afcs_auto.setBoolValue(1);
	var alt = alt_button.getValue();
	var hdg = cmd_switch.getValue();
	if (power) {
		if ( alt ) {
			alt_ref.setValue(press_alt_ft.getValue());
			ap_alt_lock.setValue("altitude-hold");
			vdi_alt_marker.setBoolValue(1);
		}
		if ( hdg ) {
			rdeg = roll_deg.getValue();
			if ((rdeg < -5) or (rdeg > 5)) {
				if (rdeg < -60) {
					rdeg = -60;
				}
				if (rdeg > 60) {
					rdeg = 60;
				}
				target_roll_deg.setValue( rdeg );
				ap_hdg_lock.setValue("roll-hold");
			} else {
				ap_hdg_lock.setValue("wing-leveler");
			}
			vdi_hdg_marker.setBoolValue(1);
		}
	} else {
		settimer(func { afcs_disengage() }, 0.1);
	}
}

afcs_disengage = func() {
	afcs_auto.setBoolValue(0);
	alt_ref.setValue(0);
	ap_alt_lock.setValue("");
	vdi_alt_marker.setBoolValue(0);
	ap_hdg_lock.setValue("");
	target_roll_deg.setValue(0);
	vdi_hdg_marker.setBoolValue(0);
}



# collision lights flasher
# ------------------------
var beacon = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("sim/model/A-6E/lighting/beacon_state", [0.08, 1.20], beacon);

# warning lights medium speed flasher
# -----------------------------------
aircraft.light.new("sim/model/A-6E/lighting/warn-medium-lights-switch", [0.4, 0.3]);
setprop("sim/model/A-6E/lighting/warn-medium-lights-switch/enabled", 1);

# warning lights fast speed flasher
# -----------------------------------
aircraft.light.new("sim/model/A-6E/lighting/warn-fast-lights-switch", [0.1, 0.1]);
setprop("sim/model/A-6E/lighting/warn-fast-lights-switch/enabled", 1);


