import Combine
import Foundation
import WatchConnectivity

@MainActor
final class WatchSessionManager: NSObject, ObservableObject {

    static let shared = WatchSessionManager()

    @Published private(set) var isPaired = false
    @Published private(set) var isWatchAppInstalled = false
    @Published private(set) var isReachable = false

    var isConnected: Bool {
        isPaired && isWatchAppInstalled && isReachable
    }

    var statusMessage: String {
        guard WCSession.isSupported() else { return "Not Supported" }
        if !isPaired { return "Watch Disconnected" }
        if !isWatchAppInstalled { return "App Not Installed" }
        if !isReachable { return "Watch Disconnected" }
        return "Watch Connected"
    }

    var openWatchInstructionsMessage: String {
        if !isPaired {
            return "Pair your Apple Watch using the Watch app on this iPhone, then return here."
        }
        if !isWatchAppInstalled {
            return "Install MotionDetector on your Apple Watch from the Watch app, then open it on your watch."
        }
        return "Open MotionDetector on your Apple Watch and keep it running while you play."
    }

    // Dictionary tetap private, diisolasi secara otomatis oleh @MainActor
    private var messageHandlers: [UUID: ([String: Any]) -> Void] = [:]
    
    // NSLock DIHAPUS karena @MainActor sudah menjamin thread-safety

    var session: WCSession { WCSession.default }

    private override init() {
        super.init()
        activate()
    }

    func activate() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        if session.delegate !== self {
            session.delegate = self
        }
        if session.activationState != .activated {
            session.activate()
        }
        refreshStatus()
    }

    func refreshStatus() {
        guard WCSession.isSupported() else {
            isPaired = false
            isWatchAppInstalled = false
            isReachable = false
            return
        }

        let session = WCSession.default
        isPaired = session.isPaired
        isWatchAppInstalled = session.isWatchAppInstalled
        isReachable = session.isReachable
    }

    @discardableResult
    func registerMessageHandler(_ handler: @escaping ([String: Any]) -> Void) -> UUID {
        let id = UUID()
        // Aman dieksekusi karena otomatis berjalan di MainActor
        messageHandlers[id] = handler
        return id
    }

    // Kata kunci 'nonisolated' DIHAPUS agar fungsinya berjalan di MainActor
    func unregisterMessageHandler(_ id: UUID) {
        messageHandlers.removeValue(forKey: id)
    }

    func requestWatchAppLaunch() {
        activate()

        guard isPaired else { return }

        if isWatchAppInstalled, session.isReachable == false {
            session.sendMessage(["command": "wake"], replyHandler: nil, errorHandler: nil)
        }
    }
}

extension WatchSessionManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.refreshStatus()
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.refreshStatus()
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in
            self.refreshStatus()
        }
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
        Task { @MainActor in
            self.refreshStatus()
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Akses messageHandlers secara aman dengan melompat ke MainActor menggunakan Task
        Task { @MainActor in
            self.messageHandlers.values.forEach { $0(message) }
        }
    }
}
