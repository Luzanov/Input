//
//  InputInternal.swift
//  Input
//
//  Created by LuzanovRoman on 24.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PeripheralApprovalDelegate {
    func didAllowPeripheral(_ inputPeripheral: InputPeripheral)
    func didDismissPeripheral(_ inputPeripheral: InputPeripheral)
}

protocol InputInternalDelegate {
    func didFindPeripheral(_ peripheral: InputPeripheral)
    func didConnectPeripheral(_ peripheral: InputPeripheral)
    func didDisconnectPeripheral(_ peripheral: InputPeripheral)
}

class InputInternal: NSObject {
    var inputDelegates = [UnsafeRawPointer]()
    
    fileprivate let mouseServiceUUID = CBUUID(string: "0001")
    fileprivate let keyboardServiceUUID = CBUUID(string: "0002")
    
    fileprivate var inputWindow: InputWindow!
    fileprivate let mouseVC = MouseViewController.instance()
    fileprivate let peripheralsVC = PeripheralsViewController.instance()
    
    fileprivate var mainCentralManager: CBCentralManager!
    fileprivate var mousePeripheralHandler: MousePeripheralHandler?
    fileprivate var keyboardPeripheralHandler: KeyboardPeripheralHandler?
    
    var enable = false {
        didSet {
            if self.enable {
                self.startScanIfNeeded()
            } else {
                self.stopScan()
            }
        }
    }
    
    var isMouseCursorHidden: Bool {
        get { return self.mouseVC.isMouseCursorHidden }
        set { self.mouseVC.isMouseCursorHidden = newValue }
    }
    
    var mousePosition: CGPoint {
        get { return self.mouseVC.mousePosition }
        set { self.mouseVC.mousePosition = newValue }
    }
    
    public override init() {
        super.init()
        
        self.inputWindow = InputWindow(frame: UIScreen.main.bounds)
        self.inputWindow.addViewController(self.mouseVC)
        self.inputWindow.addViewController(self.peripheralsVC)
        self.peripheralsVC.approvalDelegate = self
        
        self.mainCentralManager = CBCentralManager(delegate: self, queue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startScanIfNeeded), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopScan), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func isMouseButtonPressed(_ button: MouseButton) -> Bool {
        guard let handler = self.mousePeripheralHandler else { return false }
        return handler.isMouseButtonPressed(button)
    }
    
    func isKeyPressed(_ key: String) -> Bool {
        guard let handler = self.keyboardPeripheralHandler else { return false }
        return handler.isKeyPressed(key)
    }
    
    @objc func startScanIfNeeded() {
        guard self.mainCentralManager.state == .poweredOn, self.enable else { return }
        
        if self.mousePeripheralHandler == nil || self.keyboardPeripheralHandler == nil {
            let services: [CBUUID] = [mouseServiceUUID, keyboardServiceUUID]
            self.mainCentralManager.scanForPeripherals(withServices: services, options: nil)
        }
    }
    
    @objc func stopScan() {
        self.mainCentralManager.stopScan()
        self.releaseMousePeripheral()
        self.releaseKeyboardPeripheral()
    }
    
    @objc func orientationDidChange() {
        let newX = min(self.mousePosition.x, UIScreen.main.bounds.width)
        let newY = min(self.mousePosition.y, UIScreen.main.bounds.height)
        let newPosition = CGPoint(x: newX, y: newY)
        
        if self.mousePosition != newPosition {
            self.mousePosition = newPosition
        }
    }
    
    fileprivate func connect(_ peripheral: InputPeripheral) {
        switch peripheral.type {
        case .mouse:
            self.mousePeripheralHandler = MousePeripheralHandler(mainPeripheral: peripheral.peripheral)
            self.mousePeripheralHandler?.mouseDelegate = self
            self.mousePeripheralHandler?.delegate = self
            
        case .keyboard:
            self.keyboardPeripheralHandler = KeyboardPeripheralHandler(mainPeripheral: peripheral.peripheral)
            self.keyboardPeripheralHandler?.keyboardDelegate = self
            self.keyboardPeripheralHandler?.delegate = self
        }
        self.mainCentralManager.connect(peripheral.peripheral, options: nil)
    }
    
