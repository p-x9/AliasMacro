//
//  PatternBindingSyntax+.swift
//
//
//  Created by p-x9 on 2023/06/17.
//
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension PatternBindingSyntax {
    public var setter: AccessorDeclSyntax? {
        get {
            if case let .accessors(list) = accessor {
                return list.accessors.first(where: {
                    $0.accessorKind.tokenKind == .keyword(.set)
                })
            }
            return nil
        }

        set {
            var newAccessor: Accessor?

            switch accessor {
            case let .getter(body):
                guard let newValue else { return }
                newAccessor = .accessors(.init(accessors: AccessorListSyntax {
                    AccessorDeclSyntax(accessorKind: .keyword(.get), body: body)
                    newValue
                }))
            case let .accessors(block):
                var accessors = block.accessors
                for (i, accessor) in block.accessors.enumerated() {
                    guard accessor.accessorKind.tokenKind == .keyword(.set) else {
                        continue
                    }
                    if let newValue {
                        accessors = accessors.replacing(childAt: i, with: newValue)
                    } else {
                        accessors = accessors.removing(childAt: i)
                    }
                    break
                }
                let newBlock = block.with(\.accessors, accessors)
                newAccessor = .accessors(newBlock)
            case .none:
                // NOTE: Be careful that setter cannot be implemented without a getter.　　　
                guard let newValue else { return }
                newAccessor = .accessors(.init(accessors: AccessorListSyntax {
                    newValue
                }))
            }

            accessor = newAccessor
        }
    }

    public var getter: AccessorDeclSyntax? {
        get {
            switch accessor {
            case let .accessors(list):
                return list.accessors.first(where: {
                    $0.accessorKind.tokenKind == .keyword(.get)
                })
            case let .getter(body):
                return AccessorDeclSyntax(accessorKind: .keyword(.get), body: body)
            case .none:
                return nil
            }
        }

        set {
            switch accessor {
            case .getter, .none:
                if let newValue {
                    if let body = newValue.body {
                        accessor = .getter(body)
                    } else {
                        let accessors = AccessorListSyntax {
                            newValue
                        }
                        accessor = .accessors(.init(accessors: accessors))
                    }
                } else {
                    accessor = .none
                }

            case let .accessors(block):
                var accessors = block.accessors
                for (i, accessor) in block.accessors.enumerated() {
                    guard accessor.accessorKind.tokenKind == .keyword(.get) else {
                        continue
                    }
                    if let newValue {
                        accessors = accessors.replacing(childAt: i, with: newValue)
                    } else {
                        accessors = accessors.removing(childAt: i)
                    }
                    break
                }
                let newBlock = block.with(\.accessors, accessors)
                accessor = .accessors(newBlock)
            }
        }
    }

    public var isGetOnly: Bool {
        if initializer != nil {
            return false
        }
        if case let .accessors(list) = accessor,
           list.accessors.contains(where: { $0.accessorKind.tokenKind == .keyword(.set) }) {
            return false
        }
        if accessor == nil && initializer == nil {
            return false
        }
        return true
    }
}
