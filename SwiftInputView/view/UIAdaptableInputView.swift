//
//  InputView.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftBaseViews
import SwiftUIUtilities
import UIKit

/// This UIView subclass can adapt itself to different input types. For each
/// input type, we should define a InputViewBuilder subclass and 
/// InputViewBuilderConfig.
public final class UIAdaptableInputView: UIView {
    
    fileprivate lazy var presenter: Presenter = Presenter(view: self)
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // Disable this to avoid unwanted constraints.
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Presenter class for UIAdaptableInputView.
    fileprivate class Presenter: BaseViewPresenter {
        fileprivate let disposeBag = DisposeBag()
        
        fileprivate init(view: UIAdaptableInputView) {
            super.init(view: view)
        }
    }
}

extension UIAdaptableInputView: TextInputViewComponentType {
    public var disposeBag: DisposeBag {
        return presenter.disposeBag
    }
}

extension UIAdaptableInputView: TextInputViewIdentifierType {}

public extension UIAdaptableInputView {
    
    /// Get all parent subviews using a base identifier.
    fileprivate var parentSubviews: [UIView] {
        let id = parentSubviewId
        let views = findAll(withBaseIdentifier: id, andStartingIndex: 1)
        return views.isNotEmpty ? views : [self]
    }
    
    /// Get all InputFieldType instances.
    public var inputFields: [InputFieldType] {
        let parentSubviews = self.parentSubviews
        
        return parentSubviews
            .flatMap({$0.subviews})
            .flatMap({$0 as? InputFieldType})
    }
}

public extension Reactive where Base: UIAdaptableInputView {
    
    /// Use this Observable to observe text changes.
    public var text: Observable<String?> {
        return base.inputFields
            .map({$0.rxText})
            .flatMap({$0})
            .mergeAsObservable()
    }
}
