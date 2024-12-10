import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct CreateEventView: View {
    @StateObject private var viewModel = CreateEventViewModel()
    @State private var showingInfoPackPicker = false
    @State private var showingPhotoPicker = false
    @State private var showingInfoPackPreview = false
    @State private var showingPhotoPreview = false
    @State private var pdfData: Data?
    @State private var showAlert = false
    @State private var isFormLinkValid = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var shouldDismiss: Bool
    @State private var navigateToMyEvents = false 

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Event Details")
                        .font(.headline)
                        .padding(.horizontal)
                    TextField("Event Name", text: $viewModel.event.title)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Venue")
                            .font(.headline)
                            .padding(.horizontal)
                        TextField("City/Country", text: $viewModel.event.country)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    Text("Event Type")
                        .font(.headline)
                        .padding(.horizontal)
                    Picker("Type", selection: $viewModel.event.type) {
                        ForEach(EventTypes.types, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onAppear {
                        if viewModel.event.type.isEmpty {
                            viewModel.event.type = "Youth Exchange"
                        }
                    }
                    
                    topicPicker
                    
                    dateRangePicker
                    
                    includedSection
                    
                    lookingForSection
                    
                    countriesSection
                    
                    Text("Reimbursement Limit")
                        .font(.headline)
                        .padding(.horizontal)
                    TextField("Reimbursement Limit", value: $viewModel.event.reimbursementLimit, formatter: NumberFormatter())
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    infoPackSection
                    
                    photoSection
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Application Form Link")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("Create a form to screen applicants according to the requirements of the event and get to know them better.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        TextField("Paste Google Forms Link", text: $viewModel.event.formLink)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .onChange(of: viewModel.event.formLink) { _ in
                                validateFormLink()
                            }
                        
                        if !isFormLinkValid {
                            Text("Please enter a valid Google Forms link")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    
                    Button(action: { // Update 2: Updated Button action
                        if isFormValid() {
                            viewModel.createEvent { success in
                                if success {
                                    navigateToMyEvents = true // Update 2
                                } else {
                                    showAlert = true
                                }
                            }
                        } else {
                            showAlert = true
                        }
                    }) {
                        Text("PUBLISH")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading || !isFormValid())
                    .background( // Update 3: Added NavigationLink
                        NavigationLink(destination: NgoMyEventsView(), isActive: $navigateToMyEvents) {
                            EmptyView()
                        }
                    )
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Create Event", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                Text("Back")
            })
        }
        .alert(isPresented: $showAlert) {
            if isFormValid() {
                return Alert(
                    title: Text("Error"),
                    message: Text("There was an error creating the event. Please try again."),
                    dismissButton: .default(Text("OK"))
                )
            } else {
                return Alert(
                    title: Text("Incomplete Form"),
                    message: Text("Please fill in all required fields before publishing."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("Creating event...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        )
    }
    
    private var topicPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topic")
                .font(.headline)
            Picker("Topic", selection: $viewModel.event.topic) {
                ForEach(TopicList.topics + ["Other"], id: \.self) { topic in
                    Text(topic)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
            .onAppear {
                if viewModel.event.topic.isEmpty {
                    viewModel.event.topic = "Improve Yourself"
                }
            }
            
            if viewModel.event.topic == "Other" {
                TextField("Specify other topic", text: $viewModel.event.otherTopic)
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private var dateRangePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Dates")
                .font(.headline)
            DatePicker("Start Date", selection: $viewModel.event.startDate, displayedComponents: .date)
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            DatePicker("End Date", selection: $viewModel.event.endDate, displayedComponents: .date)
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var includedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Included Items")
                .font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Transportation", isOn: $viewModel.event.includedItems.transportation)
                Toggle("Accommodation", isOn: $viewModel.event.includedItems.accommodation)
                Toggle("Food", isOn: $viewModel.event.includedItems.food)
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var lookingForSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Participants")
                .font(.headline)
            ForEach(viewModel.event.lookingFor.indices, id: \.self) { index in
                HStack {
                    Stepper(value: $viewModel.event.lookingFor[index].count, in: 1...10) {
                        Text("\(viewModel.event.lookingFor[index].count) People")
                    }
                    Picker("Nationality", selection: $viewModel.event.lookingFor[index].nationality) {
                        Text("Select Nationality").tag("")
                        ForEach(NationalityList.nationalities, id: \.self) { nationality in
                            Text(nationality)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Button(action: {
                        viewModel.event.lookingFor.remove(at: index)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            Button(action: {
                viewModel.event.lookingFor.append(Participant(count: 1, nationality: ""))
            }) {
                Label("Add More", systemImage: "plus.circle.fill")
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var countriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Participating Countries")
                .font(.headline)
            ForEach(viewModel.event.countries.indices, id: \.self) { index in
                HStack {
                    Picker("Country", selection: $viewModel.event.countries[index].country) {
                        Text("Select Country").tag("")
                        ForEach(CountryList.countries, id: \.self) { country in
                            Text("\(CountryList.flag(for: country)) \(country)")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    TextField("NGO Name", text: $viewModel.event.countries[index].ngoName)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    Button(action: {
                        viewModel.event.countries.remove(at: index)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            Button(action: {
                viewModel.event.countries.append(CountryNGO(country: "", ngoName: ""))
            }) {
                Label("Add Country", systemImage: "plus.circle.fill")
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var infoPackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Information Pack")
                .font(.headline)
            HStack {
                Button(action: {
                    showingInfoPackPicker = true
                }) {
                    Label("Choose File", systemImage: "doc.fill")
                }
                if pdfData != nil {
                    Button(action: {
                        showingInfoPackPreview = true
                    }) {
                        Label("View PDF", systemImage: "eye.fill")
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingInfoPackPicker) {
            DocumentPicker(pdfData: $pdfData, url: $viewModel.selectedInfoPack, contentTypes: [UTType.pdf])
        }
        .sheet(isPresented: $showingInfoPackPreview) {
            if let pdfData = pdfData {
                PDFViewer(pdfData: pdfData)
            }
        }
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Photo")
                .font(.headline)
            HStack {
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    Label("Choose File", systemImage: "photo.fill")
                }
                if viewModel.selectedPhoto != nil {
                    Button(action: {
                        showingPhotoPreview = true
                    }) {
                        Label("View Photo", systemImage: "eye.fill")
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingPhotoPicker) {
            ImagePicker(url: $viewModel.selectedPhoto)
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let url = viewModel.selectedPhoto {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        let isBasicInfoValid = !viewModel.event.title.isEmpty &&
        !viewModel.event.country.isEmpty &&
        !viewModel.event.type.isEmpty &&
        !viewModel.event.topic.isEmpty &&
        (viewModel.event.topic != "Other" || !viewModel.event.otherTopic.isEmpty) &&
        !viewModel.event.lookingFor.isEmpty &&
        !viewModel.event.countries.isEmpty &&
        viewModel.selectedInfoPack != nil &&
        viewModel.selectedPhoto != nil &&
        isFormLinkValid
        
        return isBasicInfoValid
    }
    
    private func validateFormLink() {
        isFormLinkValid = !viewModel.event.formLink.isEmpty &&
            viewModel.event.formLink.starts(with: "https://") &&
            viewModel.event.formLink.contains("docs.google.com/forms")
    }
}


struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var pdfData: Data?
    @Binding var url: URL?
    let contentTypes: [UTType]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.url = url
            
            if let data = try? Data(contentsOf: url) {
                parent.pdfData = data
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var url: URL?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let imageURL = info[.imageURL] as? URL {
                parent.url = imageURL
            }
            picker.dismiss(animated: true)
        }
    }
}

