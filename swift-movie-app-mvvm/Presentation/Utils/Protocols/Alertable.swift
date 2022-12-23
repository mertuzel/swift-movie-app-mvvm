import UIKit



public protocol Alertable {}

public extension Alertable where Self: UIViewController {
    typealias CustomAlertAction = (title : String, function : ((UIAlertAction) -> Void)?)
    
    func showAlert(title: String = "", message: String,actions : [CustomAlertAction], preferredStyle: UIAlertController.Style = .alert, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: UIAlertAction.Style.default, handler: action.function))
        }
        
        self.present(alert, animated: true, completion: completion)
    }
}
