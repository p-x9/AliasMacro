//
//  VariableDeclSyntax+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//
//

import Foundation
import SwiftSyntax

extension VariableDeclSyntax {
    var isLet: Bool {
        bindingKeyword.tokenKind == .keyword(.let)
    }

    var isVar: Bool {
        bindingKeyword.tokenKind == .keyword(.var)
    }
}

extension VariableDeclSyntax {
    var isStatic: Bool {
        guard let modifiers else { return false }
        return modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }

    var isClass: Bool {
        guard let modifiers else { return false }
        return modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.class)
        }
    }

    var isInstance: Bool {
        return !isClass && !isStatic
    }
}
