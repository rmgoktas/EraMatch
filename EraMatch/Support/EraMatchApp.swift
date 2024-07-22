//
//  EraMatchApp.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct EraMatchApp: App {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isFirstLaunch {
                    OnboardingView(isFirstLaunch: $isFirstLaunch)
                } else {
                    ContentView()
                        .environmentObject(loginViewModel)
                }
            }
        }
    }
}







