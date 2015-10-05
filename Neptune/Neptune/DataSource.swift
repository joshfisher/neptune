import UIKit

internal protocol DataSourceDelegate {
    func dataSource<T>(dataSource: DataSource<T>, didInsertSectionsAtIndexes: NSIndexSet) -> ()
    func dataSource<T>(dataSource: DataSource<T>, didDeleteSectionsAtIndexes: NSIndexSet) -> ()
    func dataSource<T>(dataSource: DataSource<T>, didReloadSectionsAtIndexes: NSIndexSet) -> ()
    func dataSource<T>(dataSource: DataSource<T>, didMoveSection: Int, toSection: Int) -> ()
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertItemsAtIndexPaths: [NSIndexPath]) -> ()
    func dataSource<T>(dataSource: DataSource<T>, didDeleteItemsAtIndexPaths: [NSIndexPath]) -> ()
    func dataSource<T>(dataSource: DataSource<T>, didReloadItemsAtIndexPaths: [NSIndexPath]) -> ()
    func dataSource<T>(dataSource: DataSource<T>, didMoveItemAtIndexPath: NSIndexPath, toIndexPath: NSIndexPath) -> ()
}

public class DataSource<CollectionViewType: CollectionView> {
    
    var delegate: DataSourceDelegate? = nil
    
    // MARK: Data
    
    public func numberOfSections() -> Int {
        return 0
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        return 0
    }
    
    public func reuseIdentifierForHeaderViewInSection(section: Int) -> String? {
        fatalError("Function should be implemented by concrete subclass.")
    }
    
    public func reuseIdentifierForFooterViewInSection(section: Int) -> String? {
        fatalError("Function should be implemented by concrete subclass.")
    }
    
    public func reuseIdentifierForCellAtIndexPath(indexPath: NSIndexPath) -> String {
        fatalError("Function should be implemented by concrete subclass.")
    }
    
    // MARK: Configuration
    
    public func configureHeaderForCollectionView(collectionView: CollectionViewType, header: CollectionViewType.RunningViewType, section: Int) -> () {
        
    }
    
    public func configureFooterForCollectionView(collectionView: CollectionViewType, footer: CollectionViewType.RunningViewType, section: Int) -> () {
        
    }
    
    public func configureCellForCollectionView(collectionView: CollectionViewType, cell: CollectionViewType.ItemViewType, indexPath: NSIndexPath) -> () {
    
    }
    
    // MARK: Sizing
    
    public func sizeForHeaderViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        return CGSize.zero
    }
    
    public func sizeForFooterViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        return CGSize.zero
    }
    
    public func sizeForItemAtIndexPath(indexPath: NSIndexPath, constrainedToSize size: CGSize) -> CGSize {
        return CGSize.zero
    }
    
    // MARK: Selection
    
    public func selectedCellForCollectionView(collectionView: CollectionViewType, indexPath: NSIndexPath) -> () {
        
    }
    
    // MARK: Mutation
    
    public final func didInsertSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didInsertSectionsAtIndexes: indexes)
    }
    
    public final func didDeleteSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didDeleteSectionsAtIndexes: indexes)
    }
    
    public final func didReloadSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didReloadSectionsAtIndexes: indexes)
    }
    
    public final func didMoveSection(section: Int, toSection newSection: Int) -> () {
        delegate?.dataSource(self, didMoveSection: section, toSection: newSection)
    }
    
    public final func didInsertItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
    }
    
    public final func didDeleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths)
    }
    
    public final func didReloadItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didReloadItemsAtIndexPaths: indexPaths)
    }
    
    public final func didMoveItemAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        delegate?.dataSource(self, didMoveItemAtIndexPath: indexPath, toIndexPath: newIndexPath)
    }
}

// MARK: - Hashable

extension DataSource: Hashable {
    public var hashValue: Int {
        get {
            return ObjectIdentifier(self).hashValue
        }
    }
}

// MARK: - Equatable

public func ==<T>(lhs: DataSource<T>, rhs: DataSource<T>) -> Bool {
    return lhs === rhs
}
