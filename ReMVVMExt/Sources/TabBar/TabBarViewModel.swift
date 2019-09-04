//
//  TabBarViewModel.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak on 12/02/2019.
//  Copyright © 2019 HYD. All rights reserved.
//

import ReMVVM
import RxSwift

public final class TabBarViewModel: StateSubscriber, ReMVVMDriven {
    public typealias State = NavigationTabState

    public let tabBarItemsViewModels: Observable<[TabBarItemViewModel]>

    public init() {
        tabBarItemsViewModels = TabBarViewModel.remvvm.rx.state
            .map { state in
                return type(of: state).allTabs.map {
                    TabBarItemViewModel(tab: $0, isSelected: $0 == state.currentTab)
                }
            }
    }
}

public protocol NavigationTabState: StoreState {
    var currentTab: AnyNavigationTab? { get }
    static var allTabs: [AnyNavigationTab] { get }
}

public struct AnyNavigationTab: NavigationTab {

    public let title: String
    public let iconImage: Data
    public let action: StoreAction
}

public protocol NavigationTab: Equatable {
    var title: String { get }
    var iconImage: Data { get }
    var action: StoreAction { get }
}

extension NavigationTab {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.title == rhs.title
    }

    public var any: AnyNavigationTab {
        return AnyNavigationTab(title: title,
                                iconImage: iconImage,
                                action: action)
    }
}

extension Array where Element: NavigationTab {
    public var any: [AnyNavigationTab] {
        return map { $0.any }
    }
}
