# XkeysOSX
X-keys SDK for OS X

This sample is generously provided by Robert Basilio

The XkeysMacOSXSample contains a console app written in Swift that demonstrates reading from and writing to an X-keys XK-24. When a button is pressed the input report is displayed in the output window, then the blue and red backlight LEDs for the corresponding button will be flashed. The output report used to flash the LEDs is displayed in the output window.

HID Reports for all X-keys products can be found at https://github.com/piengineering/PI-Engineering-SDK/tree/main/Documentation

Other available utilities are X-keys for Mac (https://apps.apple.com/us/app/x-keys-setup/id6446948270) and X-keys Web App (https://piengineering.com/pages/x-keys-web-app). These utilities are for users who wish to program memory resident macros such as keystrokes, mouse clicks, game controller buttons, etc. to their X-keys. Once programmed the unit can be used on any OS. The utility is not for developers wishing to integrate X-keys products for their own specific purposes or who need to use the analog features of certain X-keys products like jog shuttle knob or T-bar. Developers wishing to read/write the raw HID reports should use the XkeysMacOSXSample provided here.

Please contact Tech@piengineering.com for further details
