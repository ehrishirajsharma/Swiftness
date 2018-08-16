import Cocoa

extension NSViewController {

    func show(error: Error) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: "Ok")
        alert.alertStyle = NSAlert.Style.critical

        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
