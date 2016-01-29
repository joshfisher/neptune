import UIKit

public typealias CollectionRunning = Running<UICollectionView>
public typealias CollectionItem = Item<UICollectionView>
public typealias CollectionSection = Section<UICollectionView>

// MARK: - CollectionView

extension UICollectionView: CollectionView {
    public typealias RunningViewType = UICollectionReusableView
    public typealias ItemViewType = UICollectionViewCell
}

// MARK: - CollectionViewController

public class CollectionViewController: UIViewController, CollectionDataSourceDelegate {

    public private(set) var collectionView: UICollectionView!
    public let collectionViewLayout: UICollectionViewLayout
    
    public var modelDataSource = CollectionDataSource.Empty {
        didSet {
            modelDataSource.delegate = self
            collectionView.dataSource = modelDataSource
            collectionView.delegate = modelDataSource
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
        collectionView.dataSource = modelDataSource
        collectionView.delegate = modelDataSource
        view.addSubview(collectionView)
    }
    
    public override func viewDidLayoutSubviews() -> () {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    public func collectionViewForDataSource(dataSource: CollectionDataSource) -> UICollectionView? {
        return collectionView
    }
    
    public func collectionViewSizeConstraints() -> CGSize {
        return CGSize(width: CGFloat.max, height: CGFloat.max)
    }
}
