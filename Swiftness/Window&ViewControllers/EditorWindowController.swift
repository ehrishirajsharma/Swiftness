import Cocoa

class EditorWindowController: NSWindowController {

    // MARK: - Properties
    var templateManager: TemplateManager! {
        didSet {
            let viewController = window?.contentViewController as! EditorViewController
            viewController.templateManager = templateManager
        }
    }

    // MARK: - Overrides
    override func windowDidLoad() {
        self.window?.isOpaque = false
        self.window?.backgroundColor = NSColor.clear
    }

}

// MARK: - WindowDelegate
extension EditorWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        (NSApp.delegate as! MainWindowDelegate).hideMainWindow()
        return false
    }
}
