import Cocoa

protocol SourceViewControllerDelegate: class {
    func sourceDidChange(folder: Folder, isLibrary: Bool)
    func sourceDidReset()
}

class SourceViewController: NSViewController {

    private let targetDataType = NSPasteboard.PasteboardType(rawValue: "com.RishirajSharma.Swiftness.Target")
    private let libraryDataType = NSPasteboard.PasteboardType(rawValue: "com.RishirajSharma.Swiftness.Library")
    private let folderDataType = NSPasteboard.PasteboardType(rawValue: "com.RishirajSharma.Swiftness.Folder")

    // MARK: - Properties
    private var sections = [SourceSection(title: "Targets"), SourceSection(title: "Libraries")]

    private var expandedItem: Any?

    weak var delegate: SourceViewControllerDelegate!
    var dataManager: DataManager! {
        didSet {
            guard dataManager != nil else { return }
            sections[0].data = dataManager.targets
            sections[1].data = dataManager.libraries

            outlineView.beginUpdates()
            outlineView.reloadData()
            outlineView.expandItem(sections[0], expandChildren: false)
            outlineView.expandItem(sections[1], expandChildren: false)
            outlineView.endUpdates()
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet var addMenu: NSMenu!
    @IBOutlet weak var newFolderMenuItem: NSMenuItem!
    @IBOutlet weak var newTargetMenuItem: NSMenuItem!

    // MARK: - IBActions
    @IBAction func showAddMenu(_ sender: NSButton) {
        newFolderMenuItem.isEnabled = outlineView.selectedItem != nil
        newTargetMenuItem.submenu?.removeAllItems()
        let menuItem = NSMenuItem(title: "Empty", action: #selector(newTarget(_:)), keyEquivalent: "")
        menuItem.tag = -1
        newTargetMenuItem.submenu?.addItem(menuItem)
        for (index, library) in dataManager.libraries.enumerated() {
            let menuItem = NSMenuItem(title: library.title, action: #selector(newTarget(_:)), keyEquivalent: "")
            menuItem.tag = index
            newTargetMenuItem.submenu?.addItem(menuItem)
        }
        addMenu.popUp(positioning: nil, at: NSPoint(), in: sender)
    }

    @IBAction func newLibrary(_ sender: Any) {
        dataManager.libraries.append(Library())
        sections[1].data = dataManager.libraries
        insertItem(at: sections[1])
    }

    @IBAction func newFolder(_ sender: Any) {
        switch outlineView.selectedItem {
        case let folder as Folder:
            guard let folderable = outlineView.parent(forItem: folder) as? Folderable else { return }
            folderable.addNewFolder()
            insertFolder(at: folderable)
        case let folderable as Folderable:
            folderable.addNewFolder()
            insertFolder(at: folderable)
        default:
            break
        }
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        outlineView.registerForDraggedTypes([targetDataType, libraryDataType, folderDataType])

        outlineView.setDraggingSourceOperationMask([], forLocal: false)
        outlineView.setDraggingSourceOperationMask(.move, forLocal: true)
    }

    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func deleteBackward(_ sender: Any?) {
        showRemoveDialog()
    }
}

// MARK: - OutlineView DataSource
extension SourceViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return sections[index]
        } else if let section = item as? SourceSection {
            return section.data[index]
        } else if let item = item as? Folderable {
            return item.folders[index]
        } else {
            fatalError("Wants children")
        }
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return sections.count
        } else if let section = item as? SourceSection {
            return section.data.count
        } else if let item = item as? Folderable {
            return item.folders.count
        } else {
            return 0
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case let section as SourceSection:
            return section.data.count > 0
        case let folderable as Folderable:
            return folderable.folders.count > 0
        default:
            return false
        }
    }
}

