import Foundation

class Folder: Codable, Copyable {
    var title: String
    var templates: [Template] = []
    var checklist: [CheckListItem] = []
    var notes: [Note] = []

    init() {
        self.title = "New Folder"
    }

    required init(instance: Folder) {
        self.title = instance.title
        self.templates = instance.templates.copy()
        self.checklist = instance.checklist.copy()
        self.notes = instance.notes.copy()
    }

}
