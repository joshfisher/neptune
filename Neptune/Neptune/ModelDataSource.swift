import UIKit
import Mars

public typealias TableModelDataSource = ModelDataSource<UITableView>
public typealias CollectionModelDataSource = ModelDataSource<UICollectionView>

public class ModelDataSource<CollectionViewType: CollectionView>: DataSource<CollectionViewType> {
    
    public typealias CompatibleItem = Item<CollectionViewType>
    public typealias CompatibleSection = Section<CollectionViewType>
    
    public private(set) var sections: [CompatibleSection]
    
    public required init(sections: [CompatibleSection]) {
        self.sections = sections
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> CompatibleItem {
        return sections[indexPath.section][indexPath.item]
    }
    
    // MARK: Data
    
    public override func numberOfSections() -> Int {
        return sections.count
    }
    
    public override func numberOfItemsInSection(section: Int) -> Int {
        let section = sections[section]
        return section.items.count
    }
    
    public override func reuseIdentifierForHeaderViewInSection(section: Int) -> String? {
        var reuseIdentifier: String? = nil
        if let headerModel = sections[section].headerModel {
            reuseIdentifier = NSStringFromClass(headerModel.viewClass)
        }
        return reuseIdentifier
    }
    
    public override func reuseIdentifierForFooterViewInSection(section: Int) -> String? {
        var reuseIdentifier: String? = nil
        if let footerModel = sections[section].footerModel {
            reuseIdentifier = NSStringFromClass(footerModel.viewClass)
        }
        return reuseIdentifier
    }
    
    public override func reuseIdentifierForCellAtIndexPath(indexPath: NSIndexPath) -> String {
        let item = itemAtIndexPath(indexPath)
        return NSStringFromClass(item.cellClass)
    }
    
    // MARK: Configuration
    
    public override func configureHeaderForCollectionView(collectionView: CollectionViewType, header: CollectionViewType.RunningViewType, section: Int) -> () {
        if let headerModel = sections[section].headerModel {
            headerModel.internalConfigurationBlock(view: header, indexPath: NSIndexPath(forItem: 0, inSection: section))
        }
    }
    
    public override func configureFooterForCollectionView(collectionView: CollectionViewType, footer: CollectionViewType.RunningViewType, section: Int) -> () {
        if let footerModel = sections[section].footerModel {
            footerModel.internalConfigurationBlock(view: footer, indexPath: NSIndexPath(forItem: 0, inSection: section))
        }
    }
    
    public override func configureCellForCollectionView(collectionView: CollectionViewType, cell: CollectionViewType.ItemViewType, indexPath: NSIndexPath) -> () {
        let item = itemAtIndexPath(indexPath)
        item.internalConfigurationBlock(cell: cell, indexPath: indexPath)
        item.configurationBlock?(collectionView, cell, item, indexPath)
    }
    
    // MARK: Sizing
    
    public override func sizeForHeaderViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        var size = CGSize.zero
        if let headerModel = sections[section].headerModel {
            size = headerModel.internalSizingBlock(constrainedToSize: size)
        }
        return size
    }
    
    public override func sizeForFooterViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        var size = CGSize.zero
        if let footerModel = sections[section].footerModel {
            size = footerModel.internalSizingBlock(constrainedToSize: size)
        }
        return size
    }
    
    public override func sizeForItemAtIndexPath(indexPath: NSIndexPath, constrainedToSize size: CGSize) -> CGSize {
        let item = itemAtIndexPath(indexPath)
        return item.internalSizingBlock(constrainedToSize: size)
    }
    
    // MARK: Selection
    
    public override func selectedCellForCollectionView(collectionView: CollectionViewType, indexPath: NSIndexPath) -> () {
        let item = itemAtIndexPath(indexPath)
        item.selectionBlock?(collectionView, item, indexPath)
    }
    
    // MARK: Mutation
    
    public func insertSections(sections models: [CompatibleSection], atIndexes indexes: NSIndexSet) -> () {
        sections.insert(models, atIndexes: indexes)
        didInsertSectionsAtIndexes(indexes)
    }
    
    public func deleteSectionsAtIndexes(indexes: NSIndexSet) -> () {
        sections.removeAtIndexes(indexes)
        didDeleteSectionsAtIndexes(indexes)
    }
    
    public func insertItems(items: [CompatibleItem], atIndexPaths indexPaths: [NSIndexPath]) -> () {
        for (items, section, indexes) in self.dynamicType.partitionItems(items, atIndexPaths: indexPaths) {
            sections[section].insertItems(items, atIndexes: indexes)
        }
        didInsertItemsAtIndexPaths(indexPaths)
    }
    
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        let sectionToIndexSetMap = self.dynamicType.indexSetsFromIndexPaths(indexPaths)
        for (section, indexSet) in sectionToIndexSetMap {
            sections[section].removeItemsAtIndexes(indexSet)
        }
        didDeleteItemsAtIndexPaths(indexPaths)
    }
    
    // MARK: Helpers
    
    private static func partitionItems<T>(items: [T], atIndexPaths indexPaths: [NSIndexPath]) -> [([T], Int, NSIndexSet)] {
        var elements = Array(zip(items, indexPaths))
        elements.sortInPlace({(lhs, rhs) in
            return lhs.1.compare(rhs.1) == NSComparisonResult.OrderedAscending
        })
        
        let groupedElements = elements.groupBy({(lhs, rhs) -> Bool in
            return lhs.1.section == rhs.1.section
        })
        
        let results = groupedElements.map({(sectionGroup) -> ([T], Int, NSIndexSet) in
            var items: [T] = []
            let indexSet = NSMutableIndexSet()
            let section = sectionGroup.first!.1.section
            for row in sectionGroup {
                items.append(row.0)
                indexSet.addIndex(row.1.item)
            }
            return (items, section, indexSet)
        })
        
        return results
    }
    
    private static func indexSetsFromIndexPaths(indexPaths: [NSIndexPath]) -> [Int: NSIndexSet] {
        var sectionToIndexSetMap = [Int: NSMutableIndexSet]()
        for indexPath in indexPaths {
            if let indexSet = sectionToIndexSetMap[indexPath.section] {
                indexSet.addIndex(indexPath.item)
            }
            else {
                let indexSet = NSMutableIndexSet(index: indexPath.item)
                sectionToIndexSetMap[indexPath.section] = indexSet
            }
        }
        return sectionToIndexSetMap
    }
}
