//
//  ImagePickerView.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 20.07.2024.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var completionHandler: (UIImage?, String?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, completionHandler: completionHandler)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView
        var completionHandler: (UIImage?, String?) -> Void // Update the completion handler type

        init(_ parent: ImagePickerView, completionHandler: @escaping (UIImage?, String?) -> Void) {
            self.parent = parent
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let assetUrl = info[.imageURL] as? URL,
               let image = info[.originalImage] as? UIImage {
                let fileExtension = assetUrl.pathExtension
                completionHandler(image, fileExtension)
            } else {
                completionHandler(nil, nil)
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil, nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

