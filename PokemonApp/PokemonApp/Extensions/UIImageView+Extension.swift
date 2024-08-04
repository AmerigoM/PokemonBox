//
//  UIImageView+Extension.swift
//  PokemonApp
//
//  Created by Amerigo Mancino on 02/08/24.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder
        let urlString = url.absoluteString as NSString

        if let cachedImage = ImageCache.shared.object(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image data")
                return
            }
            
            ImageCache.shared.setObject(image, forKey: urlString)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
        
        task.resume()
    }
}
