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
    func callWithSameArguments<C>(calledExpression: C) -> FunctionCallExprSyntax where C: ExprSyntaxProtocol  {
        let params = signature.input.parameterList

        let arguments: [TokenSyntax] = params.map {
            $0.secondName == nil ? $0.firstName : $0.secondName
        }.compactMap { $0 }

        return call(calledExpression: calledExpression, arguments: arguments)
    }

    func call<C>(calledExpression: C, arguments: [TokenSyntax]) -> FunctionCallExprSyntax where C: ExprSyntaxProtocol  {
        let params = signature.input.parameterList

        precondition(arguments.count >= params.count)

        var argumentList: [TupleExprElementSyntax] = params.enumerated().map { i, param in
            var label: TokenSyntax? = param.firstName.trimmed
            if label?.tokenKind == .wildcard { label = nil }

            let expression = arguments[i]

            return TupleExprElementSyntax(
                label: label,
                colon: label == nil ? nil : .colonToken(),
                expression: IdentifierExprSyntax(identifier: expression),
                trailingComma: .commaToken()
            )
        }

        argumentList[safe: argumentList.endIndex - 1]?.trailingComma = nil

        return FunctionCallExprSyntax(
            calledExpression: calledExpression,
            leftParen: .leftParenToken(),
            argumentList: .init(argumentList),
            rightParen: .rightParenToken()
        )
    }
}

extension FunctionDeclSyntax {
    var isInstance: Bool {
        guard let modifiers else { return true }
        return !modifiers.contains(where: { modifier in
            modifier.name.tokenKind == .keyword(.class) || modifier.name.tokenKind == .keyword(.static)
        })
    }
}
