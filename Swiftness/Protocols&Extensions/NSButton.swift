import Cocoa

extension NSButton {

    @IBInspectable open var textColor: NSColor? {
        get {
            return attributedTitle.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
        }
        set {
            var attributes = attributedTitle.attributes(at: 0, effectiveRange: nil)
            attributes[.foregroundColor] = newValue ?? NSColor.black
            attributedTitle = NSMutableAttributedString(string: self.title, attributes: attributes)
        }
    }

}
