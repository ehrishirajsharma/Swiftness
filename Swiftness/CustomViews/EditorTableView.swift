import Cocoa

class EditorTableView: NSTableView {

    override func menu(for event: NSEvent) -> NSMenu? {
        let mouseLocation = event.locationInWindow

        let viewLocation = convert(mouseLocation, from: nil)
        let row = self.row(at: viewLocation)
        return row == -1 ? nil : super.menu(for: event)
    }
    
}
