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
                // Profile Header
                HStack(spacing: 20) {
                    if let logoUrl = homeViewModel.logoUrl {
                        AsyncImage(url: logoUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .onTapGesture {
                            showLogoUpdateSheet = true
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                            .onTapGesture {
                                showLogoUpdateSheet = true
                            }
                    }
                    
                    Text(homeViewModel.ngoName)
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Profile Fields
                VStack(spacing: 24) {
                    profileFieldView(fieldName: "Country", fieldKey: "country", fieldText: $homeViewModel.country, homeViewModel: homeViewModel)
                    profileFieldView(fieldName: "OID Number", fieldKey: "oidNumber", fieldText: $homeViewModel.oidNumber, homeViewModel: homeViewModel)
                    profileFieldView(fieldName: "E-Mail", fieldKey: "email", fieldText: $homeViewModel.email, homeViewModel: homeViewModel)
                    profileFieldView(fieldName: "Instagram Profile", fieldKey: "instagram", fieldText: $homeViewModel.instagram, homeViewModel: homeViewModel)
                    profileFieldView(fieldName: "Facebook Profile", fieldKey: "facebook", fieldText: $homeViewModel.facebook, homeViewModel: homeViewModel)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // PIF Section
                VStack(spacing: 16) {
                    Button(action: {
                        isPDF = true
                        showFilePicker = true
                    }) {
                        Text("Update PIF")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                    
                    if let pifUrl = homeViewModel.pifUrl {
                        Button(action: {
                            homeViewModel.loadPDFData()
                            showPDFView = true
                        }) {
                            Text("View PIF")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                        }
                    }
                    
                    if homeViewModel.isLoading {
                        ProgressView("Uploading...")
                    }
                }
                .padding(.horizontal)
                
                // Sign Out Button
                Button(action: {
                    loginViewModel.logoutUser()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showPDFView) {
            if let pdfData = homeViewModel.pdfData {
                PDFViewer(pdfData: pdfData)
            }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: isPDF ? [.pdf] : [.image]) { result in
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
        }
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
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text(fieldName)
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                if homeViewModel.isEditingField(fieldKey) {
                    homeViewModel.toggleEditing(for: fieldKey, fieldText: fieldText.wrappedValue)
                } else {
                    homeViewModel.toggleEditing(for: fieldKey, fieldText: "")
                }
            }) {
                Text(homeViewModel.isEditingField(fieldKey) ? "Done" : "Edit")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
        }
        
        TextField(fieldName, text: fieldText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(!homeViewModel.isEditingField(fieldKey))
    }
}
