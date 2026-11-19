//
//  NotificationPermissionManager.swift
//  bookshelf
//

import Foundation
import Observation
import UserNotifications

/// Wraps the notification permission and schedules the daily reading reminder.
@MainActor
@Observable
final class NotificationPermissionManager {
    static let shared = NotificationPermissionManager()

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let reminderIdentifier = "dailyReadingReminder"

    private init() {}

    var isEnabled: Bool {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral: true
        default: false
        }
    }

    func fetchStatus() async {
        authorizationStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Asks for permission (if not asked yet) and schedules a reminder every day at `hour`.
    /// Returns `false` if the user did not allow notifications.
    func enableDailyReminder(hour: Int = 20) async -> Bool {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
        await fetchStatus()
        guard isEnabled else { return false }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time to read")
        content.body = String(localized: "Your books are waiting for you.")
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour), repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        return (try? await center.add(request)) != nil
    }

    func disableDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }
}
