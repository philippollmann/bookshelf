//
//  CustomError.swift
//  bookshelf
//

import Foundation

/// The one error type the UI deals with. Anything a repository throws is turned into a
/// `CustomError` (see `Error.toCustomError()`) by `.errorHandler`, so views never have
/// to know about URLSession, SwiftData or decoding errors.
enum CustomError: LocalizedError {
    case generic
    case notConnectedToInternet
    case serverError(statusCode: Int)
    case invalidImage
    /// The user denied the permission, so only the iOS settings can change it (the alert offers a button).
    case notificationsDisabled

    /// The alert then offers a button to the iOS settings, the only place where the user can fix it.
    var opensSettings: Bool {
        if case .notificationsDisabled = self { true } else { false }
    }

    /// Used as the title of the alert.
    var errorDescription: String? {
        switch self {
        case .generic:
            String(localized: "Something went wrong")
        case .notConnectedToInternet:
            String(localized: "No internet connection")
        case .serverError:
            String(localized: "Server error")
        case .invalidImage:
            String(localized: "Image not usable")
        case .notificationsDisabled:
            String(localized: "Notifications are off")
        }
    }

    /// Used as the message of the alert.
    var failureReason: String? {
        switch self {
        case .generic:
            String(localized: "Please try again in a moment.")
        case .notConnectedToInternet:
            String(localized: "Please check your connection and try again.")
        case let .serverError(statusCode):
            String(localized: "The server answered with status \(statusCode).")
        case .invalidImage:
            String(localized: "Please pick a different photo.")
        case .notificationsDisabled:
            String(localized: "Allow notifications for Bookshelf in the iOS settings to get a daily reminder.")
        }
    }
}

extension Error {
    /// Normalizes any error into a `CustomError`.
    func toCustomError() -> CustomError {
        if let customError = self as? CustomError {
            return customError
        }

        if let networkError = self as? NetworkError {
            switch networkError {
            case let .statusCode(response):
                return .serverError(statusCode: response.statusCode)
            case let .underlying(underlyingError):
                return underlyingError.toCustomError()
            default:
                return .generic
            }
        }

        let nsError = self as NSError
        if nsError.domain == NSURLErrorDomain,
           nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorInternationalRoamingOff
        {
            return .notConnectedToInternet
        }

        return .generic
    }
}
