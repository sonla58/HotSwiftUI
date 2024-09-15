//
//  MacroDefination.swift
//
//
//  Created by Anh Son Le on 14/9/24.
//

import Foundation

@attached(member, names: named(_redraw))
public macro HotReload() = #externalMacro(module: "HotReloadMacros", type: "HotReloadMacro")
