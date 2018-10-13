//
//  InputInternal+MousePeripheralDelegate.swift
//  Input
//
//  Created by LuzanovRoman on 27.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import Foundation

extension InputInternal: MousePeripheralDelegate {
    
    func mouseDidMove(withOffset offset: CGPoint) {
        let newX = min(max(0, self.mousePosition.x + offset.x), UIScreen.main.bounds.width)
        let newY = min(max(0, self.mousePosition.y + offset.y), UIScreen.main.bounds.height)
        let newPosition = CGPoint(x: newX, y: newY)
        
        if self.mousePosition != newPosition {
            let newOffset = CGPoint(x: newPosition.x - self.mousePosition.x, y: newPosition.y - self.mousePosition.y)
            
            self.mousePosition = newPosition
            
            self.allInputDelegates().forEach { (delegate) in
                delegate.didMoveMouse?(withOffset: newOffset)
            }
        }
    }
    
    func mouseButtonDidPress(_ button: MouseButton) {
        self.allInputDelegates().forEach { (delegate) in
            delegate.didPressMouseButton?(button)
        }
    }
    
    func mouseButtonDidRelease(_ button: MouseButton) {
        self.allInputDelegates().forEach { (delegate) in
            delegate.didReleaseMouseButton?(button)
        }
    }
}
