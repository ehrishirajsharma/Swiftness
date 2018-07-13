import Cocoa

protocol FolderViewControllerDelegate: class {
    func editableDidChange(editable: Editable?)
    func wasChanges()
}

class FolderViewController: NSViewController {

    private var folder: Folder? {
        didSet {
            reloadSource()
        }
    }
    private var showAsLibrary = true
    private var data: [Editable]?
    private var filteredData: [Editable]?

    weak var delegate: FolderViewControllerDelegate!

    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBAction func sourceDidChange(_ sender: NSSegmentedControl) {
        reloadSource()
        delegate.editableDidChange(editable: nil)
    }

    @IBAction func addItem(_ sender: Any) {
        switch segmentedControl.selectedSegment {
        case 0: folder?.addNewTemplate()
        case 1: folder?.addNewCheckListItem()
        case 2: folder?.addNewNote()
        default: break
        }
        delegate.wasChanges()
        reloadSource()
    }

    @IBAction func filterDidChange(_ sender: NSSearchField) {
        filterDataAndReload()
    }

    @IBAction func changeDoneState(_ sender: NSButton) {
        guard let data = filteredData, let checkListItem = data[sender.tag] as? CheckListItem else { return }
        checkListItem.done = sender.state == .on
        delegate.wasChanges()
    }
    
    // MARK: - Overrides
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func deleteBackward(_ sender: Any?) {
        showRemoveDialog()
    }
}

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

extension FolderViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredData?.count ?? 0
    }

}

extension FolderViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let data = filteredData else { return nil }

        if
            segmentedControl.indexOfSelectedItem == 1,
            !showAsLibrary,
            let checkListItem = data[row] as? CheckListItem
        {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckBoxCell"), owner: self) as! CheckBoxCellView
            view.textField?.stringValue = checkListItem.title
            view.button.state = checkListItem.done ? .on : .off
            view.button.tag = row
            return view
        } else {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: self) as! NSTableCellView
            view.textField?.stringValue = data[row].title
            return view
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            let item = filteredData?[tableView.selectedRow]
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

private extension FolderViewController {

    func reloadSource() {
        if let folder = folder {
            switch segmentedControl.indexOfSelectedItem {
            case 0:
                data = folder.templates
            case 1:
                data = folder.checklist
            case 2:
                data = folder.notes
            default:
                break
            }
        } else {
            data = nil
        }

        filterDataAndReload()
    }

    func filterDataAndReload() {
        guard let data = data else { return }
        let search = searchField.stringValue.lowercased()
        if search.count > 0 {
            filteredData = data.filter {
                $0.title.lowercased().contains(search) || $0.content.string.lowercased().contains(search)
            }
        } else {
            filteredData = data
        }
        tableView.reloadData()
    }
}

extension FolderViewController: Removable {

    func removeCurrentItem() {
        guard tableView.selectedRow >= 0 else { return }

        let editable = filteredData![tableView.selectedRow]
        let index = folder!.remove(editable)!
        filteredData?.remove(at: tableView.selectedRow)
        tableView.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
        delegate.wasChanges()
    }
}
