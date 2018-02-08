import Cocoa

class HoverButton: NSButton {

    private var trackingArea: NSTrackingArea?
    
    open override func cursorUpdate(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }

    override open func updateTrackingAreas() {
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        let trackingOptions: NSTrackingArea.Options = [.cursorUpdate, .activeAlways]
        trackingArea = NSTrackingArea(rect: bounds, options: trackingOptions, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
}
