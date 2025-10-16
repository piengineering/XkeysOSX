//
//  main.swift
//  XKeyReadData
//
//  Created by Silver Reliable Results on 01/04/21.
//  Updated by Robert Basilio on 10/05/25.
//

import Foundation
import AppKit

let objUSB = USBConnection.singleton
print("This application will flash pressed Key backlights of XK-24")
var objThread = Thread(target: objUSB, selector:#selector(USBConnection.initUsb), object: nil)
objThread.start()
RunLoop.current.run()
