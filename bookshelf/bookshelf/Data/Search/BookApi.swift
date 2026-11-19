//
//  BookApi.swift
//  bookshelf
//
//  The "service" layer: one enum per backend area that only describes endpoints.
//  No state and no logic, that belongs into the repository.
//

import Foundation

enum BookApi {
    case search(query: String)
}

extension BookApi: BaseTargetType {
    var path: String {
        switch self {
        case .search:
            "search.json"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .search:
            .GET
        }
    }

    var task: NetworkTask {
        switch self {
        case let .search(query):
            return .requestParameters([
                "q": query,
                "limit": String(Configuration.searchLimit),
                "fields": "key,title,author_name,first_publish_year,number_of_pages_median,cover_i",
            ])
        }
    }
}
