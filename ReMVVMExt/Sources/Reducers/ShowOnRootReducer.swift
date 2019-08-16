//
//  ShowOnRootReducer.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM

struct ShowOnRootReducer: Reducer {

    public static func reduce(state: NavigationTree, with action: ShowOnRoot) -> NavigationTree {

        return NavigationTree(stack: [action.controllerInfo.factory], modals: [])
    }
}

//struct ShowOnTabReducer: Reducer {
//
//    public static func reduce(state: NavigationTree, with action: ShowOnTab) -> NavigationTree {
//
//        return NavigationTree(stack: [action.controllerInfo.factory], modals: [])
//    }
//}

public struct ShowOnRootMiddleware: AnyMiddleware {

    public let uiState: UIState

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func next<State>(for state: State,
                            action: StoreAction,
                            middlewares: AnyMiddlewares<State>,
                            dispatcher: StoreActionDispatcher) where State: StoreState {

        guard state is NavigationTreeContainingState, let action = action as? ShowOnRoot else {
            middlewares.next()
            return
        }

        let uiState = self.uiState

        middlewares.next { _ in // newState - state variable is used below
            // side effect

            uiState.setRoot(controller: action.controllerInfo.controller,
                            animated: action.controllerInfo.animated,
                            navigationBarHidden: action.navigationBarHidden)

            // dismiss modals
            uiState.rootViewController.dismiss(animated: true, completion: nil)
        }
    }
}
