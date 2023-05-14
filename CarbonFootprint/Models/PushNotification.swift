//
//  Notification.swift
//  CarbonFootprint
//
//  Created by Mac on 7.05.2023.
//

import Foundation
import UserNotifications

struct PushNotification{
    
    func notification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case.denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        }
    }
    
    func dispatchNotification() {
        let identifier = "Daily Messages"
        let title = "Save the WORLD"
        let notificationMessages = [
            "Please pay attention to your carbon footprint and take actions to reduce it. Let's protect our planet together.",
            "Did you know that reducing your meat consumption can greatly reduce your carbon footprint? Try a vegetarian meal today!",
            "Small actions can make a big difference. Remember to turn off lights when you leave a room and unplug electronics when not in use.",
            "Every time you use your car, you contribute to carbon emissions. Consider walking, biking, or taking public transportation to reduce your carbon footprint.",
            "Planting a tree is a great way to offset your carbon footprint. Join a local tree-planting initiative today!",
            "Remember to turn off lights when you leave a room",
            "Consider using public transportation or carpooling",
            "Try reducing meat consumption for a more sustainable diet",
            "Reuse and recycle whenever possible",
            "Unplug electronics when not in use to save energy",
            "Plant a tree to offset your carbon footprint",
            "Choose energy-efficient appliances for your home",
            "Conserve water by taking shorter showers and fixing leaks",
            "Switch to LED light bulbs for greater energy efficiency"
        ]
        let randomIndex = Int.random(in: 0..<notificationMessages.count)
        let body = notificationMessages[randomIndex]
        let hour = 19
        let minute = 45
        
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
}
