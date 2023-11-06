//
//  Collection+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

import Foundation

extension Collection {
    package subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension MutableCollection {
    package subscript(safe index: Index) -> Element? {
        get {
            indices.contains(index) ? self[index] : nil
        }
        set {
            if let newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
    }
}
