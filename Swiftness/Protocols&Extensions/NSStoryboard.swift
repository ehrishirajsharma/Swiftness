import Cocoa

extension NSStoryboard {

    class func statusBarViewController() -> StatusBarViewController? {
        return load(identifier: "StatusBarViewController") as? StatusBarViewController
    }

    class func editorWindowController() -> EditorWindowController? {
        return load(identifier: "EditorWindowController") as? EditorWindowController
    }

}

private extension NSStoryboard {

    static func load(identifier: String) -> Any {
        let storyboard = NSStoryboard(name: Name("Main"), bundle: nil)
        return storyboard.instantiateController(withIdentifier: SceneIdentifier(identifier))
    }

}
