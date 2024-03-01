//
//  DescriptionPeresenter.swift
//  Architecture
//
//  Created by Kristina on 12.02.2024.
//

import Foundation

protocol DescriptionPeresenterProtocol: AnyObject {
}

final class DescriptionPeresenter: DescriptionPeresenterProtocol {
    weak var view: DescriptionPhotoViewProtocol?
    var photoProvider: PhotoProviderProtocol

    init(view: DescriptionPhotoViewProtocol? = nil, photoProvider: PhotoProviderProtocol) {
        self.view = view
        self.photoProvider = photoProvider
    }
}
