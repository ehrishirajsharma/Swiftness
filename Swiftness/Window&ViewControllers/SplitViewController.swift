import Cocoa

class SplitViewController: NSSplitViewController {

    var sourceViewController: SourceViewController!
    var folderViewController: FolderViewController!
    var editorViewController: EditorViewController!

    var dataManager: DataManager! {
        didSet {
            sourceViewController.dataManager = dataManager
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in splitViewItems {
            switch item.viewController {
            case let controller as SourceViewController:
                sourceViewController = controller
                sourceViewController.delegate = self
            case let controller as FolderViewController:
                folderViewController = controller
                folderViewController.delegate = self
                folderViewController.resetView()
            case let controller as EditorViewController:
                editorViewController = controller
                editorViewController.delegate = self
                editorViewController.resetView()
            default:
                break
            }
        }
    }

}

extension SplitViewController: SourceViewControllerDelegate {

    func sourceDidChange(folder: Folder, isLibrary: Bool) {
        folderViewController.updateView(with: folder, showAsLibrary: isLibrary)
        editorViewController.resetView()
    }

    func sourceDidReset() {
        folderViewController.resetView()
        editorViewController.resetView()
    }

}

extension SplitViewController: FolderViewControllerDelegate {

    func editableDidChange(editable: Editable?) {
        if let editable = editable {
            editorViewController.updateView(with: editable)
        } else {
            editorViewController.resetView()
        }
    }

    func wasChanges() {
        dataManager.save()
    }

}

extension SplitViewController: EditorViewControllerDelegate {

    func editableTitleDidUpdate() {
        dataManager.save()
        folderViewController.updateCurrentFolder()
    }

    func editableContentDidUpdate() {
        dataManager.save()
    }

}