// MARK: - OtlineView Delegate
extension SourceViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        switch item {
        case let section as SourceSection:
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as! NSTableCellView
            view.textField?.stringValue = section.title
            return view
        case let item as Folderable:
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as! NSTableCellView
            view.textField?.stringValue = item.title
            view.textField?.delegate = self
            view.imageView?.isHidden = false
            if item is Target {
                view.imageView?.image = NSImage.target
            } else if item is Library {
                view.imageView?.image = NSImage.library
            }
            return view
        case let item as Folder:
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as! NSTableCellView
            view.textField?.stringValue = item.title
            view.textField?.delegate = self
            view.imageView?.isHidden = true
            return view
        default:
            return nil
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is SourceSection
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return !(item is SourceSection)
    }

    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return TransparentTableRowView(frame: NSRect())
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return item is SourceSection ? 19 : 23
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        switch outlineView.selectedItem {
        case let folder as Folder:
            let isLibrary = outlineView.parent(forItem: outlineView.selectedItem) is Library
            delegate.sourceDidChange(folder: folder, isLibrary: isLibrary)
        case let foldarable as Folderable:
            if expandedItem != nil {
                outlineView.collapseItem(expandedItem)
            }
            expandedItem = foldarable
            outlineView.expandItem(expandedItem, expandChildren: false)
            if let firstFolder = foldarable.folders.first {
                delegate.sourceDidChange(folder: firstFolder, isLibrary: outlineView.parent(forItem: firstFolder) is Library)
            } else {
                delegate.sourceDidReset()
            }
        default:
            break
        }
    }

    // MARK: Draggable
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard let pasteboardItem = info.draggingPasteboard().pasteboardItems?.first, index != -1, let item = item else {
            return false
        }

        switch item {
        case _ as SourceSection:
            let sectionIndex = outlineView.childIndex(forItem: item)
            let isTarget = sectionIndex == 0
            let dataType = isTarget ? targetDataType : libraryDataType
            guard
                let row = pasteboardItem.rowIndex(forType: dataType),
                let source = outlineView.childIndex(forRow: row)
            else { return false }

            if isTarget {
                dataManager.targets.move(at: source, to: index)
                sections[0].data = dataManager.targets
            } else {
                dataManager.libraries.move(at: source, to: index)
                sections[1].data = dataManager.libraries
            }

            let offset = source < index ? 1 : 0
            outlineView.moveItem(at: source, inParent: item, to: index - offset, inParent: item)
            dataManager.save()
            return true
        case _ as Folderable:
            guard
                let sourceRow = pasteboardItem.rowIndex(forType: folderDataType),
                let sourceItem = outlineView.item(atRow: sourceRow),
                let sourceParent = outlineView.parent(forItem: sourceItem)
            else { return false }

            let sourceIndex = outlineView.childIndex(forItem: sourceItem)
            let isSameParent = outlineView.row(forItem: sourceParent) == outlineView.row(forItem: item)
            guard let sourceFolderable = sourceParent as? Folderable else { return false }
            if isSameParent {
                sourceFolderable.folders.move(at: sourceIndex, to: index)
            } else {
                guard let destinationFolderable = item as? Folderable else { return false }
                let folder = sourceFolderable.folders[sourceIndex]
                sourceFolderable.folders.remove(at: sourceIndex)
                destinationFolderable.folders.insert(folder, at: index)
            }
            let offset = (sourceIndex < index) && isSameParent ? 1 : 0

            outlineView.moveItem(at: sourceIndex, inParent: sourceParent, to: index - offset, inParent: item)
            dataManager.save()
            return true
        default:
            return false
        }
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        print(index)
        guard let pasteboardItem = info.draggingPasteboard().pasteboardItems?.first, index != -1, let item = item else {
            return []
        }

        switch item {
        case _ as SourceSection:
            if pasteboardItem.data(forType: targetDataType) != nil && outlineView.childIndex(forItem: item) == 0 {
                // Target
                return .move
            } else if (pasteboardItem.data(forType: libraryDataType) != nil) && outlineView.childIndex(forItem: item) == 1 {
                // Library
                return .move
            } else {
                return []
            }
        case _ as Folderable where (pasteboardItem.data(forType: folderDataType) != nil):
            return .move
        default:
            return []
        }
    }

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let itemType: NSPasteboard.PasteboardType
        switch item {
        case _ as Target:
            itemType = targetDataType
        case _ as Library:
            itemType = libraryDataType
        case _ as Folder:
            itemType = folderDataType
        default:
            return nil
        }
        let index = outlineView.row(forItem: item)

        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setRowIndex(index, forType: itemType)
        return pasteboardItem
    }
}

