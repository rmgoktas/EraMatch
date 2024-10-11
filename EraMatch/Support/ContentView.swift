//
//  ContentView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject var ngoHomeViewModel = NgoHomeViewModel()
    @StateObject var userHomeViewModel = UserHomeViewModel()

    var body: some View {
        NavigationView {
            Group {
                if loginViewModel.navigateToTravellerHome {
                    travellerHomeView
                } else if loginViewModel.navigateToNGOHome {
                    ngoHomeView
                } else {
                    LoginView()
                        .environmentObject(loginViewModel)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }

    private var travellerHomeView: some View {
        UserHomeView() // homeViewModel geçmeden
            .environmentObject(loginViewModel) // LoginViewModel geç
            .navigationBarHidden(true)
    }

    private var ngoHomeView: some View {
        NgoHomeView(homeViewModel: ngoHomeViewModel)
            .environmentObject(loginViewModel)
            .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel()) 
    }
}

