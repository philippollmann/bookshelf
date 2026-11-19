//
//  SettingsViewModel.swift
//  bookshelf
//

import Foundation
import Observation

protocol SettingsViewModel: AnyObject, Observable {
    var reminderEnabled: Bool { get }
    var error: Error? { get set }

    func setReminder(enabled: Bool) async
}

@Observable
final class SettingsViewModelImpl: SettingsViewModel {
    private(set) var reminderEnabled = UserDefaults.standard.bool(forKey: Configuration.reminderEnabledKey)
    var error: Error?

    private let notificationManager = NotificationPermissionManager.shared

    func setReminder(enabled: Bool) async {
        if enabled {
            let granted = await notificationManager.enableDailyReminder()
            reminderEnabled = granted
            if !granted {
                error = CustomError.notificationsDisabled
            }
        } else {
            notificationManager.disableDailyReminder()
            reminderEnabled = false
        }
        UserDefaults.standard.set(reminderEnabled, forKey: Configuration.reminderEnabledKey)
    }
}

@Observable
final class SettingsViewModelPreview: SettingsViewModel {
    var reminderEnabled = true
    var error: Error?

    func setReminder(enabled: Bool) async {
        reminderEnabled = enabled
    }
}
