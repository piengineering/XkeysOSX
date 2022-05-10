# XkeysOSX
X-keys SDK for OSX

We have dedicated new resources to the development of an OSX SDK for X-keys as of March, 2021
We are not sure when we will have a releasable version. 

Please contact Tech@piengineeering.com for further details

XKeyReadData v2 Code
This is a simple app written in Swift that demonstrates reading from and writing to an X-keys XK-24. When a button is pressed the input report is displayed in the output window, then the blue and red backlight LEDs for the corresponding button will be flashed. The output report used to flash the LEDs is displayed in the output window.

NOTICE: As of September 27, 2019 this SDK is no longer supported by P.I. Engineering. Use at own risk. 

This Software Development Kit (SDK) is in the form of an Xcode workspace with two projects: one for the viewer application, and one for the Xkeys framework. The framework serves as the interface to the hardware, and would be the part that is included in a host application. The viewer application is basically a sample implementation and a means to exercise the framework. Requires Mac OS X 10.10 or later.

Version 1.6 Changes

Changes for Big Sur. XkeysUnit.m - comment out the NSCAssert line. Xkeys3SIUnit.m, Xkeys124TbarUnit.m, and Xkeys24Unit.m - set cookie manually in handleInputValue based on buttons detected in Xkeys3SIInputReportCallback. 

Version 1.4 Changes

Cookie offset introduced because 10.15 changed them. The OS version is checked and offset applied if appropriate. Search on [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion >= 15 for where the changes are implemented.

Version 1.3 Changes

Modified the Xkeys3SIUnit.m file. This is the file which supports all products other than the XK-24 and the XKE-124 Tbar in a generic manner. Because there could be different read and write lengths on different products supported we cannot set the size of the report buffers in the @implementation section as is done in Xkeys24Unit.m and Xkeys124TbarUnit.m. In v1.2 the report buffer was declared locally under startListeningForInputReports and stopListeningForInputReports but this caused a program crash in certain situations. v1.3 changes how the report buffers are declared and sized, using malloc now.

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
