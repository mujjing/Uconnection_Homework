//
//  NSObject.swift
//  Uconnection_Homework
//
//  Created by 전지훈 on 2021/11/01.
//

import Foundation
import RxSwift

extension NSObject: AssociatableObjectProtocol {
    
    var disposeBag: DisposeBag {
        let key = "disposeBag"
        if let bag = associatedObjectContainer[key] as? DisposeBag {
            return bag
        } else {
            let bag = DisposeBag()
            associatedObjectContainer[key] = bag
            return bag
        }
    }
    
}


extension Range where Bound == String.Index {
    var nsRange: NSRange {
        return NSRange(location: self.lowerBound.encodedOffset, length: self.upperBound.encodedOffset - self.lowerBound.encodedOffset)
    }
}
