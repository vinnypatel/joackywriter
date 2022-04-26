//
//  String.swift
//  JoackyWriter
//
//  Created by Ilya Kulbakin on 01/03/2017.
//  Copyright © 2017 Jenex Software. All rights reserved.
//

import UIKit
extension NSAttributedString {
    
    func height(withFixedWidth fixedWidth:CGFloat) -> CGFloat {
        
        let constraintRect = CGSize(width: fixedWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withFixedHeight fixedHeight:CGFloat) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: fixedHeight)
        
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            context: nil)
        return ceil(boundingBox.width)
    }
}

public protocol Unwrappable {
    func unwrap() -> Any?
}

extension Optional: Unwrappable {
    public func unwrap() -> Any? {
        switch self {
        case .none:
            return nil
        case .some(let unwrappable as Unwrappable):
            return unwrappable.unwrap()
        case .some (let some):
            return some
        }
    }
}

