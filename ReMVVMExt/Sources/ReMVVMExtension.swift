//
//  ReMVVMExtension.swift
//  ReMVVMExt
//
//  Created by Dariusz Grzeszczak on 07/06/2019.
//

import ReMVVM
import RxSwift

public enum ReMVVMExtension {

    public static func initialize<State: StoreState>(with window: UIWindow,
                                                     uiStateConfig: UIStateConfig,
                                                     state: State,
                                                     reducer: AnyReducer<State>,
                                                     middleware: [AnyMiddleware]) -> Store<State> {

        let uiState = UIState(window: window, config: uiStateConfig)

        let middleware: [AnyMiddleware] = [
            ShowModalMiddleware(uiState: uiState),
            DismissModalMiddleware(uiState: uiState),
            ShowOnRootMiddleware(uiState: uiState),
            ShowOnTabMiddleware(uiState: uiState),
            PushMiddleware(uiState: uiState),
            PopMiddleware(uiState: uiState),
            SynchronizeStateMiddleware(uiState: uiState)
            ] + middleware

        let store = Store<State>(with: state, reducer: reducer, middleware: middleware)
        store.add(subscriber: EndEditingFormListener<State>(uiState: uiState))
        ReMVVMConfig.initialize(with: store)
        return store
    }
}

public final class EndEditingFormListener<State: StoreState>: StateSubscriber {

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
