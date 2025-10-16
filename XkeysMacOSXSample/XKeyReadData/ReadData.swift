//
//  ReadData.swift
//  XKeyReadData
//
//  Created by Silver Reliable Results on 02/04/21.
//  Updated by Robert Basilio on 10/05/25.
//

import Foundation
import AppKit
import CoreGraphics
import Carbon.HIToolbox

class KeyState {
    var index:Int
    var bit: Bool
    
    init(index : Int, bit: Bool) {
        self.index = index
        self.bit = bit
    }
}


//example KeyCode Enum, which makes it easier to keep track of keyboard codes and related flags.
//use this to simplify code that creates keyboard codes
enum KeyCode {
    case enter
    case scene0
    case scene1
    case scene2
    case scene3
    case scene4
    
    func getCode() -> CGKeyCode {
        switch self {
        case .enter:
            return UInt16(kVK_Return)
        case .scene0:
            return UInt16(kVK_ANSI_0)
        case .scene1:
            return UInt16(kVK_ANSI_1)
        case .scene2:
            return UInt16(kVK_ANSI_2)
        case .scene3:
            return UInt16(kVK_ANSI_3)
        case .scene4:
            return UInt16(kVK_ANSI_4)
        }
    }
    
    func getFlags() -> CGEventFlags {
        switch self {
        case .enter:
            return []
        case .scene0, .scene1, .scene2, .scene3, .scene4:
            return.maskAlternate
        }
    }
    
    static func getKeyCode(for keyNum: Int) -> KeyCode {
        switch keyNum {
        case 0:
            return .scene0
        case 1:
            return .scene1
        case 2:
            return .scene2
        case 3:
            return .scene3
        case 4:
            return .scene4
        default:
            return .enter
        }
    }
}

//example application identifiers for use with interacting with other applications
var applicationBundleId = "com.apple.Notes"
var isApplicationActive: Bool {
    return NSWorkspace.shared.frontmostApplication?.bundleIdentifier == applicationBundleId
}


class ReadData: ObservableObject {
    static var lastKeyNum: Int? = nil
    static var objPrevKeyState:[KeyState] = []
    static var lastdata =  [UInt8](repeating: 0, count: 33) //[UInt8](arrayLiteral: 33)
    static var saveabsolutetime: Int = 0
    static var lastPSdata: UInt8 = 8
    
    //**************************************************************************************************************************************************
    
    func getRawData(message: Data) -> String {
        var joinString = ""
        for i in message {
            //convert in hexadecimal
            let thisbyte = String(format: "%02X", i) //2 digit hex string2
            //OR let thisbyte = String(format: "%02X", message[i]) + " "
            joinString = "\(joinString)|\(thisbyte)"
        }
        
        //            print("Output: " + joinString)
        
        return joinString
    }
    
