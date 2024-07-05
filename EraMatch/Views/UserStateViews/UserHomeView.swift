//
//  HomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct UserHomeView: View {
    var body: some View {
        Text("User Home Screen")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .navigationBarBackButtonHidden(true)
    }
}
    
    struct UserHomeView_Previews: PreviewProvider {
        static var previews: some View {
            UserHomeView()
        }
    }

