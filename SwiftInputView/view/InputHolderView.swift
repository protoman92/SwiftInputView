//
//  InputHolderView.swift
//  SwiftInputView
//
//  Created by Hai Pham on 5/3/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import SwiftUIUtilities
import UIKit

/// Views that hold inputs should implement this protocol. E.g:
/// - UIAdaptableInputListView.
/// - UIAdaptableInputView.
/// - UIInputComponentView.
@objc public protocol InputHolderViewType: class {
    
    /// This ControllerPresentableType instance is used to present view
    /// controllers that are required as part of the input process. For e.g.,
    /// for choice-based input whereby the user needs to display a dialog
    /// view controller, this presenter shall be used.
    ///
    /// If this variable is nil, traverse upwards the view hierarchy to find
    /// a superview that also implements InputHolderViewType and get its
    /// controllerPresentable instance. This way, all InputHolderViewType
    /// can share the same ControllerPresentableType instance.
    @objc optional weak var controllerPresentable: ControllerPresentableType? { get set }
}

public extension InputHolderViewType where Self: UIView {
    
    /// If the current InputHolderViewType does not have controllerPresentable
    /// set, check its superviews.     
    weak var controllerPresenter: ControllerPresentableType? {
        guard let view = superview(satisfying: {
            (($0 as? InputHolderViewType)?.controllerPresentable ?? nil) != nil
        }) as? InputHolderViewType else {
            return nil
        }
        
        return view.controllerPresentable ?? nil
    }
}
