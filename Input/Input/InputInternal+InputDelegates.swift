//
//  InputInternal+InputDelegates.swift
//  Input
//
//  Created by LuzanovRoman on 27.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import Foundation
import UIKit

extension InputInternal {
    
    fileprivate static func pointer(forDelegate delegate: AnyObject) -> UnsafeRawPointer? {
        if !delegate.conforms(to: InputDelegate.self) { return nil }
        return UnsafeRawPointer(Unmanaged.passUnretained(delegate).toOpaque())
    }
    
    fileprivate static func delegate(fromPointer pointer: UnsafeRawPointer) -> AnyObject {
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func addInputDelegate(_ delegate: AnyObject) {
        guard let pointer = InputInternal.pointer(forDelegate: delegate) else { return }
        if self.inputDelegates.contains(pointer) { return }
        self.inputDelegates.append(pointer)
    }
    
    func removeInputDelegate(_ delegate: AnyObject) {
        guard let pointer = InputInternal.pointer(forDelegate: delegate) else { return }
        guard let index = self.inputDelegates.index(of: pointer) else { return }
        self.inputDelegates.remove(at: index)
    }
    
    func allInputDelegates() -> [InputDelegate] {
        return self.inputDelegates.map { (pointer) -> InputDelegate in
            InputInternal.delegate(fromPointer: pointer) as! InputDelegate
        }
    }
}