extension SourceViewController: NSMenuDelegate {

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return !(menuItem.tag == 2 && outlineView.selectedItem == nil)
    }

}

extension SourceViewController: NSTextFieldDelegate {

    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        let newTitle = textField.stringValue
        let row = outlineView.row(for: textField)
        let item = outlineView.item(atRow: row)

        if let folder = item as? Folder {
            folder.title = newTitle
        } else if let folderable = item as? Folderable {
            folderable.title = newTitle
        }
        dataManager.save()
    }

}

private extension SourceViewController {

    func insertItem(at section: SourceSection) {
        outlineView.beginUpdates()
        let indexSet = IndexSet(integer: section.data.count - 1)
        outlineView.insertItems(at: indexSet, inParent: section, withAnimation: .slideLeft)
        if !outlineView.isItemExpanded(section) {
            outlineView.expandItem(section)
        }
        outlineView.endUpdates()
    }

    func insertFolder(at folderable: Folderable) {
        outlineView.beginUpdates()
        let indexSet = IndexSet(integer: folderable.folders.count - 1)
        outlineView.insertItems(at: indexSet, inParent: folderable, withAnimation: .slideLeft)
        if !outlineView.isItemExpanded(folderable) {
            outlineView.expandItem(folderable)
        }
        let newItemRow = outlineView.row(forItem: folderable.folders.last!)
        outlineView.selectRowIndexes(IndexSet(integer: newItemRow), byExtendingSelection: false)
        outlineView.endUpdates()
    }

    @objc func newTarget(_ sender: Any) {
        guard let menuItem = sender as? NSMenuItem else { return }
        if menuItem.tag == -1 {
            dataManager.targets.append(Target())
        } else {
            let library = dataManager.libraries[menuItem.tag]
            dataManager.targets.append(Target(library: library))
        }

        sections[0].data = dataManager.targets
        insertItem(at: sections[0])
    }

}

// MARK: - Removable
extension SourceViewController: Removable {

    func removeSelectedRow() {
        guard let selectedItem = outlineView.selectedItem else { return }

        do {
            switch selectedItem {
            case let target as Target:
                let index = try dataManager.targets.remove(target)
                dataManager.save()
                sections[0].data = dataManager.targets
                outlineView.removeItems(at: IndexSet(integer: index), inParent: sections[0], withAnimation: .effectFade)
            case let library as Library:
                let index = try dataManager.libraries.remove(library)
                dataManager.save()
                sections[1].data = dataManager.libraries
                outlineView.removeItems(at: IndexSet(integer: index), inParent: sections[1], withAnimation: .effectFade)
            case let folder as Folder:
                let folderable = outlineView.parent(forItem: folder) as! Folderable
                let index = try folderable.folders.remove(folder)
                dataManager.save()
                outlineView.removeItems(at: IndexSet(integer: index), inParent: folderable, withAnimation: .effectFade)
            default:
                break
            }
        } catch {
            show(error: error)
        }

    }

}

private extension NSOutlineView {

    var selectedItem: Any? {
        return item(atRow: selectedRow)
    }

    func childIndex(forRow row: Int) -> Int? {
        guard let item = self.item(atRow: row) else { return nil }
        return childIndex(forItem: item)
    }

}
