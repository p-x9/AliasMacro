//
//  VariableDeclSyntax+Tests.swift
//  
//
//  Created by p-x9 on 2023/06/21.
//  
//

import XCTest
@testable import Alias
@testable import AliasPlugin
import SwiftSyntax
import SwiftSyntaxBuilder

final class VariableDeclSyntaxTests: XCTestCase {
    func testIsLet() {
        let letVariable = VariableDeclSyntax(
            .let,
            name: .init(IdentifierPatternSyntax(identifier: .identifier("value")))
        )

        let varVariable = VariableDeclSyntax(
            .var,
            name: .init(IdentifierPatternSyntax(identifier: .identifier("value")))
        )

        XCTAssertTrue(letVariable.isLet)
        XCTAssertFalse(varVariable.isLet)
    }

    func testIsVar() {
        let letVariable = VariableDeclSyntax(
            .let,
            name: .init(IdentifierPatternSyntax(identifier: .identifier("value")))
        )

        let varVariable = VariableDeclSyntax(
            .var,
            name: .init(IdentifierPatternSyntax(identifier: .identifier("value")))
        )

        XCTAssertFalse(letVariable.isLet)
        XCTAssertTrue(varVariable.isLet)
    }
}
