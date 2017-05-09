//
//     /||\
//    / || \
//   /  )(  \
//  /__/  \__\
//

import UIKit

@IBDesignable class NavBarButton: UIButton {
    
    // MARK: - Inspectable properties
    
    @IBInspectable var mainTitle: String? = "Team Name" {
        didSet {
            updateText()
        }
    }
    
    @IBInspectable var subTitle: String? = "Team List" {
        didSet {
            updateText()
        }
    }
    
    
    // MARK: - Private properties
    
    fileprivate let mainStackView = UIStackView()
    fileprivate let titleStackView = UIStackView()
    fileprivate let mainTitleLabel = UILabel()
    fileprivate let subtitleLabel = UILabel()
    let icon = UIImageView()
    fileprivate let spacer = UIView()
    
    
    // MARK: - Lifecycle overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override func tintColorDidChange() {
        updateColors()
    }
    
    override var isHighlighted: Bool {
        didSet {
            mainStackView.alpha = isHighlighted ? 0.2 : 1.0
        }
    }
    
    var isPointingDown: Bool {
        return icon.transform == CGAffineTransform.identity
    }
    
    func update(with group: Group?) {
        mainTitle = group?.name ?? "Create your first class!"
        subTitle = group == nil ? nil : "\(group!.studentIds.count) students"
    }
    
    func update(with theme: Theme) {
        mainTitleLabel.font = theme.font(withSize: Platform.isPad ? 18 : 20)
        subtitleLabel.font = theme.font(withSize: Platform.isPad ? 12 : 14)
    }
    
}


// MARK: - Private functions

private extension NavBarButton {
    
    func setupViews() {
        addSubview(mainStackView)
        mainStackView.axis = .horizontal
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = 8.0
        mainStackView.isUserInteractionEnabled = false
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        mainStackView.addArrangedSubview(spacer)
        
        mainStackView.addArrangedSubview(titleStackView)
        titleStackView.axis = .vertical
        titleStackView.alignment = .center
        titleStackView.distribution = .fill
        titleStackView.spacing = -2.0
        
        titleStackView.addArrangedSubview(mainTitleLabel)
        mainTitleLabel.font = App.core.state.theme.font(withSize: 20)
        
        titleStackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.font = App.core.state.theme.font(withSize: 14)
        
        mainStackView.addArrangedSubview(icon)
        icon.image = #imageLiteral(resourceName: "DisclosureArrow")
        icon.contentMode = .center
        
        spacer.widthAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        updateText()
        updateColors()
    }
    
    func updateText() {
        mainTitleLabel.text = mainTitle
        subtitleLabel.text = subTitle
    }
    
    func updateColors() {
        mainTitleLabel.textColor = tintColor
        subtitleLabel.textColor = tintColor
        icon.tintColor = tintColor
    }
    
}
