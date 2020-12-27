//
// Attract-Mode Front-End - "Verted" by mahuti, based off of work "The Invaders" by MarkC74, FrizzleFried, ArcadeBliss and others...
// original posting: http://forum.attractmode.org/index.php?topic=2120.0
// history.dat code: http://forum.attractmode.org/index.php?topic=643.0
// 
// requires animate2 and pos modules
//
local order = 0 
class UserConfig {

	</ label="Show games list?", 
		help="Shows a list of games on the left hand side", 
		options="Yes,No", 
		order=order++ /> 
		show_games_list="No";

    </ label="Show History/Info?",
                help="Shows the History/Info tab when enabled. History.dat plugin must also be enabled and working. Set custom1 AM control to use",
                options="Yes,No",
                order=order++ />
                show_info_tab="No";    

    </ label="Show Flyers?",
                help="Shows the Flyer tab when enabled. Set custom1 AM control to use",
                options="Yes,No",
                order=order++ />
                show_flyer_tab="Yes";

    </ label="Show Cabinets?",
                help="Shows the Cabinet tab when enabled.  Set custom1 AM control to use",
                options="Yes,No",
                order=order++ />
                show_cabinet_tab="Yes";
 /*
    </ label="Tab Button", 
        help="Button/keypress that used to switch tabs", 
        is_input="yes", 
        order=order++ />
	    key=""; 
 */ 
    </ label="Bezel Style/Color", 
		help="The bezel is the image that wraps around the snap image", 
		options="gray,black,red,blue", 
		order=order++ /> 
		bezel="gray";
    
    </ label="Blink the PLAY NOW graphic?", 
		help="When set to yes, the play now graphic will pulse", 
		options="Yes,No", 
		order=order++ /> 
		show_play_now_blinking="No";
  
    </ label="History.dat", 
        help="History.dat location. If History.dat plugin is enabled, be sure to select an accurate history.dat file location, or the info tab will not work", 
        order=order++ />
        dat_path="/home/pi/.attract/mame2003-extras/history.dat";	  
 
     </ label="Scaling", 
		help="Controls how the layout should be scaled. Stretch will fill the entire space. Scale will scale up/down to fit the space with potential cropping of non-critical elements (eg. backgrounds)", 
		options="stretch,scale,none", 
		order=order++ /> 
		scale="stretch";
    
    </ label="Rotate", 
		help="Controls how the layout should be rotated", 
		options="0,90,-90", 
		order=order++ /> 
		rotate="0";
    /*
    </ label="Show marquee on second monitor?", 
		help="Shows the marquee on a second monitor", 
		options="Yes,No", 
		order=order++ /> 
		show_marquee_on_second_monitor="No";  
    */ 
}

local config = fe.get_config()
fe.layout.font = "American Captain"

fe.layout.width=480 
fe.layout.height=640

local key_state = {}

local dat_path = config["dat_path"] // must be set, even if history.dat's dat_path is set to use within a layout

function dirty_debug( text )
{
	local debug_text = fe.add_text(text, pos.x(10), pos.y(200), pos.width(400), pos.height(100));
	debug_text.align = Align.Left;
	debug_text.charsize = 20;
	debug_text.set_rgb(255, 255, 255);
 	
}

/* ************************************  
Module Loading & Instantiating
************************************ */ 
fe.load_module("animate2")
fe.load_module("fade")
fe.load_module("file") 
fe.load_module("preserve-art")
fe.load_module("pos") // positioning & scaling module
    
local posData =  {
    base_width = 480.0,
    base_height = 640.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    rotate = config["rotate"], 
    scale= config["scale"],
    debug = false,
}

local pos = Pos(posData) 
    
/* ************************************  
Tab Content defaults
************************************ */ 
    
local show_cab = false 
local show_flyer = false
local show_info = false 

if ( config["show_cabinet_tab"] == "Yes" ){
    show_cab = true
}
if ( config["show_flyer_tab"] == "Yes" ){
    show_flyer = true
}
if ( config["show_info_tab"] == "Yes" ){
    show_info = true
}

// this will be loaded with active tabs on a game-by-game basis, based on available content
local available_tabs = []

local info_view = 0 // video tab selected by default
local slide_time = "350ms"

local flyer_available = false
local cabinet_available = false

// basic tab positioning default
local tab_video_x = 0
local tab_info_x = 0     
local tab_info_width = 0 
local tab_flyer_x = 0  
local tab_flyer_width = 0 
local tab_cabinet_x = 0 
local tab_cabinet_width = 0 
local tab_right_x = 440
    
