//
//  DescriptionViewController.swift
//  Architecture
//
//  Created by Kristina on 12.02.2024.
//

import Foundation
import UIKit

protocol DescriptionPhotoViewProtocol: AnyObject {
    //func updateImageData()
    func getIndexPath() -> Int
}

final class DescriptionViewController: UIViewController, DescriptionPhotoViewProtocol {
    var presenter: DescriptionPeresenterProtocol!
    var photo: PhotoData
    var indexPath: Int

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(data: photo.imageData ?? Data()))
        imageView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = photo.metadata.title
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = photo.metadata.description
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(photo: PhotoData, indexPath: Int) {
        self.photo = photo
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)

        //subscribe
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
        addSubview()
    }

    func addSubview() {
        self.view.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }

    func getIndexPath() -> Int {
        indexPath
    }
}
