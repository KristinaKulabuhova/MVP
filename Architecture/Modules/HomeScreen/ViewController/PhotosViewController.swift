//
//  ViewController.swift
//  Architecture
//
//  Created by Kristina on 14.01.2024.
//
import Foundation
import UIKit
import Combine

// for coordinator
protocol PhotosViewDelegate: AnyObject {
    func didSelect(in index: Int)
}

// for presenter
protocol PhotosViewProtocol: AnyObject {
    func updatePhotos()
    func showError(error: String)
}

final class PhotosViewController: UIViewController, PhotosViewProtocol {
    var presenter: PhotosPresenterProtocol!
    var loadingPhoto: Task<Void, Error>?
    var cancelationHandles: [Int: AnyCancellable?] = [:]

    weak var delegate: PhotosViewDelegate?

    private let photosCollection = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photo")
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        Task {
            await presenter.viewLoaded()
        }

        view.addSubview(photosCollection)
        photosCollection.delegate = self
        photosCollection.dataSource = self

        photosCollection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photosCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photosCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            photosCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photosCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    func updatePhotos() {
        photosCollection.reloadData()
    }

    func showError(error: String) {
        view.backgroundColor = .red
    }
}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getCountInModel()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as? PhotoCollectionViewCell else { return PhotoCollectionViewCell() }
        var photoData = self.presenter.getPhotoData(in: indexPath.item)
        print("\(indexPath.item): imageData: \(photoData.imageData)")
        cell.configureCell(photo: photoData)
        if !cancelationHandles.contains(where: { $0.key == indexPath.item }) && photoData.imageData ==  nil {
            let subscriber = presenter.getImageData(for: indexPath.item).sink { completion in
                print("completed for index in sink \(indexPath.item), \(completion)")
            } receiveValue: { imageData in
                print("update image in index: \(indexPath.item)")
                cell.updateImage(imageData: imageData)
            }

            cancelationHandles[indexPath.item] = subscriber
        }

        cell.backgroundColor = UIColor.cyan
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        loadingPhoto?.cancel()
        cancelationHandles.removeAll()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(in: indexPath.item)
    }
}
