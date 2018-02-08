import Cocoa

class StatusBarTemplateCellView: NSTableCellView {

    static let identifier = NSUserInterfaceItemIdentifier("StatusBarTemplateCellView")

    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var copyButton: NSButton!

    func setSelected(selected: Bool) {
        layer?.backgroundColor = selected ? CGColor.clear : CGColor.white
    }
}
