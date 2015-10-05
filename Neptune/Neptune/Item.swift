import UIKit

public class Item<CollectionViewType: CollectionView> {
    
    public typealias ConfigurationBlock = (CollectionViewType, CollectionViewType.ItemViewType, Item<CollectionViewType>, NSIndexPath) -> ()
    public typealias SelectionBlock = (CollectionViewType, Item<CollectionViewType>, NSIndexPath) -> ()
    
    internal typealias InternalConfigurationBlock = (cell: CollectionViewType.ItemViewType, indexPath: NSIndexPath) -> ()
    internal typealias InternalSizingBlock = (constrainedToSize: CGSize) -> CGSize
    
    public let model: Any
    public let cellClass: AnyClass
    
    public var configurationBlock: ConfigurationBlock?
    public var selectionBlock: SelectionBlock?
    
    internal let internalSizingBlock: InternalSizingBlock
    internal let internalConfigurationBlock: InternalConfigurationBlock
    
    public init<ModelType, CellType: ModelView where ModelType == CellType.ModelType>(model: ModelType, cellClass: CellType.Type, configurationBlock: ConfigurationBlock? = nil, selectionBlock: SelectionBlock? = nil) {
        self.model = model
        self.cellClass = cellClass
        self.configurationBlock = configurationBlock
        self.selectionBlock = selectionBlock
        
        self.internalConfigurationBlock = {(cell, indexPath) in
            assert(cell is CellType, String(format: "Attempting to configure Item with cell of unexpected type. Expected type: %@, provided type: %@.", NSStringFromClass(CellType), NSStringFromClass(cell.dynamicType)))
            if let castedCell = cell as? CellType {
                castedCell.configureWithModel(model, indexPath: indexPath)
            }
        }
        
        self.internalSizingBlock = {(constrainedToSize) in
            return cellClass.sizeForModel(model, constrainedToSize: constrainedToSize)
        }
    }
}
