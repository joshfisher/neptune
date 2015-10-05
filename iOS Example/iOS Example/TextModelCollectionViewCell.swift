import UIKit
import Neptune

class TextModelCollectionViewCell: UICollectionViewCell {
    
    var textLabel = UILabel(frame: CGRect.zero)
    var lineView = UIView(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        contentView.addSubview(textLabel)
        
        lineView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        contentView.addSubview(lineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() -> () {
        super.layoutSubviews()
        let hairline = 1.0 / UIScreen.mainScreen().scale
        textLabel.frame = CGRect(x: 15.0, y: 0.0, width: contentView.bounds.size.width - 30.0, height: contentView.bounds.size.height - hairline)
        lineView.frame = CGRect(x: 0.0, y: contentView.bounds.size.height - hairline, width: contentView.bounds.size.width, height: hairline)
    }
}

extension  TextModelCollectionViewCell: ModelView {
    func configureWithModel(model: String, indexPath: NSIndexPath) -> () {
        textLabel.text = model
    }
    
    class func sizeForModel(model: String, constrainedToSize size: CGSize) -> CGSize {
        return CGSizeMake(size.width, 40.0)
    }
}