// tab content
local vid = fe.add_artwork( "snap", 0, 0, pos.width(480), pos.height(640) )		
        vid.preserve_aspect_ratio = false
        vid.trigger=Transition.EndNavigation
        
local info = fe.add_image( "black.png", 0, 0, pos.width(448), pos.height(528) )
        info.alpha = 150
        info.x = pos.x(480)
        info.y = pos.y(56)	

// by default, leave the history text off. Need to wait until the history.dat plugin is confirmed as enabled before using
local info_text = fe.add_text("You must enable History.dat plugin to show history info in this tab", pos.x(480), pos.y(100), pos.width(400), pos.height(440))
        info_text.charsize = pos.height(14, true)
        info_text.align = Align.Left
        info_text.word_wrap = true
        info_text.font = "Metropolis-Regular.otf"

local flyer = fe.add_surface(pos.width(448), pos.height(528))
        flyer.add_image( "black.png", 0, 0, pos.width(448), pos.height(528) )
        flyer.add_text( "No flyer available", pos.x(120), pos.y(254), pos.width(208), pos.height(20) )
        flyer.add_artwork ("flyer", 0, 0, pos.width(448), pos.height(528) )
        flyer.x = pos.x(480)
        flyer.y = pos.y(56)
        flyer.trigger=Transition.EndNavigation

local cabinet = fe.add_surface(pos.width(448), pos.height(528))
        cabinet.add_image( "black.png", 0, 0, pos.width(448), pos.height(528) )
        cabinet.add_text( "No cabinet picture available", pos.x(108), pos.y(254), pos.width(228), pos.height(20) )	
        cabinet.add_artwork ("cabinet", pos.x(100), pos.y(64), pos.width(248), pos.height(428))
        cabinet.x = pos.x(480) 
        cabinet.y = pos.y(56) 
        cabinet.trigger=Transition.EndNavigation

/* ************************************  
General Layout
************************************ */ 
 
function key_pressed( key )
{
    if ( fe.get_input_state( key ) && !key_state.rawin( key ))
    {
        key_state.rawset( key, true )

        return true
    }
    else return false
}

function key_update()
{
    foreach ( key, val in key_state )
        if ( !fe.get_input_state( key )) key_state.rawdelete( key )
    
    //return false; 
}

// list box background 
local shade = fe.add_image( "shade.png", pos.x(-480), 0, pos.width(480), pos.height(640) )        
local bezel_folder = "bezel/" + config["bezel"] + "/"
local list_box = fe.add_listbox( pos.x(-405), pos.y(100), pos.width(400), pos.height(440) )
    list_box.charsize = pos.height(32)
    list_box.set_sel_rgb( 255, 255, 125 )
    list_box.alpha = 75
    list_box.selbg_alpha = 0
    list_box.sel_alpha = 255
    list_box.rows = 9
    list_box.align = Align.Left  

// bezel  
local	background = fe.add_image( bezel_folder + "background.png", 0, 0, pos.width(480), pos.height(640))

// logo
local wheel_header = PreserveArt( "wheel", pos.x(100), pos.y(20), pos.width(280), pos.height(120) )
wheel_header.set_fit_or_fill( "fit" )
wheel_header.set_anchor( ::Anchor.Top )

// Bottom Left Game Details
local game_details = fe.add_text( "[Year]-[Category]", pos.x(24), pos.y(594), pos.width(170), pos.height(20) )	
        game_details.align = Align.Left
        game_details.alpha = 120
        game_details.charsize = pos.height(13)

// Playcount
local label_play = fe.add_text("PLAYED [PlayedCount] TIME(S)",pos.x(208),pos.y(592), pos.width(140), pos.height(24) )
        label_play.align = Align.Left
        label_play.charsize = pos.height(14)
        label_play.alpha = 120

// Play Now!
local label_play2 = fe.add_text("PLAY NOW!!!",pos.x(368),pos.y(592), pos.width(130),pos.height(24))
        label_play2.align = Align.Left
        label_play2.charsize = pos.height(14)

// Player 1 Button
local	player_1_button = fe.add_image("player_1_button.png", pos.x(318), pos.y(595), pos.width(27), pos.height(27))
        player_1_button.alpha = 255

local tab = fe.add_image(bezel_folder + "tab.png",pos.x(tab_video_x),pos.y(550),pos.width(68), pos.height(35)) 
local label_video = fe.add_text("VIDEO",pos.x(tab_video_x),pos.y(552),pos.width(68),pos.height(30)) 
local label_info = fe.add_text("INFO",pos.x(tab_info_x),pos.y(552),pos.width(68),pos.height(30))  
local label_flyer = fe.add_text("FLYER",pos.x(tab_flyer_x),pos.y(552),pos.width(68),pos.height(30)) 
local label_cabinet = fe.add_text("CABINET ",pos.x(tab_cabinet_x),pos.y(552),pos.width(76),pos.height(30)) 

