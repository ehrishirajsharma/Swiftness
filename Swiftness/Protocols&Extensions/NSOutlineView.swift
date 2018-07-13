import Cocoa

extension NSOutlineView {

    var selectedItem: Any? {
        return item(atRow: selectedRow)
    }
    
}
