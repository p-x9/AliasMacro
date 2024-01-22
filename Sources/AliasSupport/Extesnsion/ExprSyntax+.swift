//
//  ExprSyntax+.swift
//
//
//  Created by p-x9 on 2024/01/18.
//  
//

import SwiftSyntax

extension ExprSyntax {
    package var detectedTypeByLiteral: TypeSyntax? {
        switch self.kind {
        case .stringLiteralExpr: return "Swift.String"
        case .integerLiteralExpr: return "Swift.Int"
        case .floatLiteralExpr: return "Swift.Double"
        case .booleanLiteralExpr: return "Swift.Bool"

        case .arrayExpr:
            guard let arrayExpr = self.as(ArrayExprSyntax.self) else {
                return nil
            }
            return arrayExpr.detectedTypeByLiteral

        case .dictionaryExpr:
            guard let dictionaryExpr = self.as(DictionaryExprSyntax.self) else {
                return nil
            }
            return dictionaryExpr.detectedTypeByLiteral

        case .tupleExpr:
            guard let tupleExpr = self.as(TupleExprSyntax.self) else {
                return nil
            }
            return tupleExpr.detectedTypeByLiteral

        default:
            return nil
        }
    }
}

extension Sequence where Element == ExprSyntax {
    var detectedElementTypeByLiteral: TypeSyntaxProtocol? {
        let expressions = Array(self)
        let isOptional = expressions.map(\.kind).contains(.nilLiteralExpr)

        let numberOfLiteralTypes = expressions
            .filter {
                $0.detectedTypeByLiteral != nil || $0.kind == .nilLiteralExpr
            }.count

        guard expressions.count == numberOfLiteralTypes else {
            return nil
        }

        let elementTypes = expressions
                .compactMap(\.detectedTypeByLiteral)
        guard !elementTypes.isEmpty else { return nil }

        let uniqueElementTypeStrings = Set(elementTypes.map { "\($0)" })
        let isAllSameType = uniqueElementTypeStrings.count == 1

        var detectedType: TypeSyntax?
        if isAllSameType,
           let type = elementTypes.first {
            detectedType = type
        } else if uniqueElementTypeStrings == ["Swift.Int", "Swift.Double"] {
            detectedType = "Swift.Double"
        }

        guard let detectedType else { return nil }
        if isOptional {
            return OptionalTypeSyntax(wrappedType: detectedType)
        } else {
            return detectedType
        }
    }
}

extension ArrayExprSyntax {
    var detectedElementTypeByLiteral: TypeSyntaxProtocol? {
        let expressions = elements.map(\.expression)
        return expressions.detectedElementTypeByLiteral
    }

    var detectedTypeByLiteral: TypeSyntax? {
        guard let elementType = detectedElementTypeByLiteral else {
            return nil
        }
        return .init(
            ArrayTypeSyntax(element: elementType)
        )
    }
}

extension DictionaryExprSyntax {
    var detectedKeyTypeByLiteral: TypeSyntaxProtocol? {
        guard case let .elements(elements) = self.content else {
            return nil
        }
        let expressions = elements.map(\.key)
        return expressions.detectedElementTypeByLiteral
    }

    var detectedValueTypeByLiteral: TypeSyntaxProtocol? {
        guard case let .elements(elements) = self.content else {
            return nil
        }
        let expressions = elements.map(\.value)
        return expressions.detectedElementTypeByLiteral
    }

    var detectedTypeByLiteral: TypeSyntax? {
        guard let keyType = detectedKeyTypeByLiteral,
              let valueType = detectedValueTypeByLiteral else {
            return nil
        }
        return .init(
            DictionaryTypeSyntax(key: keyType, value: valueType)
        )
    }
}

extension TupleExprSyntax {
    var detectedTypeByLiteral: TypeSyntax? {
        let expressions = elements.map(\.expression)
        let types = expressions.compactMap(\.detectedTypeByLiteral)
        guard !expressions.isEmpty,
              expressions.count == types.count else {
            return nil
        }
        var tupleElements = types.map {
            TupleTypeElementSyntax(
                type: $0,
                trailingComma: .commaToken()
            )
        }
        tupleElements[tupleElements.count - 1].trailingComma = nil
        return .init(
            TupleTypeSyntax(
                elements: TupleTypeElementListSyntax(
                    tupleElements
                )
            )
        )
    }
}
