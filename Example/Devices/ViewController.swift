//
//  ViewController.swift
//  Devices
//
//  Created by Hector Matos on 10/4/18.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

import UIKit
import Components

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 4)
        scrollView.contentOffset = CGPoint(x: 0.0, y: view.bounds.height * 1.65)
        view.addSubview(scrollView)

        let curvePlayground = CurvePlayground(viewSize: scrollView.contentSize)
        curvePlayground.drawGraphView()
        scrollView.addSubview(curvePlayground.view)

        scrollView.backgroundColor = curvePlayground.view.backgroundColor
    }
}
