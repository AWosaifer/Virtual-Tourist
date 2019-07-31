//
//  Helpers.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func showFailureFromViewController(viewController: UIViewController, message: String) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    
}
