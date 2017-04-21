//
//  InputView.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

public final class InputView: UIView {}

extension InputView: InputViewIdentifierType {
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // Disable this to avoid unwanted constraints.
        translatesAutoresizingMaskIntoConstraints = false
    }
}
