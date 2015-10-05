import UIKit
import Mars

public typealias TableComposedDataSource = ComposedDataSource<UITableView>
public typealias CollectionComposedDataSource = ComposedDataSource<UICollectionView>

private class DataSourceTranslator<CollectionViewType: CollectionView> {
    
    private var startingSection = 0
    private let dataSource: DataSource<CollectionViewType>
    
    private required init(dataSource: DataSource<CollectionViewType>) {
        self.dataSource = dataSource
    }
    
    private func translateLocalSection(section: Int) -> Int {
        return section + startingSection
    }
    
    private func translateGlobalSection(section: Int) -> Int {
        return section - startingSection
    }
    
    private func translateLocalIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forItem: indexPath.item, inSection: translateLocalSection(indexPath.section))
    }
    
    private func translateGlobalIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forItem: indexPath.item, inSection: translateGlobalSection(indexPath.section))
    }
    
    private func translateLocalSections(sections: NSIndexSet) -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        sections.enumerateIndexesUsingBlock({(index, stop) -> () in
            indexSet.addIndex(self.translateLocalSection(index))
        })
        return indexSet
    }
    
    private func translateGlobalSections(sections: NSIndexSet) -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        sections.enumerateIndexesUsingBlock({(index, stop) -> () in
            indexSet.addIndex(self.translateGlobalSection(index))
        })
        return indexSet
    }
    
    private func translateLocalIndexPaths(indexPaths: [NSIndexPath]) -> [NSIndexPath] {
        return indexPaths.map({(indexPath) in return self.translateLocalIndexPath(indexPath)})
    }
    
    private func translateGlobalIndexPaths(indexPaths: [NSIndexPath]) -> [NSIndexPath] {
        return indexPaths.map({(indexPath) in return self.translateGlobalIndexPath(indexPath)})
    }
}

public class ComposedDataSource<CollectionViewType: CollectionView>: DataSource<CollectionViewType> {

    public typealias CompatibleDataSource = DataSource<CollectionViewType>
    private typealias CompatibleDataSourceTranslator = DataSourceTranslator<CollectionViewType>
    
    private var sectionCount = 0
    private var dataSourceTranslators = [CompatibleDataSourceTranslator]()
    private var sectionToTranslatorMap = [Int: CompatibleDataSourceTranslator]()
    private var dataSourceToTranslatorrMap = [CompatibleDataSource: CompatibleDataSourceTranslator]()
    
    public var dataSources: [CompatibleDataSource] {
        return dataSourceTranslators.map({(translator) in return translator.dataSource})
    }
    
    public override required init() {
        super.init()
    }
    
    public func addDataSource(dataSource: CompatibleDataSource) -> () {
        assert(dataSourceToTranslatorrMap[dataSource] == nil, "Attemping to add the same data source multiple times.")
        let translator = DataSourceTranslator(dataSource: dataSource)
        dataSourceTranslators.append(translator)
        dataSourceToTranslatorrMap[dataSource] = translator
        
        dataSource.delegate = self
        updateTranslators()
    }
    
    public func removeDataSource(dataSource: CompatibleDataSource) -> () {
        assert(dataSourceToTranslatorrMap[dataSource] != nil, "Attempting to remove data source that doesn't exist.")
        if let translator = dataSourceToTranslatorrMap[dataSource] {
            dataSourceTranslators.removeAtIndex(dataSourceTranslators.indexOf({(element) -> Bool in return element === translator})!)
            dataSourceToTranslatorrMap.removeValueForKey(dataSource)
            
            dataSource.delegate = nil
            updateTranslators()
        }
    }
    
    public func updateTranslators() -> () {
        sectionCount = 0
        sectionToTranslatorMap.removeAll(keepCapacity: true)
        
        for translator in dataSourceTranslators {
            translator.startingSection = sectionCount
            for var section = 0; section < translator.dataSource.numberOfSections(); ++section {
                sectionToTranslatorMap[sectionCount++] = translator
            }
        }
    }
    
    private func translatorForSection(section: Int) -> CompatibleDataSourceTranslator {
        return sectionToTranslatorMap[section]!
    }
    
    // MARK: Data
    
    public override func numberOfSections() -> Int {
        return sectionCount
    }
    
    public override func numberOfItemsInSection(section: Int) -> Int {
        let translator = translatorForSection(section)
        return translator.dataSource.numberOfItemsInSection(translator.translateGlobalSection(section))
    }
    
    public override func reuseIdentifierForHeaderViewInSection(section: Int) -> String? {
        let translator = translatorForSection(section)
        return translator.dataSource.reuseIdentifierForHeaderViewInSection(translator.translateGlobalSection(section))
    }
    
