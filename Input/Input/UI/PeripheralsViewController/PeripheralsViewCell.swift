//
//  PeripheralsViewCell.swift
//  Input
//
//  Created by LuzanovRoman on 28.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit

protocol PeripheralsViewCellDelegate: class {
    func didPressAllowPeripheral(_ statedPeripheral: StatedPeripheral)
    func didPressDismissPeripheral(_ statedPeripheral: StatedPeripheral)
}

class PeripheralsViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate var container: UIView!
    @IBOutlet fileprivate var noteLabel: UILabel!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var iconImageView: UIImageView!
    
    weak var delegate: PeripheralsViewCellDelegate?
    
    var statedPeripheral: StatedPeripheral? {
        didSet {
            guard let sp = self.statedPeripheral else { return }

            let bundle = Bundle (for: PeripheralsViewCell.self)
            var titleText = ""
            
            switch sp.inputPeripheral.type {
            case .mouse:
                titleText = "A mouse "
                self.iconImageView.image = UIImage(named: "mouse_icon", in: bundle, compatibleWith: nil)
                
            case .keyboard:
                titleText = "A keyboard "
                self.iconImageView.image = UIImage(named: "keyboard_icon", in: bundle, compatibleWith: nil)
            }
            switch sp.state {
            case .new: titleText += "is found"
            case .connected: titleText += "is connected"
            case .disconnected: titleText += "is disconnected"
            }
            self.titleLabel.text = titleText
            self.noteLabel.isHidden = sp.state != .new
            self.container.transform = .identity
            self.container.alpha = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.container.layer.borderColor = UIColor.lightGray.cgColor
        self.container.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
        self.container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    @objc fileprivate func tap() {
        guard let peripheral = self.statedPeripheral else { return }
        self.delegate?.didPressAllowPeripheral(peripheral)
    }
    
    @objc fileprivate func pan(_ recognizer: UIPanGestureRecognizer) {
        guard let peripheral = statedPeripheral, peripheral.state == .new else { return }
        
        let limit: CGFloat = 200
        
        switch recognizer.state {
        case .began:
            let translation = recognizer.translation(in: recognizer.view)
            
            if translation.y > 0 {
                recognizer.setTranslation(.zero, in: recognizer.view)
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                return
            }

        case .changed:
            var translationY = recognizer.translation(in: self.container).y
            
            if translationY > 0 {
                translationY = 0;
            }
            self.container.transform = CGAffineTransform(translationX: 0, y: translationY)
            self.container.alpha = 1.0 - min(1.0, abs(translationY) / limit)

        case .ended:
            let translation = recognizer.translation(in: self.container)
            let velocity = recognizer.velocity(in: self.container)
            var targetTranslationY: CGFloat = 0
            var alpha: CGFloat = 1
            
            if translation.y < 0 && velocity.y < 0 && (abs(translation.y) > limit || abs(velocity.y) > 300) {
                targetTranslationY = translation.y + velocity.y
                alpha = 0
                
                if let peripheral = self.statedPeripheral {
                    self.delegate?.didPressDismissPeripheral(peripheral)
                }
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveLinear], animations: {
                self.container.transform = CGAffineTransform(translationX: 0, y: targetTranslationY)
                self.container.alpha = alpha
            }, completion:nil)

        default: break
        }
    }
}
