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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    TextField("Event Name", text: $viewModel.event.title)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    TextField("City/Country", text: $viewModel.event.country)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
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
                    
                    topicPicker
                    
                    dateRangePicker
                    
                    includedSection
                    
                    lookingForSection
                    
                    countriesSection
                    
                    HStack {
                        Text("Reimbursement Limit:")
                        TextField("Choose Amount", value: $viewModel.event.reimbursementLimit, formatter: NumberFormatter())
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                            .keyboardType(.decimalPad)
                    }
                    .padding(.horizontal)
                    
                    infoPackSection
                    
                    photoSection
                    
                    TextField("Paste Here", text: $viewModel.event.formLink)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.createEvent { success in
                            if success {
                                showAlert = true
                            }
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
                    .disabled(viewModel.isLoading)
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
            Alert(
                title: Text("Success"),
                message: Text("Event created successfully"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
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
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message))
        }
    }
    
    private var topicPicker: some View {
        VStack(alignment: .leading) {
            Text("Topic:")
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
        }
        .padding(.horizontal)
    }
    
    private var dateRangePicker: some View {
        VStack(alignment: .leading) {
            Text("Dates Between:")
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
        VStack(alignment: .leading) {
            Text("Included:")
                .font(.headline)
            HStack {
                Toggle("Transportation", isOn: .constant(true))
                Toggle("Accommodation", isOn: .constant(true))
                Toggle("Food", isOn: .constant(true))
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var lookingForSection: some View {
        VStack(alignment: .leading) {
            Text("Looking For:")
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
        VStack(alignment: .leading) {
            Text("Countries:")
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
        VStack(alignment: .leading) {
            Text("Upload Event's Information Pack:")
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
        VStack(alignment: .leading) {
            Text("Upload Event's Logo or Photo of Venue:")
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

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}

