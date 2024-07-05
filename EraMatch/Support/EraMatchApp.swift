//
//  EraMatchApp.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

@main
struct EraMatchApp: App {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true

    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                OnboardingView(isFirstLaunch: $isFirstLaunch)
            } else {
                ContentView()
            }
        }
    }
}


