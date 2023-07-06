//
//  PatternBindingSyntax+Tests.swift
//
//
//  Created by p-x9 on 2023/06/19.
//  
//

import XCTest
@testable import Alias
@testable import AliasSupport
import SwiftSyntax
import SwiftSyntaxBuilder

final class PatternBindingSyntaxTests: XCTestCase {
    
    func testSetter() {
        let setter = AccessorDeclSyntax(accessorKind: .keyword(.set), body: .init(statements: CodeBlockItemListSyntax {}))

        let binding: PatternBindingSyntax = .init(
            pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
            accessor: .accessors(
                AccessorBlockSyntax(accessors: AccessorListSyntax {
                    setter
                })
            )
        )

        XCTAssertEqual(setter.description, binding.setter?.description)
    }

    func testGetter() {
        let getter = AccessorDeclSyntax(accessorKind: .keyword(.get), body: .init(statements: CodeBlockItemListSyntax {}))

        var binding: PatternBindingSyntax = .init(
            pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
            accessor: .accessors(
                AccessorBlockSyntax(accessors: AccessorListSyntax {
                    getter
                })
            )
        )

        XCTAssertEqual(getter.description, binding.getter?.description)

        /* getter only */
        guard let body = getter.body else {
            XCTFail("body must not be nil")
            return
        }
        binding = .init(
            pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
            accessor: .getter(body)
        )

        XCTAssertEqual(getter.description, binding.getter?.description)
    }

    func testSetSetter() {
        var binding: PatternBindingSyntax = .init(
            pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
            accessor: .accessors(
                AccessorBlockSyntax(accessors: AccessorListSyntax {
                    AccessorDeclSyntax(accessorKind: .keyword(.set), body: .init(statements: CodeBlockItemListSyntax {}))
                })
            )
        )
        let newSetter = AccessorDeclSyntax(
            accessorKind: .keyword(.set),
            body: .init(statements: CodeBlockItemListSyntax {
                .init(item: .expr("print(\"hello\")"))
            })
        )

        binding.setter = newSetter

        XCTAssertEqual(newSetter.description, binding.setter?.description)
    }

    func testSetGetter() {
        var binding: PatternBindingSyntax = .init(
            pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
            accessor: .accessors(
                AccessorBlockSyntax(accessors: AccessorListSyntax {
                    AccessorDeclSyntax(accessorKind: .keyword(.get), body: .init(statements: CodeBlockItemListSyntax {}))
                })
            )
        )

        let newGetter = AccessorDeclSyntax(
            accessorKind: .keyword(.get),
            body: .init(statements: CodeBlockItemListSyntax {
                .init(item: .decl("\"hello\""))
            })
        )

        binding.getter = newGetter
        XCTAssertEqual(newGetter.description, binding.getter?.description)

        /* getter only */
        binding = .init(
            pattern: IdentifierPatternSyntax(identifier: .identifier("value")),
            accessor: .getter(.init(statements: CodeBlockItemListSyntax {
                DeclSyntax("\"hello\"")
            }))
        )
        binding.getter = newGetter
        XCTAssertEqual(newGetter.description, binding.getter?.description)
    }
}
