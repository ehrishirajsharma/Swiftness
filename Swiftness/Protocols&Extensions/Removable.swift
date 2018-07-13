import AppKit

protocol Removable {
    func showRemoveDialog()
    func removeCurrentItem()
}

extension Removable where Self: NSViewController {

    func showRemoveDialog() {
        let alert = NSAlert()
        alert.messageText = "Remove item?"
        alert.informativeText = "Are you sure you would like to delete the item?"
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = NSAlert.Style.warning

        alert.beginSheetModal(for: view.window!) { modalResponse in
            if modalResponse == .alertFirstButtonReturn {
                self.removeCurrentItem()
            }
        }
    }
}
