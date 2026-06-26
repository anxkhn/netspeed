import AppKit

@MainActor
final class FontPickerController: NSObject {
    static let shared = FontPickerController()

    private override init() { super.init() }

    func show() {
        let manager = NSFontManager.shared
        manager.target = self
        manager.action = #selector(changeFont(_:))
        manager.setSelectedFont(MenuBarFont.nsFont(size: CGFloat(UserDefaults.standard.double(forKey: AppDefaults.menuBarFontSize))), isMultiple: false)
        manager.orderFrontFontPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func changeFont(_ sender: NSFontManager) {
        let current = MenuBarFont.nsFont(size: CGFloat(UserDefaults.standard.double(forKey: AppDefaults.menuBarFontSize)))
        let converted = sender.convert(current)
        UserDefaults.standard.set(MenuBarFontMode.custom.rawValue, forKey: AppDefaults.menuBarFontMode)
        UserDefaults.standard.set(converted.fontName, forKey: AppDefaults.menuBarFontName)
        UserDefaults.standard.set(Double(converted.pointSize), forKey: AppDefaults.menuBarFontSize)
    }
}
