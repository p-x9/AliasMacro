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
        bindingSpecifier.tokenKind == .keyword(.let)
    }

    public var isVar: Bool {
        bindingSpecifier.tokenKind == .keyword(.var)
    }
}

extension VariableDeclSyntax {
    public var isStatic: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }

    public var isClass: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.class)
        }
    }

    public var isInstance: Bool {
        !isClass && !isStatic
    }
}
