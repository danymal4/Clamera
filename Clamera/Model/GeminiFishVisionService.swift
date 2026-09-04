//
//  GeminiFishVisionService.swift
//  Clamera
//
//  Created by Isaac on 5/4/26.
//

import Foundation
import UIKit
import FirebaseFunctions

enum GeminiFishVisionError: LocalizedError {
    case invalidImageData
    case functionFailure(message: String)
    case missingResponseText
    case rateLimited(message: String?)
    case throttled(waitSeconds: Int)

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Could not read image data."
        case .functionFailure(let message):
            return message
        case .missingResponseText:
            return "Could not identify a species from that photo."
        case .rateLimited(let message):
            return message ?? "Rate limit reached. Please wait and try again."
        case .throttled(let waitSeconds):
            return "Please wait \(waitSeconds)s before another detection."
        }
    }
}

actor GeminiFishVisionService {
    static let shared = GeminiFishVisionService()

    private lazy var functions = Functions.functions()
    private var lastRequestDate: Date?
    private var cachedPredictions: [String: String] = [:]
    private let minimumRequestInterval: TimeInterval = 2

    func detectFishName(from image: UIImage, speciesList: [String]) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw GeminiFishVisionError.invalidImageData
        }

        let cacheKey = makeCacheKey(for: imageData)
        if let cached = cachedPredictions[cacheKey] {
            return cached
        }

        if let lastRequestDate {
            let elapsed = Date().timeIntervalSince(lastRequestDate)
            if elapsed < minimumRequestInterval {
                let waitSeconds = max(1, Int((minimumRequestInterval - elapsed).rounded(.up)))
                throw GeminiFishVisionError.throttled(waitSeconds: waitSeconds)
            }
        }

        lastRequestDate = Date()
        let base64Image = imageData.base64EncodedString()

        do {
            let callable = functions.httpsCallable("identifyFish")
            let result = try await callable.call([
                "imageBase64": base64Image,
                "speciesList": speciesList
            ])

            guard let dict = result.data as? [String: Any],
                  let species = dict["species"] as? String,
                  !species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw GeminiFishVisionError.missingResponseText
            }

            let cleaned = species.trimmingCharacters(in: .whitespacesAndNewlines)
            cachedPredictions[cacheKey] = cleaned
            return cleaned
        } catch let error as NSError {
            if error.domain == FunctionsErrorDomain,
               let code = FunctionsErrorCode(rawValue: error.code) {
                switch code {
                case .resourceExhausted:
                    throw GeminiFishVisionError.rateLimited(message: error.localizedDescription)
                case .unauthenticated:
                    throw GeminiFishVisionError.functionFailure(message: "Please sign in to use fish detection.")
                default:
                    throw GeminiFishVisionError.functionFailure(message: "Couldn't identify the species. Please try again.")
                }
            }
            throw GeminiFishVisionError.functionFailure(message: "Couldn't identify the species. Please try again.")
        }
    }

    private func makeCacheKey(for data: Data) -> String {
        let prefixSum = data.prefix(64).reduce(0) { partialResult, byte in
            partialResult + Int(byte)
        }
        return "\(data.count)-\(prefixSum)"
    }
}
