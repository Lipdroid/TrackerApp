//
//  Progress.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 9/15/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import UIKit
class Progress: NSObject {
    static let sharedInstance = Progress()
    private var activityIndicator = UIActivityIndicatorView()
    
    //MARK: - Private Methods -
    private func setupLoader() {
        dismissLoading()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 60, 60))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.cornerRadius = 05
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicator.transform = transform
        activityIndicator.isOpaque = false
        activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.color = UIColor(red:1,green:1,blue:1.0,alpha:1.0)
        
    }
    
    //MARK: - Public Methods -
    func showLoading() {
        setupLoader()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let holdingView = appDel.window!.rootViewController!.view!
        
        DispatchQueue.main.async {
            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            holdingView.addSubview(self.activityIndicator)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func dismissLoading(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    private func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
