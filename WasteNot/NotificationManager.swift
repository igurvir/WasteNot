import UserNotifications
import Foundation

// Function to get current time in Toronto time zone
func currentTimeInToronto() -> Date {
    let timeZone = TimeZone(identifier: "America/Toronto") ?? TimeZone.current
    let currentTime = Date()
    let timeZoneOffset = TimeInterval(timeZone.secondsFromGMT(for: currentTime))
    return currentTime.addingTimeInterval(timeZoneOffset)
}

// Schedule an immediate notification to inform the user about the expiry date
func scheduleImmediateNotification(for item: FoodItem) {
    let content = UNMutableNotificationContent()
    content.title = "Item Added: \(item.name)"
    content.body = "This item will expire on \(item.expiryDateFormatted())."
    content.sound = .default

    // Trigger the notification immediately
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

    let request = UNNotificationRequest(identifier: "\(item.id.uuidString)-immediate", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling immediate notification: \(error.localizedDescription)")
        } else {
            print("Immediate notification scheduled for \(item.name).")
        }
    }
}

// Schedule a 24-hour reminder notification before the item expires
func scheduleExpiryReminder(for item: FoodItem) {
    let content = UNMutableNotificationContent()
    content.title = "Reminder: \(item.name) is expiring soon!"
    content.body = "Your item will expire in 24 hours on \(item.expiryDateFormatted())."
    content.sound = .default

    let now = currentTimeInToronto()
    let timeIntervalUntilExpiry = item.expiryDate.timeIntervalSince(now)

    // 24-hour notification (only if the expiry date is more than 24 hours away)
    if timeIntervalUntilExpiry > 24 * 60 * 60 {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilExpiry - 24 * 60 * 60, repeats: false)

        let request = UNNotificationRequest(identifier: "\(item.id.uuidString)-24hr", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling 24-hour notification: \(error.localizedDescription)")
            } else {
                print("24-hour notification scheduled for \(item.name).")
            }
        }
    } else {
        print("\(item.name) expires within 24 hours, skipping 24-hour notification.")
    }
}
