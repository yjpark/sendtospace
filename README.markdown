Send to Space
=============

What's it
---------
I use the spaces feature of OSX a lot, it's quite nice, though I always miss the way to send a window to anothe space on Linux, just a keyboard shortcut, on OSX, the ways I know are either press F8 and drag the window or swithing space with shortcut while dragging a window, both require mouse control.

After some experiment, got a SIMBL plugin for this purpose, finially I can send a window to a specified space with keyboard only.

How to install
--------------
You need to install SIMBL first: http://www.culater.net/software/SIMBL/SIMBL.php

Get the source code, build it, put the Send-To-Space.bundle folder under ~/Library/Application\ Support/SIMBL/Plugins/

You can try to use the binary version (only tested on 10.6.7) as well, they will be put in github's Downloads section.

How to use
----------
After proper setup, it will add a few menuitems into the "Window" section (only work for cocoa applications), selecting the menu item will hopefully send the current window to the selected space.

Default shortcuts are Ctrl-Shift-1 ~ Ctrl-Shift-9

Known issues
------------
It's a quick and dirty fix, used some delay constant to make it work, only tested it on my own machine, if it doesn't work for you, probably you can change the two constants in Classes/PFSendToSpacePlugin.h

