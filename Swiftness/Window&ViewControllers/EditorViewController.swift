import Cocoa

class EditorViewController: NSViewController, Copyable {

    // MARK: - Properties
    var templateManager: TemplateManager! {
        didSet {
            templates = templateManager.templates
            tableView?.reloadData()
        }
    }

    private var templates: Templates!
    private var editingRow: Int?

    // MARK: - IBOutlets
    @IBOutlet var contentTextView: NSTextView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var box: NSBox!

    // MARK: - IBActions
    @IBAction func createNewTemplate(_ sender: Any) {
        templateManager.createNewTemplate()
        templates = templateManager.templates
        tableView.insertRows(at: [0], withAnimation: .slideLeft)
    }

    @IBAction func deleteTemplate(_ sender: NSMenuItem) {
        let row = tableView.clickedRow
        guard row != -1 else { return }

        let template = templates[row]
        templateManager.templates = self.templateManager.templates.filter { $0 !== template }
        templates.remove(at: row)
        if tableView.selectedRow == row {
            clearInputs()
        }
        tableView.removeRows(at: [row], withAnimation: NSTableView.AnimationOptions.slideLeft)
    }

    @IBAction func copyTemplate(_ sender: Any) {
        copyToPasteboard(contentTextView.attributedString())
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        templateManager = (NSApp.delegate as? AppDelegate)!.templateManager

        box.superview?.wantsLayer = true

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSize(width: 2.0, height: -2.0)
        shadow.shadowColor = NSColor.init(white: 0.0, alpha: 0.5)

        box.shadow = shadow
    }

    override func viewWillDisappear() {
        templateManager.save()
    }
}

// MARK: - TableView Data Source
extension EditorViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return templates.count
    }

}

// MARK: - TableView Delegate
extension EditorViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: EditorTemplateCellView.identifier,
                                            owner: nil) as? EditorTemplateCellView
        else { return nil }

        cell.titleTextField.stringValue = templates[row].title

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else {
            editingRow = nil
            clearInputs()
            return
        }
        editingRow = tableView.selectedRow
        let template =  templates[tableView.selectedRow]
        titleTextField.stringValue = template.title
        contentTextView.layoutManager?.replaceTextStorage(NSTextStorage(attributedString: template.content))
    }

    // For white background on selection
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return RowView()
    }

}

// MARK: - TextField Delegate
extension EditorViewController: NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }

        if textField === titleTextField {
            update(title: textField.stringValue)
        } else {
            filter(string: textField.stringValue)
        }
    }

    func update(title: String) {
        guard let index = editingRow else { return }

        templates[index].title = title
        tableView.reloadData(forRowIndexes: [index], columnIndexes: [0])
    }

    func filter(string: String) {
        templates = templateManager.filteredTemplates(string.lowercased())
        tableView.reloadData()
    }

}

// MARK: - TextView Delegate
extension EditorViewController: NSTextViewDelegate {

    func textDidChange(_ notification: Notification) {
        guard
            let textView = notification.object as? NSTextView,
            let index = editingRow
        else { return }

        templates[index].content = textView.attributedString()
    }
}


// MARK: - Tracking Areas
extension EditorViewController {

    override func mouseMoved(with event: NSEvent) {
        let mouseLocation = event.locationInWindow

        let viewLocation = tableView.convert(mouseLocation, from: nil)
        let row = tableView.row(at: viewLocation)
        if row != -1 && row != tableView.selectedRow {
            tableView.deselectAll(nil)
        }
        tableView.selectRowIndexes([row], byExtendingSelection: true)
    }

    func addTrackingArea() {
        let trackingOptions: NSTrackingArea.Options = [.mouseMoved, .activeAlways]
        let trackingArea = NSTrackingArea(rect: view.bounds, options: trackingOptions, owner: self, userInfo: nil)
        tableView.addTrackingArea(trackingArea)
    }

}

// MARK: - Private methods
private extension EditorViewController {

    func clearInputs() {
        titleTextField.stringValue = ""
        contentTextView.string = ""
    }

}
