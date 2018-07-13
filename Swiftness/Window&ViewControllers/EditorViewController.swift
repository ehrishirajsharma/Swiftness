import Cocoa

protocol EditorViewControllerDelegate: class {
    func editableTitleDidUpdate()
    func editableContentDidUpdate()
}

class EditorViewController: NSViewController, Pasteboardable {

    private var editable: Editable? {
        willSet {
            if let editable = editable, editable !== newValue {
                saveContent()
            }
        }
    }

    weak var delegate: EditorViewControllerDelegate!

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet var textView: NSTextView!
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

    override func viewDidLoad() {
        setFont()
        textView.textContainerInset = NSSize(width: 8, height: 8)
    }

    override func viewWillAppear() {
        DispatchQueue.main.async{
            self.view.window?.makeFirstResponder(nil)
        }
    }

    override func viewWillDisappear() {
        saveContent()
    }

}

extension EditorViewController: NSTextViewDelegate {

    func textViewDidChangeTypingAttributes(_ notification: Notification) {
        let font = textView.typingAttributes[NSAttributedStringKey.font] as! NSFont
        boldButton.state = font.isBold ? .on : .off
        italicButton.state = font.isItalic ? .on : .off
    }

}

extension EditorViewController: NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        editable?.title = textField.stringValue
        delegate.editableTitleDidUpdate()
    }

}

extension EditorViewController {

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

}

private extension EditorViewController {

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
        delegate.editableContentDidUpdate()
    }
    
}
