//
//  View+Haptic.swift
//  bookshelf
//

import SwiftUI

enum HapticFeedbackType {
    /// A physical tap, e.g. a button landing. Light, medium, heavy, soft or rigid.
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    /// A tick while the user moves through values (stepper, picker, slider).
    case selection
    /// The result of an action: success, warning or error.
    case notification(UINotificationFeedbackGenerator.FeedbackType)
}

extension View {
    /// Plays a haptic whenever `value` changes, so the ViewModel state that changes anyway is the trigger.
    ///
    /// Haptics are an extra signal, never the only one: some people can't feel them or turned them off.
    /// They can't play in the Simulator, test them on a device.
    func hapticFeedback(on value: some Equatable, type: HapticFeedbackType = .impact(.light)) -> some View {
        modifier(HapticFeedbackModifier(value: value, type: type))
    }
}

private struct HapticFeedbackModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let type: HapticFeedbackType

    func body(content: Content) -> some View {
        content.onChange(of: value) {
            play()
        }
    }

    private func play() {
        switch type {
        case let .impact(style):
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case let .notification(feedback):
            UINotificationFeedbackGenerator().notificationOccurred(feedback)
        }
    }
}
