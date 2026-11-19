//
//  ErrorHandler.swift
//  bookshelf
//

import SwiftUI

extension View {
    /// Shows an alert whenever `error` is set. Bind it to the `error` property of a ViewModel:
    ///
    /// ```swift
    /// .errorHandler($viewModel.error)
    /// ```
    func errorHandler(_ error: Binding<Error?>) -> some View {
        modifier(ErrorHandlerModifier(error: error))
    }
}

private struct ErrorHandlerModifier: ViewModifier {
    @Binding var error: Error?
    @Environment(\.openURL) private var openURL

    private var customError: CustomError? {
        error?.toCustomError()
    }

    func body(content: Content) -> some View {
        content.alert(
            customError?.errorDescription ?? "",
            isPresented: $error.isPresent()
        ) {
            if customError?.opensSettings == true {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(customError?.failureReason ?? "")
        }
    }
}
