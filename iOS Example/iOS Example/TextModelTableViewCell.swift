import UIKit
import Neptune

class TextModelTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.whiteColor()
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextModelTableViewCell: ModelView {
    func configureWithModel(model: String, indexPath: NSIndexPath) -> () {
        textLabel!.text = model
    }
    
    class func sizeForModel(model: String, constrainedToSize size: CGSize) -> CGSize {
        return CGSize(width: 0.0, height: 40.0)
    }
}
