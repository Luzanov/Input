//
//  Input.swift
//  Input
//
//  Created by LuzanovRoman on 22.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit

@objc public protocol InputDelegate {
    @objc optional func didMoveMouse(withOffset offset: CGPoint)
    @objc optional func didPressMouseButton(_ button: MouseButton)
    @objc optional func didReleaseMouseButton(_ button: MouseButton)
    @objc optional func didPressKeyboardKey(_ key: String)
    @objc optional func didReleaseKeyboardKey(_ key: String)
}

public class Input: NSObject {
    static let inputInternal = InputInternal()

    public static var isMouseCursorHidden: Bool {
        get { return self.inputInternal.isMouseCursorHidden }
        set { self.inputInternal.isMouseCursorHidden = newValue }
    }
    
    public static func isKeyPressed(_ key: String) -> Bool {
        return self.inputInternal.isKeyPressed(key)
    }
    
    public static func isMouseButtonPressed(_ button: MouseButton) -> Bool {
        return self.inputInternal.isMouseButtonPressed(button)
    }
    
    public static var mousePosition: CGPoint {
        get { return self.inputInternal.mousePosition }
        set { self.inputInternal.mousePosition = newValue }
    }
    
    public static func enable() {
        self.inputInternal.enable = true
    }
    
    public static func disable() {
        self.inputInternal.enable = false
    }
    
    public static func addDelegate(_ delegate: InputDelegate) {
        self.inputInternal.addInputDelegate(delegate)
    }
    
    public static func removeDelegate(_ delegate: InputDelegate) {
        self.inputInternal.removeInputDelegate(delegate)
    }
}
