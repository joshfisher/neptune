import UIKit
import Mars

// MARK: - DataSource -

public class DataSource<CollectionViewType: CollectionView>: NSObject {
    
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
    
    public func numberOfSections() -> Int {
        return sections.count
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        let section = sections[section]
        return section.items.count
    }
    
    public func reuseIdentifierForHeaderViewInSection(section: Int) -> String? {
        var reuseIdentifier: String? = nil
        if let headerModel = sections[section].headerModel {
            reuseIdentifier = NSStringFromClass(headerModel.viewClass)
        }
        return reuseIdentifier
    }
    
    public func reuseIdentifierForFooterViewInSection(section: Int) -> String? {
        var reuseIdentifier: String? = nil
        if let footerModel = sections[section].footerModel {
            reuseIdentifier = NSStringFromClass(footerModel.viewClass)
        }
        return reuseIdentifier
    }
    
    public func reuseIdentifierForCellAtIndexPath(indexPath: NSIndexPath) -> String {
        let item = itemAtIndexPath(indexPath)
        return NSStringFromClass(item.cellClass)
    }
    
    // MARK: Configuration
    
    public func configureHeaderForCollectionView(collectionView: CollectionViewType, header: CollectionViewType.RunningViewType, section: Int) -> () {
        if let headerModel = sections[section].headerModel {
            let indexPath = NSIndexPath(forItem: 0, inSection: section)
            headerModel.internalConfigurationBlock(view: header, indexPath: indexPath)
            headerModel.configurationBlock?(collectionView, header, headerModel, indexPath)
        }
    }
    
    public func configureFooterForCollectionView(collectionView: CollectionViewType, footer: CollectionViewType.RunningViewType, section: Int) -> () {
        if let footerModel = sections[section].footerModel {
            let indexPath = NSIndexPath(forItem: 0, inSection: section)
            footerModel.internalConfigurationBlock(view: footer, indexPath: indexPath)
            footerModel.configurationBlock?(collectionView, footer, footerModel, indexPath)
        }
    }
    
    public func configureCellForCollectionView(collectionView: CollectionViewType, cell: CollectionViewType.ItemViewType, indexPath: NSIndexPath) -> () {
        let item = itemAtIndexPath(indexPath)
        item.internalConfigurationBlock(cell: cell, indexPath: indexPath)
        item.configurationBlock?(collectionView, cell, item, indexPath)
    }
    
    // MARK: Sizing
    
    public func sizeForHeaderViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        guard section < sections.count, let headerModel = sections[section].headerModel else {
            return CGSize.zero
        }

