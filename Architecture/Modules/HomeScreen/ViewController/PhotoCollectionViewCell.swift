//
//  PhotoCollectionViewCell.swift
//  Architecture
//
//  Created by Kristina on 30.01.2024.
//

import Foundation
import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
   // var imageView: UIImageView = UIImageView()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.center
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview()
    }
    @MainActor
    func configureCell(photo: PhotoData) {
        if let imageData = photo.imageData {
            self.imageView.image = UIImage(data: imageData)
        } else {
            self.imageView = UIImageView(image: UIImage(systemName: "person")) // заглушка
        }
        setNeedsLayout()
    }

    @MainActor
    func updateImage(imageData: Data) {
        imageView.image = UIImage(data: imageData)
        setNeedsLayout()
    }

    func addSubview() {
        self.contentView.addSubview(stackView)
        stackView.addSubview(imageView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: stackView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
