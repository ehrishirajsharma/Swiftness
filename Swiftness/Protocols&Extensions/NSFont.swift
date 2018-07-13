import Cocoa

extension NSFont {

    var isBold: Bool {
        return NSFontManager.shared.traits(of: self).contains(.boldFontMask)
    }
    var isItalic: Bool {
        return NSFontManager.shared.traits(of: self).contains(.italicFontMask)
    }

    static func named(_ name: String) -> NSFont {
        return NSFont(name: name, size: 12) ?? NSFont.systemFont(ofSize: 12)
    }

    func bold(_ value: Bool) -> NSFont {
        return NSFontManager.shared.convert(self, toHaveTrait: value ? .boldFontMask : .unboldFontMask)
    }

    func italic(_ value: Bool) -> NSFont {
        return NSFontManager.shared.convert(self, toHaveTrait: value ? .italicFontMask : .unitalicFontMask)
    }

}
