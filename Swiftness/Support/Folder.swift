import Foundation

class Folder: Codable, Copyable {
    var title: String
    private(set) var templates: [Template] = []
    private(set) var checklist: [CheckListItem] = []
    private(set) var notes: [Note] = []

    init() {
        self.title = "New Folder"
    }

    required init(instance: Folder) {
        self.title = instance.title
        self.templates = instance.templates.copy()
        self.checklist = instance.checklist.copy()
        self.notes = instance.notes.copy()
    }

    func addNewTemplate() {
        templates.append(Template())
    }

    func addNewCheckListItem() {
        checklist.append(CheckListItem())
    }

    func addNewNote() {
        notes.append(Note())
    }

    func remove(_ editable: Editable) -> Int? {
        if let template = editable as? Template {
            return templates.remove(template)
        } else if let checkListItem = editable as? CheckListItem {
            return checklist.remove(checkListItem)
        } else if let note = editable as? Note {
            return notes.remove(note)
        }

        return nil
    }
}
