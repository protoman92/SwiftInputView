//
//  IncrementalIdentifierType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Implement this protocol to provide functionalities to search for an
/// incremental Array of identifiers. This is useful in the context of input
/// views with multiple inputs, leading to subviews from each input having
/// identifiers that differ by postfix numbers.
public protocol IncrementalIdentifierType {
    associatedtype Element
    
    /// Find an Element that has an identifier.
    ///
    /// - Parameter identifier: A String value.
    /// - Returns: An optional Element instance.
    func findElement(with identifier: String) -> Element?
}

public extension IncrementalIdentifierType {
    
    /// Recursively find all elements using a base identifier and a starting
    /// index.
    ///
    /// - Parameters:
    ///   - base: A String value. This base will be concat with indexes.
    ///   - index: An Int value.
    /// - Returns: An Array of Element.
    func findAll(withBaseIdentifier base: String,
                 andStartingIndex index: Int) -> [Element] {
        var elements = [Element]()
        var currentIndex = index
        
        while let element = self.findElement(with: "\(base)\(currentIndex)") {
            elements.append(element)
            currentIndex += 1
        }
        
        return elements
    }
}
