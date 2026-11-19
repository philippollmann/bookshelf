//
//  NetworkingTypes.swift
//  bookshelf
//
//  Building blocks of the networking layer. A feature describes its endpoints
//  as an enum conforming to `BaseTargetType` (see `Data/Search/BookApi.swift`),
//  the `NetworkingProvider` knows how to turn such a target into a request.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

/// What a request carries. Add cases (multipart, form-encoded, ...) when you need them.
enum NetworkTask {
    /// No query and no body.
    case requestPlain
    /// Encodes the value as a JSON body.
    case request(Encodable)
    /// Adds the parameters to the URL, e.g. `?q=dune&maxResults=20`.
    case requestParameters([String: String])
}

/// Everything the provider needs to know about one endpoint.
protocol NetworkTargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: NetworkTask { get }
    var headers: [String: String]? { get }
}

struct NetworkResponse {
    let data: Data
    let statusCode: Int

    var isSuccessful: Bool {
        (200 ... 299).contains(statusCode)
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case statusCode(NetworkResponse)
    case decodingError(Error)
    case underlying(Error)
}
