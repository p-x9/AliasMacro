//
//  AccessControlSyntax.swift
//
//
//  Created by p-x9 on 2023/06/22.
//  
//

import SwiftSyntax

public enum AccessControlModifier: String, CaseIterable {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`

    public var keyword: Keyword {
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

    public var level: Int {
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
    public static func < (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level < rhs.level
    }

    public static func <= (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level <= rhs.level
    }

    public static func >= (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level >= rhs.level
    }

    public static func > (lhs: AccessControlModifier, rhs: AccessControlModifier) -> Bool {
        lhs.level > rhs.level
    }
}

public protocol AccessControlSyntax: DeclSyntaxProtocol {
    var modifiers: ModifierListSyntax? { get set }
}

extension AccessControlSyntax {
    var accessModifier: AccessControlModifier? {
        get {
            modifiers?.lazy
                .map(\.name.trimmed.text)
                .compactMap { AccessControlModifier(rawValue: $0) }
                .first
        }
        set {
            let previous = modifiers?.lazy
                .enumerated()
                .compactMap { i, modifier in
                    if let accessModifier = AccessControlModifier(rawValue: modifier.name.trimmed.text) {
                        return (i, accessModifier)
                    } else {
                        return nil
                    }
                }
                .first

            var new: ModifierListSyntax? = modifiers
            if let previous {
                new = new?.removing(childAt: previous.0)
            }

            if let newValue {
                if new == nil {
                    new = ModifierListSyntax {}
                }
                new = new?.inserting(.init(name: .keyword(newValue.keyword)), at: 0)
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
