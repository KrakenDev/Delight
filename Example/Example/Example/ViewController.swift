//
//  ViewController.swift
//  Devices
//
//  Created by Hector Matos on 10/4/18.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var curvePlayground: CurvePlayground?
    
    lazy var inputKeyCommands = [
        UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(scrubLeft)),
        UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(scrubRight))
    ]
    
    override var keyCommands: [UIKeyCommand]? {
        return inputKeyCommands
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 4)
        scrollView.contentOffset = CGPoint(x: 0.0, y: view.bounds.height * 1.65)
        view.addSubview(scrollView)

        curvePlayground = CurvePlayground(viewSize: scrollView.contentSize)
        curvePlayground?.drawGraphView()
        scrollView.addSubview(curvePlayground!.view)

        scrollView.backgroundColor = curvePlayground?.view.backgroundColor
    }

    @objc public func scrubLeft() {
        curvePlayground?.graphView.scrub(to: (curvePlayground?.graphView.currentIndex ?? 1) - 1)
    }
    
    @objc public func scrubRight() {
        curvePlayground?.graphView.scrub(to: (curvePlayground?.graphView.currentIndex ?? -1) + 1)
    }
}
