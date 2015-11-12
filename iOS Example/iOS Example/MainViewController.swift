import UIKit
import Neptune

class MainViewController: TableViewController {
    
    override func viewDidLoad() -> () {
        super.viewDidLoad()
        
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        let collectionModel = TableItem(model: "Collection View Example", cellClass: TextModelTableViewCell.self)
        collectionModel.selectionBlock = {[unowned self] (tableView, item, indexPath) in
            self.collectionModelSelected()
        }
        
        let tableModel = TableItem(model: "Table View Example", cellClass: TextModelTableViewCell.self)
        tableModel.selectionBlock = {[unowned self] (tableView, item, indexPath) in
            self.tableModelSelected()
        }
        
        let items = [collectionModel, tableModel]
        let section = Section(items: items)
        
        modelDataSource = TableDataSource(sections: [section])
    }
    
    override func registerCollectionClasses() -> () {
        registerCellClass(TextModelTableViewCell.self)
    }
    
    func collectionModelSelected() -> () {
        let viewController = ExampleCollectionViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableModelSelected() -> () {
        let viewController = ExampleTableViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
