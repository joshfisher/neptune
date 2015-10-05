import UIKit

public class Section<CollectionViewType: CollectionView> {
    
    public typealias CompatibleItem = Item<CollectionViewType>
    public typealias CompatibleRunning = Running<CollectionViewType>
    
    public private(set) var items: [CompatibleItem]
    public private(set) var headerModel: CompatibleRunning?
    public private(set) var footerModel: CompatibleRunning?
    
    public init(items: [CompatibleItem], headerModel: CompatibleRunning? = nil, footerModel: CompatibleRunning? = nil) {
        self.items = items
        self.headerModel = headerModel
        self.footerModel = footerModel
    }
    
    public subscript(index: Int) -> CompatibleItem {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
    
    internal func insertItems(items: [CompatibleItem], atIndexes indexes: NSIndexSet) -> () {
        self.items.insert(items, atIndexes: indexes)
    }
    
    internal func removeItemsAtIndexes(indexes: NSIndexSet) -> () {
        self.items.removeAtIndexes(indexes)
    }
}
