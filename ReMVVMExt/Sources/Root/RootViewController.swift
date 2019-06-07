//
//  RootViewController.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak on 12/02/2019.
//  Copyright © 2019 HYD. All rights reserved.
//

//import BNCommon
import ReMVVM
import RxCocoa
import RxSwift
import UICommon
import UIKit

class RootViewController: UIViewController, ReMVVMDriven {

    override var childForStatusBarStyle: UIViewController? {
        return findNavigationController()?.topViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
