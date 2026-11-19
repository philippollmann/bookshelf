//
//  BookshelfApp.swift
//  bookshelf
//

import SwiftUI

@main
struct BookshelfApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: RootViewModelImpl())
        }
    }
}
