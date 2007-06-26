


var UPDATE_PERIOD = 0.1;

var ticker      = props.globals.getNode("sim/model/A-6E/instrumentation/ticker", 1);
var ikts        = props.globals.getNode("velocities/airspeed-kt");
var aft_ballast = props.globals.getNode("sim/model/A-6E/controls/flight/CG-trim-aft", 1);
var fwd_ballast = props.globals.getNode("sim/model/A-6E/controls/flight/CG-trim-fwd", 1);
var Vx 	        = props.globals.getNode("velocities/uBody-fps", 1);
var Vy          = props.globals.getNode("velocities/vBody-fps", 1);
var Vz          = props.globals.getNode("velocities/wBody-fps", 1);
var vdi_vel_y   = props.globals.getNode("sim/model/A-6E/instrumentation/vdi/velocity_marker_y", 1);
var vdi_vel_z   = props.globals.getNode("sim/model/A-6E/instrumentation/vdi/velocity_marker_z", 1);
#var wind_deg	= props.globals.getNode("environment/wind-from-heading-deg");
#var wind_kts	= props.globals.getNode("environment/wind-speed-kt");
var ac_hdg      = props.globals.getNode("/orientation/heading-deg", 1);
var g_curr 	  	= props.globals.getNode("accelerations/pilot-g");
var g_max	   	= props.globals.getNode("sim/model/A-6E/instrumentation/g-meter/g-max", 1);
var g_min	   	= props.globals.getNode("sim/model/A-6E/instrumentation/g-meter/g-min", 1);


# loop ####################

update_loop = func {
	inc_ticker();
	g_min_max();
	auto_trim();
	vdi_vel_marker();
	vdi_drift_angle();
	settimer(update_loop, UPDATE_PERIOD);
}



# functions ###############

inc_ticker = func {
	# used for vdy background continuous translation animation
	var tick = ticker.getValue();
	tick += 1 ;
	ticker.setDoubleValue(tick);
}

g_min_max = func {
	# records g min and max values
	var curr = g_curr.getValue();
	var max = g_max.getValue();
	var min = g_min.getValue();
	if ( curr >= max ) {
		g_max.setDoubleValue(curr);
	} elsif ( curr <= min ) {
		g_min.setDoubleValue(curr);
	}
}


auto_trim = func {
	# Move a ballast from one Yasim weight point to another
	# depending on the airspeed of the a/c. 
	var kts = ikts.getValue();
	var new_fwd = 0;
	if (kts > 150) { new_fwd = 30*(kts-150); }
	if (new_fwd > 7000) { new_fwd = 7000 }
	var new_aft = 7000 - new_fwd;
	
	aft_ballast.setDoubleValue(new_aft);
	fwd_ballast.setDoubleValue(new_fwd);
}


vdi_vel_marker = func {
	# displays impact point on the VDI display
	var vx = Vx.getValue();
	var vy = Vy.getValue();
	var vz = Vz.getValue();
	if (vx > 0.1 ) {
		var vely = vy/vx;
		var velz = vz/vx;
		vdi_vel_y.setDoubleValue(vely);
		vdi_vel_z.setDoubleValue(velz);
	}
}

vdi_drift_angle = func {
	#var wdeg = wind-deg.getValue();
	#var wkt = wind_kt.getValue();
	var achdg = ac_hdg.getValue();
}

# init #################

print("Initializing A-6 Intruder systems");
ticker.setDoubleValue(0);
vdi_vel_y.setDoubleValue(0);
vdi_vel_z.setDoubleValue(0);

#setlistener("/sim/signals/fdm-initialized", update_loop);
settimer(update_loop, 10);
