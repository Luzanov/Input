//
//  PeripheralsViewController.swift
//  Input
//
//  Created by LuzanovRoman on 28.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralsViewController: InputBaseViewController {

    var approvalDelegate: PeripheralApprovalDelegate?
    
    @IBOutlet fileprivate var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    fileprivate var statedPeripherals = [StatedPeripheral]()
    fileprivate let minimumLineSpacing: CGFloat = 10
    
    fileprivate var itemSize: CGFloat = {
        return max(250, min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) * 0.2)
    }()
    
    static func instance() -> PeripheralsViewController {
        return self.viewController(withIdentifier: "PeripheralsVC") as! PeripheralsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateCollectionViewLayoutWith(size: self.collectionView.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.updateCollectionViewLayoutWith(size: size)
    }
    
    fileprivate func updateCollectionViewLayoutWith(size: CGSize) {
        let itemCount = CGFloat(self.statedPeripherals.count)
        let contentWidth = (itemCount * self.itemSize) + max(itemCount - 1, 0) * self.minimumLineSpacing
        let top = (size.height - self.itemSize) / 2
        var edge = (size.width - self.itemSize) / 2
        
        if contentWidth < size.width {
            edge = (size.width - min(size.width, contentWidth)) / 2
        }
        self.collectionViewLayout.minimumLineSpacing = self.minimumLineSpacing
        self.collectionViewLayout.itemSize = CGSize(width: self.itemSize, height: self.itemSize)
        self.collectionViewLayout.sectionInset = UIEdgeInsets(top: top, left: edge, bottom: 0, right: edge)
    }
    
    fileprivate func add(statedPeripheral: StatedPeripheral) {
        self.collectionView.isHidden = false
        self.statedPeripherals.append(statedPeripheral)
        self.collectionView.performBatchUpdates({
            self.updateCollectionViewLayoutWith(size: self.collectionView.bounds.size)
            self.collectionView.insertItems(at: [IndexPath(row: self.statedPeripherals.count - 1, section: 0)])
        }, completion: nil)
    }
    
    fileprivate func update(statedPeripheral: StatedPeripheral) {
        guard let row = self.statedPeripherals.index(of: statedPeripheral) else { return }
        guard let cell = self.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) else { return }
        guard let peripheralCell = cell as? PeripheralsViewCell else { return }
        peripheralCell.statedPeripheral = statedPeripheral
    }
    
    fileprivate func hide(statedPeripheral: StatedPeripheral, afterDelay delay: TimeInterval) {
        statedPeripheral.disappearingWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let `self` = self else { return }
            guard let row = self.statedPeripherals.index(of: statedPeripheral) else { return }
            self.statedPeripherals.remove(at: row)
            
            self.collectionView.performBatchUpdates({
                self.updateCollectionViewLayoutWith(size: self.collectionView.bounds.size)
                self.collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
            }, completion: { (_) in
                self.collectionView.isHidden = self.statedPeripherals.count == 0;
            })
        }
        statedPeripheral.disappearingWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: requestWorkItem)
    }
}

extension PeripheralsViewController: InputInternalDelegate {
    
    static let defaultDelay: TimeInterval = 1
    
    func didFindPeripheral(_ inputPeripheral: InputPeripheral) {
        let peripheral = self.statedPeripherals.first(where: { (statedPeripheral) -> Bool in
            return statedPeripheral.inputPeripheral == inputPeripheral
        })
        
        if peripheral == nil {
            self.add(statedPeripheral: StatedPeripheral(inputPeripheral: inputPeripheral, state: .new))
        }
    }
    
    func didConnectPeripheral(_ inputPeripheral: InputPeripheral) {
        let peripheral = self.statedPeripherals.first(where: { (statedPeripheral) -> Bool in
            return statedPeripheral.inputPeripheral == inputPeripheral
        })
        if let existPeripheral = peripheral {
            existPeripheral.state = .connected
            self.update(statedPeripheral: existPeripheral)
            self.hide(statedPeripheral: existPeripheral, afterDelay: PeripheralsViewController.defaultDelay)
        } else {
            let statedPeripheral = StatedPeripheral(inputPeripheral: inputPeripheral, state: .connected)
            self.add(statedPeripheral: statedPeripheral)
            self.hide(statedPeripheral: statedPeripheral, afterDelay: PeripheralsViewController.defaultDelay)
        }
    }
    
    func didDisconnectPeripheral(_ inputPeripheral: InputPeripheral) {
        let peripheral = self.statedPeripherals.first(where: { (statedPeripheral) -> Bool in
            return statedPeripheral.inputPeripheral == inputPeripheral
        })
        if let existPeripheral = peripheral {
            self.hide(statedPeripheral: existPeripheral, afterDelay: 0)
        } else {
            let statedPeripheral = StatedPeripheral(inputPeripheral: inputPeripheral, state: .disconnected)
            self.add(statedPeripheral: statedPeripheral)
            self.hide(statedPeripheral: statedPeripheral, afterDelay: PeripheralsViewController.defaultDelay)
        }
    }
}

extension PeripheralsViewController: PeripheralsViewCellDelegate {
    
    func didPressAllowPeripheral(_ statedPeripheral: StatedPeripheral) {
        self.hide(statedPeripheral: statedPeripheral, afterDelay: 0)
        self.approvalDelegate?.didAllowPeripheral(statedPeripheral.inputPeripheral)
    }
    
    func didPressDismissPeripheral(_ statedPeripheral: StatedPeripheral) {
        self.hide(statedPeripheral: statedPeripheral, afterDelay: 0)
        self.approvalDelegate?.didDismissPeripheral(statedPeripheral.inputPeripheral)
    }
}

extension PeripheralsViewController:  UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.statedPeripherals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PeripheralsViewCell
        cell.statedPeripheral = self.statedPeripherals[indexPath.row]
        cell.delegate = self
        return cell
    }
}