        return headerModel.internalSizingBlock(constrainedToSize: size)
    }

    public func sizeForFooterViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        guard section < sections.count, let footerModel = sections[section].footerModel else {
            return CGSize.zero
        }

        return footerModel.internalSizingBlock(constrainedToSize: size)
    }
    
    public func sizeForItemAtIndexPath(indexPath: NSIndexPath, constrainedToSize size: CGSize) -> CGSize {
        let item = itemAtIndexPath(indexPath)
        return item.internalSizingBlock(constrainedToSize: size)
    }
    
    // MARK: Selection
    
    public func selectedCellForCollectionView(collectionView: CollectionViewType, indexPath: NSIndexPath) -> () {
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

    private func didInsertSectionsAtIndexes(indexes: NSIndexSet) -> () {}
    private func didDeleteSectionsAtIndexes(indexes: NSIndexSet) -> () {}
    private func didReloadSectionsAtIndexes(indexes: NSIndexSet) -> () {}
    private func didMoveSection(section: Int, toSection newSection: Int) -> () {}

    private func didInsertItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {}
    private func didDeleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {}
    private func didReloadItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {}
    private func didMoveItemAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {}
    
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

// MARK: - TableDataSourceDelegate -

public protocol TableDataSourceDelegate: class {
    func tableViewForDataSource(dataSource: TableDataSource) -> UITableView?
}

extension TableDataSourceDelegate {
    public func dataSource(dataSource: TableDataSource, didInsertSectionsAtIndexes indexes: NSIndexSet) -> () {
        tableViewForDataSource(dataSource)?.insertSections(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    public func dataSource(dataSource: TableDataSource, didDeleteSectionsAtIndexes indexes: NSIndexSet) -> () {
        tableViewForDataSource(dataSource)?.deleteSections(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    public func dataSource(dataSource: TableDataSource, didReloadSectionsAtIndexes indexes: NSIndexSet) -> () {
        tableViewForDataSource(dataSource)?.reloadSections(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    public func dataSource(dataSource: TableDataSource, didMoveSection section: Int, toSection newSection: Int) -> () {
        tableViewForDataSource(dataSource)?.moveSection(section, toSection: newSection)
    }

    public func dataSource(dataSource: TableDataSource, didInsertItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        tableViewForDataSource(dataSource)?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    public func dataSource(dataSource: TableDataSource, didDeleteItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        tableViewForDataSource(dataSource)?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    public func dataSource(dataSource: TableDataSource, didReloadItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        tableViewForDataSource(dataSource)?.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }

    public func dataSource(dataSource: TableDataSource, didMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        tableViewForDataSource(dataSource)?.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
    }
}

// MARK: - TableDataSource -

public class TableDataSource: DataSource<UITableView>, UITableViewDataSource, UITableViewDelegate {

    public static let Empty = TableDataSource(sections: [])

    public weak var delegate: TableDataSourceDelegate?
    private var registeredCellReuseIdentifiers: Set<String> = []
    private var registeredHeaderReuseIdentifiers: Set<String> = []
    private var registeredFooterReuseIdentifiers: Set<String> = []

    public required init(sections: [CompatibleSection]) {
        super.init(sections: sections)
    }

    private func registerItemWithReuseIdentifier(reuseIdentifier: String, atIndexPath indexPath: NSIndexPath) {
        if !registeredCellReuseIdentifiers.contains(reuseIdentifier) {
            let item = itemAtIndexPath(indexPath)
            delegate?.tableViewForDataSource(self)?.registerClass(item.cellClass, forCellReuseIdentifier: reuseIdentifier)
            registeredCellReuseIdentifiers.insert(reuseIdentifier)
        }
    }

    private func registerHeaderWithReuseIdentifier(reuseIdentifier: String, section: Int) {
        if let header = sections[section].headerModel where !registeredHeaderReuseIdentifiers.contains(reuseIdentifier) {
            delegate?.tableViewForDataSource(self)?.registerClass(header.viewClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            registeredHeaderReuseIdentifiers.insert(reuseIdentifier)
        }
    }

    private func registerFooterWithReuseIdentifier(reuseIdentifier: String, section: Int) {
        if let footer = sections[section].footerModel where !registeredFooterReuseIdentifiers.contains(reuseIdentifier) {
            delegate?.tableViewForDataSource(self)?.registerClass(footer.viewClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            registeredFooterReuseIdentifiers.insert(reuseIdentifier)
        }
    }

    // MARK: UITableViewDataSource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = reuseIdentifierForCellAtIndexPath(indexPath)
        registerItemWithReuseIdentifier(reuseIdentifier, atIndexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        configureCellForCollectionView(tableView, cell: cell, indexPath: indexPath)
        return cell
    }

    // MARK: UITableViewDelegate

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> () {
        selectedCellForCollectionView(tableView, indexPath: indexPath)
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var tableHeader: UIView? = nil
        if let reuseIdentifier = reuseIdentifierForHeaderViewInSection(section) {
            registerHeaderWithReuseIdentifier(reuseIdentifier, section: section)
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier)!
            configureHeaderForCollectionView(tableView, header: header, section: section)
            tableHeader = header
        }
        return tableHeader
    }

    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var tableFooter: UIView? = nil
        if let reuseIdentifier = reuseIdentifierForFooterViewInSection(section) {
            registerFooterWithReuseIdentifier(reuseIdentifier, section: section)
            let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier)!
            configureFooterForCollectionView(tableView, footer: footer, section: section)
            tableFooter = footer
        }
        return tableFooter
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sizeForHeaderViewInSection(section, constrainedToSize: CGSize(width: tableView.bounds.size.width, height: CGFloat.max)).height
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sizeForFooterViewInSection(section, constrainedToSize: CGSize(width: tableView.bounds.size.width, height: CGFloat.max)).height
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return sizeForItemAtIndexPath(indexPath, constrainedToSize: CGSize(width: tableView.bounds.size.width, height: CGFloat.max)).height
    }

    // MARK: Mutation

    private override func didInsertSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didInsertSectionsAtIndexes: indexes)
    }

    private override func didDeleteSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didDeleteSectionsAtIndexes: indexes)
    }

    private override func didReloadSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didReloadSectionsAtIndexes: indexes)
    }

    private override func didMoveSection(section: Int, toSection newSection: Int) -> () {
        delegate?.dataSource(self, didMoveSection: section, toSection: newSection)
    }

    private override func didInsertItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
    }

    private override func didDeleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths)
    }

    private override func didReloadItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didReloadItemsAtIndexPaths: indexPaths)
    }

    private override func didMoveItemAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        delegate?.dataSource(self, didMoveItemAtIndexPath: indexPath, toIndexPath: newIndexPath)
    }
}

