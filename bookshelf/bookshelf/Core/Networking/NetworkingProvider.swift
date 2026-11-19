//
//  NetworkingProvider.swift
//  bookshelf
//

import Foundation
import os

/// Generic provider that performs the requests described by a `NetworkTargetType`.
///
/// ```swift
/// private let provider = NetworkingProvider<BookApi>()
/// let response: BookSearchResponse = try await provider.request(.search(query: "dune"))
/// ```
final class NetworkingProvider<Target: NetworkTargetType> {
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - Public API

    /// Performs the request and decodes the response body.
    func request<Response: Decodable>(_ target: Target) async throws -> Response {
        let response = try await perform(target)

        do {
            return try decoder.decode(Response.self, from: response.data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    /// Performs the request and ignores the response body.
    func requestVoid(_ target: Target) async throws {
        _ = try await perform(target)
    }

    // MARK: - Request execution

    private func perform(_ target: Target) async throws -> NetworkResponse {
        let urlRequest = try buildURLRequest(for: target)
        Logger.network.debug("➡️ \(target.method.rawValue) \(urlRequest.url?.absoluteString ?? "")")

        let data: Data
        let urlResponse: URLResponse
        do {
            (data, urlResponse) = try await session.data(for: urlRequest)
        } catch {
            Logger.network.error("❌ \(error.localizedDescription)")
            throw NetworkError.underlying(error)
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        let response = NetworkResponse(data: data, statusCode: httpResponse.statusCode)
        Logger.network.debug("⬅️ \(response.statusCode) \(urlRequest.url?.absoluteString ?? "")")

        guard response.isSuccessful else {
            throw NetworkError.statusCode(response)
        }
        return response
    }

    private func buildURLRequest(for target: Target) throws -> URLRequest {
        var components = URLComponents(url: target.baseURL.appendingPathComponent(target.path), resolvingAgainstBaseURL: false)
        var body: Data?

        switch target.task {
        case .requestPlain:
            break
        case let .requestParameters(parameters):
            components?.queryItems = parameters
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        case let .request(encodable):
            body = try encoder.encode(AnyEncodable(encodable))
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.method.rawValue
        urlRequest.httpBody = body
        if body != nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        for (key, value) in target.headers ?? [:] {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }
}

/// Lets us encode an `Encodable` that is only known as an existential.
private struct AnyEncodable: Encodable {
    let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension Logger {
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier ?? "bookshelf", category: "network")
}
