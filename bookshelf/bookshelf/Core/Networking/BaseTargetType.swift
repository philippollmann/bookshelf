//
//  BaseTargetType.swift
//  bookshelf
//

import Foundation

/// Defaults shared by all endpoints of this app. A second backend would get its own
/// base protocol (e.g. `WeatherTargetType`) with a different `baseURL`.
protocol BaseTargetType: NetworkTargetType {}

extension BaseTargetType {
    var baseURL: URL {
        Configuration.booksApiURL
    }

    var headers: [String: String]? {
        nil
    }
}
