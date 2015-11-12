import UIKit

public typealias TableRunning = Running<UITableView>
public typealias TableItem = Item<UITableView>
public typealias TableSection = Section<UITableView>

// MARK: - CollectionView

extension UITableView: CollectionView {
    public typealias RunningViewType = UITableViewHeaderFooterView
    public typealias ItemViewType = UITableViewCell
}

// MARK: - TableViewController

public class TableViewController: UIViewController, TableDataSourceDelegate {

    public private(set) var tableView: UITableView!
    
    public var modelDataSource = TableDataSource.Empty {
        didSet {
            modelDataSource.delegate = self
            tableView.dataSource = modelDataSource
            tableView.delegate = modelDataSource
            tableView.reloadData()
        }
    }

    public override func viewWillAppear(animated: Bool) -> () {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
    public override func viewDidLoad() -> () {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.Plain)
        tableView.dataSource = modelDataSource
        tableView.delegate = modelDataSource
        view.addSubview(tableView)
        
        registerCollectionClasses()
    }
    
    public func registerCellClass(aClass: UITableViewCell.Type) -> () {
        tableView.registerClass(aClass, forCellReuseIdentifier: NSStringFromClass(aClass))
    }
    
    public func registerRunningClass(aClass: UITableViewHeaderFooterView.Type) -> () {
        tableView.registerClass(aClass, forHeaderFooterViewReuseIdentifier: NSStringFromClass(aClass))
    }
    
    public func registerCollectionClasses() -> () {

    }
    
    public override func viewDidLayoutSubviews() -> () {
        tableView.frame = view.bounds
    }
}
