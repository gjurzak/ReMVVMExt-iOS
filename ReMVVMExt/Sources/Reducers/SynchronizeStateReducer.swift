//
//  SynchronizeStateReducer.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM
import RxSwift
import RxCocoa

// needed to synchronize the state when user use back button or swipe gesture
struct SynchronizeStateReducer: Reducer {

    public typealias Action = SynchronizeState

    public static func reduce(state: NavigationTree, with action: SynchronizeState) -> NavigationTree {
        return PopReducer.reduce(state: state, with: Pop())
    }
}

public final class SynchronizeStateMiddleware: AnyMiddleware {
    public let uiState: UIState

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    private var disposeBag = DisposeBag()

    public func onNext<State>(for state: State,
                            action: StoreAction,
                            middlewares: AnyMiddlewares<State>,
                            dispatcher: StoreActionDispatcher) where State: StoreState {

        guard let state = state as? NavigationTreeContainingState else {
            middlewares.next()
            return
        }

        if action is SynchronizeState {
            guard   let navigationCount = uiState.navigationController?.viewControllers.count,
                    state.navigationTree.topStack.count > navigationCount
            else { return }

            middlewares.next()
        } else {
            middlewares.next { [weak self] _ in
                let disposeBag = DisposeBag()
                self?.disposeBag = disposeBag
                self?.uiState.navigationController?.rx.didShow
                    .subscribe(onNext: { _ in
                        dispatcher.dispatch(action: SynchronizeState())
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
}
