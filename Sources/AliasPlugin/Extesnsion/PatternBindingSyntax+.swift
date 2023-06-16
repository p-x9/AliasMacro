//
//  PatternBindingSyntax+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

import Foundation
import SwiftSyntax

extension PatternBindingSyntax {
    var hasSetter: Bool {
        if initializer != nil {
            return true
        }
        if case let .accessors(list) = accessor,
           list.accessors.contains(where: { $0.accessorKind.trimmed.text == "set" }) {
            return true
        }
        return false
    }
}