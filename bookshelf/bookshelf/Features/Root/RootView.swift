//
//  RootView.swift
//  bookshelf
//

import StoreKit
import SwiftUI

struct RootView<Model: RootViewModel>: View {
    @State var viewModel: Model
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ShelfView(viewModel: ShelfViewModelImpl())
            .onChange(of: viewModel.shouldRequestReview) { _, shouldRequest in
                if shouldRequest {
                    requestReview()
                    viewModel.didRequestReview()
                }
            }
    }
}

#Preview {
    RootView(viewModel: RootViewModelPreview())
}
