//
//  AliasMacroPlugin.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

#if canImport(SwiftCompilerPlugin)
import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct AliasMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AliasMacro.self
    ]
}
#endif
