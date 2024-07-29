//
//  ContentView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            if loginViewModel.navigateToTravellerHome {
                travellerHomeView
            } else if loginViewModel.navigateToNGOHome {
                ngoHomeView
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }

    private var travellerHomeView: some View {
        UserHomeView()
            .navigationBarHidden(true)
    }

    private var ngoHomeView: some View {
        NgoHomeView()
            .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel())
    }
}

