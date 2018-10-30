//
//        .........     .........
//      ......  ...........  .....
//      ...        .....       ....
//     ...         ....         ...
//     ...       ........        ...
//     ....      .... ....      ...
//      ...      .... ....      ...
//      .....     .......     ....
//        ...      .....     ....
//         ....             ....
//           ....         ....
//            .....     .....
//              .....  ....
//                .......
//                  ...
//

import UIKit

@IBDesignable class UITextViewWithPlaceholder: UITextView {
    
    @IBInspectable var placeholder: String = "Description" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    let placeholderLabel = UILabel()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: nil)
        placeholderLabel.text = placeholder
        placeholderLabel.font = App.core.state.theme.font(withSize: 17)
        addSubview(placeholderLabel)
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        placeholderLabel.isHidden = !text.isEmpty
        placeholderLabel.frame.origin = CGPoint(x: 6, y: 8)
        placeholderLabel.numberOfLines = 0
    }
    
    @objc func textViewDidChange(_ notification: Notification) {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
}
