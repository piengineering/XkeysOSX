# XkeysOSX
X-keys SDK for OSX

This Software Development Kit (SDK) is in the form of an Xcode workspace with two projects: one for the viewer application, and one for the Xkeys framework. The framework serves as the interface to the hardware, and would be the part that is included in a host application. The viewer application is basically a sample implementation and a means to exercise the framework. Requires Mac OS X 10.10 or later.

Version 1.2 Changes

Adds basic support for XK-3 Switch Interface,  XK-12 Switch Interface, XKE-128, XK-80, XK-60, XK-16/8/4 Stick, XK-68 Jog Shuttle, XK-68 Joystick, XK-12 Jog Shuttle, XK-12 Joystick, Matrix Encoder Board, XK-3 Foot Pedal, XKR-32 Rack Mount, HD-15 Wire Interface, XK-64 Jog Tbar, XK-16 LCD. Basic support includes reading of the raw input report, demonstration of setting the green and red indicator LEDs, backlight LED demonstration if applicable, and a demonstration of sending an output report. The graphic displayed will show 128 keys regardless of product model. All of these products use the Xkeys3SIUnit class which is designed to work for all X-keys products. 

Version 1.1 Changes

Adds XK-24 (PIDs 1027, 1028, 1029 and 1249) compatibility.
Adds an XkeysButton protocol as a superprotocol of XkeysBlueRedButton to accommodate buttons that do not have associated LEDs.
-[Xkeys124TbarUnit setAllBacklightsWithColor:toState:] now updates the state of the individual backlight LEDs in addition to updating the hardware.  Xkeys24Unit does the same.
The 'XKeysModelXKE124TbarHWMode' constant has been renamed to 'XkeysModelXKE124TbarHWMode' (internal capitalization change).
Xkeys124TbarHWModeUnit class has been removed.  Xkeys124TbarUnit now handles both hardware and SPLAT mode PIDs.  XkeysUnit classes now take an XkeysConnection instance that is injected on initialization to handle communication with the device either by HID or USB interfaces.
Splits the button input characteristics of XkeysBiColorButton into XkeysIndexedBitInput class to accommodate buttons that do not have associated LEDs.
Adds unit tests for the XK-24 implementation.
Adds additional unit tests for the XKE-124 T-bar implementation.
The Viewer application now terminates when the window is closed.

Version 1.0

Initial release.
Includes Xkeys XKE-124 T-bar (PIDs 1275, 1276, 1277 and 1278) compatibility.
