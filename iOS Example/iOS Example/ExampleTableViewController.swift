import UIKit
import Neptune

class ExampleTableViewController: TableViewController {

    var deleteBarButtonItem: UIBarButtonItem!
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        title = "Table View"
        
        deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "barButtonPressed")
        navigationItem.rightBarButtonItem = deleteBarButtonItem
    }

    override func viewDidLoad() -> () {
        super.viewDidLoad()
        
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        let headerModel = TableRunning(model: "Header", viewClass: TextModelTableHeaderView.self)
        
        var items = [TableItem]()
        for i in 1 ... 10 {
            let item = TableItem(model: "\(i)", cellClass: TextModelTableViewCell.self)
            item.selectionBlock = {(tableView, item, indexPath) in
                print(item.model)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            items.append(item)
        }
        
        let sectionOne = TableSection(items: items, headerModel: headerModel)
        let sectionTwo = TableSection(items: items, headerModel: headerModel)

        modelDataSource = TableDataSource(sections: [sectionOne, sectionTwo])
    }

    func barButtonPressed() -> () {
        let count = modelDataSource.sections[0].items.count
        
        if count > 0 {
            var indexPaths: [NSIndexPath] = []
            
            let deletions = min(2, count)
            
            for i in 0 ..< deletions {
                indexPaths.append(NSIndexPath(forItem: count - i - 1, inSection: 0))
                indexPaths.append(NSIndexPath(forItem: count - i - 1, inSection: 1))
            }
            
            modelDataSource.deleteItemsAtIndexPaths(indexPaths)
            
            if count - deletions == 0 {
                deleteBarButtonItem.enabled = false
            }
        }
    }
}
