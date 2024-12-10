//
//  ImageLoader.swift
//  EraMatch
//
//  Created by R. Metehan GÖKTAŞ on 10.12.2024.
//


import SwiftUI
import FirebaseStorage

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private static let cache = NSCache<NSString, UIImage>()
    private var task: URLSessionDataTask?
    
    func loadImage(from urlString: String) {
        if let cachedImage = Self.cache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else { return }
                Self.cache.setObject(image, forKey: urlString as NSString)
                self.image = image
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}