    public override func reuseIdentifierForFooterViewInSection(section: Int) -> String? {
        let translator = translatorForSection(section)
        return translator.dataSource.reuseIdentifierForFooterViewInSection(translator.translateGlobalSection(section))
    }
    
    public override func reuseIdentifierForCellAtIndexPath(indexPath: NSIndexPath) -> String {
        let translator = translatorForSection(indexPath.section)
        return translator.dataSource.reuseIdentifierForCellAtIndexPath(translator.translateGlobalIndexPath(indexPath))
    }
    
    // MARK: Configuration
    
    public override func configureHeaderForCollectionView(collectionView: CollectionViewType, header: CollectionViewType.RunningViewType, section: Int) -> () {
        let translator = translatorForSection(section)
        translator.dataSource.configureHeaderForCollectionView(collectionView, header: header, section: translator.translateGlobalSection(section))
    }
    
    public override func configureFooterForCollectionView(collectionView: CollectionViewType, footer: CollectionViewType.RunningViewType, section: Int) -> () {
        let translator = translatorForSection(section)
        translator.dataSource.configureFooterForCollectionView(collectionView, footer: footer, section: translator.translateGlobalSection(section))
    }
    
    public override func configureCellForCollectionView(collectionView: CollectionViewType, cell: CollectionViewType.ItemViewType, indexPath: NSIndexPath) -> () {
        let translator = translatorForSection(indexPath.section)
        translator.dataSource.configureCellForCollectionView(collectionView, cell: cell, indexPath: translator.translateGlobalIndexPath(indexPath))
    }
    
    // MARK: Sizing
    
    public override func sizeForHeaderViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        let translator = translatorForSection(section)
        return translator.dataSource.sizeForHeaderViewInSection(translator.translateGlobalSection(section), constrainedToSize: size)
    }
    
    public override func sizeForFooterViewInSection(section: Int, constrainedToSize size: CGSize) -> CGSize {
        let translator = translatorForSection(section)
        return translator.dataSource.sizeForFooterViewInSection(translator.translateGlobalSection(section), constrainedToSize: size)
    }
    
    public override func sizeForItemAtIndexPath(indexPath: NSIndexPath, constrainedToSize size: CGSize) -> CGSize {
        let translator = translatorForSection(indexPath.section)
        return translator.dataSource.sizeForItemAtIndexPath(translator.translateGlobalIndexPath(indexPath), constrainedToSize: size)
    }
    
    // MARK: Selection
    
    public override func selectedCellForCollectionView(collectionView: CollectionViewType, indexPath: NSIndexPath) -> () {
        let translator = translatorForSection(indexPath.section)
        return translator.dataSource.selectedCellForCollectionView(collectionView, indexPath: translator.translateGlobalIndexPath(indexPath))
    }
}

// MARK: - DataSourceDelegate

extension ComposedDataSource: DataSourceDelegate {
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertSectionsAtIndexes indexes: NSIndexSet) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            let translatedIndexes = translator.translateLocalSections(indexes)
            didInsertSectionsAtIndexes(translatedIndexes)
            updateTranslators()
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didDeleteSectionsAtIndexes indexes: NSIndexSet) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            let translatedIndexes = translator.translateLocalSections(indexes)
            didDeleteSectionsAtIndexes(translatedIndexes)
            updateTranslators()
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didReloadSectionsAtIndexes indexes: NSIndexSet) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            let translatedIndexes = translator.translateLocalSections(indexes)
            didReloadSectionsAtIndexes(translatedIndexes)
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didMoveSection section: Int, toSection newSection: Int) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            didMoveSection(translator.translateLocalSection(section), toSection: translator.translateLocalSection(newSection))
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            let translatedIndexPaths = translator.translateLocalIndexPaths(indexPaths)
            didInsertItemsAtIndexPaths(translatedIndexPaths)
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didDeleteItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            let translatedIndexPaths = translator.translateLocalIndexPaths(indexPaths)
            didDeleteItemsAtIndexPaths(translatedIndexPaths)
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didReloadItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            let translatedIndexPaths = translator.translateLocalIndexPaths(indexPaths)
            didReloadItemsAtIndexPaths(translatedIndexPaths)
        }
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        if let dataSource = dataSource as AnyObject as? CompatibleDataSource, translator = dataSourceToTranslatorrMap[dataSource] {
            didMoveItemAtIndexPath(translator.translateLocalIndexPath(indexPath), toIndexPath: translator.translateLocalIndexPath(newIndexPath))
        }
    }
}
