//
//  Model.swift
//  Architecture
//
//  Created by Kristina on 14.01.2024.
//

import Foundation
import Combine

protocol PhotoProviderProtocol {
    func getCountPhotos() -> Int
    func getPhotoData(in index: Int) -> PhotoData
    func fetchPhoto() async throws

    func loadDataImage(in index: Int) -> AnyPublisher<Data, Error>
}

final class PhotoProvider: PhotoProviderProtocol {
    var photos: [PhotoData] = []
    var dataManager: DataManagerProtocol
    var cancellable: AnyCancellable?

    private var publishers: [AnyPublisher<RawImageData, Error>] = []

    private var futureImageData: [Future<Data?, Error>] = []
    private let urlStr = "https://api.slingacademy.com/v1/sample-data/photos?offset=5&limit=100"

    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    func getCountPhotos() -> Int {
        photos.count
    }

    func getPhotoData(in index: Int) -> PhotoData {
        photos[index]
    }

    func loadDataImage(in index: Int) -> AnyPublisher<RawImageData, Error> {
        let future = Future<Data, Error> { promise in
            Task {
                do {
                    let imageData = try await self.dataManager.fetchData(from: self.photos[index].metadata.url)
                    self.photos[index].imageData = imageData
                    print("set image for index: \(index)")
                    promise(.success(imageData))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()


        publishers.insert(future, at: index)

        cancellable = future.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let failure):
                print("JOPA")
            }
        }, receiveValue: { imageData in
            self.photos[index].imageData = imageData
        })
        return publishers[index]
    }

    func fetchPhoto() async throws {
        let response: PhotoResponse = try await dataManager.fetchDTO(from: urlStr)
        for photoMetadata in response.photos {
            photos.append(PhotoData(metadata: photoMetadata))
        }
    }
}
