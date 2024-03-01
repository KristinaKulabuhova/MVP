//
//  AppCoordinator.swift
//  Architecture
//
//  Created by Kristina on 21.02.2024.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }

    func start()
    func stop()
}

final class AppCoordinator: DescriptionPeresenterProtocol, AllPhotosViewControllerDelegate {
    private var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    let photoProvider = PhotoProvider(dataManager: DataManager())

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showAllPhotos()
    }

    func showAllPhotos() {
        let allPhotosFlowCoordinator = AllPhotosFlowCoordinator(navigationController: navigationController, 
                                                                photoProvider: photoProvider)
        allPhotosFlowCoordinator.delegate = self
        allPhotosFlowCoordinator.start()
        childCoordinators.append(allPhotosFlowCoordinator)
    }

    func showDescriptionPhoto(in index: Int) {
        let descriptionPhotoFlowCoordinator = DescriptionPhotoFlowCoordinator(navigationController: navigationController,
                                                                              photoProvider: photoProvider,
                                                                              index: index)
        descriptionPhotoFlowCoordinator.delegate = self
        descriptionPhotoFlowCoordinator.start()
        childCoordinators.append(descriptionPhotoFlowCoordinator)
    }
}

// MARK: - AllPhotos

protocol AllPhotosViewControllerDelegate: AnyObject {
    func showDescriptionPhoto(in index: Int)
}

final class AllPhotosFlowCoordinator: Coordinator {
    let photoProvider: PhotoProvider
    var navigationController: UINavigationController
    weak var delegate: AllPhotosViewControllerDelegate?

    init(navigationController: UINavigationController, photoProvider: PhotoProvider) {
        self.navigationController = navigationController
        self.photoProvider = photoProvider
    }

    func start() {
        let viewController = PhotosViewController()
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: true)

        let presenter = PhotosPresenter(view: viewController, photoProvider: photoProvider)
            viewController.presenter = presenter
    }

    func stop() {
        navigationController.popViewController(animated: true)
    }
}

extension AllPhotosFlowCoordinator: PhotosViewDelegate {
    func didSelect(in index: Int) {
        delegate?.showDescriptionPhoto(in: index)
    }
}

// MARK: - DescriptionPhoto

final class DescriptionPhotoFlowCoordinator: Coordinator {
    let photoProvider: PhotoProvider
    var navigationController: UINavigationController
    weak var delegate: DescriptionPeresenterProtocol?

    private var index: Int

    init(navigationController: UINavigationController, photoProvider: PhotoProvider, index: Int) {
        self.navigationController = navigationController
        self.photoProvider = photoProvider
        self.index = index
    }

    func start() {
        let viewController = DescriptionViewController(photo: photoProvider.getPhotoData(in: index), indexPath: index)
        viewController.presenter = DescriptionPeresenter(view: viewController, photoProvider: photoProvider)
        navigationController.pushViewController(viewController, animated: true)
    }

    func stop() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