// Alphabet Progress Bar
local list_inc = pos.height(416.0) / pos.height((fe.list.size-1)) 
local current_pos = pos.y(64) + (fe.list.index * list_inc) 
local list_pos_image = fe.add_image( bezel_folder +  "circle.png", pos.x(15) , pos.y(current_pos), pos.width(48), pos.height(48) ) 

function alphafirst(){
  return fe.game_info( Info.Title ).slice(0,1)
}

local list_label = fe.add_text( "[!alphafirst]", pos.x(13), pos.y(current_pos+pos.height(12)), pos.width(24), pos.height(20) ) 

/*
// show marquee on second monitor. I have NO idea if this works because I can't test it. 
if ( config["show_marquee_on_second_monitor"] == "Yes" )
{
    local marquee = fe.add_artwork( "marquee", pos.x(250), pos.y(641), pos.width(1440), pos.height(440) )	
        /* marquee.rotation = 90  */ 
        marquee.preserve_aspect_ratio = false    
}
*/ 

/* ************************************  
set_layer_alpha
transition callback

activates/deactivates tabs based on  
whether or not content exists for them
or not

@return false
************************************ */ 
function set_layer_alpha( ttype, var, ttime)
{
    label_flyer.alpha = 100
    label_cabinet.alpha = 100

    if (fe.get_art("flyer").len() >0) {
        flyer_available = true
        label_flyer.alpha = 255
    } 
    else
    {
        flyer_available = false
        label_flyer.alpha = 100
    }
    if (fe.get_art("cabinet").len() >0) {
        cabinet_available = true
        label_cabinet.alpha = 255
    }
    else
    {
        cabinet_available = false
        label_cabinet.alpha = 100

    }
    next_tab(true)
        
    return false
}
fe.add_transition_callback( "set_layer_alpha" )	

/* ************************************  
invaders_init
transition callback

// This loads information into the 
info/history panel. This has to be run 
in a callback to check whether history.dat 
plugin is enabled. This saves a crash
from happening when not enabled

@return false
************************************ */ 
    
function invaders_init( ttype, var, ttime )
{
    if ( ttype == Transition.StartLayout ){
        if (show_info)
        {
            // this mdethod does not seem to work in some 
            // of the other transitions
            if ( fe.plugin.rawin( "History.dat" )){
                if ( config["show_info_tab"] == "Yes" ){
                    info_text.msg = "[!get_hisinfo]"
                }
            }
        }

    }
    return false  
} 

fe.add_transition_callback( "invaders_init")

/* ************************************  
progress bar
transition callback

moves the INITIAL of the game on the left side

@return false
************************************ */ 
    
function progress_bar( ttype, var, ttime )			
{
    current_pos = pos.height(90) + pos.height((fe.list.index*list_inc))
    list_pos_image.y = pos.y(current_pos)
    list_label.y = pos.y(current_pos+pos.height(12))	
    return false 
}
fe.add_transition_callback( "progress_bar" )

/* ************************************  
pulse_start
transition callback

makes the player1 button flash on and off

@return false
************************************ */ 
 
function pulse_start( ttype, var, transition_time ) 
{
    PropertyAnimation(player_1_button).key("alpha").from(0).to(225).duration("500ms").yoyo(1).loops(-1).play()
    return false
}    
    		
if ( config["show_play_now_blinking"] == "Yes" )
{
    fe.add_transition_callback("pulse_start")     
}
		
/* ************************************  
select_sound
transition callback

plays an unobtrusive sound when moving to
a new game

@return false
************************************ */ 
 
function select_sound( ttype, var, ttime ) {
 switch ( ttype ) {

  case Transition.ToNewSelection:
        local sound = fe.add_sound("game.mp3")
        sound.playing=true
        break
  }
 return false
}
fe.add_transition_callback( "select_sound" )	


