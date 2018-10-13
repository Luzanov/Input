//
//  InputInternal+KeyboardPeripheralDelegate.swift
//  Input
//
//  Created by LuzanovRoman on 15.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import Foundation

extension InputInternal: KeyboardPeripheralDelegate {
    
    func keyboardDidPress(key: String) {
        self.allInputDelegates().forEach { (delegate) in
            delegate.didPressKeyboardKey?(key)
        }
    }
    
    func keyboardDidRelease(key: String) {
        self.allInputDelegates().forEach { (delegate) in
            delegate.didReleaseKeyboardKey?(key)
        }
    }
}
