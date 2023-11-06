//
//  AttributeListSyntax+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

import Foundation
import SwiftSyntax

extension AttributeListSyntax {
    package func removed(_ attribute: AttributeSyntax) -> AttributeListSyntax {
        let attributes = self.filter {
            if case let .attribute(item) = $0 {
                return attribute.id == item.id
            }
            return true
        }
        return attributes
    }
}
