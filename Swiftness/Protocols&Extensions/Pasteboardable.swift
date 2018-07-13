import Cocoa

protocol Pasteboardable {
    func copyToPasteboard(_ string: NSAttributedString)
}

extension Pasteboardable {

    func copyToPasteboard(_ string: NSAttributedString) {
        let pasteboard = NSPasteboard.general
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
        let data = try! string.data(from: NSRange(location: 0, length: string.length), documentAttributes: documentAttributes)
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .rtf)
    }
    
}