    //**************************************************************************************************************************************************
    
    
    func getKeyState(message: Data, reportLength: Int) {
        
        //check the switch byte
        //*********************************
        
        var data = message
        
        data.insert(0, at: 0) // just to make it same as C#, will remove it later === Rupee 8-Apr-2021
        // byte is UInt8 in swift
        
        //check the switch byte
        let PSval = (UInt8)(data[2] & 1); //(UInt8(data[2]) & UInt8(1))
        
        var buttonsdown = "" // "Buttons Pressed: "; //for demonstration, reset this every time a new input report received
        
        // if value change, then only print PS value
        
        let dec = (pow(Decimal(2), 0))
        let temp1 =  Int(truncating: dec as NSNumber)
        let temp2 =  (data[2] & UInt8(temp1)) % 2 //on XK-24 this can only be 0 or 1, but on some it can be other values
        
        //check using bitwise AND the previous value of this bit
        let temp3 =  (ReadData.lastPSdata & UInt8(temp1)) % 2
        
        var state = 0; //0=was up, now up, 1=was up, now down, 2= was down, still down, 3= was down, now up
        if (temp2 != 0 && (temp3 == 0 || ReadData.lastPSdata == 8)) {
            state = 1; //press
        } else if (temp2 == 0 && (temp3 != 0 || ReadData.lastPSdata == 8)) {
            state = 3; //release
        } else if (temp2 != 0 && temp3 != 0) {
            state = 2; //held down
        }
        
        switch(state) {
        case 1: //key was up and now is pressed
            activatePSSwitch()
            buttonsdown = buttonsdown + "\n Program switch flipped on";
            break;
        case 2: //key was pressed and still is pressed
            buttonsdown = buttonsdown + "\n Program switch still on";
            break;
        case 3: //key was pressed and now released
            deactivatePSSwitch()
            buttonsdown = buttonsdown + "\n Program switch flipped off";
            break;
        default:
            break;
        }
        ReadData.lastPSdata = PSval
        
        //read the unit ID
        print("UnitID:" + String(data[1]))
        
        
        //write raw data to listbox1 in HEX
        let output = "Callback: " + getRawData(message: data)// + sourceDevice.Pid + ", ID: " + selecteddevice.ToString() + ", data=";
        print(output)
                
        //buttons
        //this routine is for separating out the individual button presses/releases from the data byte array.
        let maxcols = objUSB.bBytes //number of columns of Xkeys digital button data, labeled "Keys" in P.I. Engineering SDK - General Incoming Data Input Report
        let maxrows = objUSB.bBits
        
        for i in 0..<maxcols { //loop through digital button bytes
            for j in 0..<maxrows { //loop through each bit in the button byte
                let dec = (pow(Decimal(2), j))
                let temp1 =  Int(truncating: dec as NSNumber)
                
                //for XK16, this is actually i + maxcols * j
                let keynum = maxrows * i + j //using key numbering in sdk; column 1 = 0,1,2... column 2 = 8,9,10... column 3 = 16,17,18... column 4 = 24,25,26... etc
                //var temp2 = (byte)(data[i + 3] & temp1); //check using bitwise AND the current value of this bit. The + 3 is because the 1st button byte starts 3 bytes in at data[3]
                
                //                byte temp2 = (byte)(data[i + 3] & temp1); //check using bitwise AND the current value of this bit. The + 3 is because the 1st button byte starts 3 bytes in at data[3]
                //                byte temp3 = (byte)(lastdata[i + 3] & temp1); //check using bitwise AND the previous value of this bit
                
                let temp2 =  data[i + 3] & UInt8(temp1)
                
                //var temp3 = (byte)(lastdata[i + 3] & temp1); //check using bitwise AND the previous value of this bit
                let temp3 =  ReadData.lastdata[i + 3] & UInt8(temp1)
                
                var state = 0; //0=was up, now up, 1=was up, now down, 2= was down, still down, 3= was down, now up
                if (temp2 != 0 && temp3 == 0) {
                    state = 1; //press
                } else if (temp2 != 0 && temp3 != 0) {
                    state = 2; //held down
                }
                else if (temp2 == 0 && temp3 != 0) {
                    state = 3; //release
                }
                
                switch(state) {
                case 1: //key was up and now is pressed
                    buttonsdown = buttonsdown + "\n Button " + String(keynum) + " down ";
                    pressButton(keyNum: keynum)
                    break;
                case 2: //key was pressed and still is pressed
                    buttonsdown = buttonsdown + "\n Button " + String(keynum) + " still pressed ";
                    break;
                case 3: //key was pressed and now released
                    buttonsdown = buttonsdown + "\n Button " + String(keynum) + " up ";
                    break;
                default:
                    break;
                }
            }
        } // for loop end
        
        print(buttonsdown + "\n")
        
        for i in 0..<reportLength { //sourceDevice.ReadLength; i++)
            ReadData.lastdata[i] = data[i];
        }
        //        end buttons
        
        //time stamp info 4 bytes27
        
        let absolutetime =  16777216 * Int(data[7]) + 65536 * Int(data[8]) + 256 * Int(data[9]) + Int(data[10])  //ms
        let absolutetime2 = absolutetime / 1000; //seconds
        //                      c = this.label19;
        //this.SetText("absolute time: " + absolutetime2.ToString() + " s");
        print("absolute time: " + String(absolutetime2) + " s")
        let deltatime = absolutetime - ReadData.saveabsolutetime
        //c = this.label20;
        print("delta time: " + String(deltatime) + " ms");
        ReadData.saveabsolutetime = absolutetime;
    }
    
    
    private func activatePSSwitch() {
        DispatchQueue.main.async {
            //change lights
            objUSB.setGreenIndicatorVal(0x01)
            objUSB.setRedIndicatorVal(0x00)
            objUSB.setAllBlueOnOff(false)
        }
        //open lightkey program
        let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: applicationBundleId)

        if let appUrl = appUrl {
            NSWorkspace.shared.openApplication(at: appUrl, configuration: NSWorkspace.OpenConfiguration())
        }
    }
    
    
    private func deactivatePSSwitch() {
        DispatchQueue.main.async {
            objUSB.setRedIndicatorVal(0x01)
            objUSB.setGreenIndicatorVal(0x00)
            objUSB.setAllBlueOnOff(false)
            ReadData.lastKeyNum = nil
        }
        
        let runningApplications = NSWorkspace.shared.runningApplications
        if let app = runningApplications.first(where: { (application) in
            return application.bundleIdentifier == applicationBundleId
        }) {
            app.terminate()
        }
    }
    
    
    private func pressButton(keyNum: Int) {
        let scene = KeyCode.getKeyCode(for: keyNum)
        
        DispatchQueue.main.async {
            objUSB.setAllBlueOnOff(false)
            objUSB.individualBtnSendBacklight(keyIndex: keyNum, colorBank: 1, onOffFlash: 1)
        }
        
        let sourceRef = CGEventSource(stateID: .hidSystemState)
        let scenePress = CGEvent(keyboardEventSource: sourceRef, virtualKey: scene.getCode(), keyDown: true)
        scenePress?.flags = scene.getFlags()
        let sceneRelease = CGEvent(keyboardEventSource: sourceRef, virtualKey: scene.getCode(), keyDown: false)
        sceneRelease?.flags = scene.getFlags()
        scenePress?.post(tap: .cghidEventTap)
        sceneRelease?.post(tap: .cghidEventTap)
        
        ReadData.lastKeyNum = keyNum
    }
    
    
}
