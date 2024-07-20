//
//  UserSliderMenu.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 20.07.2024.
//

import SwiftUI

struct UserSliderView: View {
    @Binding var isMenuOpen: Bool
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("EraMatch")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .padding()
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text("What is EraMatch?")
                Text("How Do I Participate?")
                Text("Do I Have to Pay?")
                Text("How Can I Get Selected?")
            }
            .font(.title2)
            .padding(.top, 20)
            
            Spacer()
            
            Button(action: {
                loginViewModel.logoutUser()
                withAnimation {
                    isMenuOpen.toggle()
                }
            }) {
                HStack {
                    Text("Sign Out")
                    Image(systemName: "arrow.right.square")
                }
                .font(.title2)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.bottom, 50)
        }
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .background(Color.white)
        .shadow(radius: 5)
        .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.width)
        .animation(.default)
    }
}


