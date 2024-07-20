//
//  HomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct UserHomeView: View {
    @StateObject private var viewModel = UserHomeViewModel()

    var body: some View {
        VStack {
            Text("Welcome, \(viewModel.userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
            
            // Diğer UI elemanları burada
        }
        .onAppear {
            viewModel.fetchUsername()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct UserHomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomeView()
    }
}


