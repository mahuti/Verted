/////////////////////////////////////////////////////////
//
// Attract-Mode Frontend - Pos (Layout Scaling) Module
//
/////////////////////////////////////////////////////////
// Pos (Position) module helps position, scale or stretch items to fit a wide variety of screen dimensions using easy-to-reference pixel values. 
// 
// I made this module so that I could just look at the pixel dimensions of objects in my Photoshop design of a layout 
// without having to do any further calculations and scale easily to multiple layout resolutions
// 
// Layouts using this module can easily stretch or scale to vertical, 4:3 and 16:9 (or other) screen sizes
// The Pos module can responsively position items from the right and bottom of the screen
// so that elements in your layout can float depending on the screen size.
// This module can also be used in tandem with the PreserveArt (and similar) modules 
//
// Usage:
// 
// fe.load_module("pos"); 
// fe.load_module("preserve-art"); 
//
// /* create an array containing any values you want to set. You only need to pass the items you want. Any item not passed in will use a default */ 

// local posData =  {
//     base_width = 480.0, /* the width of the layout as you designed it */ 
//     base_height = 640.0, /* the height of the layout as you designed it */ 
//     layout_width = fe.layout.width, /* usually not necessary, but allows you to override the layout width and height */ 
//     layout_height = fe.layout.height, 
//     rotate = 90, /* setting to 90, -90 will rotate the layout, otherwise leave at 0 */  
//     scale= "stretch" /* stretch, scale, none. Stretch scales without preserving aspect ratio. Scale preserves aspect ratio 
// }

// local pos = Pos(posData)
// 
//	local vid = fe.add_artwork( "snap", pos.x(10), pos.y(20), pos.width(480), pos.height(640) ); /* my design file shows the image 10x, 20y, 480wide, 640tall */	
//	vid.preserve_aspect_ratio = false;
//
// 	local instruction_card = fe.add_image("instruction_card_bg.png" , pos.x(10), pos.y(20), pos.width(1440), pos.height(1080));
//	instruction_card.x = pos.x(272, "right", instruction_card.width); /* this is for an image whos right edge is 272 pixels from the right edge of my design */ 
//  
//  /* used with PreserveArt/PreserveImage */ 
// 
// local bg = PreserveImage( "image.png", pos.x(20), pos.y(20), pos.width(300), pos.height(400) );
// bg.set_fit_or_fill( "fill" );
// bg.set_anchor( ::Anchor.Top );

::Posdata <-
{
    base_width = 640.0,
    base_height = 480.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    rotate =0, 
    scale= "stretch",
    debug= false,
}
 
// scale can be stretch, scale, none
// rotate can be 0, 90, -90 ( any other value will trigger -90)

class Pos
{
    VERSION = 1.0
    pos_debug = true
    xconv = 1
    yconv = 1
    nostretch_xconv = 1
    nostretch_yconv = 1
    pos_scale = "stretch"

    constructor( properties )
    {
        foreach(key, value in properties) {
            try {
                switch (key) {
                    case "base_width":
                        ::Posdata.base_width = value.tofloat()
                        break
                    case "base_height":
                        ::Posdata.base_height = value.tofloat()
                        break
                    case "layout_width":
                        ::Posdata.layout_width = value.tofloat()
                        break
                    case "layout_height":
                        ::Posdata.layout_height = value.tofloat()
                        break
                    case "rotate":
                        ::Posdata.rotate = value.tofloat()
                        break
                    case "scale":
                        switch(::Posdata.scale){
                            case "scale": 
                                pos_scale = "scale"
                                break
                            case "none":
                                pos_scale = "none"
                                break
                            default:
                                pos_scale = "stretch"   
                        }
                        break
                   case "debug":
                        if (::Posdata.debug=="true"){pos_debug = true }
                        break
                }
            }
            catch(e) { if (pos_debug) printL("Error setting property: " + key); } 
        }
 
        if (::Posdata.rotate.tofloat() != 0)
        {
            if (::Posdata.rotate==90)
            {
                ::fe.layout.orient=RotateScreen.Right
            }
            else
            {
                ::fe.layout.orient=RotateScreen.Left
            }
        }
        
        // width conversion factor
        xconv = ::Posdata.layout_width / ::Posdata.base_width 
        nostretch_xconv = xconv
        
        // height conversion factor
        yconv = ::Posdata.layout_height / ::Posdata.base_height
        nostretch_yconv = yconv

        if (::Posdata.layout_height < ::Posdata.base_height)
        {
            nostretch_xconv = yconv
        }
        else
        {
            nostretch_yconv = xconv
        }

        if (pos_scale=="scale")
        {
            if (::Posdata.layout_height < ::Posdata.base_height)
            {
                xconv = yconv 
            }
            else
            {
                yconv = xconv 
            }
        }
        if (pos_scale=="none")
        {
            xconv = 1 
            yconv = 1
            nostretch_xconv = 1
            nostretch_yconv = 1
        }
    }
    
    // Print line
    function printLine(x) {
        if (pos_debug){
            print(x + " \n")            
        }
    }
    function printL(x)
    {
        printLine(x)
    }

    // get a width value converted using conversion factor
    // allow_stretch=false will cause the value to use the scaling, not stretching values. Handy when an item shouldn't be stretched (like a Logo)
    function width(num, allow_stretch=true )
    {	
        if (!allow_stretch)
        {
            return num * nostretch_xconv
        }
        return num * xconv
    }

    // get a height value converted using conversion factor
    // allow_stretch=false will cause the image to scale height, without stretching. This is useful for backgrounds that don't need to line up perfectly with the content. 
    function height ( num, allow_stretch=true)
    {
        if (!allow_stretch)
        {
            return num * nostretch_yconv 
        } 
        return num * yconv
    }

    /* 
    get x position converted to a scaled value using conversion factor
    
    use anchor="right" to offset the left edge (num) pixels from right side of screen
    combine with object_width to offset the right edge of the object (num) pixels from right side of screen
    */ 
    function x( num, anchor="left", object_width=0)
    {
        if (pos_scale=="stretch" || pos_scale=="none")
        {
            return num * xconv
        }
        else
        {
            if (anchor == "left")
            {
                return num * xconv
            }
            else
            {
                local page_width_difference = 0; 
                if (::Posdata.base_width > ::Posdata.layout_width)
                {
                    page_width_difference = ::Posdata.base_width - Posdata.layout_width
                }
                return (::Posdata.layout_width - (object_width * xconv)-(num * xconv) - page_width_difference) 
            }
        }
    } 

    /* 
    get y position converted to a scaled value using conversion factor
    
    use anchor="bottom" to offset the top edge (num) pixels from bottom side of screen
    combine with object_height to offset the bottom edge of the object (num) pixels from bottom side of screen
    */ 
    function y( num, anchor="top", object_height=0 )
    {
        if (pos_scale=="stretch")
        {
            return num * yconv 
        }
        else
        {
            if (anchor == "top")
            {
                return num * yconv
            }
            else
            {
                local page_height_difference = 0; 
                if (::Posdata.base_height > ::Posdata.layout_height)
                {
                    page_height_difference = ::Posdata.base_height - Posdata.layout_height
                }
                return (::Posdata.layout_height - (object_height * yconv)-(num * yconv) - page_height_difference) 
            }
        }
    }
}
