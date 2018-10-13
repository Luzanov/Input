//
//  InputWindow.swift
//  Input
//
//  Created by LuzanovRoman on 03.02.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit

class InputWindow: UIWindow {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let viewController = UIViewController()
        viewController.view.frame = self.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(viewController.view)
        self.rootViewController = viewController
        self.windowLevel = UIWindowLevelStatusBar - 1
        self.backgroundColor = nil
        self.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        guard let rootVC = self.rootViewController else { return hitView }
        if rootVC.view === hitView { return nil }
        
        for childVC in rootVC.childViewControllers {
            if childVC.view === hitView { return nil }
        }
        return hitView
    }
    
    func addViewController(_ viewController: UIViewController) {
        guard let rootVC = self.rootViewController else { return }
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.frame = self.bounds
        rootVC.view.addSubview(viewController.view)
        rootVC.addChildViewController(viewController)
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
