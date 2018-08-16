import Cocoa

extension NSPasteboardItem {

    func rowIndex(forType pasteboardType: NSPasteboard.PasteboardType) -> Int? {
        guard let pasteboardData = data(forType: pasteboardType) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: pasteboardData) as? Int
    }

    func setRowIndex(_ rowIndex: Int, forType pasteboardType: NSPasteboard.PasteboardType) {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndex)
        setData(data, forType: pasteboardType)
    }
    
}
