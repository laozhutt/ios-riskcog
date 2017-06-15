//
//  LoadingView.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/6/12.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    private let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private let dimView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    private weak var parent: UIView?
    
    override init(frame: CGRect = UIScreen.main.bounds) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        dimView.layer.cornerRadius = 8.0
        dimView.clipsToBounds = true
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        activityView.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(dimView)
        dimView.addSubview(activityView)
        dimView.center = center
        activityView.center = CGPoint(x: dimView.bounds.midX, y: dimView.bounds.midY)
    }
    
    class func show(toParent parent: UIView) -> LoadingView {
        let loadingView = LoadingView(frame: UIScreen.main.bounds)
        loadingView.parent = parent
        parent.addSubview(loadingView)
        loadingView.center = parent.center
        return loadingView
    }
    func hide() {
        removeFromSuperview()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
