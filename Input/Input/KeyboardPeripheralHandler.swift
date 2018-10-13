//
//  KeyboardPeripheralHandler.swift
//  Input
//
//  Created by LuzanovRoman on 14.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol KeyboardPeripheralDelegate: class {
    func keyboardDidPress(key: String)
    func keyboardDidRelease(key: String)
}

class KeyboardPeripheralHandler: PeripheralHandler {
    
    weak var keyboardDelegate: KeyboardPeripheralDelegate?
    
    fileprivate let keys: [String] = ["w", "r", "s", "a", "d", " "]
    fileprivate var state: Int8 = 0
    
    fileprivate func checkValue(forKeyWithIndex keyIndex: Int) -> Int8 {
        if keyIndex > 1 {
            return (pow(2, keyIndex) as NSDecimalNumber).int8Value
        }
        return Int8(keyIndex) + 1
    }
    
    fileprivate func updateState(withState newState: Int8) {
        for i in 0..<self.keys.count {
            let value = self.checkValue(forKeyWithIndex: i)
            let oldKeyState = self.state & (1 << i) == value
            let newKeyState = newState & (1 << i) == value
            
            if oldKeyState != newKeyState {
                if newKeyState {
                    self.keyboardDelegate?.keyboardDidPress(key: keys[i])
                } else {
                    self.keyboardDelegate?.keyboardDidRelease(key: keys[i])
                }
            }
        }
        self.state = newState
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        let bytes = data.withUnsafeBytes {
            [Int8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        for byte in bytes {
            self.updateState(withState: byte)
        }
    }
    
    func isKeyPressed(_ key: String) -> Bool {
        guard let keyIndex = self.keys.index(of: key) else { return false }
        return self.state & (1 << keyIndex) == self.checkValue(forKeyWithIndex: keyIndex)
    }
}
