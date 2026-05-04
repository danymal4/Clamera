//
//  GeminiFishVisionService.swift
//  Clamera
//
//  Created by Codex on 5/4/26.
//

import Foundation
import UIKit

enum GeminiFishVisionError: Error {
    case invalidImageData
    case invalidURL
    case badResponseStatus(Int)
    case missingResponseText
}

final class GeminiFishVisionService {
    static let shared = GeminiFishVisionService()

    private let apiKey = "AIzaSyC_v7VlUertFNmRVQudG2t27fy3lyWHghw"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func detectFishName(from image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw GeminiFishVisionError.invalidImageData
        }

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
            throw GeminiFishVisionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody(base64Image: imageData.base64EncodedString()))

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiFishVisionError.badResponseStatus(-1)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
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

        return cleaned
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
