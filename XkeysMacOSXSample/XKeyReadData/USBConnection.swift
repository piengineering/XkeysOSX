//
//  USBConnection.swift
//  XKeyReadData
//
//  Created by Silver Reliable Results on 01/04/21.
//  Updated by Robert Basilio on 10/05/25.
//

import Foundation
import IOKit.hid


class USBConnection : NSObject {
    
    // USB DEVICE IDENTIFIERS
    // Replace these 4 values for the unique XKey product, particularly the productID.
    // Reference the PID table in the data report. The primaryUsagePage and primaryUsage are listed in the endpoints.
    // 12 & 1 for the Consumer Usage are probably the ones you want if you want to interact with the lights.
    let vendorId = 0x05F3 // XK24 Vendor ID - 1523
    let productId = 0x0405 // XK24 Product ID - 1029
    let primaryUsagePage = 0x000C //12
    let primaryUsage = 0x0001
    
    static let singleton = USBConnection()
    var device : IOHIDDevice? = nil
    
    static var countDevAttached = 0
    static var countDevRemoved = 0
    
    // For XK-24
    let reportSize = 32 //Device specific, one less than documentation for Mac (no leading 0 byte)
    let reportSizeOutput = 35 //one less than documentation for Mac (no leading 0 byte)
    let backLight2offset: Int = 32
    let bBytes =  4 // number of button bytes, COL
    let bBits =  6 // number button bits per byte, ROW
    var totalButtons: Int {
        return bBytes * bBits
    }
    let colorBankTotal = 2 // number of colored backlights. XK-24 has 2: blue and red.
    
