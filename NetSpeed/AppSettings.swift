import Foundation
import SwiftUI

enum SpeedUnit: String, CaseIterable, Identifiable {
    case autoBytes
    case bytes
    case kilobytes
    case megabytes
    case gigabytes
    case autoBits
    case bits
    case kilobits
    case megabits
    case gigabits

    var id: Self { self }
    var title: String {
        switch self {
        case .autoBytes: "Auto bytes"
        case .bytes: "B/s"
        case .kilobytes: "KB/s"
        case .megabytes: "MB/s"
        case .gigabytes: "GB/s"
        case .autoBits: "Auto bits"
        case .bits: "bps"
        case .kilobits: "Kbps"
        case .megabits: "Mbps"
        case .gigabits: "Gbps"
        }
    }

    var isBitBased: Bool {
        switch self {
        case .autoBits, .bits, .kilobits, .megabits, .gigabits: true
        case .autoBytes, .bytes, .kilobytes, .megabytes, .gigabytes: false
        }
    }
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

enum MenuBarArrowPosition: String, CaseIterable, Identifiable {
    case left
    case right

    var id: Self { self }
    var title: String {
        switch self {
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
    static let menuBarArrowPosition = "menuBarArrowPosition"
    static let showUnitLabels = "showUnitLabels"
    static let menuBarFontMode = "menuBarFontMode"
    static let menuBarFontName = "menuBarFontName"
    static let menuBarFontSize = "menuBarFontSize"
    static let stabilizeMenuBarWidth = "stabilizeMenuBarWidth"
    static let smoothMenuBarTransitions = "smoothMenuBarTransitions"
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
            AppDefaults.unit: SpeedUnit.autoBytes.rawValue,
            AppDefaults.menuBarLayout: MenuBarLayout.stacked.rawValue,
            AppDefaults.menuBarArrowPosition: MenuBarArrowPosition.left.rawValue,
            AppDefaults.showUnitLabels: true,
            AppDefaults.menuBarFontMode: MenuBarFontMode.condensed.rawValue,
            AppDefaults.menuBarFontName: "",
            AppDefaults.menuBarFontSize: 10.0,
            AppDefaults.stabilizeMenuBarWidth: true,
            AppDefaults.smoothMenuBarTransitions: true,
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
