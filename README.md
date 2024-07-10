# OpenCH - Simple Crosshair Overlay

## Controls:

F12 - Settings

ESC - Show / Hide Crosshair

F1, F2, ..., F9 - Crosshair Presets


## Crosshair Files

Crosshairs are stored as .ini files under ```/crosshairs```

Here's an example *default.ini* file, which generates a standard green crosshair:
```ini
[features]
wings = 1,1,1,1
center_dot = 0

[values]
w_length = 3
thickness = 2
b_thickness = 1
gap = 6

[colors]
color = "150,255,30,255"
b_color = "0,0,0,255"
```
*wings* defines which of the crosshair "wings" are rendered, in order top, bottom, left, right.

A T-style crosshair, would then, be defined as ```wings = 0,1,1,1```.

*center_dot*, as the name implies, defines if the center dot is rendered.

The parameters under [values] define basics characteristics of the crosshairs, such as wing length, thickness, border thickness and center gap.

The parameters under [colors], then, define the color of the crosshair itself and its' border.

The crosshair color should never be pure magenta (255,0,255,255) or else it will not render.


## Init File

Crosshair preset paths are initiated with ```/crosshairs/init.txt```.

- In this file are written in order, the nine preset crosshairs to use, each on a separate line.

- Lines that start with ```//``` are ignored as comments, e.g. ```// this is a comment```.

- Lines with the length of < 5 letters are ignored, as the shortest .ini filename can be five letters long.

- If there are more than nine paths specified, any past the 9th are ignored.

- If the file doesn't exist, or all crosshairs aren't able to be de-ciphered, default paths are used.



## Requirements (For Compilation)

Odin Compiler

[Odin INI Parser](https://github.com/laytan/odin-ini-parser) - Place in ```odin_path/shared```
_