    // For XK-16/8/4
//    let bBytes =  4 // number of button bytes, COl
//    let bBits =  4 // number button bits per byte, ROW
    
    
    //Callback to pass on reading the General Incoming Data
    func input(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, type: IOHIDReportType, reportId: UInt32, report: UnsafeMutablePointer<UInt8>, reportLength: CFIndex) {
        let message = Data(bytes: report, count: reportLength)
        
        guard message.count == reportSize else { return }
        
        let objReadData = ReadData()
        
        objReadData.getKeyState(message: message, reportLength: reportLength)
    }
    
    
    func individualBtnSendBacklight(keyIndex: Int, colorBank: Int, onOffFlash: UInt8)  {
        guard (0..<totalButtons).contains(keyIndex) &&
                (0..<colorBankTotal).contains(colorBank) &&
                onOffFlash <= 2
        else { return }
        var backlightIndex: UInt8
        
        backlightIndex = UInt8(keyIndex + colorBankTotal * backLight2offset)
        
        //For XK16/8/4
//        switch keyIndex {
//        case 0, 1, 2, 3, 4, 5:
//            backlightIndex = UInt8(keyIndex)
//        case 6, 7, 8, 9, 10, 11:
//            backlightIndex = UInt8(keyIndex + 2)
//        case 12, 13, 14, 15:
//            backlightIndex = UInt8(keyIndex + 4)
//        default:
//            backlightIndex = 6 //unused value that shouldn't be hit
//        }
        
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        bytes[0] = 0xb5 // 181
        bytes[1] = UInt8(backlightIndex)  // 0x00 // 0th index
        bytes[2] = onOffFlash  // 1 - on, 0- off, 2 flash
        
        self.output(Data(bytes))
    }
    
    
    func setToggle() {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        bytes[0] = 0xb8  //184
        self.output(Data(bytes))
    }
    
    
    func setUnitID(_ newUnitVal: UInt8) {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        bytes[0] = 0xbd //189 //command
        bytes[1] = newUnitVal //New unit ID value
        
        self.output(Data(bytes))
    }
    
    
    func setGreenIndicatorVal(_ onOffFlash: UInt8) {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        bytes[0] = 0xb3 //179 //command
        bytes[1] = 0x06 //6 for green
        bytes[2] = onOffFlash // ON- 0x01,  OFF - 0x00,  Flash - 0x02
        
        self.output(Data(bytes))
    }
    
    
    func setRedIndicatorVal(_ onOffFlash: UInt8) {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        bytes[0] = 0xb3 //179 //command
        bytes[1] = 0x07 // 7 for red
        bytes[2] = onOffFlash // ON- 0x01,  OFF - 0x00,  Flash - 0x02
        
        self.output(Data(bytes))
    }
    
    
    func setBacklightIntensity(_ intensity: UInt8) {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        bytes[0] = 0xbb //187 //command
        bytes[1] = intensity
        
        self.output(Data(bytes))
    }
    
    
    func setAllBlueOnOff(_ onOffVal: Bool) {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        var val: UInt8 = 0x00 // Off lights
        if(onOffVal == true) {
            val = 0xff // on lights
        }
        bytes[0] = 0xb6 //182 //command
        bytes[1] = 0x0 //0 - Blue
        bytes[2] = val // 0xff // 255
        
        self.output(Data(bytes))
    }
    
    
    func setAllRedOnOff(_ onOffVal: Bool) {
        var bytes =  [UInt8](repeating: 0, count: reportSizeOutput)
        
        var val: UInt8 = 0x00 // Off lights
        if(onOffVal == true) {
            val = 0xff // on lights
        }
        bytes[0] = 0xb6 //182 //command
        bytes[1] = 0x1 //1 - Red
        bytes[2] = val // 0xff // 255
        
        self.output(Data(bytes))
    }
    
    
    func rebootDevice() {
        //21. Reboot Device
        // Send this output report to reboot the device without having to unplug it. After sending this report the device must be re-enumerated.
        print("Rebooting device..")
        
        var bytes =  [UInt8](repeating: 0, count: self.reportSizeOutput)
        bytes[0] = 0xee //238 to enumerate // 0xd6 // 214  Descriptor Data   //
        
        // same code as Output method, added here just to maintain flag: isEnumerating
        let data = Data(bytes)
        guard (data.count <= reportSizeOutput) else {
            print("output data too large for USB report")
            return
        }
        
        let reportId : CFIndex = CFIndex(0) //data[0])
        if let blink1 = device {
           // print("Senting Reboot output: \([UInt8](data))")
            
            let deviceNameResult:IOReturn
            deviceNameResult = IOHIDDeviceSetReport(blink1, kIOHIDReportTypeOutput, reportId, [UInt8](data), data.count)
            if(deviceNameResult != kIOReturnSuccess) {
                print("Error in sending Data " + String(deviceNameResult))
            }
        }
    }
    
    
    // function used to send commands formatted by other functions to the XKey device
    func output(_ data: Data) {
        guard data.count <= reportSizeOutput else {
            print("output data too large for USB report")
            return
        }
        
        let reportId : CFIndex = CFIndex(0) //data[0])
        if let blink1 = device {
//            print("Sending output: \([UInt8](data))")
            
            let deviceNameResult:IOReturn
            deviceNameResult = IOHIDDeviceSetReport(blink1, kIOHIDReportTypeOutput, reportId, [UInt8](data), data.count)
            if(deviceNameResult != kIOReturnSuccess) {
                print("Error in sending Data " + String(deviceNameResult))
            }
        }
    }
    
    
    // callback function to set up the XKey device when it connects.
    func connected(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        
        //all debugging info, can be commented out
        if USBConnection.countDevAttached == 0 {
            let arr = String(inIOHIDDeviceRef.debugDescription).components(separatedBy: " ")
            print("Device connected")
            
            if arr.count > 11 {
                //at index 11: Product name
                //index 7: Product ID
                //index 6: Vendor ID
                print(arr[11] + " " + arr[7] + " " + arr[6])
            } else {
                print(inIOHIDDeviceRef.debugDescription)
            }
            
            USBConnection.countDevAttached = 1
            USBConnection.countDevRemoved = 0
        }
        
        // It would be better to look up the report size and create a chunk of memory of that size1234522727272727
        let report = UnsafeMutablePointer<UInt8>.allocate(capacity: reportSize)
        
        device = inIOHIDDeviceRef
        
        //print("report size:" + String(reportSize))
        
        let inputCallback : IOHIDReportCallback = { inContext, inResult, inSender, type, reportId, report, reportLength in
            let this : USBConnection = Unmanaged<USBConnection>.fromOpaque(inContext!).takeUnretainedValue()
            this.input(inResult, inSender: inSender!, type: type, reportId: reportId, report: report, reportLength: reportLength)
        }
      
        //Hook up inputcallback
        let this = Unmanaged.passRetained(self).toOpaque()
        IOHIDDeviceRegisterInputReportCallback(device!, report, reportSize, inputCallback, this)
        
        //initialize various backlights
        setGreenIndicatorVal(0x01)  // ON- 0x01,  OFF - 0x00,  Flash - 0x02
        setRedIndicatorVal(0x01)  // ON- 0x01,  OFF - 0x00,  Flash - 0x02
        setAllBlueOnOff(true)
        setAllRedOnOff(true)
        
        setUnitID(0x05)
        setGreenIndicatorVal(0x00)  // ON- 0x01,  OFF - 0x00,  Flash - 0x02
//        setRedIndicatorVal(0x00)  // ON- 0x01,  OFF - 0x00,  Flash - 0x02
        setAllBlueOnOff(false)
        setAllRedOnOff(false)
        
        setBacklightIntensity(0xff)
    }
    
    
    // callback function for when Xkey device is removed
    func removed(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        print("Device removed")
        print(inIOHIDDeviceRef.debugDescription)
        USBConnection.countDevAttached = 0
        USBConnection.countDevRemoved = 1
        NotificationCenter.default.post(name: Notification.Name(rawValue: "deviceDisconnected"), object: nil, userInfo: ["class": NSStringFromClass(type(of: self))])
    }
    
    
    //sets up the USB connections and listeners
    @objc func initUsb() {
        // device match sets the descriptors to match to
        let deviceMatch = [kIOHIDProductIDKey: productId, kIOHIDVendorIDKey: vendorId, kIOHIDPrimaryUsagePageKey: primaryUsagePage, kIOHIDPrimaryUsageKey: primaryUsage]
        let managerRef = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        IOHIDManagerSetDeviceMatching(managerRef, deviceMatch as CFDictionary?)
        IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(managerRef, 0)
        
        let matchingCallback : IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
            let this : USBConnection = Unmanaged<USBConnection>.fromOpaque(inContext!).takeUnretainedValue()
            this.connected(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
        }
        
        let removalCallback : IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
            let this : USBConnection = Unmanaged<USBConnection>.fromOpaque(inContext!).takeUnretainedValue()
            this.removed(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
        }
        
        let this = Unmanaged.passRetained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(managerRef, matchingCallback, this)
        IOHIDManagerRegisterDeviceRemovalCallback(managerRef, removalCallback, this)
        
        RunLoop.current.run()
    }
}




