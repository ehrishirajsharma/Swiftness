import Cocoa

class ExportViewController: NSViewController {

    var dataManager: DataManager? {
        didSet {
            if dataManager != nil {
                targetsTableView.reloadData()
                librariesTableView.reloadData()
            }
        }
    }

    var targetIndexes = Set<Int>()
    var libraryIndexes = Set<Int>()
    
    @IBOutlet weak var targetsTableView: NSTableView!
    @IBOutlet weak var librariesTableView: NSTableView!
    @IBOutlet weak var selectAllTargetsButton: NSButton!
    @IBOutlet weak var selectAllLibrariesButton: NSButton!
    @IBOutlet weak var exportButton: NSButton!

    @IBAction func changeTargetsState(_ sender: NSButton) {
        let index = sender.tag
        if targetIndexes.contains(index) {
            targetIndexes.remove(index)
        } else {
            targetIndexes.insert(index)
        }
        if targetIndexes.isEmpty {
            selectAllTargetsButton.state = .off
        } else if targetIndexes.count == dataManager?.targets.count {
            selectAllTargetsButton.state = .on
        } else {
            selectAllTargetsButton.allowsMixedState = true
            selectAllTargetsButton.state = .mixed
        }
        updateExportButton()
    }

    @IBAction func changeLibrariesState(_ sender: NSButton) {
        let index = sender.tag
        if libraryIndexes.contains(index) {
            libraryIndexes.remove(index)
        } else {
            libraryIndexes.insert(index)
        }
        if libraryIndexes.isEmpty {
            selectAllLibrariesButton.state = .off
        } else if libraryIndexes.count == dataManager?.libraries.count {
            selectAllLibrariesButton.state = .on
        } else {
            selectAllLibrariesButton.allowsMixedState = true
            selectAllLibrariesButton.state = .mixed
        }
        updateExportButton()
    }

    @IBAction func selectAllTargets(_ sender: NSButton) {
        selectAllTargetsButton.allowsMixedState = false
        if sender.state == .on {
            targetIndexes = Set(0..<dataManager!.targets.count)
            targetsTableView.reloadData()
        } else if sender.state == .off {
            targetIndexes.removeAll()
            targetsTableView.reloadData()
        }
        updateExportButton()
    }

    @IBAction func selectAllLibraries(_ sender: NSButton) {
        selectAllLibrariesButton.allowsMixedState = false
        if sender.state == .on {
            libraryIndexes = Set(0..<dataManager!.libraries.count)
            librariesTableView.reloadData()
        } else if sender.state == .off {
            libraryIndexes.removeAll()
            librariesTableView.reloadData()
        }
        updateExportButton()
    }

    @IBAction func cancel(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!)
    }

    @IBAction func export(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = [DataManager.fileExtension]
        savePanel.allowsOtherFileTypes = false
        savePanel.nameFieldStringValue = DataManager.defaultFileName
        savePanel.begin { (result) -> Void in
            guard result == NSApplication.ModalResponse.OK else { return }
            let targets = self.targetIndexes.map { self.dataManager!.targets[$0] }
            let libraries = self.libraryIndexes.map { self.dataManager!.libraries[$0] }
            self.dataManager!.save(targets: targets, libraries: libraries, url: savePanel.url!)
            self.cancel(self)
        }
    }

    override func viewDidLoad() {
        exportButton.isHighlighted = true
    }

}

extension ExportViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView === targetsTableView {
            return dataManager?.targets.count ?? 0
        } else {
            return dataManager?.libraries.count ?? 0
        }
    }

}

extension ExportViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckBoxCell"), owner: self) as! CheckBoxCellView
        if tableView === targetsTableView {
            let target = dataManager!.targets[row]
            view.textField?.stringValue = target.title
            view.button.state = targetIndexes.contains(row) ? .on : .off
        } else {
            let library = dataManager!.libraries[row]
            view.textField?.stringValue = library.title
            view.button.state = libraryIndexes.contains(row) ? .on : .off
        }
        view.button.tag = row
        return view
    }

}

private extension ExportViewController {

    func updateExportButton() {
        exportButton.isEnabled = (!targetIndexes.isEmpty) || (!libraryIndexes.isEmpty)
    }

}
