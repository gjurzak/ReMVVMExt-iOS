//
//  ShowTabReducer.swift
//  ReMVVMExt
//
//  Created by DGrzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import Loaders
import ReMVVM

public enum NavigationTabReducer {

    public static let reducers: [AnyReducer<AnyNavigationTab?>] = [NavigationTabShowOnTabReducer.any, NavigationTabShowOnRootReducer.any]
}

struct NavigationTabShowOnTabReducer: Reducer {

    public typealias Action = ShowOnTab

    public static func reduce(state: AnyNavigationTab?, with action: ShowOnTab) -> AnyNavigationTab? {
        return action.tab
    }
}

struct NavigationTabShowOnRootReducer: Reducer {

    public typealias Action = ShowOnRoot

    public static func reduce(state: AnyNavigationTab?, with action: ShowOnRoot) -> AnyNavigationTab? {
        return nil
    }
}

public struct ShowOnTabMiddleware: AnyMiddleware {

    public let uiState: UIState

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func next<State>(for state: State, action: StoreAction, middlewares: AnyMiddlewares<State>, dispatcher: StoreActionDispatcher) where State : StoreState {

        guard let state = state as? NavigationTabState, let tabAction = action as? ShowOnTab else {
            middlewares.next(action: action)
            return
        }

        guard state.currentTab != tabAction.tab else { return }

        let uiState = self.uiState

        if let tabController = uiState.rootViewController as? TabBarViewController {
            tabController.findNavigationController()?
                .setViewControllers([tabAction.controllerInfo.controller],
                                    animated: tabAction.controllerInfo.animated)
        } else {
            let tabViewController: UIViewController = TabBarStoryboards.TabBar.initialViewController()
            tabViewController.loadViewIfNeeded()
            tabViewController.findNavigationController()?
                .setViewControllers([tabAction.controllerInfo.controller],
                                    animated: false)

            uiState.setRoot(controller: tabViewController,
                            animated: tabAction.controllerInfo.animated,
                            navigationBarHidden: tabAction.navigationBarHidden)
        }

        // dismiss modals
        uiState.rootViewController.dismiss(animated: true, completion: nil)
    }
}

enum TabBarStoryboards {
    enum TabBar: Storyboard, HasInitialController { }
}
