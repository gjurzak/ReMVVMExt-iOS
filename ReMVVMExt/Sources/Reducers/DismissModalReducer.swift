//
//  DismissModalReducer.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM

public struct DismissModalReducer: Reducer {

    public typealias Action = DismissModal

    public static func reduce(state: NavigationTree, with action: DismissModal) -> NavigationTree {

        //let root = state.root
        let stack = state.stack

        var modals = state.modals
        if action.dismissAllViews {
            modals.removeAll()
        } else {
            modals.removeLast()
        }
        return NavigationTree(stack: stack, modals: modals)
    }

}

public struct DismissModalMiddleware: AnyMiddleware {

    public let uiState: UIState

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func next<State>(for state: State,
                            action: StoreAction,
                            middlewares: AnyMiddlewares<State>,
                            dispatcher: StoreActionDispatcher) where State: StoreState {

        guard state is NavigationTreeContainingState, let action = action as? DismissModal else {
            middlewares.next()
            return
        }

        let uiState = self.uiState

        guard !uiState.modalControllers.isEmpty else { return }

        middlewares.next { _ in
            // side effect

            //dismiss not needed modals
            if action.dismissAllViews {
                uiState.dismissAll(animated: action.animated)
            } else {
                uiState.dismiss(animated: action.animated)
            }
        }

    }
}
