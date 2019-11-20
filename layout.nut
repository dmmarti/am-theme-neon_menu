////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////   

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below";
   </ label="Select background image", help="Select background", options="background_1", order=2 /> enable_background="background_1";
   </ label="Select wheel type", help="Select wheel type or listbox", options="horizontal", order=4 /> enable_list_type="horizontal";
   </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=5 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=6 /> transition_ms="35";  
</ label=" ", help=" ", options=" ", order=7 /> divider1="";
</ label="--------    Extras     --------", help="Extra layout options", order=8 /> uct2="select below";
   </ label="Enable flyer animation", help="Select yes or no", options="Yes,No", order=9 /> enable_gflyer="Yes"; 
   </ label="Random Wheel Sounds", help="Play random sounds when navigating games wheel", options="Yes,No", order=25 /> enable_random_sound="Yes";   
}

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
//fe.layout.font="Roboto";

// modules
fe.load_module("fade");
fe.load_module( "animate" );

/////////////////////////////////////////////

//create surface for snap
local surface_snap = fe.add_surface( 640, 480 );
local snap = FadeArt("snap", 0, 0, 640, 480, surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = false;

//now position and pinch surface of snap
//adjust the below values for the game video preview snap
surface_snap.set_pos(flx*0.415, fly*0.205, flw*0.532, flh*0.56);
surface_snap.skew_y = 0;
surface_snap.skew_x = 0;
surface_snap.pinch_y = 0;
surface_snap.pinch_x = 0;
surface_snap.rotation = 0;

/////////////////////////////////////////////
// Load background image
if ( my_config["enable_background"] == "background_1" )
{
local bgsolid = fe.add_image( "backgrounds/background_1.png", 0, 0, flw, flh );
bgsolid.alpha=255;
}

/////////////////////////////////////////////
// Flyer

if ( my_config["enable_gflyer"] == "No" )
{
local flyerstatic = fe.add_artwork("flyer", flx*0.057, fly*0.053, flw*0.3 flh*0.71 );
}

if ( my_config["enable_gflyer"] == "Yes" )
::OBJECTS <- {
 flyer = fe.add_artwork("flyer", flx*0.057, fly*0.053, flw*0.3 flh*0.71 ),
}

local move_transition1 = {
 when = Transition.ToNewSelection ,property = "x", start = flx*-1, end = flx*0.057, time = 1000
}
 
if ( my_config["enable_gflyer"] == "Yes" )
{
//Animation
animation.add( PropertyAnimation( OBJECTS.flyer, move_transition1 ) );
}

//////////////////////////////////////////////////////////////////////////////////
// The following section sets up the wheel art

//horizontal wheel
if ( my_config["enable_list_type"] == "horizontal" )
{
fe.load_module( "conveyor" );
local wheel_x = [ -flx*1.3, -flx*1.2, flx*0.0, flx*0.1, flx*0.2 flx*0.3, flx*0.4, flx*0.57, flx*0.67, flx*0.77, flx*0.87, flx*0.97 ];
local wheel_y = [ fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.8, fly*0.784, fly*0.784, fly*0.784, fly*0.784, fly*0.784, ]; 
local wheel_w = [ flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.2, flw*0.13, flw*0.13, flw*0.13, flw*0.13, flw*0.13, ];
local wheel_h = [  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, flh*0.175,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102,  flh*0.102, ];
local wheel_a = [  100,  100,  100,  100,  100,  100, 255,  100,  100,  100,  100,  100, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 10;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
		//preserve_aspect_ratio = true;
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}

//////////////////////////////////////////////////////////////////////////////////
// Play random sound when transitioning to next / previous game on wheel
function sound_transitions(ttype, var, ttime) 
{
	if (my_config["enable_random_sound"] == "Yes")
	{
		local random_num = floor(((rand() % 1000 ) / 1000.0) * (124 - (1 - 1)) + 1);
		local sound_name = "sounds/GS"+random_num+".mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
}
fe.add_transition_callback("sound_transitions")
