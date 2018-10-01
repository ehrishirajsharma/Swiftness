import Cocoa

protocol FolderViewControllerDelegate: class {
    func editableDidChange(editable: Editable?)
    func wasChanges()
}

enum FolderViewControllerError: LocalizedError {
    case folder
    case unknown

    var errorDescription: String {
        switch self {
        case .folder: return "Didn't select folder"
        case .unknown: return "Unknown error"
        }
    }

}

class FolderViewController: NSViewController {

    private let dataType = NSPasteboard.PasteboardType(rawValue: "com.RishirajSharma.Swiftness.Item")

    private var folder: Folder? {
        didSet { updateTableView() }
    }
    private var showAsLibrary = true
    private var filteredData: [Editable] = []

    weak var delegate: FolderViewControllerDelegate!

    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!

    @IBAction func addNewItem(_ sender: Any) {
        guard let folder = folder else { return }

        switch segmentedControl.selectedSegment {
        case 0: folder.templates.append(Template())
        case 1: folder.checklist.append(CheckListItem())
        case 2: folder.notes.append(Note())
        default: break
        }
        delegate.wasChanges()
        updateTableView()
    }

    @IBAction func filterDidChange(_ sender: NSSearchField) {
        updateTableView()
    }

    @IBAction func changeDoneState(_ sender: NSButton) {
        guard let checkListItem = filteredData[sender.tag] as? CheckListItem else { return }

        checkListItem.done = sender.state == .on
        delegate.wasChanges()
    }

    @IBAction func itemTypeDidChange(_ sender: Any) {
        updateTableView()
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        tableView.registerForDraggedTypes([dataType])
        tableView.setDraggingSourceOperationMask([], forLocal: false)
        tableView.setDraggingSourceOperationMask(.move, forLocal: true)
    }

    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func deleteBackward(_ sender: Any?) {
        showRemoveDialog()
    }
}

// MARK: - Public methods
extension FolderViewController {

    func updateView(with folder: Folder?, showAsLibrary: Bool) {
        view.isHidden = false
        self.showAsLibrary = showAsLibrary
        self.folder = folder
        segmentedControl.setEnabled(!showAsLibrary, forSegment: 2)
        if segmentedControl.selectedSegment == 2 && showAsLibrary {
            segmentedControl.setSelected(true, forSegment: 0)
        }
    }

    func resetView() {
        view.isHidden = true
        folder = nil
    }

    func updateCurrentFolder() {
        let index = tableView.selectedRow
        tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 0))
    }

}

// MARK: - TableView Data Source
extension FolderViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredData.count
    }

}

// MARK: - TableView Delegate
extension FolderViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if
            segmentedControl.indexOfSelectedItem == 1,
            !showAsLibrary,
            let checkListItem = filteredData[row] as? CheckListItem
        {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckBoxCell"), owner: self) as! CheckBoxCellView
            view.textField?.stringValue = checkListItem.title
            view.button.state = checkListItem.done ? .on : .off
            view.button.tag = row
            return view
        } else {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: self) as! NSTableCellView
            view.textField?.stringValue = filteredData[row].title
            return view
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            let item = filteredData[tableView.selectedRow]
            delegate.editableDidChange(editable: item)
        } else {
            delegate.editableDidChange(editable: nil)
        }
    }

    // For white background on selection
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return RowView()
    }

}

// MARK: - Draggable
extension FolderViewController {

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard let source = info.draggingPasteboard().pasteboardItems?.first?.rowIndex(forType: dataType) else {
            return false
        }

        do {
            try moveItem(at: source, to: row)
            filteredData.move(at: source, to: row)
            let offset = source < row ? 1 : 0
            tableView.moveRow(at: source, to: row - offset)
            delegate.wasChanges()
            return true
        } catch {
            show(error: error)
            return false
        }
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return dropOperation == .above ? .move : []
    }

    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        guard let rowIndex = rowIndexes.first else { return false }

        let item = NSPasteboardItem()
        item.setRowIndex(rowIndex, forType: dataType)
        pboard.writeObjects([item])
        return true
    }
}

// MARK: - Removable
extension FolderViewController: Removable {

    func removeSelectedRow() {
        guard tableView.selectedRow >= 0 else { return }

        let editable = filteredData[tableView.selectedRow]
        do {
            let index = try removeItem(editable: editable)
            filteredData.remove(at: tableView.selectedRow)
            tableView.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
            delegate.wasChanges()
        } catch {
            show(error: error)
        }
    }

}

// MARK: - Private methods
private extension FolderViewController {

    func removeItem(editable: Editable) throws -> Int {
        guard let folder = folder else { throw FolderViewControllerError.folder }

        switch editable {
        case let template as Template:
            return try folder.templates.remove(template)
        case let checkListItem as CheckListItem:
            return try folder.checklist.remove(checkListItem)
        case let note as Note:
            return try folder.notes.remove(note)
        default:
            throw FolderViewControllerError.unknown
        }
    }

    func moveItem(at source: Int, to destination: Int) throws {
        guard let folder = folder else { throw FolderViewControllerError.folder }

        switch segmentedControl.selectedSegment {
        case 0:
             folder.templates.move(at: source, to: destination)
        case 1:
            folder.checklist.move(at: source, to: destination)
        case 2:
            folder.notes.move(at: source, to: destination)
        default:
            throw FolderViewControllerError.unknown
        }
    }

    func updateTableView() {
        defer { tableView.reloadData() }

        guard let folder = folder else {
            filteredData = []
            return
        }

        let data: [Editable]
        switch segmentedControl.indexOfSelectedItem {
        case 0:
            data = folder.templates
        case 1:
            data = folder.checklist
        case 2:
            data = folder.notes
        default:
            data = []
        }

        let search = searchField.stringValue.lowercased()
        if search.count > 0 {
            filteredData = data.filter {
                $0.title.lowercased().contains(search) || $0.content.string.lowercased().contains(search)
            }
        } else {
            filteredData = data
        }
    }
}
