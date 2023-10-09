import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import AliasPlugin
@testable import AliasSupport

final class AliasTests: XCTestCase {
    let macros: [String: Macro.Type] = [
        "Alias": AliasMacro.self
    ]

    func testTypeAlias() throws {
        assertMacroExpansion(
            """
            @Alias("NewItem")
            struct Item {}
            """,
            expandedSource:
            """
            struct Item {}

            typealias NewItem = Item
            """,
            macros: macros
        )
    }

    func testVariableAlias() throws {
        assertMacroExpansion(
            """
            @Alias("newText")
            var text: String
            """,
            expandedSource:
            """
            var text: String

            var newText: String {
                set {
                    text = newValue
                }
                get {
                    text
                }
            }
            """,
            macros: macros
        )
    }

    func testFunctionAlias() throws {
        assertMacroExpansion(
            """
            @Alias("こんにちは")
            func hello(_ arg1: String, arg2: Int, label arg3: Double) {}
            """,
            expandedSource:
            """
            func hello(_ arg1: String, arg2: Int, label arg3: Double) {}

            func こんにちは(_ arg1: String, arg2: Int, label arg3: Double) {
                self.hello(arg1, arg2: arg2, label: arg3)
            }
            """,
            macros: macros
        )
    }

    func testFunctionAliasWithCustomArgs() throws {
        assertMacroExpansion(
            """
            @Alias("こんにちは:label1:_:")
            func hello(_ arg1: String, arg2: Int, label arg3: Double) {}
            """,
            expandedSource:
            """
            func hello(_ arg1: String, arg2: Int, label arg3: Double) {}

            func こんにちは(label1 arg1: String, _ arg2: Int, label arg3: Double) {
                self.hello(arg1, arg2: arg2, label: arg3)
            }
            """,
            macros: macros
        )
    }

    func testTypeAliasWithAccessor() throws {
        assertMacroExpansion(
            """
            @Alias("NewItem", access: .private)
            public struct Item {}
            """,
            expandedSource:
            """
            public struct Item {}

            private typealias NewItem = Item
            """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @Alias("NewItem", access: .inherit)
            public struct Item {}
            """,
            expandedSource:
            """
            public struct Item {}

            public typealias NewItem = Item
            """,
            macros: macros
        )
    }

    func testVariableAliasWithAccessor() throws {
        assertMacroExpansion(
            """
            @Alias("newText", access: .private)
            public var text: String
            """,
            expandedSource:
            """
            public var text: String

            private var newText: String {
                set {
                    text = newValue
                }
                get {
                    text
                }
            }
            """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @Alias("newText", access: .inherit)
            public var text: String
            """,
            expandedSource:
            """
            public var text: String

            public var newText: String {
                set {
                    text = newValue
                }
                get {
                    text
                }
            }
            """,
            macros: macros
        )
    }

    func testFunctionAliasWithAccessor() throws {
        assertMacroExpansion(
            """
            @Alias("こんにちは", access: .private)
            public func hello(_ arg1: String, arg2: Int, label arg3: Double) {}
            """,
            expandedSource:
            """
            public func hello(_ arg1: String, arg2: Int, label arg3: Double) {}

            private func こんにちは(_ arg1: String, arg2: Int, label arg3: Double) {
                self.hello(arg1, arg2: arg2, label: arg3)
            }
            """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @Alias("こんにちは", access: .inherit)
            private func hello(_ arg1: String, arg2: Int, label arg3: Double) {}
            """,
            expandedSource:
            """
            private func hello(_ arg1: String, arg2: Int, label arg3: Double) {}

            private func こんにちは(_ arg1: String, arg2: Int, label arg3: Double) {
                self.hello(arg1, arg2: arg2, label: arg3)
            }
            """,
            macros: macros
        )
    }

    func testMultipleTypeAlias() throws {
        assertMacroExpansion(
            """
            @Alias("NewItem")
            @Alias("NewItem2")
            struct Item {}
            """,
            expandedSource:
            """
            struct Item {}

            typealias NewItem = Item

            typealias NewItem2 = Item
            """,
            macros: macros
        )
    }

    // MARK: Diagnostics test
    func testDiagnosticsUnsupportedDeclaration() throws {
        assertMacroExpansion(
            """
            @Alias("NewTypeName")
            extension String {}
            """,
            expandedSource:
            """
            extension String {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: AliasMacroDiagnostic
                        .unsupportedDeclaration
                        .message,
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )

        assertMacroExpansion(
            """
            @Alias("NewProtocol")
            typealias SwiftString = String
            """,
            expandedSource:
            """
            typealias SwiftString = String
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: AliasMacroDiagnostic
                        .unsupportedDeclaration
                        .message,
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    func testDiagnosticsSpecifyType() throws {
        assertMacroExpansion(
             """
             @Alias("newText", access: .inherit)
             fileprivate var string = "text"
             """,
             expandedSource:
             """
             fileprivate var string = "text"
             """,
             diagnostics: [
                DiagnosticSpec(
                    message: AliasMacroDiagnostic
                        .specifyTypeExplicitly
                        .message,
                    line: 1,
                    column: 1
                )
             ],
             macros: macros
        )
    }
}
