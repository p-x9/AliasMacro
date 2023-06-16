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
    var isInstanceMethod: Bool {
        guard let modifiers else { return true }
        return !modifiers.contains(where: { modifier in
            ["static", "class"].contains(modifier.name.trimmed.text)
        })
    }
}
