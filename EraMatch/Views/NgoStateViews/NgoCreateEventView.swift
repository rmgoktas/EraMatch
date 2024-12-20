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
    @Environment(\.dismiss) var dismiss
    @State private var isEventCreated = false
    var creatorId: String

    var body: some View {
        NavigationView {
            FormContent()
                .navigationTitle("Create Event")
                .navigationBarItems(
                    leading: cancelButton,
                    trailing: publishButton
                )
                .overlay(loadingOverlay)
        }
    }
    
    private func FormContent() -> some View {
        Form {
            basicInfoSection
            topicSection
            datesSection
            includedItemsSection
            participantsSection
            participatingCountriesSection
            reimbursementSection
            documentsSection
            applicationFormSection
        }
    }
    
    private var basicInfoSection: some View {
        Section(header: Text("Basic Information")) {
            TextField("Event Name", text: $viewModel.event.title)
            TextField("City/Country", text: $viewModel.event.country)
            
            Picker("Event Type", selection: $viewModel.event.type) {
                ForEach(EventTypes.types, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
        }
    }
    
    private var documentsSection: some View {
        Section(header: Text("Documents")) {
            infoPack
            eventPhoto
        }
    }
    
    private var infoPack: some View {
        HStack {
            Button(action: { showingInfoPackPicker = true }) {
                Label("Info Pack", systemImage: "doc.fill")
            }
            if pdfData != nil {
                Button(action: { showingInfoPackPreview = true }) {
                    Label("Preview", systemImage: "eye.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingInfoPackPicker) {
            DocumentPicker(pdfData: $pdfData, url: $viewModel.selectedInfoPack, contentTypes: [.pdf])
        }
        .sheet(isPresented: $showingInfoPackPreview) {
            if let pdfData = pdfData {
                PDFViewer(pdfData: pdfData)
            }
        }
    }
    
    private var eventPhoto: some View {
        HStack {
            Button(action: { showingPhotoPicker = true }) {
                Label("Event Photo", systemImage: "photo.fill")
            }
            if viewModel.selectedPhoto != nil {
                Button(action: { showingPhotoPreview = true }) {
                    Label("Preview", systemImage: "eye.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            ImagePicker(url: $viewModel.selectedPhoto)
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let photoURL = viewModel.selectedPhoto,
               let image = UIImage(contentsOfFile: photoURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    private var topicSection: some View {
        Section(header: Text("Topic")) {
            Picker("Select Topic", selection: $viewModel.event.topic) {
                ForEach(TopicList.topics + ["Other"], id: \.self) { topic in
                    Text(topic).tag(topic)
                }
            }
            
            if viewModel.event.topic == "Other" {
                TextField("Specify other topic", text: $viewModel.event.otherTopic)
            }
        }
    }
    
    private var datesSection: some View {
        Section(header: Text("Event Dates")) {
            DatePicker("Start Date", selection: $viewModel.event.startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $viewModel.event.endDate, displayedComponents: .date)
        }
    }
    
    private var includedItemsSection: some View {
        Section(header: Text("Included Items")) {
            Toggle("Transportation", isOn: $viewModel.event.includedItems.transportation)
            Toggle("Accommodation", isOn: $viewModel.event.includedItems.accommodation)
            Toggle("Food", isOn: $viewModel.event.includedItems.food)
        }
    }
    
    private var participantsSection: some View {
        Section(header: Text("Participants Looking For")) {
            ForEach(viewModel.event.lookingFor.indices, id: \.self) { index in
                HStack {
                    Stepper("\(viewModel.event.lookingFor[index].count)",
                           value: $viewModel.event.lookingFor[index].count, in: 1...10)
                    Picker("", selection: $viewModel.event.lookingFor[index].nationality) {
                        Text("Select").tag("")
                        ForEach(CountryList.countries, id: \.self) { country in
                            Text(country).tag(country)
                        }
                    }
                    Button(action: {
                        viewModel.event.lookingFor.remove(at: index)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Button(action: {
                viewModel.event.lookingFor.append(Participant(count: 1, nationality: ""))
            }) {
                Label("Add Participant", systemImage: "plus.circle.fill")
            }
        }
    }
    
    private var participatingCountriesSection: some View {
        Section(header: Text("Participating Countries")) {
            // enterOID
            VStack(alignment: .leading) {
                HStack {
                    TextField("Enter OID Number (E + 8 digits)", text: $viewModel.oidNumberInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .onChange(of: viewModel.oidNumberInput) { newValue in
                            //FORMAT
                            let filtered = newValue.filter { $0.isNumber || $0 == "E" }
                            if filtered != newValue {
                                viewModel.oidNumberInput = filtered
                            }
                            if filtered.count > 9 {
                                viewModel.oidNumberInput = String(filtered.prefix(9))
                            }
                        }
                    
                    Button(action: {
                        if viewModel.isValidOIDFormat(viewModel.oidNumberInput) {
                            viewModel.fetchNGODetails(oidNumber: viewModel.oidNumberInput) { success in
                                if success {
                                    viewModel.oidNumberInput = "" //clear input
                                }
                            }
                        }
                    }) {
                        Text("Add")
                    }
                    .disabled(!viewModel.isValidOIDFormat(viewModel.oidNumberInput))
                }
                
                if viewModel.isLoadingNGO {
                    ProgressView()
                }
                
                if let error = viewModel.ngoError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            // Eklenen NGO'ların Listesi
            ForEach(viewModel.event.countries.indices, id: \.self) { index in
                HStack {
                    Text("\(CountryList.flag(for: viewModel.event.countries[index].country)) \(viewModel.event.countries[index].country)")
                    Spacer()
                    Text(viewModel.event.countries[index].ngoName)
                        .foregroundColor(.gray)
                    Button(action: {
                        viewModel.event.countries.remove(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private var reimbursementSection: some View {
        Section(header: Text("Reimbursement")) {
            TextField("Limit", value: $viewModel.event.reimbursementLimit, formatter: NumberFormatter())
                .keyboardType(.numberPad)
        }
    }
    
    private var applicationFormSection: some View {
        Section(header: Text("Application Form")) {
            TextField("Google Forms Link", text: $viewModel.event.formLink)
                .autocapitalization(.none)
                .onChange(of: viewModel.event.formLink) { _ in
                    validateFormLink()
                }
            if !isFormLinkValid && !viewModel.event.formLink.isEmpty {
                Text("Please enter a valid Google Forms link")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var publishButton: some View {
        Button("Publish") {
            if isFormValid() {
                createEvent()
            }
        }
        .disabled(!isFormValid())
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Creating event...")
                            .foregroundColor(.black)
                    }
                    .padding(24)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
                .ignoresSafeArea()
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
    
    private func createEvent() {
        viewModel.createEvent { success in
            if success {
                isEventCreated = true
                dismiss()
                Task {
                    await viewModel.refreshEvents(for: creatorId)
                }
            }
        }
    }
}


struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var pdfData: Data?
    @Binding var url: URL?
    let contentTypes: [UTType]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
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
            guard let selectedURL = urls.first else { return }
            
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let destinationURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString + ".pdf")
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: selectedURL, to: destinationURL)
                
                parent.url = destinationURL
                parent.pdfData = try Data(contentsOf: destinationURL)
                
            } catch {
                print("Dosya kopyalama hatası: \(error)")
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

