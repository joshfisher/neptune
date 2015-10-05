import UIKit

public protocol ModelView: class {
    typealias ModelType
    func configureWithModel(model: ModelType, indexPath: NSIndexPath) -> ()
    static func sizeForModel(model: ModelType, constrainedToSize size: CGSize) -> CGSize
}

public protocol CollectionView: class {
    typealias RunningViewType: UIView
    typealias ItemViewType: UIView
}
