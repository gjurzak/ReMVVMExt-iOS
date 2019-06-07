//
//  ReMVVM+Rx.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM
import RxSwift

extension ReMVVM: ReactiveCompatible { }
extension Store: ReactiveCompatible { } 

extension Reactive: ObserverType where Base: StoreActionDispatcher {
    public func on(_ event: Event<StoreAction>) {
        guard let action = event.element else { return }
        base.dispatch(action: action)
    }
}

extension Reactive where Base: StateSubject & AnyStateSubject {

    public var state: Observable<Base.State> {
        let base = self.base
        guard let state = base.state else { return .empty() }

        return Observable.create { observer in
            let subscriber = Subscriber(observer)
            base.add(subscriber: subscriber)

            return Disposables.create {
                base.remove(subscriber: subscriber)
            }
        }
        .startWith(state)
        .share(replay: 1)
    }

    private class Subscriber: StateSubscriber {

        let observer: AnyObserver<Base.State>
        init(_ observer: AnyObserver<Base.State>) {
            self.observer = observer
        }

        func didChange(state: Base.State, oldState: Base.State) {
            observer.onNext(state)
        }
    }
}
