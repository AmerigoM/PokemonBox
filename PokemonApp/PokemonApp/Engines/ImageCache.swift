//
//  ImageCache.swift
//  PokemonApp
//
//  Created by Amerigo Mancino on 03/08/24.
//

import UIKit

class ImageCache {
    
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func clearCache() {
        ImageCache.shared.removeAllObjects()
    }
}
