//
//  ShowModalReducer.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM

public struct ShowModalReducer: Reducer {

    public typealias Action = ShowModal

    public static func reduce(state: NavigationTree, with action: ShowModal) -> NavigationTree {

        let stack = state.stack
        //let root = state.root

        let factory = action.controllerInfo.factory
        let modal: NavigationTree.Modal = action.withNavigationController ? .navigation([factory]) : .single(factory)
        // dismiss all modals without navigation
        let modals = state.modals.reversed().drop { !$0.hasNavigation }.reversed() + [modal]

        return NavigationTree(//root: root,
                         stack: stack, modals: modals)
    }
}

public struct ShowModalMiddleware: AnyMiddleware {

    public let uiState: UIState
    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func next<State>(for state: State,
                            action: StoreAction,
                            middlewares: AnyMiddlewares<State>,
                            dispatcher: StoreActionDispatcher) where State: StoreState {

        guard state is NavigationTreeContainingState, let action = action as? ShowModal else {
            middlewares.next()
            return
        }

        let uiState = self.uiState

        // block if already on screen
        if !action.showOverSelfType, let modal = uiState.modalControllers.last,
            type(of: modal) == type(of: action.controllerInfo.controller) {

            return
        }

        middlewares.next { state in
            // side effect
            guard let state = state as? NavigationTreeContainingState else { return }

            //dismiss not needed modals
            uiState.dismiss(animated: action.controllerInfo.animated,
                            number: uiState.modalControllers.count - state.navigationTree.modals.count + 1)

            var controller = action.controllerInfo.controller
            if action.withNavigationController {

                let navController = uiState.config.navigation()
                let viewController = action.controllerInfo.controller

                navController.viewControllers = [viewController]
                navController.modalTransitionStyle = viewController.modalTransitionStyle
                navController.modalPresentationStyle = viewController.modalPresentationStyle
                controller = navController
            }

            uiState.present(controller, animated: action.controllerInfo.animated)
        }
    }
}
