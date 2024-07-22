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
                UserHomeView()
                    .environmentObject(loginViewModel) // Ekstra geçiş
            } else if loginViewModel.navigateToNGOHome {
                NgoHomeView()
                    .environmentObject(loginViewModel) // Ekstra geçiş
            } else {
                LoginView()
                    .environmentObject(loginViewModel) // Ekstra geçiş
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel())
    }
}








