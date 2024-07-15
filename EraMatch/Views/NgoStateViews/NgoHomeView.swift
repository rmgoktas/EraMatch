//
//  AdminHomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 4.07.2024.
//

import SwiftUI

struct NgoHomeView: View {
    var body: some View {
            Text("Ngo Home")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .navigationBarBackButtonHidden(true)
    }
}

struct NgoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NgoHomeView()
    }
}
