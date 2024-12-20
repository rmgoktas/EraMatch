//
//  EventDetailsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 17.12.2024.
//

import SwiftUI
import WebKit
import FirebaseAuth
import FirebaseFirestore

struct UserEventDetailsView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    @State private var showWebView = false
    @State private var showInfoPack = false
    @AppStorage private var hasApplied: Bool
    @StateObject private var imageLoader = ImageLoader()
    @State private var showConfirmationDialog = false
    @StateObject private var submissionViewModel = UserSubmissionViewModel()
    
    // NGO detayları için state değişkenleri
    @State private var showNGOSheet = false
    @State private var selectedNGO: String? // Seçilen NGO'nun adı
    
    init(event: Event) {
        self.event = event
        self._hasApplied = AppStorage(wrappedValue: false, "applied_\(event.id ?? "")")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Etkinlik Fotoğrafı
                if let photoURL = event.eventPhotoURL,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(15)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                    }
                }
                
                basicInfoSection
                
                dateSection
                
                participantSection
                
                countriesSection
                
                includedItemsSection
                
                if let infoPackURL = event.eventInfoPackURL {
                    infoPackButton(url: infoPackURL)
                }
                
                applicationButton
            }
            .padding()
        }
        .sheet(isPresented: $showWebView) {
            SafariWebView(url: URL(string: event.formLink)!)
        }
        .sheet(isPresented: $showInfoPack) {
            if let url = URL(string: event.eventInfoPackURL ?? "") {
                SafariWebView(url: url)
            }
        }
        .sheet(isPresented: $showNGOSheet) {
            // NGO bilgilerini gösteren view
        }
        .onAppear {
            if event.id != nil {
                Task {
                    await submissionViewModel.fetchUserSubmissions()
                    checkIfUserApplied()
                }
            } else {
                print("Event ID is nil, cannot load event details.")
            }
        }
        .onChange(of: showWebView) { isPresented in
            if !isPresented {
                showConfirmationDialog = true
            }
        }
        .alert("Did you submit your application?", isPresented: $showConfirmationDialog) {
            Button("No", role: .cancel) { }
            Button("Yes") {
                hasApplied = true
                submissionViewModel.saveSubmission(for: event)
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.title)
                .font(.title)
                .fontWeight(.bold)
            
            DetailRow(icon: "mappin.circle.fill", title: "Country", value: event.country)
            DetailRow(icon: "tag.fill", title: "Type", value: event.type)
            DetailRow(icon: "book.fill", title: "Topic", value: event.topic)
            if !event.otherTopic.isEmpty {
                DetailRow(icon: "text.bubble.fill", title: "Other Topic", value: event.otherTopic)
            }
            DetailRow(icon: "eurosign.circle.fill", title: "Reimbursement", value: "\(Int(event.reimbursementLimit))€")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Event Dates")
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start Date")
                        .foregroundColor(.secondary)
                    Text(formatDate(event.startDate))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("End Date")
                        .foregroundColor(.secondary)
                    Text(formatDate(event.endDate))
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var participantSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Looking For")
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(event.lookingFor.enumerated()), id: \.offset) { _, participant in
                    HStack {
                        Text("\(CountryList.flag(for: participant.nationality)) \(participant.nationality)")
                        Spacer()
                        Text("\(participant.count ?? 0) participants")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var countriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Participating Organizations")
            
            ForEach(event.countries, id: \.country) { country in
                HStack {
                    Text(CountryList.flag(for: country.country))
                    Text(country.country)
                    Spacer()
                    Button(action: {
                        selectedNGO = country.ngoName
                        showNGOSheet = false
                    }) {
                        Text(country.ngoName)
                            .foregroundColor(.black)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var includedItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Included Items")
            
            HStack(spacing: 20) {
                if event.includedItems.accommodation {
                    IncludedItemBadge(icon: "bed.double.fill", text: "")
                }
                if event.includedItems.transportation {
                    IncludedItemBadge(icon: "airplane", text: "")
                }
                if event.includedItems.food {
                    IncludedItemBadge(icon: "fork.knife", text: "")
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private func infoPackButton(url: String) -> some View {
        Button(action: {
            showInfoPack = true
        }) {
            HStack {
                Image(systemName: "doc.fill")
                Text("View Info Pack")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue)
            )
        }
    }
    
    private var applicationButton: some View {
        Button(action: {
            if !hasApplied {
                showWebView = true
            }
        }) {
            Text(hasApplied ? "Applied" : "Apply Now")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(hasApplied ? Color.gray : Color.green)
                )
        }
        .disabled(hasApplied)
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func checkIfUserApplied() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let submissions = submissionViewModel.submissions
        
        // Kullanıcının başvuru yapıp yapmadığının kontrolü
        hasApplied = submissions.contains { $0.userId == userId && $0.eventId == event.id }
    }
}

// WebView için UIViewRepresentable yapısı
struct SafariWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct IncludedItemBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.1))
        )
        .foregroundColor(.blue)
    }
}
