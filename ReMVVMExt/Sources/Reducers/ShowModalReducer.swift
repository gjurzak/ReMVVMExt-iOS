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

    public func onNext<State>(for state: State,
                            action: StoreAction,
                            interceptor: Interceptor<StoreAction, State>,
                            dispatcher: Dispatcher) where State: StoreState {

        guard state is NavigationTreeContainingState, let action = action as? ShowModal else {
            interceptor.next()
            return
        }

        let uiState = self.uiState

        var controller: UIViewController?
        // block if already on screen
        // TODO use some id maybe ? 
        if !action.showOverSelfType {
            controller = action.controllerInfo.loader.load()
            if let modal = uiState.modalControllers.last, type(of: modal) == type(of: controller!) {
                return
            }
        }

        interceptor.next { state in
            // side effect
            guard let state = state as? NavigationTreeContainingState else { return }

            //dismiss not needed modals
            uiState.dismiss(animated: action.controllerInfo.animated,
                            number: uiState.modalControllers.count - state.navigationTree.modals.count + 1)

            let newModal: UIViewController
            if action.withNavigationController {

                let navController = uiState.config.navigation()
                let viewController = controller ?? action.controllerInfo.loader.load()

                navController.viewControllers = [viewController]
                navController.modalTransitionStyle = viewController.modalTransitionStyle
                navController.modalPresentationStyle = viewController.modalPresentationStyle
                newModal = navController
            } else {
                newModal = controller ?? action.controllerInfo.loader.load()
            }

            newModal.modalPresentationStyle = action.presentationStyle
            uiState.present(newModal, animated: action.controllerInfo.animated)
        }
    }
}
