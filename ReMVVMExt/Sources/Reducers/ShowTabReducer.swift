//
//  ShowTabReducer.swift
//  ReMVVMExt
//
//  Created by DGrzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import Loaders
import ReMVVM

public struct TabBarConfig {
    public static var tabBarViewController: (() -> UIViewController) = {
        return TabBarStoryboards.TabBar.instantiateInitialViewController()
    }
}

public enum NavigationTabReducer {
    public static func reduce(state: AnyNavigationTab?, with action: StoreAction) -> AnyNavigationTab? {
        return reducer.reduce(state: state, with: action)
    }

    static let reducer = AnyReducer(with: reducers)
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

    public func onNext<State>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: StoreActionDispatcher) where State : StoreState {

        guard let state = state as? NavigationTabState, let tabAction = action as? ShowOnTab else {
            interceptor.next(action: action)
            return
        }

        guard state.currentTab != tabAction.tab else { return }

        interceptor.next(action: action) { [uiState] state in

            if let tabController = uiState.rootViewController as? TabBarViewController {
                tabController.findNavigationController()?
                    .setViewControllers([tabAction.controllerInfo.loader.load()],
                                        animated: false)
            } else {

                let loader = Loader {
                    let tabViewController: UIViewController = TabBarConfig.tabBarViewController()
                    (tabViewController as? TabBarViewController)?.tabItemCreator = tabAction.tabItemCreator
                    tabViewController.loadViewIfNeeded()
                    tabViewController.findNavigationController()?
                        .setViewControllers([tabAction.controllerInfo.loader.load()],
                                            animated: false)

                    uiState.setRoot(controller: tabViewController,
                                    animated: tabAction.controllerInfo.animated,
                                    navigationBarHidden: tabAction.navigationBarHidden)
                    return tabViewController
                }

                dispatcher.dispatch(action: ShowOnRoot(loader: loader,
                                                       factory: tabAction.controllerInfo.factory,
                                                       animated: tabAction.controllerInfo.animated,
                                                       navigationBarHidden: tabAction.navigationBarHidden))
            }

            // dismiss modals
            uiState.rootViewController.dismiss(animated: true, completion: nil)
        }
    }
}

enum TabBarStoryboards {
    enum TabBar: Storyboard, HasInitialController { }
}
