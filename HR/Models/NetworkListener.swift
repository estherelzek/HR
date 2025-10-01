import Network

final class NetworkListener {
    static let shared = NetworkListener()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkListener")

    var onConnected: (() -> Void)?

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async { self.onConnected?() }
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}
