import Foundation

extension Array where Element: AnyObject {

    mutating func remove(_ element: Element) -> Int? {
        if let i = index(where: { $0 === element }) {
            remove(at: i)
            return i
        } else {
            return nil
        }
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
