//
//  PeripheralLists.swift
//  Input
//
//  Created by LuzanovRoman on 26.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit
import Foundation

class PeripheralLists {
    static let shared = PeripheralLists()
    
    fileprivate let separator = "|"
    fileprivate let approvedListFileName = "ApprovePeripherals.txt"
    fileprivate let dismissedListFileName = "DismissedPeripherals.txt"
    fileprivate let documentsURL : URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    fileprivate func save(list: [String], toFile file: String) {
        let string = list.joined(separator: self.separator)
        guard let data = string.data(using: .utf8) else { return }
        try? data.write(to: self.documentsURL.appendingPathComponent(file))
    }
    
    fileprivate func loadList(fromFile file: String) -> [String]? {
        guard let string = try? String(contentsOf: self.documentsURL.appendingPathComponent(file)) else { return nil }
        return string.components(separatedBy: self.separator)
    }
    
    init() {
        if let list = self.loadList(fromFile: self.approvedListFileName) { self.approved = list }
        if let list = self.loadList(fromFile: self.dismissedListFileName) { self.dismissed = list }
    }
    
    var approved = [String]() {
        didSet {
            self.save(list: self.approved, toFile: self.approvedListFileName)
        }
    }
    
    var dismissed = [String]() {
        didSet {
            self.save(list: self.dismissed, toFile: self.dismissedListFileName)
        }
    }
}
