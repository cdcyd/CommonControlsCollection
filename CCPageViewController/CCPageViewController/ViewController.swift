//
//  ViewController.swift
//  CCPageViewController
//
//  Created by cyd on 2018/3/23.
//  Copyright © 2018年 cyd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let colors = [UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.green, UIColor.magenta]

    private var buffer = [DetailViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.title = "分页控件"
        self.setupUI()
    }

    private func setupUI() {
        let vc = CCPageViewController()
        vc.dataSource = self
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
    }

    private func vc(index: Int) -> UIViewController {
        for vc in buffer where vc.index == index {
            return vc
        }
        let vc = DetailViewController()
        vc.view.backgroundColor = colors[index%5]
        vc.index = index
        buffer.append(vc)
        return vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: CCPageViewControllerDataSource {
    func numbersOfPage() -> Int {
        return 50
    }

    func previewController(formPage index: Int) -> UIViewController {
        return self.vc(index: index)
    }

    func itemText(index: Int) -> String {
        return "第\((index+1).description)页"
    }
}
