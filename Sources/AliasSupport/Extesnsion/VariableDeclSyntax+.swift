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
    public var isLet: Bool {
        bindingKeyword.tokenKind == .keyword(.let)
    }

    public var isVar: Bool {
        bindingKeyword.tokenKind == .keyword(.var)
    }
}

extension VariableDeclSyntax {
    public var isStatic: Bool {
        guard let modifiers else { return false }
        return modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }

    public var isClass: Bool {
        guard let modifiers else { return false }
        return modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.class)
        }
    }

    public var isInstance: Bool {
        return !isClass && !isStatic
    }
}
