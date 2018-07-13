import Cocoa

class WindowController: NSWindowController {

    // MARK: - Properties
    var dataManager: DataManager! {
        didSet {
            let viewController = window?.contentViewController as! SplitViewController
            viewController.dataManager = dataManager
        }
    }

    // MARK: - Overrides
    override func windowDidLoad() {
        //self.window?.isOpaque = false
        //self.window?.backgroundColor = NSColor.clear
    }

}

// MARK: - WindowDelegate
extension WindowController: NSWindowDelegate {

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        (NSApp.delegate as! MainWindowDelegate).hideMainWindow()
        return false
    }
    
}
