import AppKit
import Foundation

#if canImport(Sparkle)
import Combine
import Sparkle
#endif

@MainActor
final class UpdaterManager: NSObject, ObservableObject {
    static let shared = UpdaterManager()

    @Published var canCheckForUpdates = false

    #if canImport(Sparkle)
    private let controller: SPUStandardUpdaterController
    #endif

    var automaticallyChecksForUpdates: Bool {
        get {
            #if canImport(Sparkle)
            controller.updater.automaticallyChecksForUpdates
            #else
            false
            #endif
        }
        set {
            #if canImport(Sparkle)
            controller.updater.automaticallyChecksForUpdates = newValue
            #endif
        }
    }

    private override init() {
        #if canImport(Sparkle)
        controller = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
        #endif
        super.init()
        #if canImport(Sparkle)
        controller.updater.publisher(for: \.canCheckForUpdates).assign(to: &$canCheckForUpdates)
        #endif
    }

    func start() {
        #if canImport(Sparkle) && !DEBUG
        controller.startUpdater()
        #endif
    }

    func checkForUpdates() {
        #if canImport(Sparkle) && !DEBUG
        AppActivationPolicy.enter()
        controller.checkForUpdates(nil)
        #endif
    }
}
