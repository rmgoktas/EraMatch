//
//  EventDetailsView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 17.12.2024.
//

import SwiftUI
import WebKit
import PDFKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct UserEventDetailsView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    @State private var showWebView = false
    @State private var showInfoPack = false
    @AppStorage private var hasApplied: Bool
    @StateObject private var imageLoader = ImageLoader()
    @State private var showConfirmationDialog = false
    @StateObject private var submissionViewModel = UserSubmissionViewModel()
    @State private var showNGOSheet = false
    @State private var selectedNGO: CountryNGO?
    
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
        .onAppear {
            if event.id != nil {
                Task {
                    await submissionViewModel.fetchUserSubmissions()
                    checkIfUserApplied()
                }
            }
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
            if let ngo = selectedNGO {
                NGODetailsView(countryNGO: ngo)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Participating NGOs")
                .font(.headline)
            
            ForEach(event.countries, id: \.country) { countryNGO in
                Button(action: {
                    showNGODetails(countryNGO)
                }) {
                    HStack {
                        Text("\(CountryList.flag(for: countryNGO.country)) \(countryNGO.country)")
                        Spacer()
                        Text(countryNGO.ngoName)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
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
    
    private func showNGODetails(_ ngo: CountryNGO) {
        selectedNGO = ngo
        showNGOSheet = true
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

struct NGODetailsView: View {
    let countryNGO: CountryNGO
    @Environment(\.dismiss) var dismiss
    @State private var ngoData: NGO?
    @State private var isLoading = true
    @State private var showPDFViewer = false
    @State private var pdfFileData: Data?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if let ngo = ngoData {
                        // Logo
                        if let logoUrl = ngo.logoUrl, !logoUrl.isEmpty {
                            AsyncImage(url: URL(string: logoUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "building.2")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // NGO Info
                        Group {
                            Text(ngo.ngoName)
                                .font(.title)
                                .bold()
                            
                            Text("\(CountryList.flag(for: ngo.country)) \(ngo.country)")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            DetailRow(icon: "number", 
                                    title: "OID Number", 
                                    value: ngo.oidNumber)
                            
                            DetailRow(icon: "envelope", 
                                    title: "Email", 
                                    value: ngo.email)
                        }
                        .padding(.horizontal)
                        
                        // Social Media Links
                        VStack(spacing: 15) {
                            if let instagram = ngo.instagram, !instagram.isEmpty {
                                LinkButton(title: "Instagram", icon: "camera", url: "https://instagram.com/\(instagram)")
                            }
                            if let facebook = ngo.facebook, !facebook.isEmpty {
                                LinkButton(title: "Facebook", icon: "f.square", url: "https://facebook.com/\(facebook)")
                            }
                        }
                        .padding()
                        
                        // PIF Document
                        Group {
                            if let pifUrl = ngo.pifUrl, !pifUrl.isEmpty {
                                Button(action: {
                                    downloadAndShowPDF(from: pifUrl)
                                }) {
                                    HStack {
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Image(systemName: "doc.fill")
                                            Text("View PIF Document")
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                                .disabled(isLoading)
                                .padding(.horizontal)
                                .sheet(isPresented: $showPDFViewer) {
                                    if let pdfData = pdfFileData {
                                        PDFViewer(pdfData: pdfData)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            })
            .background(Color(.systemBackground))
        }
        .onAppear {
            loadNGOData()
        }
    }
    
    private func loadNGOData() {
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("ngos")
            .whereField("ngoName", isEqualTo: countryNGO.ngoName)
            .whereField("country", isEqualTo: countryNGO.country)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching NGO data: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    // PIF URL'yi direkt olarak kontrol edelim
                    if let pifUrl = data["pifUrl"] as? String, !pifUrl.isEmpty {
                        print("Found PIF URL in raw data: \(pifUrl)")
                    }
                    
                    do {
                        var ngo = try document.data(as: NGO.self)
                        ngo.id = document.documentID
                        print("Successfully decoded NGO: \(ngo.ngoName)")
                        print("PIF URL in NGO model: \(String(describing: ngo.pifUrl))")
                        
                        DispatchQueue.main.async {
                            self.ngoData = ngo
                            self.isLoading = false
                        }
                    } catch {
                        print("Error decoding NGO data: \(error.localizedDescription)")
                        print("Raw document data: \(data)")
                        isLoading = false
                    }
                } else {
                    print("No NGO found")
                    isLoading = false
                }
            }
    }
    
    private func downloadAndShowPDF(from urlString: String) {
        guard !urlString.isEmpty else {
            print("Empty URL string")
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        isLoading = true
        print("Starting PDF download from: \(urlString)")
        
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: urlString)
        
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Firebase Storage error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                guard PDFDocument(data: data) != nil else {
                    print("Invalid PDF data")
                    return
                }
                
                print("PDF downloaded successfully")
                self.pdfFileData = data
                self.showPDFViewer = true
            }
        }
    }
}

struct LinkButton: View {
    let title: String
    let icon: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.8))
            .cornerRadius(10)
        }
    }
}

struct PDFViewerView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                PDFKitView(url: url)
                
                if isLoading {
                    ProgressView("Loading PDF...")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Text("PIF Document").bold(),
                trailing: Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            )
        }
        .onAppear {
            // Give a short delay to show loading indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
    }
}
