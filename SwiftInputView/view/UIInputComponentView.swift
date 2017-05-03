//
//  UIInputComponentView.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftBaseViews
import SwiftUIUtilities
import SwiftUtilities
import UIKit

/// Each instance of this view shall serve as a component within a multi-input
/// UIAdaptableInputView.
public final class UIInputComponentView: UIView {
    lazy var presenter: Presenter = Presenter(view: self)
    
    /// Presenter class for UIInputComponentView
    class Presenter: BaseViewPresenter {
        let disposeBag = DisposeBag()
        
        init(view: UIInputComponentView) { super.init(view: view) }
    }
}

extension UIInputComponentView: InputHolderViewType {}
extension UIInputComponentView.Presenter: TextInputViewIdentifierType {}

extension UIInputComponentView: TextInputViewComponentType {
    public var disposeBag: DisposeBag { return presenter.disposeBag }
}

extension UIInputComponentView.Presenter {
    
    /// Get the viewDelegate as a UIInputComponentView instance.
    var view: UIInputComponentView? {
        return viewDelegate as? UIInputComponentView
    }
}
