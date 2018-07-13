import Cocoa

class RowView: NSTableRowView {

//    override func drawSelection(in dirtyRect: NSRect) {
//        isEmphasized ? NSColor.white.set() : NSColor.white.set()
//        dirtyRect.fill()
//    }
    override var isEmphasized: Bool {
        set {}
        get { return false }
    }
}
