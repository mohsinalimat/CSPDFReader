//
//  CSPDFPage.swift
//  CSPDFReader
//
//  Created by 享印科技 on 2018/11/13.
//

import Foundation

public extension CGPDFPage {
    
    var originalPageRect: CGRect {
        switch rotationAngle {
        case 90, 270:
            let originalRect = getBoxRect(.mediaBox)
            let rotatedSize = CGSize(width: originalRect.height, height: originalRect.width)
            return CGRect(origin: originalRect.origin, size: rotatedSize)
        default:
            return getBoxRect(.mediaBox)
        }
    }
    
}


public extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
