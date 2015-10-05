import UIKit

public class Running<CollectionViewType: CollectionView> {
    
    internal typealias InternalConfigurationBlock = (view: CollectionViewType.RunningViewType, indexPath: NSIndexPath) -> ()
    internal typealias InternalSizingBlock = (constrainedToSize: CGSize) -> CGSize
    
    public let model: Any
    public let viewClass: AnyClass
    
    internal let internalSizingBlock: InternalSizingBlock
    internal let internalConfigurationBlock: InternalConfigurationBlock
    
    public init<ModelType, ViewType: ModelView where ModelType == ViewType.ModelType>(model: ModelType, viewClass: ViewType.Type) {
        self.model = model
        self.viewClass = viewClass
        
        self.internalConfigurationBlock = {(view, indexPath) in
            assert(view is ViewType, String(format: "Attempting to configure Running with view of unexpected type. Expected type: %@, provided type: %@.", NSStringFromClass(ViewType), NSStringFromClass(view.dynamicType)))
            if let castedView = view as? ViewType {
                castedView.configureWithModel(model, indexPath: indexPath)
            }
        }
        
        self.internalSizingBlock = {(constrainedToSize) in
            return viewClass.sizeForModel(model, constrainedToSize: constrainedToSize)
        }
    }
}
