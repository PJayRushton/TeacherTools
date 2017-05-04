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

final class LoadingImageViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var appleImageView: UIImageView!
    
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(presentICloudAlert), name: NSNotification.Name.iCloudError, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appleImageView.rotate()
    }
    
    func presentICloudAlert() {
        let alert = UIAlertController(title: NSLocalizedString("iCloud error", comment: "There was an error with iCloud"), message: NSLocalizedString("Teacher Tools uses iCloud to sync your data. Make sure you've given Teacher Tools iCloud access from the settings app", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            self.openSettings()
        }))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
            self.core.fire(command: GetICloudUser())
            self.appleImageView.rotate()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func openSettings() {
        var settingsURL: URL?
        settingsURL = URL(string:"App-Prefs:") ?? URL(string: UIApplicationOpenSettingsURLString)
        guard let url = settingsURL , UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

}
