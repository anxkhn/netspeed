import Foundation
import SwiftUI

enum SpeedUnit: String, CaseIterable, Identifiable {
    case bytes
    case bits

    var id: Self { self }
    var title: String { self == .bytes ? "Bytes/s" : "Bits/s" }
}

enum MenuBarLayout: String, CaseIterable, Identifiable {
    case stacked
    case compact
    case downloadOnly

    var id: Self { self }
    var title: String {
        switch self {
        case .stacked: "Stacked"
        case .compact: "Compact"
        case .downloadOnly: "Download only"
        }
    }
}

enum MenuBarIconPosition: String, CaseIterable, Identifiable {
    case hidden
    case left
    case right

    var id: Self { self }
    var title: String {
        switch self {
        case .hidden: "Hidden"
        case .left: "Left"
        case .right: "Right"
        }
    }
}

enum SurfaceStyle: String, CaseIterable, Identifiable {
    case system
    case transparent
    case opaque

    var id: Self { self }
    var title: String {
        switch self {
        case .system: "System"
        case .transparent: "Transparent"
        case .opaque: "Opaque"
        }
    }
}

enum MenuBarFontMode: String, CaseIterable, Identifiable {
    case system
    case condensed
    case monospaced
    case custom

    var id: Self { self }
    var title: String {
        switch self {
        case .system: "System"
        case .condensed: "Condensed"
        case .monospaced: "Monospaced"
        case .custom: "Custom"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }
    var title: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AppDefaults {
    static let unit = "unit"
    static let menuBarLayout = "menuBarLayout"
    static let menuBarIconPosition = "menuBarIconPosition"
    static let showUnitLabels = "showUnitLabels"
    static let menuBarFontMode = "menuBarFontMode"
    static let menuBarFontName = "menuBarFontName"
    static let menuBarFontSize = "menuBarFontSize"
    static let menuBarCondensedWidth = "menuBarCondensedWidth"
    static let surfaceStyle = "surfaceStyle"
    static let onboardingCompleted = "onboardingCompleted"
    static let showInterfaceName = "showInterfaceName"
    static let showPublicIP = "showPublicIP"
    static let alertEnabled = "alertEnabled"
    static let downloadAlertMBps = "downloadAlertMBps"
    static let uploadAlertMBps = "uploadAlertMBps"
    static let sampleInterval = "sampleInterval"
    static let historyRetentionDays = "historyRetentionDays"
    static let appTheme = "appTheme"
    static let accentColorName = "accentColorName"
}

extension UserDefaults {
    static func registerNetSpeedDefaults() {
        standard.register(defaults: [
            AppDefaults.unit: SpeedUnit.bytes.rawValue,
            AppDefaults.menuBarLayout: MenuBarLayout.stacked.rawValue,
            AppDefaults.menuBarIconPosition: MenuBarIconPosition.hidden.rawValue,
            AppDefaults.showUnitLabels: true,
            AppDefaults.menuBarFontMode: MenuBarFontMode.condensed.rawValue,
            AppDefaults.menuBarFontName: "",
            AppDefaults.menuBarFontSize: 9.0,
            AppDefaults.menuBarCondensedWidth: 0.82,
            AppDefaults.surfaceStyle: SurfaceStyle.system.rawValue,
            AppDefaults.onboardingCompleted: false,
            AppDefaults.showInterfaceName: true,
            AppDefaults.showPublicIP: false,
            AppDefaults.alertEnabled: false,
            AppDefaults.downloadAlertMBps: 50.0,
            AppDefaults.uploadAlertMBps: 10.0,
            AppDefaults.sampleInterval: 1.0,
            AppDefaults.historyRetentionDays: 30,
            AppDefaults.appTheme: AppTheme.system.rawValue,
            AppDefaults.accentColorName: "blue",
        ])
    }
}
