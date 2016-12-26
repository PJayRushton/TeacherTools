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

import UIKit

final class CustomTabBarController: UITabBarController {
    
    enum Tab: Int {
        case list
        case groups
        case drawName
        case settings
        
        var dataObject: TabDataObject {
            switch self {
            case .list:
                return TabDataObject(title: NSLocalizedString("List", comment: ""), image: UIImage(named: "lists"))
            case .groups:
                return TabDataObject(title: NSLocalizedString("Groups", comment: ""), image: UIImage(named: "groups"))
            case .drawName:
                return TabDataObject(title: NSLocalizedString("Draw names", comment: ""), image: UIImage(named: "hat"))
            case .settings:
                return TabDataObject(title: NSLocalizedString("Settings", comment: ""), image: UIImage(named: "settings"))
            }
        }
        
        static let allValues = [Tab.list, .groups, .drawName, .settings]
    }
    
    
    // MARK: - Public properties

    @IBOutlet var customTabBar: CustomTabBar!
    
    var core = App.core
    fileprivate let tabBarHeight: CGFloat = 48.0
    
    
    // MARK: - Lifecycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
        setupTabBar()
        displayCustomTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
}


// MARK: - Custom tab bar delegate

extension CustomTabBarController: CustomTabBarDelegate, AutoStoryboardInitializable {
    
    func tabBar(_ tabBar: CustomTabBar, didSelectTab tab: Int) {
        if let selectedNav = selectedViewController as? UINavigationController, tab == selectedIndex {
            selectedNav.popToRootViewController(animated: true)
        } else {
            selectedIndex = tab
        }
    }
    
}

extension CustomTabBarController: Subscriber {
    
    func update(with state: AppState) {
        customTabBar.translucentBackground = false
        customTabBar.backgroundColor = .clear
        customTabBar.tintColor = state.theme.tintColor
        customTabBar.textColor = state.theme.textColor
        customTabBar.selectedTextColor = state.theme.tintColor
    }
    
}


// MARK: - Private functions

private extension CustomTabBarController {
    
    func setupViewControllers() {
        let studentListVC = StudentListViewController.initializeFromStoryboard().embededInNavigationController
        let randomizerVC = StudentRandomizerViewController.initializeFromStoryboard().embededInNavigationController
        let nameDrawVC = NameDrawViewController.initializeFromStoryboard().embededInNavigationController
        let groupSettingsVC = GroupSettingsViewController.initializeFromStoryboard().embededInNavigationController
        viewControllers = [studentListVC, randomizerVC, nameDrawVC, groupSettingsVC]
    }
    
    func setupTabBar() {
        let allDataObjects = Tab.allValues.map { $0.dataObject }
        customTabBar.titleFont = core.state.theme.font(withSize: 10)
        customTabBar.dataObjects = allDataObjects
        tabBar.isHidden = true
    }
    
    func displayCustomTabBar() {
        view.addSubview(customTabBar)
        customTabBar.delegate = self
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
        customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}
