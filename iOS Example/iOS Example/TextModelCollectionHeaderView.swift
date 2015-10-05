import UIKit
import Neptune

class TextModelCollectionHeaderView: UICollectionReusableView {
    
    let textLabel = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        
        textLabel.font = UIFont.systemFontOfSize(14)
        textLabel.textColor = UIColor.blackColor()
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() -> () {
        super.layoutSubviews()
        textLabel.frame = bounds.insetBy(dx: 10.0, dy: 10.0)
    }
}

extension TextModelCollectionHeaderView: ModelView {
    func configureWithModel(model: String, indexPath: NSIndexPath) -> () {
        textLabel.text = model
    }
    
    class func sizeForModel(model: String, constrainedToSize size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 30.0)
    }
}
