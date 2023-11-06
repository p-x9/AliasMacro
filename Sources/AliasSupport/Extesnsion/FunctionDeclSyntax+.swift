//
//  FunctionDeclSyntax+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
    package func callWithSameArguments<C>(calledExpression: C) -> FunctionCallExprSyntax where C: ExprSyntaxProtocol  {
        let params = signature.parameterClause.parameters

        let arguments: [TokenSyntax] = params.map {
            $0.secondName == nil ? $0.firstName : $0.secondName
        }.compactMap { $0 }

        return call(calledExpression: calledExpression, arguments: arguments)
    }

    public func call<C>(calledExpression: C, arguments: [TokenSyntax]) -> FunctionCallExprSyntax where C: ExprSyntaxProtocol  {
        let params = signature.parameterClause.parameters

        precondition(arguments.count >= params.count)

        var argumentList: [LabeledExprSyntax] = params.enumerated().map { i, param in
            var label: TokenSyntax? = param.firstName.trimmed
            if label?.tokenKind == .wildcard { label = nil }

            let expression = arguments[i]

            return LabeledExprSyntax(
                label: label,
                colon: label == nil ? nil : .colonToken(),
                expression: DeclReferenceExprSyntax(baseName: expression),
                trailingComma: .commaToken()
            )
        }

        argumentList[safe: argumentList.endIndex - 1]?.trailingComma = nil

        return FunctionCallExprSyntax(
            calledExpression: calledExpression,
            leftParen: .leftParenToken(),
            arguments: .init(argumentList),
            rightParen: .rightParenToken()
        )
    }
}

extension FunctionDeclSyntax {
    package var isInstance: Bool {
        return !modifiers.contains(where: { modifier in
            modifier.name.tokenKind == .keyword(.class) || modifier.name.tokenKind == .keyword(.static)
        })
    }
}
