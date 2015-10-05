import Foundation

extension Array {
    mutating func insert(elements: [Element], atIndexes indexes: NSIndexSet) -> () {
        assert(elements.count == indexes.count, "Attempting to insert elements to array with unmatched numbered of indexes.")
        var index = indexes.firstIndex
        for i in 0..<elements.count {
            insert(elements[i], atIndex: index)
            index = indexes.indexGreaterThanIndex(index)
        }
    }
    
    mutating func removeAtIndexes(indexes: NSIndexSet) -> () {
        indexes.enumerateIndexesWithOptions(NSEnumerationOptions.Reverse, usingBlock: {(index, stop) in
            _ = self.removeAtIndex(index)
        })
    }
}
