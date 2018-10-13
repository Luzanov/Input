//
//  ViewController.swift
//  InputTestSwift
//
//  Created by LuzanovRoman on 24.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import Input

class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    fileprivate var isMainViewSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Input.enable()
        Input.addDelegate(self)
    }
    
    deinit {
        Input.removeDelegate(self)
    }
}

extension ViewController: InputDelegate {
    
    func didMoveMouse(withOffset offset: CGPoint) {
        guard self.isMainViewSelected else { return }
        self.mainView.frame = self.mainView.frame.offsetBy(dx: offset.x, dy: offset.y)
    }
    
    func didPressMouseButton(_ button: MouseButton) {
        if button == .mbLeft {
            self.isMainViewSelected = self.mainView.frame.contains(Input.mousePosition)
        }
    }
    
    func didReleaseMouseButton(_ button: MouseButton) {
        if button == .mbLeft {
            self.isMainViewSelected = false
        }
    }
    
    func didPressKeyboardKey(_ key: String) {
        print("\(key) is pressed")
    }
    
    func didReleaseKeyboardKey(_ key: String) {
        print("\(key) is released")
    }
}

