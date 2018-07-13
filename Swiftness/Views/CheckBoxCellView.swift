import Cocoa

class CheckBoxCellView: NSTableCellView {

    @IBOutlet weak var button: NSButton!

    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            textField?.textColor = (backgroundStyle == .light) ? NSColor.black : NSColor.white
        }
    }
}
