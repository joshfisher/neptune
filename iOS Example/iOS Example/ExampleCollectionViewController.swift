import UIKit
import Neptune

class ExampleCollectionViewController: CollectionViewController {

    var addBarButtonItem: UIBarButtonItem!

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        super.init(collectionViewLayout: layout)
        
        title = "Collection View"
        
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "barButtonPressed")
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    required init(collectionViewLayout: UICollectionViewLayout) {
        fatalError("init(collectionViewLayout:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() -> () {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        let headerModel = CollectionRunning(model: "Header", viewClass: TextModelCollectionHeaderView.self)
        
        let sectionOne = Section(items: [], headerModel: headerModel)
        let sectionTwo = Section(items: [], headerModel: headerModel)
        let sections = [sectionOne, sectionTwo]
        
        modelDataSource = CollectionDataSource(sections: sections)
    }
    
    override func collectionViewSizeConstraints() -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat.max)
    }
    
    func barButtonPressed() -> () {
        let count = modelDataSource.sections[0].items.count
        
        if count < 10 {
            var items: [CollectionItem] = []
            var indexPaths: [NSIndexPath] = []
            
            let additions = 2
            
            for i in 0 ..< additions {
                items.append(CollectionItem(model: "\(count + additions - i)", cellClass: TextModelCollectionViewCell.self))
                indexPaths.append(NSIndexPath(forItem: count + additions - i - 1, inSection: 0))

                items.append(CollectionItem(model: "\(count + additions - i)", cellClass: TextModelCollectionViewCell.self))
                indexPaths.append(NSIndexPath(forItem: count + additions - i - 1, inSection: 1))
            }
            
            modelDataSource.insertItems(items, atIndexPaths: indexPaths)
            
            if count + additions >= 10 {
                addBarButtonItem.enabled = false
            }
        }
    }
}