// MARK: - CollectionDataSourceDelegate -

public protocol CollectionDataSourceDelegate: class {
    func collectionViewForDataSource(dataSource: CollectionDataSource) -> UICollectionView?
    func collectionViewSizeConstraints() -> CGSize
}

extension CollectionDataSourceDelegate {
    public func dataSource(dataSource: CollectionDataSource, didInsertSectionsAtIndexes indexes: NSIndexSet) -> () {
        collectionViewForDataSource(dataSource)?.insertSections(indexes)
    }

    public func dataSource(dataSource: CollectionDataSource, didDeleteSectionsAtIndexes indexes: NSIndexSet) -> () {
        collectionViewForDataSource(dataSource)?.deleteSections(indexes)
    }

    public func dataSource(dataSource: CollectionDataSource, didReloadSectionsAtIndexes indexes: NSIndexSet) -> () {
        collectionViewForDataSource(dataSource)?.reloadSections(indexes)
    }

    public func dataSource(dataSource: CollectionDataSource, didMoveSection section: Int, toSection newSection: Int) -> () {
        collectionViewForDataSource(dataSource)?.moveSection(section, toSection: newSection)
    }

    public func dataSource(dataSource: CollectionDataSource, didInsertItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        collectionViewForDataSource(dataSource)?.insertItemsAtIndexPaths(indexPaths)
    }

    public func dataSource(dataSource: CollectionDataSource, didDeleteItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        collectionViewForDataSource(dataSource)?.deleteItemsAtIndexPaths(indexPaths)
    }

    public func dataSource(dataSource: CollectionDataSource, didReloadItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        collectionViewForDataSource(dataSource)?.reloadItemsAtIndexPaths(indexPaths)
    }

    public func dataSource(dataSource: CollectionDataSource, didMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        collectionViewForDataSource(dataSource)?.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
    }
}

// MARK: - CollectionDataSource -

