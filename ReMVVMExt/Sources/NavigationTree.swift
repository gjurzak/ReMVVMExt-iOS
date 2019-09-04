//
//  StateTree.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak on 12/02/2019.
//  Copyright © 2019. All rights reserved.
//

import ReMVVM

public protocol NavigationTreeContainingState: StoreState {

    var navigationTree: NavigationTree { get }
}

public struct NavigationTree {
    public let stack: [ViewModelFactory]
    public let modals: [Modal]

    public init(
        stack: [ViewModelFactory], modals: [Modal]) {
        self.stack = stack
        self.modals = modals
    }

    public var factory: ViewModelFactory {
        return modals.last?.factory ?? stack.last ?? CompositeViewModelFactory()
    }

    public enum Modal {
        case single(ViewModelFactory)
        case navigation([ViewModelFactory])

        public var factory: ViewModelFactory? {
            switch self {
            case .single(let factory): return factory
            case .navigation(let stack): return stack.last
            }
        }

        public var hasNavigation: Bool {
            guard case .navigation = self else { return false }
            return true
        }
    }

    public var topStack: [ViewModelFactory] {
        if let modal = modals.last {
            guard case .navigation(let stack) = modal else { return [] }
            return stack
        } else {
            return stack
        }
    }
}

public enum NavigationTreeReducer {

    public static func reduce(state: NavigationTree, with action: StoreAction) -> NavigationTree {
        return reducer.reduce(state: state, with: action)
    }

    static let reducer = AnyReducer(with: reducers)
    static let reducers: [AnyReducer<NavigationTree>] = [
        ShowOnRootReducer.any,
        ShowOnTabReducer.any,
        SynchronizeStateReducer.any,
        PushReducer.any,
        PopReducer.any,
        ShowModalReducer.any,
        DismissModalReducer.any
    ]
}
