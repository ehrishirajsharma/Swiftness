import Cocoa

private extension NSImage.Name {
    static let target = NSImage.Name("ic_target")
    static let library = NSImage.Name("ic_library")
    static let checkedBox = NSImage.Name("check_box_selected")
    static let emptyBox = NSImage.Name("check_box_unselected")
    static let link = NSImage.Name(rawValue: "link")
}

extension NSImage {
    static var target: NSImage { return NSImage(named: .target)! }
    static var library: NSImage { return NSImage(named: .library)! }
    static var checkedBox: NSImage { return NSImage(named: .checkedBox)! }
    static var emptyBox: NSImage { return NSImage(named: .emptyBox)! }
    static var statusBar: NSImage { return NSImage(named: .link)! }
}
