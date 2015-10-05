import UIKit

public typealias CollectionRunning = Running<UICollectionView>
public typealias CollectionItem = Item<UICollectionView>
public typealias CollectionSection = Section<UICollectionView>
public typealias CollectionDataSource = DataSource<UICollectionView>

// MARK: - CollectionView

extension UICollectionView: CollectionView {
    public typealias RunningViewType = UICollectionReusableView
    public typealias ItemViewType = UICollectionViewCell
}

// MARK: - CollectionViewController

public class CollectionViewController: UIViewController {

    public private(set) var collectionView: UICollectionView!
    public let collectionViewLayout: UICollectionViewLayout
    
    public var dataSource: CollectionDataSource? {
        didSet {
            dataSource?.delegate = self
            collectionView.reloadData()
        }
    }
    
    public required init(collectionViewLayout: UICollectionViewLayout) {
        self.collectionViewLayout = collectionViewLayout
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(animated: Bool) -> () {
        super.viewWillAppear(animated)
        
        for indexPath in collectionView.indexPathsForSelectedItems() ?? []  {
            collectionView.deselectItemAtIndexPath(indexPath, animated: animated)
         }
    }
    
    public override func viewDidLoad() -> () {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        registerCollectionClasses()
    }
    
    public func registerItemClass(aClass: UICollectionViewCell.Type) -> () {
        collectionView.registerClass(aClass, forCellWithReuseIdentifier: NSStringFromClass(aClass))
    }
    
    public func registerItemClass(aClass: UICollectionReusableView.Type, forSupplementaryElementOfKind kind: String) -> () {
        collectionView.registerClass(aClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: NSStringFromClass(aClass))
    }
    
    public func registerCollectionClasses() -> () {
        
    }
    
    public override func viewDidLayoutSubviews() -> () {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func collectionViewSizeConstraints() -> CGSize {
        return CGSize(width: CGFloat.max, height: CGFloat.max)
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewController: UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        var numberOfSections = 0
        if let dataSource = dataSource {
            numberOfSections = dataSource.numberOfSections()
        }
        return numberOfSections
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        if let dataSource = dataSource {
            numberOfItems = dataSource.numberOfItemsInSection(section)
        }
        return numberOfItems
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(dataSource!.reuseIdentifierForCellAtIndexPath(indexPath), forIndexPath: indexPath) as UICollectionViewCell
        dataSource!.configureCellForCollectionView(collectionView, cell: cell, indexPath: indexPath)
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView? = nil
        if kind == UICollectionElementKindSectionHeader {
            if let reuseIdentifier = dataSource!.reuseIdentifierForHeaderViewInSection(indexPath.section) {
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                dataSource!.configureHeaderForCollectionView(collectionView, header: header, section: indexPath.section)
                view = header
            }
        }
        else if kind == UICollectionElementKindSectionFooter {
            if let reuseIdentifier = dataSource!.reuseIdentifierForFooterViewInSection(indexPath.section) {
                let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath) as UICollectionReusableView
                dataSource!.configureFooterForCollectionView(collectionView, footer: footer, section: indexPath.section)
                view = footer
            }
        }
        return view!
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewController: UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) -> () {
        if let dataSource = dataSource {
            dataSource.selectedCellForCollectionView(collectionView, indexPath: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSize.zero
        if let dataSource = dataSource {
            size = dataSource.sizeForItemAtIndexPath(indexPath, constrainedToSize: collectionViewSizeConstraints())
        }
        return size
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = CGSize.zero
        if let dataSource = dataSource {
            size = dataSource.sizeForHeaderViewInSection(section, constrainedToSize: collectionViewSizeConstraints())
        }
        return size
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var size = CGSize.zero
        if let dataSource = dataSource {
            size = dataSource.sizeForFooterViewInSection(section, constrainedToSize: collectionViewSizeConstraints())
        }
        return size
    }
}

// MARK: - DataSourceDelegate

extension CollectionViewController: DataSourceDelegate {
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertSectionsAtIndexes indexes: NSIndexSet) -> () {
        collectionView.insertSections(indexes)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didDeleteSectionsAtIndexes indexes: NSIndexSet) -> () {
        collectionView.deleteSections(indexes)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didReloadSectionsAtIndexes indexes: NSIndexSet) -> () {
        collectionView.reloadSections(indexes)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didMoveSection section: Int, toSection newSection: Int) -> () {
        collectionView.moveSection(section, toSection: newSection)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        collectionView.insertItemsAtIndexPaths(indexPaths)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didDeleteItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        collectionView.deleteItemsAtIndexPaths(indexPaths)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didReloadItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        collectionView.reloadItemsAtIndexPaths(indexPaths)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        collectionView.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
    }
}
