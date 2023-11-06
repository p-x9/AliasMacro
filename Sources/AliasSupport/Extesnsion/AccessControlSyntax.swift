//
//  AccessControlSyntax.swift
//
//
//  Created by p-x9 on 2023/06/22.
//  
//

import SwiftSyntax

package enum AccessControlModifier: String, CaseIterable {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`

    package var keyword: Keyword {
        switch self {
        case .private:
            return .private
        case .fileprivate:
            return .fileprivate
        case .internal:
            return .internal
        case .public:
            return .public
        case .open:
            return .open
        }
    }

    package var level: Int {
        switch self {
        case .private:
            return 0
        case .fileprivate:
            return 1
        case .internal:
            return 2
        case .public:
            return 3
        case .open:
            return 4
        }
    }
}

extension AccessControlModifier: Comparable {
    package static func < (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level < rhs.level
    }

    package static func <= (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level <= rhs.level
    }

    package static func >= (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level >= rhs.level
    }

    package static func > (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level > rhs.level
    }
}

package protocol AccessControlSyntax: DeclSyntaxProtocol {
    var modifiers: DeclModifierListSyntax { get set }
}

extension AccessControlSyntax {
    package var accessModifier: AccessControlModifier? {
        get {
            modifiers.lazy
                .map(\.name.trimmed.text)
                .compactMap { AccessControlModifier(rawValue: $0) }
                .first
        }
        set {
            let previous = zip(modifiers.indices, modifiers)
                .lazy
                .compactMap { i, modifier in
                    if let accessModifier = AccessControlModifier(rawValue: modifier.name.trimmed.text) {
                        return (i, accessModifier)
                    } else {
                        return nil
                    }
                }
                .first

            var new: DeclModifierListSyntax = modifiers
            if let previous {
                new.remove(at: previous.0)
            }

            if let newValue {
                new = [.init(name: .keyword(newValue.keyword))] + new
            }

            self.modifiers = new
        }
    }
}

extension StructDeclSyntax: AccessControlSyntax {}
extension ClassDeclSyntax: AccessControlSyntax {}
extension EnumDeclSyntax: AccessControlSyntax {}
extension ActorDeclSyntax: AccessControlSyntax {}

extension VariableDeclSyntax: AccessControlSyntax {}
extension FunctionDeclSyntax: AccessControlSyntax {}

extension ExtensionDeclSyntax: AccessControlSyntax {}
