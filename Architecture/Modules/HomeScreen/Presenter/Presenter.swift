//
//  Presenter.swift
//  Architecture
//
//  Created by Kristina on 14.01.2024.
//

import Foundation
import Combine

protocol PhotosPresenterProtocol: AnyObject {
    func viewLoaded() async
    func getCountInModel() -> Int
    func getPhotoData(in index: Int) -> PhotoData
    func openDescriptionPhoto(for index: Int)

    func getImageData(for index: Int) -> AnyPublisher<Data, Error>
}

final class PhotosPresenter: PhotosPresenterProtocol {
    weak var view: PhotosViewProtocol?
    var photoProvider: PhotoProviderProtocol

    init(view: PhotosViewProtocol? = nil, photoProvider: PhotoProviderProtocol) {
        self.view = view
        self.photoProvider = photoProvider
    }

    func getCountInModel() -> Int {
        photoProvider.getCountPhotos()
    }

    func getPhotoData(in index: Int) -> PhotoData {
        photoProvider.getPhotoData(in: index)
    }

    func getImageData(for index: Int) -> AnyPublisher<Data, Error> {
        print("photoProvider.loadDataImage in \(index)")
        return photoProvider.loadDataImage(in: index)
    }

    func viewLoaded() async {
        do {
            try await photoProvider.fetchPhoto()
            DispatchQueue.main.async {
                self.view?.updatePhotos()
            }
        } catch let error {
            DispatchQueue.main.async {
                self.view?.showError(error: error.localizedDescription)
            }
        }
    }

    func openDescriptionPhoto(for index: Int) {
    }
}
