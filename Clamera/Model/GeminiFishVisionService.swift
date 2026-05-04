//
//  GeminiFishVisionService.swift
//  Clamera
//
//  Created by Codex on 5/4/26.
//

import Foundation
import UIKit

enum GeminiFishVisionError: LocalizedError {
    case invalidImageData
    case invalidURL
    case badResponseStatus(Int)
    case missingResponseText
    case rateLimited(retryAfter: Int?)
    case throttled(waitSeconds: Int)

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Could not read image data."
        case .invalidURL:
            return "Gemini endpoint URL is invalid."
        case .badResponseStatus(let statusCode):
            return "Gemini request failed with status code \(statusCode)."
        case .missingResponseText:
            return "Gemini returned no species text."
        case .rateLimited(let retryAfter):
            if let retryAfter {
                return "Rate limit reached. Try again in about \(retryAfter)s."
            }
            return "Rate limit reached. Please wait and try again."
        case .throttled(let waitSeconds):
            return "Please wait \(waitSeconds)s before another detection."
        }
    }
}

actor GeminiFishVisionService {
    static let shared = GeminiFishVisionService()

    private let apiKey = "AIzaSyC_v7VlUertFNmRVQudG2t27fy3lyWHghw"
    private let session: URLSession
    private var lastRequestDate: Date?
    private var cachedPredictions: [String: String] = [:]
    private let minimumRequestInterval: TimeInterval = 2

    init(session: URLSession = .shared) {
        self.session = session
    }

    func detectFishName(from image: UIImage) async throws -> String {
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

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
            throw GeminiFishVisionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody(base64Image: imageData.base64EncodedString()))
        lastRequestDate = Date()

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiFishVisionError.badResponseStatus(-1)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 {
                let retryAfter = Int(httpResponse.value(forHTTPHeaderField: "Retry-After") ?? "")
                throw GeminiFishVisionError.rateLimited(retryAfter: retryAfter)
            }
            throw GeminiFishVisionError.badResponseStatus(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(GeminiGenerateContentResponse.self, from: data)
        guard let rawText = decoded.candidates.first?.content.parts.first?.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawText.isEmpty else {
            throw GeminiFishVisionError.missingResponseText
        }

        let cleaned = rawText
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "`", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        cachedPredictions[cacheKey] = cleaned

        return cleaned
    }

    private func makeCacheKey(for data: Data) -> String {
        let prefixSum = data.prefix(64).reduce(0) { partialResult, byte in
            partialResult + Int(byte)
        }
        return "\(data.count)-\(prefixSum)"
    }

    private func requestBody(base64Image: String) -> [String: Any] {
        [
            "contents": [
                [
                    "parts": [
                        [
                            "text": """
                            Identify the fish species in this image.
                            Return only a single common-name fish species string.
                            If unsure, return exactly Unknown.
                            """
                        ],
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
}

private struct GeminiGenerateContentResponse: Decodable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Decodable {
    let content: GeminiContent
}

private struct GeminiContent: Decodable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Decodable {
    let text: String?
}
