//
//  PDFViewer.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 2.11.2024.
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
    var pdfData: Data

    var body: some View {
        if let document = PDFDocument(data: pdfData) {
            PDFKitRepresentedView(pdfDocument: document)
                .edgesIgnoringSafeArea(.all)
        } else {
            Text("Failed to load PDF.")
        }
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    var pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}
