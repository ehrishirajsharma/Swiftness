import Cocoa

class StatusBarViewController: NSViewController, Pasteboardable {

    // MARK: - Properties
    weak var mainWindowDelegate: MainWindowDelegate!
    var dataManager: DataManager!
    var folderViewController: FolderViewController!
    private var editable: Editable? {
        willSet {
            if let editable = editable, editable !== newValue {
                saveContent()
            }
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var targetPopUpButton: NSPopUpButton!
    @IBOutlet weak var folderPopUpButton: NSPopUpButton!
    @IBOutlet weak var tabView: NSTabView!

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var boldButton: NSButton!
    @IBOutlet weak var italicButton: NSButton!
    @IBOutlet weak var fontPopUpButton: NSPopUpButton!

    @IBAction func copy(_ sender: Any) {
        copyToPasteboard(textView.attributedString())
    }

    @IBAction func boldChanged(_ sender: NSButton) {
        setFont()
    }

    @IBAction func italicChanged(_ sender: NSButton) {
        setFont()
    }

    @IBAction func fontChanged(_ sender: NSPopUpButton) {
        setFont()
    }

    
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
        mainWindowDelegate.showMainWindow()
    }

    // MARK: - Overrides
    override func viewDidLoad() {
        DispatchQueue.main.async{
            self.view.window?.makeFirstResponder(nil)
        }
        setFont()
        textView.textContainerInset = NSSize(width: 8, height: 8)
    }
    override func viewWillAppear() {
        showTableView()
        updateTargetPopUp()
        updateFolderPopUp()
        updateFolderView()
    }

    override func viewWillDisappear() {
        saveContent()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let viewController as FolderViewController:
            viewController.delegate = self
            self.folderViewController = viewController
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
        self.tabView.selectTabViewItem(at: 1)
        self.view.window?.makeFirstResponder(nil)
    }

    func showTableView() {
        folderViewController.tableView.deselectAll(nil)
        tabView.selectTabViewItem(at: 0)
    }
}

extension StatusBarViewController: FolderViewControllerDelegate {

    func editableDidChange(editable: Editable?) {
        guard
            let selectedItem = tabView.selectedTabViewItem,
            tabView.indexOfTabViewItem(selectedItem) == 0
        else { return }

        if let editable = editable {
            updateView(with: editable)
            showEditorView()
        } else {
            resetView()
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

extension StatusBarViewController: NSTextViewDelegate {

    func textViewDidChangeTypingAttributes(_ notification: Notification) {
        let font = textView.typingAttributes[NSAttributedStringKey.font] as! NSFont
        boldButton.state = font.isBold ? .on : .off
        italicButton.state = font.isItalic ? .on : .off
    }

}

extension StatusBarViewController: NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        editable?.title = textField.stringValue
        editableTitleDidUpdate()
    }

}

private extension StatusBarViewController {

    func updateView(with editable: Editable) {
        self.editable = editable
        view.isHidden = false
        textField.stringValue = editable.title
        textView.textStorage?.setAttributedString(editable.content)
    }

    func resetView() {
        editable = nil
        view.isHidden = true
        textField.stringValue = ""
        textView.string = ""
    }

    func setFont() {
        let fontName = fontPopUpButton.selectedItem!.title
        let font = NSFont.named(fontName).bold(boldButton.state == .on).italic(italicButton.state == .on)
        let range = textView.selectedRange
        if range.length > 0 {
            textView.textStorage?.addAttribute(NSAttributedStringKey.font, value: font, range: range)
        } else {
            textView.typingAttributes = [NSAttributedStringKey.font: font]
        }
    }

    func saveContent() {
        guard let editable = editable, editable.content != textView.attributedString() else { return }
        editable.content = NSAttributedString(attributedString: textView.attributedString())
        editableContentDidUpdate()
    }

}
