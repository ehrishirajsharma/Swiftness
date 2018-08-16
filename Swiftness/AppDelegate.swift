import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties
    let dataManager = DataManager()
    
    private lazy var statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.action = #selector(togglePopover)
        return statusItem
    }()

    private lazy var popover: NSPopover = {
        let popover = NSPopover()
        let statusBarViewController = NSStoryboard.statusBarViewController
        statusBarViewController.mainWindowDelegate = self
        statusBarViewController.dataManager = dataManager
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

    var mainWindowController: WindowController {
        return NSApplication.shared.mainWindow?.windowController as! WindowController
    }

    @IBAction func export(_ sender: Any) {
        let windowController = NSStoryboard.exportWindowController
        let viewController = windowController.contentViewController as! ExportViewController
        viewController.dataManager = dataManager
        NSApplication.shared.mainWindow?.beginSheet(windowController.window!)
    }

    @IBAction func `import`(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = [DataManager.fileExtension]
        openPanel.allowsOtherFileTypes = false
        openPanel.begin { result in 
            guard result == .OK else { return }
            self.dataManager.load(url: openPanel.url!)
            self.mainWindowController.dataManager = self.dataManager
        }
    }

    // MARK: - Overrides
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController.dataManager = dataManager
        hideMainWindow()
        statusItem.button?.image = NSImage.statusBar
    }

}

// MARK: - MainWindowDelegate
extension AppDelegate: MainWindowDelegate {

    func hideMainWindow() {
        NSApp.setActivationPolicy(.accessory)
    }

    func showMainWindow() {
        if NSApp.isHidden {
            NSApp.setActivationPolicy(.regular)
        }
        closePopover()
        dirtyHackToUnfreezeMenu()
    }

    func dirtyHackToUnfreezeMenu() {
        if (NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first?.activate(options: []))! {
            let deadlineTime = DispatchTime.now() + .milliseconds(200)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
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
