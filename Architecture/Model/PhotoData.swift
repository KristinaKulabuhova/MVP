//
//  Photo.swift
//  Architecture
//
//  Created by Kristina on 12.02.2024.
//

import Foundation

struct PhotoResponse: Decodable {
    let success: Bool
    let photos: [PhotoMetadata]
}

struct PhotoData: Decodable {
    let metadata: PhotoMetadata
    var imageData: RawImageData?
}

typealias RawImageData = Data

struct PhotoMetadata: Decodable {
    let url: String
    let title: String
    let description: String
}
