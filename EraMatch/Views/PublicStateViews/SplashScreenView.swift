//
//  SplashScreenView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 18.12.2024.
//


import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            if isActive {
                LoginView()
            } else {
                Image("logo") // assets içindeki logo resmi
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150) // İsteğe bağlı boyut ayarı
                    .opacity(isActive ? 0 : 1)
                    .scaleEffect(isActive ? 1.5 : 1)
                    .animation(.easeInOut(duration: 1.0), value: isActive)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}