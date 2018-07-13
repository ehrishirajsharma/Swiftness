import Cocoa

extension NSStoryboard {

    static var statusBarViewController: StatusBarViewController {
        return load(identifier: "StatusBarViewController") as! StatusBarViewController
    }

    static var  editorWindowController: WindowController {
        return load(identifier: "EditorWindowController") as! WindowController
    }

    static var  exportWindowController: NSWindowController {
        return load(identifier: "ExportWindowController") as! NSWindowController
    }

}

private extension NSStoryboard {

    static func load(identifier: String) -> Any {
        let storyboard = NSStoryboard(name: Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: SceneIdentifier(identifier))
    }

}
