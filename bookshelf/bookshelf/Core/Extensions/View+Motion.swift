//
//  View+Motion.swift
//  bookshelf
//

import SwiftUI

extension View {
    /// Like `.animation(_:value:)`, but without animation when the user turned on **Reduce Motion**
    /// (Settings > Accessibility > Motion). Use it instead of a bare `.animation` or `withAnimation`
    /// for everything that moves, scales or slides.
    func animationRespectingReduceMotion(_ animation: Animation? = .snappy, value: some Equatable) -> some View {
        modifier(ReduceMotionAnimation(animation: animation, value: value))
    }
}

extension View {
    /// Like `.contentTransition(_:)`, but without the transition when the user turned on **Reduce Motion**.
    func contentTransitionRespectingReduceMotion(_ transition: ContentTransition = .numericText()) -> some View {
        modifier(ReduceMotionContentTransition(transition: transition))
    }
}

private struct ReduceMotionContentTransition: ViewModifier {
    let transition: ContentTransition

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.contentTransition(reduceMotion ? .identity : transition)
    }
}

private struct ReduceMotionAnimation<Value: Equatable>: ViewModifier {
    let animation: Animation?
    let value: Value

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}
