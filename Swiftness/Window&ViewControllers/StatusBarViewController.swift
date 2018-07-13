import Cocoa

class StatusBarViewController: NSViewController, Pasteboardable {

    // MARK: - Properties
    weak var delegate: MainWindowDelegate!
    var dataManager: DataManager!
    var folderViewController: FolderViewController!
    var editorViewController: EditorViewController!

    // MARK: - IBOutlets
    @IBOutlet weak var targetPopUpButton: NSPopUpButton!
    @IBOutlet weak var folderPopUpButton: NSPopUpButton!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var folderNavBar: NSStackView!
    @IBOutlet weak var editorNavBar: NSStackView!
    
    // MARK: - IBActions
    @IBAction func targetPopUpButtonAction(_ sender: Any) {
        updateFolderPopUp()
        updateFolderView()
    }

    @IBAction func folderPopUpButtonAction(_ sender: Any) {
        updateFolderView()
    }

    @IBAction func backButtonAction(_ sender: Any) {
        showTableView()
    }

    @IBAction func appButtonAction(_ sender: Any) {
        delegate.showMainWindow()
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        DispatchQueue.main.async{
            self.view.window?.makeFirstResponder(nil)
        }
    }
    override func viewWillAppear() {
        showTableView()
        updateTargetPopUp()
        updateFolderPopUp()
        updateFolderView()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let viewController as FolderViewController:
            viewController.delegate = self
            self.folderViewController = viewController
        case let viewController as EditorViewController:
            viewController.delegate = self
            self.editorViewController = viewController
        default:
            break
        }
    }
}

extension StatusBarViewController {

    func updateTargetPopUp() {
        let previousIndex = targetPopUpButton.indexOfSelectedItem
        let titles = dataManager.targets.map{ $0.title }.uniques(postfixingWith: " ")
        targetPopUpButton.removeAllItems()
        targetPopUpButton.addItems(withTitles: titles)
        if previousIndex != -1 {
            targetPopUpButton.selectItem(at: previousIndex)
        }
    }

    func updateFolderPopUp() {
        let previousIndex = folderPopUpButton.indexOfSelectedItem
        let target = dataManager.targets[targetPopUpButton.indexOfSelectedItem]
        let titles = target.folders.map{ $0.title }.uniques(postfixingWith: " ")
        folderPopUpButton.removeAllItems()
        folderPopUpButton.addItems(withTitles: titles)
        if previousIndex != -1 {
            folderPopUpButton.selectItem(at: previousIndex)
        }
    }

    func updateFolderView() {
        let target = dataManager.targets[targetPopUpButton.indexOfSelectedItem]
        let folder = target.folders[folderPopUpButton.indexOfSelectedItem]
        folderViewController.updateView(with: folder, showAsLibrary: false)
    }

    func showEditorView() {
        tabView.selectTabViewItem(at: 1)
        folderNavBar.isHidden = true
        editorNavBar.isHidden = false
    }

    func showTableView() {
        tabView.selectTabViewItem(at: 0)
        folderNavBar.isHidden = false
        editorNavBar.isHidden = true
        folderViewController.tableView.deselectAll(nil)
    }
}

extension StatusBarViewController: FolderViewControllerDelegate {

    func editableDidChange(editable: Editable?) {
        if let editable = editable {
            editorViewController.updateView(with: editable)
            showEditorView()
        } else {
            editorViewController.resetView()
        }
    }

    func wasChanges() {
        dataManager.save()
    }

}

extension StatusBarViewController: EditorViewControllerDelegate {

    func editableTitleDidUpdate() {
        dataManager.save()
        folderViewController.updateCurrentFolder()
    }

    func editableContentDidUpdate() {
        dataManager.save()
    }

}

private extension Array where Element == String {

    func uniques(postfixingWith char: String) -> [String] {
        var uniqueValues: [Element] = []
        forEach { item in
            var item = item
            while uniqueValues.contains(item) {
                item.append(char)
            }
            uniqueValues += [item]
        }
        return uniqueValues
    }

}
