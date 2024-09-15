//
//  HotReloadMacro.swift
//
//
//  Created by Anh Son Le on 14/9/24.
//

import SwiftUI

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HotReloadMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.notApplicable("HotReload can only be applied to structs")
        }

        // Add .enableInjection() to the end of the `body`
        let bodyVar = structDecl.memberBlock.members.first { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { return false }
            return varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "body"
        }

        guard let bodyVar else {
            throw MacroError.notApplicable("Struct does not have a `body` property")
        }

        guard let bodyVarDecl = bodyVar.decl.as(VariableDeclSyntax.self) else {
            throw MacroError.notApplicable("`body` property is not a variable declaration")
        }

        guard let _ = bodyVarDecl.bindings.first?.accessorBlock?.accessors.as(CodeBlockItemListSyntax.self) else {
            throw MacroError.notApplicable("HotReload can only be applied to computed properties")
        }

        // Add the @ObserveInjection property
        let observeInjectionProperty: DeclSyntax = "@ObserveInjection var _redraw"

        return [observeInjectionProperty]
    }
}

enum MacroError: Error, CustomStringConvertible {
    case notApplicable(String)

    var description: String {
        switch self {
        case .notApplicable(let reason):
            return "This macro is not applicable: \(reason)"
        }
    }
}

@main
struct HotReloadMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HotReloadMacro.self,
    ]
}
