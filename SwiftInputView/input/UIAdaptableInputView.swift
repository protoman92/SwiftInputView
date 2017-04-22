//
//  InputView.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftUIUtilities
import UIKit

/// This UIView subclass can adapt itself to different input types. For each
/// input type, we should define a InputViewBuilder subclass and 
/// InputViewBuilderConfig.
public final class UIAdaptableInputView: UIView {
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // Disable this to avoid unwanted constraints.
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIAdaptableInputView: TextInputViewIdentifierType {}

public extension UIAdaptableInputView {
    
    /// Get all parent subviews using a base identifier.
    fileprivate var parentSubviews: [UIView] {
        let id = parentSubviewIdentifier
        var views = findAll(withBaseIdentifier: id, andStartingIndex: 1)
        
        // We need to add the current view as well, in case there is only
        // one input.
        views.append(self)
        return views
    }
    
    /// Get all InputFieldType instances.
    fileprivate var inputFields: [InputFieldType] {
        let parentSubviews = self.parentSubviews
        
        return parentSubviews
            .map({$0.subviews})
            .reduce([], +)
            .flatMap({$0 as? InputFieldType})
    }
}

public extension Reactive where Base: UIAdaptableInputView {
    public var text: Observable<String?> {
        return base.inputFields
            .map({$0.rxText})
            .flatMap({$0?.asObservable()})
            .mergeAsObservable()
    }
}
