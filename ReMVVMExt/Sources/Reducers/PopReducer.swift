//
//  PopReducer.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM

public struct PopReducer: Reducer {

    public typealias Action = Pop

    public static func reduce(state: NavigationTree, with action: Pop) -> NavigationTree {
        return updateStateTree(state, for: action.mode)
    }

    private static func updateStateTree(_ stateTree: NavigationTree, for mode: PopMode) -> NavigationTree {
        switch mode {
        case .popToRoot:
            return popStateTree(stateTree, dropCount: stateTree.topStack.count - 1)
        case .pop(let count):
            return popStateTree(stateTree, dropCount: count)
        }
    }

    private static func popStateTree(_ stateTree: NavigationTree, dropCount: Int) -> NavigationTree {
        guard dropCount > 0, stateTree.topStack.count > dropCount else { return stateTree }
        let newStack = Array(stateTree.topStack.dropLast(dropCount))

        let hasModal = !stateTree.modals.isEmpty
        let stack = hasModal ? stateTree.stack : newStack
        let modals = hasModal ? Array(stateTree.modals.dropLast()) + [.navigation(newStack)] : stateTree.modals
        return NavigationTree(//root: stateTree.root,
                         stack: stack, modals: modals)
    }

}

public struct PopMiddleware: AnyMiddleware {

    public let uiState: UIState

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func onNext<State>(for state: State,
                            action: StoreAction,
                            interceptor: MiddlewareInterceptor<StoreAction, State>,
                            dispatcher: StoreActionDispatcher) where State: StoreState {

        guard let state = state as? NavigationTreeContainingState, let action = action as? Pop else {
            interceptor.next()
            return
        }

        guard state.navigationTree.topStack.count > 1 else { return }

        interceptor.next { _ in
            // side effect

            switch action.mode {
            case .popToRoot:
                self.uiState.navigationController?.popToRootViewController(animated: action.animated)
            case .pop(let count):
                if count > 1 {
                    let viewControllers = self.uiState.navigationController?.viewControllers ?? []
                    let dropCount = min(count, viewControllers.count - 1) - 1
                    let newViewControllers = Array(viewControllers.dropLast(dropCount))
                    self.uiState.navigationController?.setViewControllers(newViewControllers, animated: false)
                }

                self.uiState.navigationController?.popViewController(animated: action.animated)
            }

        }

    }

}
