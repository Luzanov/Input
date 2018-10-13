//
//  MouseViewController.swift
//  Input
//
//  Created by LuzanovRoman on 28.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit

class MouseViewController: InputBaseViewController {
    
    @IBOutlet fileprivate var cursorView: UIView!
    
    static func instance() -> MouseViewController {
        return self.viewController(withIdentifier: "MouseVC") as! MouseViewController
    }
    
    var mousePosition = CGPoint.zero {
        didSet {
            self.cursorView.frame.origin = self.mousePosition
        }
    }
    
    var needShowMouseCursor = false {
        didSet {
            self.updateMouseCursorVisibility()
        }
    }
    
    var isMouseCursorHidden = false {
        didSet {
            self.updateMouseCursorVisibility()
        }
    }

    fileprivate func updateMouseCursorVisibility() {
        self.cursorView.isHidden = self.isMouseCursorHidden || !self.needShowMouseCursor
    }
}
