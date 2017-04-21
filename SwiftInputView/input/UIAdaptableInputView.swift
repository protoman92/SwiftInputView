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
    
    /// This inputField can either be a UITextField or a PlaceholderTextView.
    fileprivate var inputField: InputFieldType? {
        return subviews.filter({
            $0.accessibilityIdentifier == inputFieldIdentifier
        }).first as? InputFieldType
    }
}

public extension Reactive where Base: UIAdaptableInputView {
    
}
