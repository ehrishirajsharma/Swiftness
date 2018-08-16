import Foundation

enum ArrayError: LocalizedError {
    case elementNotFound

    var localizedDescription: String {
        switch self {
        case .elementNotFound: return "Array element not found"
        }
    }

}

extension Array where Element: AnyObject {

    mutating func remove(_ element: Element) throws -> Int {
        guard let i = index(where: { $0 === element }) else {
            throw ArrayError.elementNotFound
        }
        
        remove(at: i)
        return i
    }

    mutating func move(at source: Int, to destination: Int) {
        let offset = source > destination ? 1 : 0
        insert(self[source], at: destination)
        remove(at: source + offset)
    }

}

extension Array where Element: Equatable {

    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> Bool {
        if !contains(element) {
            append(element)
            return true
        }
        return false
    }
    
}
