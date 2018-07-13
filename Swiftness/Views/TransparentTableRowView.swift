import Cocoa

class TransparentTableRowView: NSTableRowView {

    override var isEmphasized: Bool {
        get { return false }
        set {}
    }

}
