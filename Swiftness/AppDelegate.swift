import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    let templateManager = TemplateManager()
    
    private lazy var statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.action = #selector(togglePopover)
        return statusItem
    }()

    private lazy var popover: NSPopover = {
        let popover = NSPopover()
        let statusBarViewController = NSStoryboard.statusBarViewController()
        statusBarViewController?.delegate = self
        popover.contentViewController = statusBarViewController
        popover.behavior = .transient
        return popover
    }()

    // When the popover is shown, click outside will close the popover
    private lazy var eventMonitor: EventMonitor = {
        let eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown] ) { [unowned self] event in
            guard event?.window != self.popover.contentViewController?.view.window else { return }
            if self.popover.isShown {
                self.closePopover()
            }
        }
        return eventMonitor
    }()

    // MARK: - Overrides
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        hideMainWindow()
        statusItem.button?.image = NSImage(named: NSImage.Name(rawValue: "link"))
    }

}

// MARK: - MainWindowDelegate
extension AppDelegate: MainWindowDelegate {

    func hideMainWindow() {
        NSApp.hide(nil)
        NSApp.setActivationPolicy(.accessory)
    }

    func showMainWindow() {
        if NSApp.isHidden {
            NSApp.setActivationPolicy(.regular)
        }
        closePopover()
        NSApp.activate(ignoringOtherApps: true)
    }

}

// MARK: - Public methods
extension AppDelegate {

    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

}

// MARK: - Private methods
private extension AppDelegate {

    // MARK: Popover
    func showPopover() {
        guard let statusItemButton = statusItem.button else { return }

        (popover.contentViewController as? StatusBarViewController)?.templateManager = templateManager

        if !NSApp.isHidden {
            NSApp.activate(ignoringOtherApps: true)
        }
        
        popover.show(relativeTo: .zero, of: statusItemButton, preferredEdge: NSRectEdge.minY)
        eventMonitor.start()
    }

    func closePopover() {
        eventMonitor.stop()
        popover.performClose(self)
    }

}
