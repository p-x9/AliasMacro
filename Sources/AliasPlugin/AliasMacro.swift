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
import AliasSupport

extension AccessControl {
    var modifier: AccessControlModifier? {
        .init(rawValue: rawValue)
    }
}

struct AliasMacro {
    struct Arguments {
        let alias: String
        let functionArgumentLabels: [String]
        let accessControl: AccessControl?

        init(alias: String, accessControl: AccessControl?) {
            let components = alias.components(separatedBy: ":")
            self.alias = components.first ?? alias
            if components.count > 1 {
                self.functionArgumentLabels = Array(components[1...])
            } else {
                self.functionArgumentLabels = []
            }
            self.accessControl = accessControl
        }
    }

    static func arguments(of node: AttributeSyntax) -> Arguments? {
        guard case let .argumentList(arguments) = node.arguments,
              let firstElement = arguments.first?.expression,
              let name = firstElement.as(StringLiteralExprSyntax.self) else {
            return nil
        }

        var access: AccessControl?
        if let accessExpr = arguments.lazy.compactMap({ $0.expression.as(MemberAccessExprSyntax.self) }).first {
            let rawValue = accessExpr.declName.baseName.trimmed.text.replacingOccurrences(of: "`", with: "")
            access = AccessControl(rawValue: rawValue)
        }

        return .init(alias: name.segments.description, accessControl: access)
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
                                 attribute: node,
                                 in: context)
        }

        if let functionDecl = declaration.as(FunctionDeclSyntax.self){
            return functionAlias(for: functionDecl,
                                 with: arguments,
                                 attribute: node)
        }

        if let enumCase = declaration.as(EnumCaseDeclSyntax.self) {
            return enumCaseAlias(for: enumCase,
                                 with: arguments,
                                 attribute: node,
                                 in: context)
        }

        if let associatedTypeDecl = declaration.as(AssociatedTypeDeclSyntax.self) {
            return associatedTypeDeclAlias(for: associatedTypeDecl,
                                           with: arguments,
                                           attribute: node)
        }

        context.diagnose(AliasMacroDiagnostic.unsupportedDeclaration.diagnose(at: node))
        return []
    }
}

extension AliasMacro {
    static func typeAlias(for typeDecl: TypeDeclSyntax,
                          with arguments: Arguments,
                          attribute: AttributeSyntax) -> [DeclSyntax] {

        let accessModifier = arguments.accessControl?.modifier ?? typeDecl.accessModifier

        let alias: DeclSyntax = "typealias \(raw: arguments.alias) = \(typeDecl.identifier.trimmed)"

        if let accessModifier {
            return [
                "\(raw: accessModifier) \(alias)"
            ]
        }

        return [alias]
    }

    static func variableAlias(for varDecl: VariableDeclSyntax,
                              with arguments: Arguments,
                              attribute: AttributeSyntax,
                              in context: MacroExpansionContext) -> [DeclSyntax] {

        if varDecl.bindings.count > 1 {
            context.diagnose(AliasMacroDiagnostic.multipleVariableDeclarationIsNotSupported.diagnose(at: varDecl))
            return []
        }

        guard let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.typeAnnotation != nil else {
            context.diagnose(AliasMacroDiagnostic.specifyTypeExplicitly.diagnose(at: varDecl))
            return []
        }

        let attributes = varDecl.attributes.removed(attribute)
        let accessModifier = arguments.accessControl?.modifier ?? varDecl.accessModifier

        return [
            .init(
                varDecl
                    .with(\.attributes, attributes)
                    .with(\.accessModifier, accessModifier)
                    .with(\.bindingSpecifier, .keyword(.var))
                    .with(\.bindings, .init {
                        binding
                            .with(\.pattern, .init(IdentifierPatternSyntax(identifier: .identifier(arguments.alias))))
                            .with(\.initializer, nil)
                            .with(\.accessorBlock, .init(accessors:
                                    .accessors(
                                        AccessorDeclListSyntax {
                                            if varDecl.isVar && !binding.isGetOnly {
                                                AccessorDeclSyntax(stringLiteral: "set { \(identifier) = newValue }")
                                            }
                                            AccessorDeclSyntax(stringLiteral: "get { \(identifier) }")
                                        }
                                    )
                            ))
                    })
            )
        ]
    }


