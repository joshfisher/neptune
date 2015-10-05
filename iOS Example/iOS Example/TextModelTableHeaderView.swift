import UIKit
import Neptune

class TextModelTableHeaderView: UITableViewHeaderFooterView {
    
    let label = UILabel(frame: CGRectZero)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.blackColor()
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() -> () {
        super.layoutSubviews()
        label.frame = CGRectInset(bounds, 10.0, 10.0)
    }
}

extension TextModelTableHeaderView: ModelView {
    func configureWithModel(model: String, indexPath: NSIndexPath) -> () {
        label.text = model
    }
    
    class func sizeForModel(model: String, constrainedToSize size: CGSize) -> CGSize {
        return CGSize(width: 0.0, height: 30.0)
    }
}
