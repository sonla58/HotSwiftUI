//
//  File.swift
//  
//
//  Created by Anh Son Le on 16/9/24.
//

import XCTest

import SwiftSyntaxMacrosTestSupport
import SwiftCompilerPlugin

import HotReloadMacros

class HotReloadMacrosTests: XCTestCase {
    func testHotReloadMacro() {
        let input = """
        @HotReload
        struct ContentView: View {
            @State private var text = "Hello, World!"

            @ViewBuilder
            var headerView: some View {
                Text("Header")
            }

            var body: some View {
                Text(text)
            }
        }
        """

        let expected = """
        struct ContentView: View {
            @State private var text = "Hello, World!"

            @ViewBuilder
            var headerView: some View {
                Text("Header")
            }

            var body: some View {
                Text(text)
            }

            @ObserveInjection var _redraw
        }
        """

        assertMacroExpansion(input, expandedSource: expected, macros: ["HotReload": HotReloadMacro.self])
    }
}
