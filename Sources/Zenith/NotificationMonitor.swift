import Foundation
import UserNotifications
import Combine

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let appIcon: String?
}

class NotificationMonitor: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationMonitor()
    
    @Published var pendingNotifications: [NotificationItem] = []
    @Published var hasUnreadNotifications: Bool = false
    @Published var isAuthorized: Bool = false
    @Published var isEnabled: Bool = false
    
    private var notificationCheckTimer: Timer?
    
    private override init() {
        super.init()
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            setup()
        } else {
            stopMonitoring()
        }
    }
    
    private func setup() {
        guard isEnabled else { return }
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.startMonitoring()
                }
            }
            if granted {
                print("Notification authorization granted")
            }
        }
    }
    
    private func startMonitoring() {
        guard isAuthorized else { return }
        
        notificationCheckTimer?.invalidate()
        notificationCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkPendingNotifications()
        }
        checkPendingNotifications()
    }
    
    private func stopMonitoring() {
        notificationCheckTimer?.invalidate()
        notificationCheckTimer = nil
        pendingNotifications = []
        hasUnreadNotifications = false
    }
    
    private func checkPendingNotifications() {
        guard isAuthorized else { return }
        
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.pendingNotifications = notifications.map { notification in
                    NotificationItem(
                        id: notification.request.identifier,
                        title: notification.request.content.title,
                        body: notification.request.content.body,
                        date: notification.date,
                        appIcon: nil
                    )
                }
                self?.hasUnreadNotifications = !notifications.isEmpty
            }
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.hasUnreadNotifications = true
        }
        completionHandler([])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.hasUnreadNotifications = !(self?.pendingNotifications.isEmpty ?? true)
        }
        completionHandler()
    }
    
    func clearNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        DispatchQueue.main.async { [weak self] in
            self?.pendingNotifications = []
            self?.hasUnreadNotifications = false
        }
    }
}
