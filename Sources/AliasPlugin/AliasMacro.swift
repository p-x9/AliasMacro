//
//  AliasMacro.swift
//
//
//  Created by p-x9 on 2023/06/17.
//
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct AliasMacro {
    struct Arguments {
        let alias: String
    }

    static func arguments(of node: AttributeSyntax) -> Arguments? {
        guard case let .argumentList(arguments) = node.argument,
              let firstElement = arguments.first?.expression,
              let name = firstElement.as(StringLiteralExprSyntax.self) else {
            return nil
        }
        return .init(alias: name.segments.description)
    }
}

extension AliasMacro: PeerMacro {
    public static func expansion<Context: MacroExpansionContext, Declaration: DeclSyntaxProtocol>(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let arguments = arguments(of: node) else {
            return []
        }

        if let typeDecl = declaration.asTypeDeclSyntax() {
            return typeAlias(for: typeDecl,
                             with: arguments,
                             attribute: node)
        }

        if let varDecl = declaration.as(VariableDeclSyntax.self) {
            return variableAlias(for: varDecl,
                                 with: arguments,
                                 attribute: node)
        }

        if let functionDecl = declaration.as(FunctionDeclSyntax.self){
            return functionAlias(for: functionDecl,
                                 with: arguments,
                                 attribute: node)
        }

        return []
    }
}

extension AliasMacro {
    static func typeAlias(for typeDecl: TypeDeclSyntax,
                          with arguments: Arguments,
                          attribute: AttributeSyntax) -> [DeclSyntax] {
        return [
            "typealias \(raw: arguments.alias) = \(typeDecl.identifier.trimmed)"
        ]
    }

    static func variableAlias(for varDecl: VariableDeclSyntax,
                              with arguments: Arguments,
                              attribute: AttributeSyntax) -> [DeclSyntax] {
        guard let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let _ = binding.typeAnnotation?.type else {
            return []
        }

        let isLet = varDecl.bindingKeyword.trimmed.text == "let"
        let attributes = varDecl.attributes?.removed(attribute)

        return [
            .init(
                varDecl
                    .with(\.attributes, attributes)
                    .with(\.bindingKeyword, .identifier("var"))
                    .with(\.bindings, .init {
                        binding
                            .with(\.pattern, .init(IdentifierPatternSyntax(identifier: .identifier(arguments.alias))))
                            .with(\.initializer, nil)
                            .with(\.accessor,
                                   .init(
                                    AccessorBlockSyntax(
                                        accessors: AccessorListSyntax {
                                            if !isLet && binding.hasSetter {
                                                AccessorDeclSyntax(stringLiteral: "set { \(identifier) = newValue }")
                                            }
                                            AccessorDeclSyntax(stringLiteral: "get { \(identifier) }")
                                        }
                                    )
                                   )
                            )
                    })
            )
        ]
    }


    static func functionAlias(for functionDecl: FunctionDeclSyntax,
                              with arguments: Arguments,
                              attribute: AttributeSyntax) -> [DeclSyntax] {
        let isInstanceMethod = functionDecl.isInstanceMethod
        let baseIdentifier: TokenSyntax = isInstanceMethod ? .identifier("self") : .identifier("Self")
        let attributes = functionDecl.attributes?.removed(attribute)
        let newDecl = functionDecl
            .with(\.identifier, .identifier(arguments.alias))
            .with(\.attributes, attributes)
            .with(\.body, CodeBlockSyntax(statements: CodeBlockItemListSyntax {
                functionDecl.callWithSameArguments(
                    calledExpression: MemberAccessExprSyntax(
                        base: IdentifierExprSyntax(identifier: baseIdentifier),
                        dot: .periodToken(),
                        name: functionDecl.identifier.trimmed
                    )
                )
            }))
        return [
            .init(newDecl)
        ]
    }
}
