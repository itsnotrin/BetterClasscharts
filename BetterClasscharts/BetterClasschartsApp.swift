//
//  BetterClasschartsApp.swift
//  BetterClasscharts
//
//  Created by Ryan Wiecz on 21/11/24.
//

import SwiftUI

@main
struct BetterClasschartsApp: App {
    @StateObject private var loginState = LoginState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if loginState.isLoggedIn {
                    MainTabView(studentName: "")  // You might need to handle this differently
                } else {
                    ContentView()
                }
            }
            .environment(\.loginState, loginState)
        }
    }
}
