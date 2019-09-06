//
//  TabBarItemView.swift
//  BNUICommon
//
//  Created by Grzegorz Jurzak on 13/02/2019.
//  Copyright © 2019 HYD. All rights reserved.
//

import Loaders
import ReMVVM
import RxCocoa
import RxSwift
import UIKit

open class TabBarItemView: UIView, ReMVVMDriven {

    var viewModel: TabBarItemViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            bind(viewModel)
        }
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
    fileprivate var tapGesture: UITapGestureRecognizer?

    private let disposeBag = DisposeBag()

    private func bind(_ viewModel: TabBarItemViewModel) {
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.isSelected.map { [weak self] isSelected in isSelected ? self?.tintColor : UIColor.lightGray }
            .subscribe(onNext: { [weak self] color in
                self?.iconImageView.tintColor = color
            })
            .disposed(by: disposeBag)
        viewModel.iconImage.map { UIImage(data: $0)?.withRenderingMode(.alwaysTemplate) }.bind(to: iconImageView.rx.image).disposed(by: disposeBag)

        let alpha = viewModel.isSelected.map { CGFloat($0 ? 1.0 : 0.5) }
        alpha.bind(to: titleLabel.rx.alpha).disposed(by: disposeBag)
        alpha.bind(to: iconImageView.rx.alpha).disposed(by: disposeBag)

        rx.tap
            .skipUntil(viewModel.isSelected).debug()
            .withLatestFrom(viewModel.action)
            .bind(to: remvvm.rx)
            .disposed(by: disposeBag)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }

    open func setupNib() {
        Nib.add(to: self)
    }
}

private extension Reactive where Base: TabBarItemView {

    var tap: ControlEvent<Void> {
        var tapGesture: UITapGestureRecognizer

        if let gesture = base.tapGesture {
            tapGesture = gesture
        } else {
            tapGesture = UITapGestureRecognizer()
            base.addGestureRecognizer(tapGesture)
            base.tapGesture = tapGesture
        }

        return ControlEvent(events: tapGesture.rx.event.map { _ in return })
    }
}
