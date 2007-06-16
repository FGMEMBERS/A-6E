# used to the animation of the canopy switch and the canopy move
# toggle keystroke or 2 position switch

var cnpy = aircraft.door.new("canopy", 6);
var switch = props.globals.getNode("sim/model/A-6E/controls/canopy/canopy-switch", 1);
var pos = props.globals.getNode("canopy/position-norm", 1);

canopyswitch = func(v) {

	p = pos.getValue();

	if (v == 2 ) {
		if ( p < 1 ) {
			v = 1;
		} elsif ( p >= 1 ) {
			v = -1;
		}
	}

	if (v < 0) {
print("switch =", switch);
		switch.setIntValue(1);
		cnpy.close();

	} elsif (v > 0) {
print("switch =", switch);
		switch.setIntValue(-1);
		cnpy.open();

	}
}



