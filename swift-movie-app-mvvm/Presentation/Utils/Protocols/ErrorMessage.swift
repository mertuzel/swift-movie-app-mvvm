//import UIKit
//
//protocol ErrorMessageProtocol where Self: UIViewController {
//    func showErrorMessage(_ message : String,startingPointOfView : CGFloat)
//    func hideErrorMessage()
//}
//
//extension ErrorMessageProtocol {
//    func showErrorMessage(_ message : String,startingPointOfView : CGFloat) {
//        ErrorMessageView.shared.showMessage(message,startingPointOfView: startingPointOfView)
//    }
//
//    func hideErrorMessage() {
//        ErrorMessageView.shared.hideMessage()
//    }
//}
//
//final class ErrorMessageView {
//    static let shared = ErrorMessageView()
//    var label = UILabel()
//    var view : UIView?
//
//    init() {
//        view = UIView()
//        guard let view = view else { return }
//
//        view.backgroundColor = UIColor(white: 1, alpha: 1)
//
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .gray
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.font = UIFont.preferredFont(forTextStyle: .title2)
//        label.sizeToFit()
//
//
//
//        view.addSubview(label)
//
//
//
//
//    }
//
//    func getCreatedView() -> UIView?{
//        return view
//    }
//
//    func showMessage(_ text : String,startingPointOfView : CGFloat){
//        guard let view = view else{  return }
//
//        var yPosition = UIApplication.shared.statusBarFrame.size.height + startingPointOfView
//
//        view.frame = CGRect(x: 0, y:yPosition, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - yPosition)
//
//        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//        label.text = text
//        UIApplication.shared.currentUIWindow()?.addSubview(view)
//    }
//
//    func hideMessage(){
//        guard let view = view else{  return }
//        view.removeFromSuperview()
//    }
//}
//
//