/* ************************************  
get_hisinfo

returns history.dat info for current game

@return text
************************************ */
function get_hisinfo() 
{ 
    
    try {
        file(dat_path, "r" )
    }
    catch(e){
        return ""
    }
     
    
    local text = "" 
    
    local sys = split( fe.game_info( Info.System ), ";" ) 
    local rom = fe.game_info( Info.Name ) 
    local alt = fe.game_info( Info.AltRomname ) 
    local cloneof = fe.game_info( Info.CloneOf )  

    local lookup = get_history_offset( sys, rom, alt, cloneof ) 

    // we only go to the trouble of loading the entry if
    // it is not already currently loaded
    if ( lookup >= 0 )
    {
        text = get_history_entry( lookup, config ) 
        local index = text.find("- TECHNICAL -") 
        if (index >= 0)
        {
            local tempa = text.slice(0, index) 
            text = strip(tempa) 
        }
    } else {
        if ( lookup == -2 )
            text = "Index file not found. Try generating an index from the History.dat plug-in configuration menu." 
        else
            text = "No information available for:  " + rom 
    } 
    return text 
}

/* ************************************  
play_video_tab

plays the video tab, resets the other tabs
and calls the games list to show if 
available

@return false
************************************ */
function play_video_tab()
{
    
    if (info.x < pos.x(400))
    {
        PropertyAnimation(info).key("x").from(pos.x(16)).to(pos.x(480)).duration(slide_time).easing("ease-in-out-circle").play() 
        PropertyAnimation(info_text).key("x").from(pos.x(44)).to(pos.x(480)).duration(slide_time).easing("ease-in-out-circle").play() 
    }
    if (flyer.x < pos.x(400))
    {
        PropertyAnimation(flyer).key("x").from(pos.x(16)).to(pos.x(480)).duration(slide_time).easing("ease-in-out-circle").play() 
    }
    if (cabinet.x < pos.x(400))
    {
        PropertyAnimation(cabinet).key("x").from(pos.x(16)).to(pos.x(480)).duration(slide_time).easing("ease-in-out-circle").play() 
    }
        
    PropertyAnimation(tab).key("x").to(pos.x(tab_video_x)).duration(slide_time).easing("ease-in-out-circle").on("stop", function(anim) { key_update(); show_games_list(); }).play()
        
    return false
}

/* ************************************  
play_info_tab

plays the info tab, hides the games list

@return false
************************************ */
function play_info_tab()
{
     hide_games_list()
    PropertyAnimation(info).key("x").from(pos.x(480)).to(pos.x(16)).duration(slide_time).easing("ease-in-out-circle").play()
    PropertyAnimation(info_text).key("x").from(pos.x(480)).to(pos.x(44)).duration(slide_time).easing("ease-in-out-circle").on("stop", function(anim) { key_update(); }).play()
    PropertyAnimation(tab).key("x").to(pos.x(tab_info_x)).duration(slide_time).easing("ease-in-out-circle").play()

    return false
}

/* ************************************  
play_flyer_tab

plays the flyer tab, hides the games list

@return false
************************************ */
function play_flyer_tab()
{
   hide_games_list()
       
   PropertyAnimation(flyer).key("x").from(pos.x(480)).to(pos.x(16)).duration(slide_time).easing("ease-in-out-circle").on("stop", function(anim) { key_update(); }).play()
   PropertyAnimation(tab).key("x").to(pos.x(tab_flyer_x)).duration(slide_time).easing("ease-in-out-circle").play()
       
   return false
}

/* ************************************  
play_cabinet_tab

plays the cabinet tab, hides the games list

@return false
************************************ */
function play_cabinet_tab()
{ 
    hide_games_list()
    PropertyAnimation(cabinet).key("x").from(pos.x(480)).to(pos.x(16)).duration(slide_time).easing("ease-in-out-circle").on("stop", function(anim) { key_update(); }).play()
    PropertyAnimation(tab).key("x").to(pos.x(tab_cabinet_x)).duration(slide_time).easing("ease-in-out-circle").play()
        
    return false
}

/* ************************************  
hide_games_list

hides the games list if it's avaiable 

@return false
************************************ */
function hide_games_list()
{
    if ( config["show_games_list"] == "Yes" )
    {
       if(list_box.x > 0)
       {
           PropertyAnimation(list_box).key("x").from(pos.x(44)).to(pos.x(-405)).duration(slide_time).easing("ease-in-out-circle").play()   
            PropertyAnimation(shade).key("x").from(0).to(pos.x(-480)).duration(slide_time).easing("ease-in-out-circle").play() 

       }
    }
    return false
}

/* ************************************  
show_games_list

shows the games list if it's avaiable 

@return false
************************************ */
function show_games_list()
{
    if ( config["show_games_list"] == "Yes" )
    {                    
       if(list_box.x < 0)
       {
            PropertyAnimation(list_box).key("x").from(pos.x(-405)).to(pos.x(44)).duration(slide_time).easing("ease-in-out-circle").play() 
            PropertyAnimation(shade).key("x").from(pos.x(-480)).to(0).duration(slide_time).easing("ease-in-out-circle").play() 
       }
    }
    return false
}
/* when up / down is pressed and a tab other than "video" is shown, this reset the view to the video tab */ 

