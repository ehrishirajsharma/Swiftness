import Cocoa

protocol Copyable {
    func copyToPasteboard(_ string: NSAttributedString)
}

extension Copyable {
    func copyToPasteboard(_ string: NSAttributedString) {
        let pasteboard = NSPasteboard.general
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
        let data = try! string.data(from: NSRange(location: 0, length: string.length), documentAttributes: documentAttributes)
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .rtf)
    }
}
