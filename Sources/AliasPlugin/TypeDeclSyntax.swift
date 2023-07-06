//
//  TypeDeclSyntax.swift
//
//
//  Created by p-x9 on 2023/06/17.
//  
//

import Foundation
import SwiftSyntax
import AliasSupport

protocol TypeDeclSyntax: DeclSyntaxProtocol, AccessControlSyntax {
    var identifier: TokenSyntax { get set }
    var modifiers: ModifierListSyntax? { get set }
}

extension StructDeclSyntax: TypeDeclSyntax {}
extension ClassDeclSyntax: TypeDeclSyntax {}
extension EnumDeclSyntax: TypeDeclSyntax {}
extension ActorDeclSyntax: TypeDeclSyntax {}

extension SyntaxProtocol {
    func asTypeDeclSyntax() -> TypeDeclSyntax? {
        if let structDecl = self.as(StructDeclSyntax.self) {
            return structDecl
        }

        if let classDecl = self.as(ClassDeclSyntax.self) {
            return classDecl
        }

        if let enumDecl = self.as(EnumDeclSyntax.self) {
            return enumDecl
        }

        if let actorDecl = self.as(ActorDeclSyntax.self) {
            return actorDecl
        }

        return nil
    }
}
