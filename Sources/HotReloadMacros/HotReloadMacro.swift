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

public struct HotReloadMacro: MemberMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Add the @ObserveInjection property
        let observeInjectionProperty: DeclSyntax = "@ObserveInjection var _redraw"
        return [observeInjectionProperty]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        // Find the body property
        guard let bodyVar = structDecl.memberBlock.members.first(where: {
            $0.decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "body"
        }) else {
            return []
        }

        // Get the existing body content
        guard let variableDecl = bodyVar.decl.as(VariableDeclSyntax.self),
              let binding = variableDecl.bindings.first,
              let accessorBlock = binding.accessorBlock,
              case .accessors(let accessorList) = accessorBlock.accessors,
              let getterAccessor = accessorList.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) }),
              let getterBody = getterAccessor.body else {
            return []
        }

        // Create new body with .enableInjection()
        let newBodyContent = getterBody.statements + [
            CodeBlockItemSyntax(item: .expr(ExprSyntax(stringLiteral: ".enableInjection()")))
        ]

        // Create the new getter with updated body
        let newGetter = AccessorDeclSyntax(
            accessorSpecifier: .keyword(.get),
            body: CodeBlockSyntax(statements: newBodyContent)
        )

        // Create the new body variable
        let newBodyVar = VariableDeclSyntax(
            modifiers: variableDecl.modifiers,
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: binding.pattern,
                    typeAnnotation: binding.typeAnnotation,
                    accessorBlock: AccessorBlockSyntax(accessors: .accessors([newGetter]))
                )
            }
        )

        return [DeclSyntax(newBodyVar)]
    }
}

@main
struct HotReloadPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HotReloadMacro.self,
    ]
}
