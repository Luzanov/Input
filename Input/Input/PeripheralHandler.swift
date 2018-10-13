//
//  PeripheralHandler.swift
//  Input
//
//  Created by LuzanovRoman on 23.01.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PeripheralHandlerDelegate: class {
    func handlerDidFindMainCharacteristic(handler: AnyObject)
}

class PeripheralHandler: NSObject, CBPeripheralDelegate {
    weak var delegate: PeripheralHandlerDelegate?
    var mainCharacteristic: CBCharacteristic?
    var mainPeripheral: CBPeripheral
    
    init(mainPeripheral: CBPeripheral) {
        self.mainPeripheral = mainPeripheral
        super.init()
        self.mainPeripheral.delegate = self
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let _ = self.mainCharacteristic { return }
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                self.mainCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                self.delegate?.handlerDidFindMainCharacteristic(handler: self)
                break
            }
        }
    }
}
