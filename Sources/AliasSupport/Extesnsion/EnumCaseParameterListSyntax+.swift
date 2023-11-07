//
//  EnumCaseParameterListSyntax+.swift
//
//
//  Created by p-x9 on 2023/11/07.
//  
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension EnumCaseParameterListSyntax {
    package var functionParameterListSyntax: FunctionParameterListSyntax {
        let parameters: [FunctionParameterSyntax] = self.enumerated()
            .map {
                if let firstName = $1.firstName, $1.secondName == nil {
                    return "\(firstName.trimmed): \($1.type)"
                } else if let firstName = $1.firstName, let secondName = $1.secondName {
                    return "\(firstName.trimmed) \(secondName.trimmed): \($1.type)"
                } else {
                    return "_ arg\(raw: $0): \($1.type.trimmed)"
                }
            }
        return .init(parameters)
    }

    package var labeledExprListSyntax: LabeledExprListSyntax {
        let arguments: [LabeledExprSyntax] = self.enumerated()
            .map {
                if let firstName = $1.firstName, $1.secondName == nil {
                    return .init(label: "\(firstName.trimmed)",
                                 expression: ExprSyntax("\(firstName.trimmed)"))
                } else if let firstName = $1.firstName, let secondName = $1.secondName {
                    return .init(label: "\(firstName.trimmed)",
                                 expression: ExprSyntax("\(secondName.trimmed)"))
                } else {
                    return .init(expression: ExprSyntax("arg\(raw: $0)"))
                }
            }
        return .init(arguments)
    }
}
