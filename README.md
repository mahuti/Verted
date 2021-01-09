# Verted Layout

Attract-Mode Front-End - "Verted" by mahuti, based off of work "The Invaders" by MarkC74, FrizzleFried, ArcadeBliss and others...
original posting: http://forum.attractmode.org/index.php?topic=2120.0
history.dat code: http://forum.attractmode.org/index.php?topic=643.0

This layout will scale to any size, but is intended for use on vertical cabinets. This theme includes tabs to show snaps, flyers, cabinets, and history info (requires history.dat plugin be installed, configured, and enabled)

This layout is based off of a previous theme called "The Invaders", though largely uses different code. Primary differences from the original include bug fixes, the ability to show or hide the games list, improved tab interface, dynamic scaling, and selectable colors for bezel and tabs. 
## Requirements

1. Add the animate2 and pos modules to AttractMode's modules folder

2. You'll need to have artwork set up for the following: cabinet, flyer, marquee, snap, wheel

## Options

### Show Games list
Off by default

If enabled, shows list of games on the left-hand side.

--- 

### Tabs
The tabs feature requires custom1 control be configured in AttractMode. To add a custom control go to: AttractMode Settings > controls > custom1 > add input. Once the input has been added, you can use this control to select available tabs. Tabs that have been enabled, but do not have content will be dimmed and unselectable

#### Show History Info Tab
Off by default

If enabled, shows the History/Info tab. To use this feature: 

1. History.dat plugin must be enabled and working. 
2. You must generate the History.dat plugin's index. After generating the index the first time, you may need to restart AttractMode
3. You must set the history.dat location in the layout options (even though it's already set up in the history.dat plugin)
 
#### Show Flyers Tab
Enabled by default

If enabled, shows the Flyer tab

#### Show Cabinets Tab
Enabled by default

If enabled, shows the Cabinets tab

#### Bezel Style/Color
This sets the colors for the bezel and the tabs. The bezel is the image that wraps around the snap image. 

--- 

### Blink the PLAY NOW graphic
When set to yes, the play now graphic will pulse

### Scaling
Controls how the layout should be scaled. Stretch will fill the entire space. Scale will scale up/down to fit the space with potential cropping. 

### Rotate
Controls how the layout should be rotated
  