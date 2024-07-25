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
    }

    private var travellerHomeView: some View {
        VStack {
            NavigationLink(destination: UserHomeView()) {
                EmptyView()
            }.hidden()
            Spacer()
            UserNavBarView()
        }
    }

    private var ngoHomeView: some View {
        VStack {
            NavigationLink(destination: NgoHomeView()) {
                EmptyView()
            }.hidden()
            Spacer()
            UserNavBarView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginViewModel())
    }
}
