//
//  TabBarViewController.swift
//  BNCommon
//
//  Created by Grzegorz Jurzak on 12/02/2019.
//  Copyright © 2019 HYD. All rights reserved.
//

import Loaders
import ReMVVM
import RxCocoa
import RxSwift
import UIKit

public class TabBarViewController: UIViewController, ReMVVMDriven {

    public var tabItemCreator: (() -> UIView)?
    @IBOutlet private var tabBarStackView: UIStackView!

    private var disposeBag = DisposeBag()

    override public var childForStatusBarStyle: UIViewController? {
        return findNavigationController()?.topViewController
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let viewModel: TabBarViewModel = remvvm.viewModel(for: self) else { return }
        bind(viewModel)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    private func bind(_ viewModel: TabBarViewModel) {

        viewModel.tabBarItemsViewModels
            .map { [unowned self] in $0.map { self.tabBarItem(for: $0) } }
            .bind(to: tabBarStackView.rx.items)
            .disposed(by: disposeBag)
    }

    private func tabBarItem(for viewModel: TabBarItemViewModel) -> UIView {
        if let tabItemCreator = tabItemCreator {
            return tabItemCreator()
        }
        let view = TabBarItemView(frame: CGRect.zero)
        view.viewModel = viewModel
        return view
    }
}

extension Reactive where Base: UIStackView {

    var items: Binder<[UIView]> {
        return Binder(base) { stackView, views in
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            views.forEach { stackView.addArrangedSubview($0) }
        }
    }
}
