//
//  oneFocusApp.swift
//  oneFocus
//
//  Created by Samuel Rojas on 9/11/24.
//

import SwiftUI

@main
struct oneFocusApp: App {
    var body: some Scene {
        MenuBarExtra{
            Flow()
        } label: {
            Text("oneFocus")
        }
        .menuBarExtraStyle(.window)
    }
}
