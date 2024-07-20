//
//  HomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 3.07.2024.
//

import SwiftUI

struct UserHomeView: View {
    @StateObject private var viewModel = UserHomeViewModel()
    @State private var isMenuOpen = false
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Üst bar
                    HStack {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Home")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    
                    // Ana içerik
                    ScrollView {
                        VStack {
                            Text("Hi, \(viewModel.userName)!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 25)
                                .padding(.trailing, 100)
                            
                            VStack {
                                Text("What to Do ?")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 20)
                                
                                HStack {
                                    Image(systemName: "airplane")
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("Search Free Travels")
                                            .font(.headline)
                                        Text("Find and filter travel events")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                
                                // Event by Topics
                                VStack(alignment: .leading) {
                                    Text("Events by Topics")
                                        .font(.title3)
                                        .padding(.top, 20)
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                        ForEach(viewModel.topics, id: \.self) { topic in
                                            Text(topic)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(15)
                                                .shadow(radius: 5)
                                        }
                                    }
                                }
                                .padding(.top, 20)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                            .padding(.top, -20)
                        }
                        .padding()
                    }
                    .background(Color.blue.edgesIgnoringSafeArea(.all))
                }
                
                // Yan menü
                if isMenuOpen {
                    UserSliderView(isMenuOpen: $isMenuOpen)
                }
            }
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