/* ************************************  
tab_slider_reset
signal handler

when up/down are selected, video tab is played
and other tabs are hidden

@return false
************************************ */

function tab_slider_reset( signal_str )
{
    if ((signal_str=="up"||signal_str=="down")) 
    {        
        //local sound = fe.add_sound("game.mp3")
	    //sound.playing=true
            
        if (info_view !=0)
        {
            play_video_tab()
        }
    }
    return false
}
/* ************************************  
tab_slider
signal handler

when custom1 is pressed, info tabs are shuffled

@return false
************************************ */
function tab_slider( signal_str )					// slide between video / info / flyer / cabinet view when Custom1 is pressed
{
    if ((signal_str=="custom1")) 
    {
        info_view = next_tab()  
        if (info_view==1) {
            play_info_tab()
        }
        else if (info_view==2) {
            play_flyer_tab()
        }
        else if (info_view==3) {
            play_cabinet_tab()
        }
        else {
            play_video_tab()
        }
    }	
    return false 
}
/* ************************************  
check_key
ticks callback

changes tabs on configured keypress

@return false
************************************ */

// local tabkey = config["key"]; 

function check_key ( ttime )
{
    if ( key_pressed(tabkey) )
    {
        info_view = next_tab()  
        if (info_view==1) {
            play_info_tab()
        }
        else if (info_view==2) {
            play_flyer_tab()
        }
        else if (info_view==3) {
            play_cabinet_tab()
        }
        else {
            play_video_tab()
        }
    }
}


/* ************************************  
next_tab

grabs current tab or resets the available tabs
based on whether or not they're available
and active

@param reset. When true, resets the available tabs
@return int
************************************ */  
function next_tab(reset=false)
{
    if (reset)
    {
        available_tabs = []

        available_tabs.push(0)

        if (show_info)
        {
           available_tabs.push(1) 
        }
        if (show_flyer && flyer_available)
        {
            available_tabs.push(2)
        }
        if (show_cab && cabinet_available)
        {
            available_tabs.push(3)
        }
        available_tabs.reverse()
    }

    local tab = available_tabs.pop()
        
    available_tabs.insert(0,tab)
    
    return tab
}

/* ************************************  
Finalizes layout positioning of tabs & 
initializes callbacks and handlers
************************************ */

// setting width of tabs & initial positions of them.
if (show_cab){
    tab_cabinet_width = 60  
    tab_cabinet_x = tab_cabinet_width 
}
if (show_flyer){
    tab_flyer_width = 60  
    tab_flyer_x = tab_cabinet_width + tab_flyer_width  
}
if ( show_info ){
    tab_info_width=60  
    tab_info_x = tab_cabinet_width + tab_flyer_width + tab_info_width 
}

// sets the x position based on the right hand offset  & the width of the tab
tab_info_x = tab_right_x - tab_info_x  
tab_cabinet_x = tab_right_x - tab_cabinet_x  
tab_flyer_x = tab_right_x - tab_flyer_x  
tab_video_x = tab_right_x - tab_cabinet_width - tab_flyer_width - tab_info_width - 60  

// if the tab isn't to be shown, set the x pos off screen
if (show_cab== false){
    tab_cabinet_x = 480  
}
if (show_flyer== false){
    tab_flyer_x = 480  
}
if (show_info == false ){
    tab_info_x = 480  
}
// set the tabs initial position
tab.set_pos( pos.x(tab_video_x), pos.y(550) )
label_video.set_pos( pos.x(tab_video_x), pos.y(550))
label_info.set_pos( pos.x(tab_info_x), pos.y(550))
label_flyer.set_pos( pos.x(tab_flyer_x), pos.y(550))
label_cabinet.set_pos( pos.x(tab_cabinet_x), pos.y(550))

label_video.charsize=pos.height(16)  
label_video.align = Align.Centre  

label_info.charsize=pos.height(16)  
label_info.align = Align.Centre  

label_flyer.charsize=pos.height(16) 

label_flyer.align = Align.Centre 

label_cabinet.charsize=pos.height(16) 
label_cabinet.align = Align.Centre 

// initiate games list now, if it's available to be shown
show_games_list()

// fe.add_ticks_callback("check_key"); // had to disable because it keeps segfaulting. why? noooo idea. 
fe.add_signal_handler("tab_slider_reset")
fe.add_signal_handler( "tab_slider" ) 

