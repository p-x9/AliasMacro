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
        }
    }

    public var severity: DiagnosticSeverity { .error }

    public var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "AliasMacro.\(self)")
    }
}
