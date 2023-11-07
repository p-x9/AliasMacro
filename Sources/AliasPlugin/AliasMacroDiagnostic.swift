//
//  AliasMacroDiagnostic.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

import SwiftSyntax
import SwiftDiagnostics

public enum AliasMacroDiagnostic {
    case unsupportedDeclaration
    case specifyTypeExplicitly
    case multipleVariableDeclarationIsNotSupported
    case enumCaseCannotInheritAccessModifiers
    case multipleEnumCaseDeclarationIsNotSupported
}

extension AliasMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case .unsupportedDeclaration:
            return "Unsupported Declaration"
        case .specifyTypeExplicitly:
            return "Specify a type explicitly"
        case .multipleVariableDeclarationIsNotSupported:
            return """
            Multiple variable declaration in one statement is not supported.
            """
        case .enumCaseCannotInheritAccessModifiers:
            return """
            Enum case has no access modifier and cannot inherit.
            """
        case .multipleEnumCaseDeclarationIsNotSupported:
            return """
            Multiple enum case declaration in one statement is not supported.
            """
        }
    }

    public var severity: DiagnosticSeverity {
        switch self {
        default:
            return .error
        }
    }

    public var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "AliasMacro.\(self)")
    }
}
