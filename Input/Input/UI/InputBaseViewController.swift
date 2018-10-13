//
//  InputBaseViewController.swift
//  Input
//
//  Created by LuzanovRoman on 28.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit

class InputBaseViewController: UIViewController {

    class func viewController(withIdentifier identifier: String) -> InputBaseViewController {
        let bundle = Bundle (for: InputBaseViewController.self)
        let storybaoard = UIStoryboard(name: "Input", bundle: bundle)
        return storybaoard.instantiateViewController(withIdentifier: identifier) as! InputBaseViewController
    }
}
