//
//  MousePeripheralHandler.swift
//  Input
//
//  Created by LuzanovRoman on 23.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol MousePeripheralDelegate: class {
    func mouseDidMove(withOffset offset: CGPoint)
    func mouseButtonDidPress(_ button: MouseButton)
    func mouseButtonDidRelease(_ button: MouseButton)
}

class MousePeripheralHandler: PeripheralHandler {
    
    weak var mouseDelegate: MousePeripheralDelegate?
    var mouseSpeed: CGFloat = 0.5
    
    private var buffer = [Int8]()
    private var isMouseLeftButtonPressed = false
    private var isMouseRightButtonPressed = false

    func isMouseButtonPressed(_ button: MouseButton) -> Bool {
        switch button {
        case .mbLeft: return self.isMouseLeftButtonPressed;
        case .mbRight: return self.isMouseRightButtonPressed;
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        let bytes = data.withUnsafeBytes {
            [Int8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        self.buffer.append(contentsOf: bytes)
        
        while self.buffer.count > 3 {
            let firstByte = self.buffer[0]
            
            if firstByte != 127 {
                self.buffer.removeFirst()
                continue;
            }
            var deltaX = CGFloat(self.buffer[1])
            var deltaY = CGFloat(self.buffer[2])
            
            if self.mouseSpeed > 0 {
                deltaX *= abs(deltaX) * self.mouseSpeed
                deltaY *= abs(deltaY) * self.mouseSpeed
            }
            if deltaX != 0 || deltaY != 0 {
                self.mouseDelegate?.mouseDidMove(withOffset: CGPoint(x: deltaX, y: deltaY))
            }
            let buttonsState = self.buffer[3]
            let newMouseLeftButtonState = buttonsState & (1 << 0) == 1
            let newMouseRightButtonState = buttonsState & (1 << 1) == 2
            
            if self.isMouseLeftButtonPressed != newMouseLeftButtonState {
                self.isMouseLeftButtonPressed = newMouseLeftButtonState
                
                if self.isMouseLeftButtonPressed {
                    self.mouseDelegate?.mouseButtonDidPress(.mbLeft)
                } else {
                    self.mouseDelegate?.mouseButtonDidRelease(.mbLeft)
                }
            }
            if self.isMouseRightButtonPressed != newMouseRightButtonState {
                self.isMouseRightButtonPressed = newMouseRightButtonState
                
                if self.isMouseRightButtonPressed {
                    self.mouseDelegate?.mouseButtonDidPress(.mbRight)
                } else {
                    self.mouseDelegate?.mouseButtonDidRelease(.mbRight)
                }
            }
            self.buffer.removeFirst(4);
        }
    }
}