public class CollectionDataSource: DataSource<UICollectionView>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public static let Empty = CollectionDataSource(sections: [])

    public weak var delegate: CollectionDataSourceDelegate?
    private var registeredCellReuseIdentifiers: Set<String> = []
    private var registeredHeaderReuseIdentifiers: Set<String> = []
    private var registeredFooterReuseIdentifiers: Set<String> = []

    public required init(sections: [CompatibleSection]) {
        super.init(sections: sections)
    }

    private func registerItemWithReuseIdentifier(reuseIdentifier: String, atIndexPath indexPath: NSIndexPath) {
        if !registeredCellReuseIdentifiers.contains(reuseIdentifier) {
            let item = itemAtIndexPath(indexPath)
            delegate?.collectionViewForDataSource(self)?.registerClass(item.cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            registeredCellReuseIdentifiers.insert(reuseIdentifier)
        }
    }

    private func registerHeaderWithReuseIdentifier(reuseIdentifier: String, section: Int) {
        if let header = self.sections[section].headerModel where !registeredHeaderReuseIdentifiers.contains(reuseIdentifier) {
            delegate?.collectionViewForDataSource(self)?.registerClass(header.viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseIdentifier)
            registeredHeaderReuseIdentifiers.insert(reuseIdentifier)
        }
    }

    private func registerFooterWithReuseIdentifier(reuseIdentifier: String, section: Int) {
        if let footer = self.sections[section].footerModel where !registeredFooterReuseIdentifiers.contains(reuseIdentifier) {
            delegate?.collectionViewForDataSource(self)?.registerClass(footer.viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseIdentifier)
            registeredFooterReuseIdentifiers.insert(reuseIdentifier)
        }
    }

    // MARK: UICollectionViewDataSource

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = reuseIdentifierForCellAtIndexPath(indexPath)
        registerItemWithReuseIdentifier(reuseIdentifier, atIndexPath: indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        configureCellForCollectionView(collectionView, cell: cell, indexPath: indexPath)
        return cell
    }

    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView? = nil
        if kind == UICollectionElementKindSectionHeader {
            if let reuseIdentifier = reuseIdentifierForHeaderViewInSection(indexPath.section) {
                registerHeaderWithReuseIdentifier(reuseIdentifier, section: indexPath.section)
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                configureHeaderForCollectionView(collectionView, header: header, section: indexPath.section)
                view = header
            }
        }
        else if kind == UICollectionElementKindSectionFooter {
            if let reuseIdentifier = reuseIdentifierForFooterViewInSection(indexPath.section) {
                registerFooterWithReuseIdentifier(reuseIdentifier, section: indexPath.section)
                let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                configureFooterForCollectionView(collectionView, footer: footer, section: indexPath.section)
                view = footer
            }
        }
        return view!
    }

    // MARK: UICollectionViewDelegate

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) -> () {
        selectedCellForCollectionView(collectionView, indexPath: indexPath)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = delegate?.collectionViewSizeConstraints() ?? CGSize(width: CGFloat.max, height: CGFloat.max)
        return sizeForItemAtIndexPath(indexPath, constrainedToSize: size)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = delegate?.collectionViewSizeConstraints() ?? CGSize(width: CGFloat.max, height: CGFloat.max)
        return sizeForHeaderViewInSection(section, constrainedToSize: size)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let size = delegate?.collectionViewSizeConstraints() ?? CGSize(width: CGFloat.max, height: CGFloat.max)
        return sizeForFooterViewInSection(section, constrainedToSize: size)
    }

    // MARK: Mutation

    private override func didInsertSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didInsertSectionsAtIndexes: indexes)
    }

    private override func didDeleteSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didDeleteSectionsAtIndexes: indexes)
    }

    private override func didReloadSectionsAtIndexes(indexes: NSIndexSet) -> () {
        delegate?.dataSource(self, didReloadSectionsAtIndexes: indexes)
    }

    private override func didMoveSection(section: Int, toSection newSection: Int) -> () {
        delegate?.dataSource(self, didMoveSection: section, toSection: newSection)
    }

    private override func didInsertItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didInsertItemsAtIndexPaths: indexPaths)
    }

    private override func didDeleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didDeleteItemsAtIndexPaths: indexPaths)
    }

    private override func didReloadItemsAtIndexPaths(indexPaths: [NSIndexPath]) -> () {
        delegate?.dataSource(self, didReloadItemsAtIndexPaths: indexPaths)
    }

    private override func didMoveItemAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        delegate?.dataSource(self, didMoveItemAtIndexPath: indexPath, toIndexPath: newIndexPath)
    }
}
