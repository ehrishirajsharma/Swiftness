import Cocoa

class StatusBarViewController: NSViewController, Copyable {

    // MARK: - Properties
    weak var delegate: MainWindowDelegate!
    var templateManager: TemplateManager! {
        didSet {
            templates = templateManager.templates
            tableView?.reloadData()
        }
    }
    
    private var templates: Templates!

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: NSTableView!

    // MARK: - IBActions
    @IBAction func showEditor(_ sender: Any) {
        delegate.showMainWindow()
    }

    @IBAction func copyTemplate(_ sender: NSButton) {
        let template = templates[sender.tag]
        copyToPasteboard(template.content)
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        addTrackingArea()
    }
}

// MARK: - TableView Data Source
extension StatusBarViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return templates.count
    }
}

// MARK: - TableView Delegate
extension StatusBarViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: StatusBarTemplateCellView.identifier,
                                            owner: nil) as? StatusBarTemplateCellView
        else { return nil }

        cell.titleTextField.stringValue = templates[row].title
        cell.copyButton.tag = row

        return cell
    }

    // For white background on selection
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return RowView()
    }
}

// MARK: - TextField Delegate
extension StatusBarViewController: NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }

        templates = templateManager.filteredTemplates(textField.stringValue.lowercased())
        tableView.reloadData()
    }

}

// MARK: - Tracking Areas
extension StatusBarViewController {

    override func mouseMoved(with event: NSEvent) {
        let mouseLocation = event.locationInWindow

        let viewLocation = tableView.convert(mouseLocation, from: nil)
        let row = tableView.row(at: viewLocation)
        if row != tableView.selectedRow {
            tableView.deselectAll(nil)
        }
        tableView.selectRowIndexes([row], byExtendingSelection: true)
    }

    override func mouseExited(with event: NSEvent) {
        tableView.deselectAll(nil)
    }

    func addTrackingArea() {
        let trackingOptions: NSTrackingArea.Options = [.mouseMoved, .activeAlways, .mouseEnteredAndExited]
        let trackingArea = NSTrackingArea(rect: tableView.visibleRect, options: trackingOptions, owner: self, userInfo: nil)
        tableView.addTrackingArea(trackingArea)
    }
    
}
