//
//  ShowTabReducer.swift
//  ReMVVMExt
//
//  Created by DGrzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM

public enum NavigationTabReducer {

    public static let retucers: [AnyReducer<AnyNavigationTab?>] = [NavigationTabShowOnTabReducer.any, NavigationTabShowOnRootReducer.any]
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

    public func applyMiddleware<State>(for state: State,
                                       action: StoreAction,
                                       dispatcher: AnyDispatcher<State>) where State: StoreState {

        guard let state = state as? NavigationTabState, let action = action as? ShowOnTab else {
            dispatcher.next()
            return
        }

        guard state.currentTab != action.tab else { return }

        let uiState = self.uiState

        dispatcher.next { _ in // newState - state variable is used below
            // side effect

            if let tabController = uiState.rootViewController as? TabBarViewController {
                tabController.findNavigationController()?
                    .setViewControllers([action.controllerInfo.controller],
                                        animated: action.controllerInfo.animated)
            } else {
                let tabViewController: TabBarViewController! = nil //todo dg
                tabViewController.loadViewIfNeeded()
                tabViewController.findNavigationController()?
                    .setViewControllers([action.controllerInfo.controller],
                                        animated: false)

                uiState.setRoot(controller: action.controllerInfo.controller,
                                animated: action.controllerInfo.animated,
                                navigationBarHidden: action.navigationBarHidden)
            }

            // dismiss modals
            uiState.rootViewController.dismiss(animated: true, completion: nil)
        }
    }
}