    fileprivate func releaseMousePeripheral() {
        guard let peripheral = self.mousePeripheralHandler?.mainPeripheral else { return }
        self.mainCentralManager.cancelPeripheralConnection(peripheral)
        self.mousePeripheralHandler = nil
        self.mouseVC.needShowMouseCursor = false
        
        if !PeripheralLists.shared.dismissed.contains(peripheral.identifier.uuidString) {
            self.peripheralsVC.didDisconnectPeripheral(InputPeripheral(peripheral: peripheral, type: .mouse))
        }
    }
    
    fileprivate func releaseKeyboardPeripheral() {
        guard let peripheral = self.keyboardPeripheralHandler?.mainPeripheral else { return }
        self.mainCentralManager.cancelPeripheralConnection(peripheral)
        self.keyboardPeripheralHandler = nil
        
        if !PeripheralLists.shared.dismissed.contains(peripheral.identifier.uuidString) {
            self.peripheralsVC.didDisconnectPeripheral(InputPeripheral(peripheral: peripheral, type: .keyboard))
        }
    }
}


extension InputInternal: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if self.mainCentralManager.state != .poweredOn {
            self.releaseMousePeripheral()
            self.releaseKeyboardPeripheral()
        }
        self.startScanIfNeeded()
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !PeripheralLists.shared.dismissed.contains(peripheral.identifier.uuidString) else { return }
        guard let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else { return }
        
        if serviceUUIDs.contains(self.mouseServiceUUID) {
            if self.mousePeripheralHandler == nil {
                self.connect(InputPeripheral(peripheral: peripheral, type: .mouse))
            }
        } else if serviceUUIDs.contains(self.keyboardServiceUUID) {
            if self.keyboardPeripheralHandler == nil {
                self.connect(InputPeripheral(peripheral: peripheral, type: .keyboard))
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let inputPeripheral: InputPeripheral
        let serviceUUIDs: [CBUUID]
        
        if let thePeripheral = self.mousePeripheralHandler?.mainPeripheral, thePeripheral === peripheral {
            inputPeripheral = InputPeripheral(peripheral: peripheral, type: .mouse)
            serviceUUIDs = [mouseServiceUUID]
        } else if let thePeripheral = self.keyboardPeripheralHandler?.mainPeripheral, thePeripheral === peripheral {
            inputPeripheral = InputPeripheral(peripheral: peripheral, type: .keyboard)
            serviceUUIDs = [keyboardServiceUUID]
        } else {
            return
        }
        if PeripheralLists.shared.approved.contains(peripheral.identifier.uuidString) {
            self.peripheralsVC.didConnectPeripheral(inputPeripheral)
            peripheral.discoverServices(serviceUUIDs)
        } else {
            self.peripheralsVC.didFindPeripheral(inputPeripheral)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheral.delegate = nil

        if let thePeripheral = self.mousePeripheralHandler?.mainPeripheral, thePeripheral === peripheral {
            self.releaseMousePeripheral()
            self.startScanIfNeeded()
        }
        if let thePeripheral = self.keyboardPeripheralHandler?.mainPeripheral, thePeripheral === peripheral {
            self.releaseKeyboardPeripheral()
            self.startScanIfNeeded()
        }
    }
}

extension InputInternal: PeripheralHandlerDelegate {
    
    func handlerDidFindMainCharacteristic(handler: AnyObject) {
        if handler === self.mousePeripheralHandler {
            let centerX = UIScreen.main.bounds.size.width / 2
            let centerY = UIScreen.main.bounds.size.height / 2
            self.mousePosition = CGPoint(x: centerX, y: centerY)
            self.mouseVC.needShowMouseCursor = true
        }
    }
}

extension InputInternal: PeripheralApprovalDelegate {
    
    func didAllowPeripheral(_ inputPeripheral: InputPeripheral) {
        let peripheral = inputPeripheral.peripheral
        PeripheralLists.shared.approved.append(peripheral.identifier.uuidString)
        
        switch inputPeripheral.type {
        case .mouse:
            peripheral.discoverServices([mouseServiceUUID])
        case .keyboard:
            peripheral.discoverServices([keyboardServiceUUID])
        }
    }
    
    func didDismissPeripheral(_ inputPeripheral: InputPeripheral) {
        PeripheralLists.shared.dismissed.append(inputPeripheral.peripheral.identifier.uuidString)
        self.mainCentralManager.cancelPeripheralConnection(inputPeripheral.peripheral)
    }
}

