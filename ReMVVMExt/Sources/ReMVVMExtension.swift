//
//  ReMVVMExtension.swift
//  ReMVVMExt
//
//  Created by Dariusz Grzeszczak on 07/06/2019.
//

import ReMVVM
import RxSwift
import UIKit

public enum ReMVVMExtension {

    public static func initialize<State: StoreState>(with window: UIWindow,
                                                     uiStateConfig: UIStateConfig,
                                                     state: State,
                                                     stateMappers: [StateMapper<State>] = [],
                                                     reducer: AnyReducer<State>,
                                                     middleware: [AnyMiddleware]) -> Store<State> {

        let uiState = UIState(window: window, config: uiStateConfig)

        let middleware: [AnyMiddleware] = [
            SynchronizeStateMiddleware(uiState: uiState),
            ShowModalMiddleware(uiState: uiState),
            DismissModalMiddleware(uiState: uiState),
            ShowOnRootMiddleware(uiState: uiState),
            ShowOnTabMiddleware(uiState: uiState),
            PushMiddleware(uiState: uiState),
            PopMiddleware(uiState: uiState)
            ] + middleware

        let store = Store<State>(with: state,
                                 reducer: reducer,
                                 middleware: middleware,
                                 stateMappers: stateMappers)

        store.add(observer: EndEditingFormListener<State>(uiState: uiState))
        ReMVVM.initialize(with: store)
        return store
    }
}

public final class EndEditingFormListener<State: StoreState>: StateObserver {

    let uiState: UIState
    var disposeBag = DisposeBag()

    public init(uiState: UIState) {
        self.uiState = uiState
    }

    public func willChange(state: State) {
        uiState.rootViewController.view.endEditing(true)
        uiState.modalControllers.last?.view.endEditing(true)
    }

    public func didChange(state: State, oldState: State?) {
        disposeBag = DisposeBag()

        uiState.navigationController?.rx
            .methodInvoked(#selector(UINavigationController.popViewController(animated:)))
            .subscribe(onNext: { [unowned self] _ in
                self.uiState.rootViewController.view.endEditing(true)
                self.uiState.modalControllers.last?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}
