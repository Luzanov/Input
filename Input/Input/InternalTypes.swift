//
//  InternalTypes.swift
//  Input
//
//  Created by LuzanovRoman on 27.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralState {
    case new
    case connected
    case disconnected
}

enum InputPeripheralType {
    case mouse
    case keyboard
}

struct InputPeripheral {
    let peripheral: CBPeripheral
    let type: InputPeripheralType
}

class StatedPeripheral {
    let inputPeripheral: InputPeripheral
    var state: PeripheralState
    var disappearingWorkItem: DispatchWorkItem?
    
    init(inputPeripheral: InputPeripheral, state: PeripheralState) {
        self.inputPeripheral = inputPeripheral
        self.state = state
    }
}

extension InputPeripheral: Equatable {
    static func == (lhs: InputPeripheral, rhs: InputPeripheral) -> Bool {
        return lhs.peripheral === rhs.peripheral
    }
}

extension StatedPeripheral: Equatable {
    static func == (lhs: StatedPeripheral, rhs: StatedPeripheral) -> Bool {
        return lhs.inputPeripheral == rhs.inputPeripheral
    }
}
