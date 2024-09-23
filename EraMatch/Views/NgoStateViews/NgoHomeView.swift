//
//  NgoHomeView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 4.07.2024.
//

import SwiftUI

struct NgoHomeView: View {
    @State private var isMenuOpen = false
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var selectedTab: String = "My Events"

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
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

                    Text("My Events")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                .padding(.horizontal)
                .background(Color.black.opacity(0))

                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 30) {
                            // Seçilen sekmeye göre görünümü göster
                            if selectedTab == "My Events" {
                                EventCardView(
                                    title: "Hidden Geniuses",
                                    subtitle: "Training Course on “Digital Skills”",
                                    location: "Madrid, SPAIN",
                                    dateRange: "14 Apr 2024 - 21 Apr 2024",
                                    onDetailTap: {
                                        // Navigate to event details
                                    }
                                )

                                EventCardView(
                                    title: "Youth Exchange",
                                    subtitle: "Exploring Cultural Diversity",
                                    location: "Berlin, GERMANY",
                                    dateRange: "10 Jun 2024 - 20 Jun 2024",
                                    onDetailTap: {
                                        // Navigate to event details
                                    }
                                )

                                EventCardView(
                                    title: "Environmental Summit",
                                    subtitle: "Actions for a Sustainable Future",
                                    location: "Oslo, NORWAY",
                                    dateRange: "5 Jul 2024 - 12 Jul 2024",
                                    onDetailTap: {
                                        // Navigate to event details
                                    }
                                )
                            } else if selectedTab == "Submissions" {
                                // Submissions görünümü
                                Text("Submissions Page")
                                    .font(.title)
                                    .padding()
                            } else if selectedTab == "Profile" {
                                // Profile görünümü
                                NgoProfileView(selectedTab: $selectedTab) // NgoProfileView'yi burada çağırıyoruz
                                    .environmentObject(NgoSignUpViewModel())
                            }

                            Spacer(minLength: 90) // Floating Action Button için altta yer bırakmak amacıyla spacer ekledim
                        }
                        .padding(.top, geometry.safeAreaInsets.top + 60)
                    }
                }
            }

            // NGO Nav Bar
            VStack {
                Spacer()
                NgoNavBarView(selectedTab: $selectedTab) // Seçilen sekmeyi güncellemek için binding kullan
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            if isMenuOpen {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }

                sliderMenu
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut(duration: 0.3))
            }

            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Add new event action
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.purple)
                            .cornerRadius(40)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    // Slider menü bileşeni
    var sliderMenu: some View {
        ZStack(alignment: .leading) {
            BackgroundView()

            VStack(alignment: .leading) {
                HStack {
                    Text("EraMatch")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding()

                // Menü içeriği
                ForEach(["Home", "My Events", "Submissions", "Profile"], id: \.self) { item in
                    Button(action: {
                        withAnimation {
                            selectedTab = item
                            isMenuOpen = false
                        }
                    }) {
                        Text(item)
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding()
                            .background(selectedTab == item ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
        }
        .frame(width: 250)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

struct NgoHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NgoHomeView()
            .environmentObject(LoginViewModel())
    }
}











