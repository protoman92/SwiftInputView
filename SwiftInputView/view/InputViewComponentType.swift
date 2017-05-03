//
//  InputViewComponentType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftUIUtilities
import UIKit

/// Views that hold a single input should implement this protocol. E.g.
/// UIInputComponentView when there are multiple inputs, or
/// UIAdaptableInputView when there is only one input.
public protocol InputViewComponentType: InputViewIdentifierType {
    var disposeBag: DisposeBag { get }
    
    /// Emulate properties of a UIView.
    var subviews: [UIView] { get }
}

/// Protocol for component views that hold text-based inputs.
public protocol TextInputViewComponentType:
    InputViewComponentType,
    TextInputViewIdentifierType {}

public extension TextInputViewComponentType {
    
    /// Get the requiredIndicator label. It can be nil if we are calling this
    /// property from a UIAdaptableInputView that has more than one input,
    /// or the input is not required (thus it is not inflated in the first
    /// place)
    public var requiredIndicator: UILabel? {
        return subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first as? UILabel
    }
    
    /// Get the main input field. This can be nil in case we are using a
    /// UIAdaptableInputView with more than one input.
    public var inputField: InputFieldType? {
        return subviews.filter({
            $0.accessibilityIdentifier == inputFieldId
        }).first as? InputFieldType
    }
    
    /// Get the inputField's rxText ControlProperty.
    public var rxText: Observable<String?> {
        return inputField?.rxText ?? Observable.empty()
    }
    
    /// Setup the inputField. There is at least one thing we want to do here:
    /// attach an observer to the inputField's rxText ControlProperty so that
    /// we can fade in/fade out the required indicator when there is no text
    /// or otherwise.
    public func setupInputField() {
        let disposeBag = self.disposeBag
        
        rxText.doOnNext(toggleRequiredIndicator)
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
    /// Toggle the required indicator if appropriate.
    ///
    /// - Parameter text: The current text displayed by the inputField.
    fileprivate func toggleRequiredIndicator(whileInputIs text: String?) {
        guard let indicator = requiredIndicator else {
            return
        }
        
        if let text = text, text.isNotEmpty, indicator.alpha == 1 {
            indicator.toggleVisible(toBe: false)
        } else if (text == nil || text!.isEmpty) && indicator.alpha < 1 {
            indicator.toggleVisible(toBe: true, withDuration: 0)
        }
    }
}
