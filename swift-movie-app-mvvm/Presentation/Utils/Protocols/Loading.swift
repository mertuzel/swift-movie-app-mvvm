import UIKit

protocol IndicatorProtocol where Self: UIViewController {
    func showIndicator()
    func hideIndicator()
}

extension IndicatorProtocol {
    func showIndicator() {
        LoadingView.shared.showIndicator()
    }
    
    func hideIndicator() {
        LoadingView.shared.hideIndicator()
    }
}

final class LoadingView {
    static let shared = LoadingView()
    var spinner = UIActivityIndicatorView(style: .large)
    var view : UIView?
    
    init() {
        view = UIView()
        guard let view = view else { return }
        
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.frame = UIWindow(frame: UIScreen.main.bounds).frame
        
    }
    
    func getCreatedView() -> UIView?{
        return view
    }
    
    func showIndicator(){
        guard let view = view else{  return }
        spinner.startAnimating()
        UIApplication.shared.currentUIWindow()?.addSubview(view)
    }
    
    func hideIndicator(){
        guard let view = view else{  return }
        view.removeFromSuperview()
        spinner.stopAnimating()
    }
}


