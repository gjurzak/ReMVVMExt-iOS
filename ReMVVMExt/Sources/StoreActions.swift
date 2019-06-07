//
//  StoreActions.swift
//  BNUICommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM
import RxSwift

public struct SynchronizeState: StoreAction {
    public init() { }
}

public struct ShowOnRoot: StoreAction {

    //public let root: NavigationRoot
    public let controllerInfo: ControlerWithFactory
    public let navigationBarHidden: Bool

    public init(controller: UIViewController,
                factory: ViewModelFactory,
                animated: Bool = true,
                navigationBarHidden: Bool = true) {

        self.controllerInfo = ControlerWithFactory(controller: controller,
                                                       factory: factory,
                                                       animated: animated)
        self.navigationBarHidden = navigationBarHidden
    }
}

//public struct ShowOnTab: StoreAction {
//    public let controllerInfo: ControlerWithFactory
//    public let navigationBarHidden: Bool
//    public let tab: AnyNavigationTab
//
//    public init<Tab: NavigationTab>(tab: Tab,
//                                    controller: UIViewController,
//                                    factory: ViewModelFactory,
//                                    animated: Bool = true,
//                                    navigationBarHidden: Bool = true) {
//
//        self.controllerInfo = ControlerWithFactory(controller: controller,
//                                                   factory: factory,
//                                                   animated: animated)
//        self.navigationBarHidden = navigationBarHidden
//        self.tab = tab.any
//    }
//}

public struct Push: StoreAction {

    public let controllerInfo: ControlerWithFactory
    public let pop: PopMode?
    public init(controller: UIViewController,
                factory: ViewModelFactory,
                pop: PopMode? = nil,
                animated: Bool = true) {
        self.pop = pop
        self.controllerInfo = ControlerWithFactory(controller: controller,
                                                       factory: factory,
                                                       animated: animated)
    }
}

public enum PopMode {
    case popToRoot, pop(Int)
}

public struct Pop: StoreAction {
    public let animated: Bool
    public let mode: PopMode
    public init(mode: PopMode = .pop(1), animated: Bool = true) {
        self.mode = mode
        self.animated = animated
    }
}

public struct ShowModal: StoreAction {

    public let controllerInfo: ControlerWithFactory
    public let withNavigationController: Bool
    public let showOverSplash: Bool
    public let showOverSelfType: Bool

    public init(controller: UIViewController,
                factory: ViewModelFactory,
                animated: Bool = true,
                withNavigationController: Bool = true,
                showOverSplash: Bool = true,
                showOverSelfType: Bool = true) {

        self.controllerInfo = ControlerWithFactory(controller: controller,
                                                   factory: factory,
                                                   animated: animated)
        self.withNavigationController = withNavigationController
        self.showOverSplash = showOverSplash
        self.showOverSelfType = showOverSelfType
    }
}

public struct DismissModal: StoreAction {

    public let dismissAllViews: Bool
    public let animated: Bool

    public init(dismissAllViews: Bool = false, animated: Bool = true) {
        self.dismissAllViews = dismissAllViews
        self.animated = animated
    }
}

public struct ControlerWithFactory {

    public let controller: UIViewController
    public let factory: ViewModelFactory
    public let animated: Bool

    public init(controller: UIViewController, factory: ViewModelFactory, animated: Bool = true) {
        self.controller = controller
        self.factory = factory
        self.animated = animated
    }
}
