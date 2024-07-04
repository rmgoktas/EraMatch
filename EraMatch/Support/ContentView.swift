//
//  ContentView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            BackgroundView()  // Arka planı ayarlıyoruz

            VStack {
                Text("Welcome to EraMatch!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                // Diğer içerikler
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

