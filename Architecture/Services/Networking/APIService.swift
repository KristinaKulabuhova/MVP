//
//  Networking.swift
//  Architecture
//
//  Created by Kristina on 14.01.2024.
//

import Foundation
import Combine

enum APIError: LocalizedError {
    case serverError(statusCode: Int)
    case invalidURL(url: String)
}

protocol DataManagerProtocol {
    func fetchData(from urlStr: String) async throws -> Data
    func fetchDTO<DTOType: Decodable>(from urlStr: String) async throws -> DTOType
}

final class DataManager: DataManagerProtocol {
    @Published var downloads: [DownloadInfo] = []
    @TaskLocal static var supportsPartialDownloads = false
    @MainActor var stopDownloads = false

    func fetchData(from urlStr: String) async throws -> Data {
        guard let url = URL(string: urlStr) else { throw APIError.invalidURL(url: urlStr) }
        let (data, response) = try await URLSession.shared.data(from: url)

        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            throw APIError.serverError(statusCode: response.statusCode)
        }

        return data
    }

//    func fetchDataPublisher(from urlStr: String) async throws -> Data {
//        guard let url = URL(string: urlStr) else { throw APIError.invalidURL(url: urlStr) }
//        let (data, response) = try await URLSession.shared.dataTaskPublisher(for: url)
//
//        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
//            throw APIError.serverError(statusCode: response.statusCode)
//        }
//
//        return data
//    }

    /// Downloads a file, returns its data, and updates the download progress in ``downloads``.
    func downloadWithProgress(file: DownloadFile, url: URL) async throws -> Data {
        return try await fetchDataPartialy(fileName: file.name, name: file.name, size: file.size, url: url)
    }

    private func fetchDataPartialy(fileName: String, name: String, size: Int, url: URL, offset: Int? = nil) async throws -> Data {
        await addDownload(name: name)

        let result: (downloadStream: URLSession.AsyncBytes, response: URLResponse)
        if let offset = offset {
            let urlRequst = URLRequest(url: url, offset: offset, length: size)
            result = try await URLSession.shared.bytes(for: urlRequst)

            guard (result.response as? HTTPURLResponse)?.statusCode == 206 else {
                throw APIError.serverError(statusCode: 0)
            }
        } else {
            result = try await URLSession.shared.bytes(from: url)

            guard (result.response as? HTTPURLResponse)?.statusCode == 200 else {
                throw APIError.serverError(statusCode: 01)
            }
        }

        var asyncDownloadIterator = result.downloadStream.makeAsyncIterator()
        var accumulator = ByteAccumulator(name: name, size: size)

        while await !stopDownloads, !accumulator.checkCompleted() {
            while !accumulator.isBatchCompleted,
                  let byte = try await asyncDownloadIterator.next() {
                accumulator.append(byte)
            }
        }
        if await stopDownloads, !Self.supportsPartialDownloads {
            throw CancellationError()
        }
        return accumulator.data
    }

    func fetchDTO<DTOType: Decodable>(from urlStr: String) async throws -> DTOType {
        let data = try await fetchData(from: urlStr)
        return try JSONDecoder().decode(DTOType.self, from: data)
    }

    @MainActor func addDownload(name: String) {
        let downloadInfo = DownloadInfo(id: UUID(), name: name, progress: 0.0)
        downloads.append(downloadInfo)
    }
}


struct DownloadFile: Codable, Identifiable, Equatable {
    var id: String { return name }
    let name: String
    let size: Int
    let date: Date
    static let empty = DownloadFile(name: "", size: 0, date: Date())
}


struct DownloadInfo: Identifiable, Equatable {
  let id: UUID
  let name: String
  var progress: Double
}

extension URLRequest {
    init(url: URL, offset: Int, length: Int) {
        self.init(url: url)
        addValue("bytes=\(offset)-\(offset + length - 1)", forHTTPHeaderField: "Range")
    }
}

/// Type that accumulates incoming data into an array of bytes.
struct ByteAccumulator: CustomStringConvertible {
  private var offset = 0
  private var counter = -1
  private let name: String
  private let size: Int
  private let chunkCount: Int
  private var bytes: [UInt8]
  var data: Data { return Data(bytes[0..<offset]) }

  /// Creates a named byte accumulator.
  init(name: String, size: Int) {
    self.name = name
    self.size = size
    chunkCount = max(Int(Double(size) / 20), 1)
    bytes = [UInt8](repeating: 0, count: size)
  }

  /// Appends a byte to the accumulator.
  mutating func append(_ byte: UInt8) {
    bytes[offset] = byte
    counter += 1
    offset += 1
  }

  /// `true` if the current batch is filled with bytes.
  var isBatchCompleted: Bool {
    return counter >= chunkCount
  }

  mutating func checkCompleted() -> Bool {
    defer { counter = 0 }
    return counter == 0
  }

  /// The overall progress.
  var progress: Double {
    Double(offset) / Double(size)
  }

  var description: String {
    "[\(name)] \(sizeFormatter.string(fromByteCount: Int64(offset)))"
  }
}

let sizeFormatter: ByteCountFormatter = {
  let formatter = ByteCountFormatter()
  formatter.allowedUnits = [.useMB]
  formatter.isAdaptive = true
  return formatter
}()