    static func functionAlias(for functionDecl: FunctionDeclSyntax,
                              with arguments: Arguments,
                              attribute: AttributeSyntax) -> [DeclSyntax] {
        let isInstance = functionDecl.isInstance
        let baseIdentifier: TokenSyntax = isInstance ? .keyword(.`self`) : .keyword(.Self)

        let attributes = functionDecl.attributes.removed(attribute)
        let accessModifier = arguments.accessControl?.modifier ?? functionDecl.accessModifier

        let parameters: [FunctionParameterSyntax] = functionDecl.signature.parameterClause.parameters.enumerated()
            .map { i, param in
                if let newLabel = arguments.functionArgumentLabels[safe: i],
                   newLabel != "" {
                    if param.secondName != nil {
                        return param.with(\.firstName, .identifier(newLabel))
                    } else {
                        return param
                            .with(\.firstName, .identifier(newLabel))
                            .with(\.secondName, param.firstName)

                    }
                }
                return param
            }

        let newDecl = functionDecl
            .with(\.name, .identifier(arguments.alias))
            .with(\.attributes, attributes)
            .with(\.accessModifier, accessModifier)
            .with(\.signature.parameterClause.parameters, .init(parameters))
            .with(\.body, CodeBlockSyntax(statements: CodeBlockItemListSyntax {
                functionDecl.callWithSameArguments(
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(baseName: baseIdentifier),
                        name: functionDecl.name.trimmed
                    )
                )
            }))
        return [
            .init(newDecl)
        ]
    }

    static func enumCaseAlias(for caseDecl: EnumCaseDeclSyntax,
                              with arguments: Arguments,
                              attribute: AttributeSyntax,
                              in context: MacroExpansionContext) -> [DeclSyntax] {
        if arguments.accessControl == .inherit {
            context.diagnose(
                AliasMacroDiagnostic.enumCaseCannotInheritAccessModifiers.diagnose(at: attribute)
            )
            return []
        }
        if caseDecl.elements.count > 1 {
            context.diagnose(
                AliasMacroDiagnostic.multipleEnumCaseDeclarationIsNotSupported.diagnose(at: caseDecl.elements)
            )
            return []
        }
        guard let element = caseDecl.elements.first else {
            return []
        }

        if let parameterClause = element.parameterClause {
            let parameters = parameterClause.parameters
            let functionParameters = parameters.functionParameterListSyntax.map {
                "\($0)"
            }.joined(separator: ", ")
            let functionArguments = parameters.labeledExprListSyntax.map {
                "\($0)"
            }.joined(separator: ", ")

            let aliasDecl: DeclSyntax = """
            static func \(raw: arguments.alias)(\(raw: functionParameters)) -> Self {
                .\(element.name)(\(raw: functionArguments))
            }
            """
            if let accessModifier = arguments.accessControl?.modifier {
                return [
                    "\(raw: accessModifier) \(aliasDecl)"
                ]
            }
            return [
                aliasDecl
            ]
        } else {
            let aliasDecl: DeclSyntax = "static let \(raw: arguments.alias): Self = .\(element.name)"

            if let accessModifier = arguments.accessControl?.modifier {
                return [
                    "\(raw: accessModifier) \(aliasDecl)"
                ]
            }
            return [
                aliasDecl
            ]
        }
    }

    static func associatedTypeDeclAlias(for associatedTypeDecl: AssociatedTypeDeclSyntax,
                                        with arguments: Arguments,
                                        attribute: AttributeSyntax) -> [DeclSyntax] {

        let accessModifier = arguments.accessControl?.modifier ?? associatedTypeDecl.accessModifier

        let decl: DeclSyntax = """
        typealias \(raw: arguments.alias) = \(associatedTypeDecl.name)
        """

        if let accessModifier {
            return [
                "\(raw: accessModifier) \(decl)"
            ]
        }else {
            return [
                decl
            ]
        }
    }
}
