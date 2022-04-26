//
//  StringExtension.swift
//  HEXColor-iOS
//
//  Created by Sergey Pugach on 2/2/18.
//  Copyright © 2018 P.D.Q. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /**
     Convert argb string to rgba string.
     */
    init(stringInterpolationSegment expr: Unwrappable) {
        self = String(describing: expr.unwrap() ?? "")
    }
    var length: Int {
        return self.count
    }
    func size(withFont font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: 1000, height: 1000)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
    
    func height(withFixedWidth fixedWidth:CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: fixedWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withFixedHeight fixedHeight:CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: fixedHeight)
        
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    func convertFromDoubleToCleanString() -> String? {
       // debugPrint("- Function convertFromDoubleToCleanString() \(self)")
        if self.last == "." {
            return self
        }
        
        if let double = Double(self) {
            
            let isInteger = floor(double) == double
            
            if isInteger {
                return "\(Int(double))"
            }
            
            return double.truncate(places: 4).clean
            
        } else {
            return nil
        }
    }
    
    public func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                        options: .usesLineFragmentOrigin,
                                        attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
    
    public var argb2rgba: String? {
        guard self.hasPrefix("#") else {
            return nil
        }
        
        let hexString: String = String(self[self.index(self.startIndex, offsetBy: 1)...])
        switch hexString.count {
        case 4:
            return "#\(String(hexString[self.index(self.startIndex, offsetBy: 1)...]))\(String(hexString[..<self.index(self.startIndex, offsetBy: 1)]))"
        case 8:
            return "#\(String(hexString[self.index(self.startIndex, offsetBy: 2)...]))\(String(hexString[..<self.index(self.startIndex, offsetBy: 2)]))"
        default:
            return nil
        }
    }
    
    var stripped: String {
        let okayChars = Set("+-*%")
        return self.filter {okayChars.contains($0) }
    }
   func substring(_ range: NSRange) -> String {
            let start = self.index(self.startIndex, offsetBy: range.lowerBound)
            let end = self.index(self.startIndex, offsetBy: range.upperBound)
            let subString = self[start..<end]
            return String(subString)
        }
    
    func stringByReplacingFirstOccurrenceOfString(
            target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
        func trimmingTrailingSpaces() -> String {
            var t = self
            while t.hasSuffix(" ") {
              t = "" + t.dropLast()
            }
            return t
        }

        mutating func trimmedTrailingSpaces() {
            self = self.trimmingTrailingSpaces()
        }
}
