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
    package var isLet: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }

    package var isVar: Bool {
        bindingSpecifier.tokenKind == .keyword(.var)
    }
}

extension VariableDeclSyntax {
    package var isStatic: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }

    package var isClass: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.class)
        }
    }

    package var isInstance: Bool {
        !isClass && !isStatic
    }
}
