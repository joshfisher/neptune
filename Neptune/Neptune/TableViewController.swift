import UIKit

public typealias TableRunning = Running<UITableView>
public typealias TableItem = Item<UITableView>
public typealias TableSection = Section<UITableView>
public typealias TableDataSource = DataSource<UITableView>

// MARK: - CollectionView

extension UITableView: CollectionView {
    public typealias RunningViewType = UITableViewHeaderFooterView
    public typealias ItemViewType = UITableViewCell
}

// MARK: - TableViewController

public class TableViewController: UIViewController {

    public private(set) var tableView: UITableView!
    
    public var dataSource: TableDataSource? {
        didSet {
            dataSource?.delegate = self
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
        tableView.dataSource = self
        tableView.delegate = self
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

// MARK: - UITableViewDataSource

extension TableViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSections = 0
        if let dataSource = dataSource {
            numberOfSections = dataSource.numberOfSections()
        }
        return numberOfSections
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let dataSource = dataSource {
            numberOfRows = dataSource.numberOfItemsInSection(section)
        }
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(dataSource!.reuseIdentifierForCellAtIndexPath(indexPath), forIndexPath: indexPath) as UITableViewCell
        dataSource!.configureCellForCollectionView(tableView, cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TableViewController: UITableViewDelegate {
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> () {
        if let dataSource = dataSource {
            dataSource.selectedCellForCollectionView(tableView, indexPath: indexPath)
        }
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var tableHeader: UIView? = nil
        if let dataSource = dataSource, reuseIdentifier = dataSource.reuseIdentifierForHeaderViewInSection(section) {
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier)!
            dataSource.configureHeaderForCollectionView(tableView, header: header, section: section)
            tableHeader = header
        }
        return tableHeader
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var tableFooter: UIView? = nil
        if let dataSource = dataSource, reuseIdentifier = dataSource.reuseIdentifierForFooterViewInSection(section) {
            let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseIdentifier)!
            dataSource.configureFooterForCollectionView(tableView, footer: footer, section: section)
            tableFooter = footer
        }
        return tableFooter
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = CGFloat(0.0)
        if let dataSource = dataSource {
            height = dataSource.sizeForHeaderViewInSection(section, constrainedToSize: CGSize(width: tableView.bounds.size.width, height: CGFloat.max)).height
        }
        return height
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height = CGFloat(0.0)
        if let dataSource = dataSource {
            height = dataSource.sizeForFooterViewInSection(section, constrainedToSize: CGSize(width: tableView.bounds.size.width, height: CGFloat.max)).height
        }
        return height
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(0.0)
        if let dataSource = dataSource {
            height = dataSource.sizeForItemAtIndexPath(indexPath, constrainedToSize: CGSize(width: tableView.bounds.size.width, height: CGFloat.max)).height
        }
        return height
    }
}

// MARK: - DataSourceDelegate

extension TableViewController: DataSourceDelegate {
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertSectionsAtIndexes indexes: NSIndexSet) -> () {
        tableView.insertSections(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didDeleteSectionsAtIndexes indexes: NSIndexSet) -> () {
        tableView.deleteSections(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didReloadSectionsAtIndexes indexes: NSIndexSet) -> () {
        tableView.reloadSections(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didMoveSection section: Int, toSection newSection: Int) -> () {
        tableView.moveSection(section, toSection: newSection)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didInsertItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didDeleteItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didReloadItemsAtIndexPaths indexPaths: [NSIndexPath]) -> () {
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func dataSource<T>(dataSource: DataSource<T>, didMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) -> () {
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
    }
}
