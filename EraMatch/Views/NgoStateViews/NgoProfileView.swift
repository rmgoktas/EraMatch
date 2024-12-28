//
//  NgoProfileView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 25.07.2024.
//

import SwiftUI
import PDFKit

struct NgoProfileView: View {
    @ObservedObject var homeViewModel: NgoHomeViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @State private var showPDFView: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var isPDF: Bool = false
    @State private var showLogoUpdateSheet: Bool = false
    @State private var selectedFileURL: URL? = nil
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo ve NGO adı
                HStack {
                    if let logoUrl = homeViewModel.logoUrl {
                        Button(action: {
                            showLogoUpdateSheet = true
                        }) {
                            AsyncImage(url: logoUrl) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                showLogoUpdateSheet = true
                            }
                    }
                    
                    Spacer()
                    
                    Text(homeViewModel.ngoName)
                        .font(.largeTitle)
                        .bold()
                }
                .padding()
                
                // Profil alanları
                profileFieldView(fieldName: "Country", fieldKey: "country", fieldText: $homeViewModel.country, homeViewModel: homeViewModel)
                profileFieldView(fieldName: "OID Number", fieldKey: "oidNumber", fieldText: $homeViewModel.oidNumber, homeViewModel: homeViewModel)
                profileFieldView(fieldName: "E-Mail", fieldKey: "email", fieldText: $homeViewModel.email, homeViewModel: homeViewModel)
                profileFieldView(fieldName: "Instagram Profile", fieldKey: "instagram", fieldText: $homeViewModel.instagram, homeViewModel: homeViewModel)
                profileFieldView(fieldName: "Facebook Profile", fieldKey: "facebook", fieldText: $homeViewModel.facebook, homeViewModel: homeViewModel)

                
                // PIF güncelleme butonu
                Button(action: {
                    isPDF = true
                    showFilePicker = true
                }) {
                    Text("Update PIF")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .padding(.top, 5)
                .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
                    switch result {
                    case .success(let url):
                        homeViewModel.uploadPDF(url: url)
                    case .failure(let error):
                        print("Error selecting file: \(error.localizedDescription)")
                    }
                }
                
                if let pifUrl = homeViewModel.pifUrl {
                    Button(action: {
                        homeViewModel.loadPDFData()
                        showPDFView = true
                    }) {
                        Text("View PIF")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                if homeViewModel.isLoading {
                    ProgressView("Uploading...")
                }
                
                Button(action: {
                    loginViewModel.logoutUser()
                }) {
                    Text("SIGN OUT")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
            }
            .padding(.all, 20)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .sheet(isPresented: $showPDFView) {
            if let pdfData = homeViewModel.pdfData {
                PDFViewer(pdfData: pdfData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: isPDF ? [.pdf] : [.image], onCompletion: { result in
            switch result {
            case .success(let url):
                selectedFileURL = url
                if isPDF {
                    homeViewModel.uploadPDF(url: url)
                } else {
                    homeViewModel.uploadLogo(url: url)
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        })
        .actionSheet(isPresented: $showLogoUpdateSheet) {
            ActionSheet(title: Text("Update Logo"), buttons: [
                .default(Text("Choose Photo")) {
                    isPDF = false
                    showImagePicker = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { image, fileExtension in
                if let selectedImage = image, let fileExtension = fileExtension {
                    homeViewModel.handleImageUpload(image: selectedImage, fileExtension: fileExtension) { uploadedUrl, error in
                        if let uploadedUrl = uploadedUrl {
                            homeViewModel.logoUrl = uploadedUrl
                        } else if let error = error {
                            print("Failed to upload logo: \(error)")
                        }
                        showImagePicker = false
                    }
                } else {
                    showImagePicker = false
                }
            }
        }
    }
}

func profileFieldView(fieldName: String, fieldKey: String, fieldText: Binding<String>, homeViewModel: NgoHomeViewModel) -> some View {
    ZStack(alignment: .topTrailing) {
        VStack(alignment: .leading) {
            Text(fieldName)
                .font(.headline)
            TextField(fieldName, text: fieldText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .disabled(!homeViewModel.isEditingField(fieldKey))
                .onChange(of: homeViewModel.isEditingField(fieldKey)) { isEditing in
                    print("\(fieldKey) editing state changed to: \(isEditing)")
                }
        }
        .padding(.horizontal)
        
        Button(action: {
            withAnimation {
                homeViewModel.toggleEditing(for: fieldKey, fieldText: fieldText.wrappedValue)
            }
        }) {
            Text(homeViewModel.isEditingField(fieldKey) ? "Done" : "Edit")
                .foregroundColor(.black)
        }
        .padding([.top, .trailing], 10)
    }
}
