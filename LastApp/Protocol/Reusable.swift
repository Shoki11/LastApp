//
//  Reusable.swift
//  LastApp
//
//  Created by cmStudent on 2021/11/10.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension NSObject: Reusable {}
