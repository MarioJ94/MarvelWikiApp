//
//  UIScrollView+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 9/1/22.
//

import Foundation
import UIKit

extension UIScrollView {
    func scrollToPoint(point: CGPoint, animated: Bool) {
        self.layoutIfNeeded()
        let adjustedInsets = self.adjustedContentInset
        let maximumPointToScrollX = self.contentSize.width - self.frame.width + adjustedInsets.right
        let maximumPointToScrollY = self.contentSize.height - self.frame.height + adjustedInsets.bottom
        
        let minimumPointToScrollX = -adjustedInsets.left
        let minimumPointToScrollY = -adjustedInsets.top
        
        let totalWidth = self.contentSize.width + adjustedInsets.left + adjustedInsets.right
        let totalHeight = self.contentSize.height + adjustedInsets.top + adjustedInsets.bottom

        let adjustedMaxX : CGFloat
        if totalWidth >= self.frame.width {
            adjustedMaxX = maximumPointToScrollX
        } else {
            adjustedMaxX = -adjustedInsets.left
        }
        let adjustedMaxY : CGFloat
        if totalHeight >= self.frame.height {
            adjustedMaxY = maximumPointToScrollY
        } else {
            adjustedMaxY = -adjustedInsets.top
        }
        let x = max(min(point.x, adjustedMaxX), minimumPointToScrollX)
        let y = max(min(point.y, adjustedMaxY), minimumPointToScrollY)
        let pointToScroll = CGPoint(x: x, y: y)
        self.setContentOffset(pointToScroll, animated: animated)
    }
    
    func scrollToPointVisible(point: CGPoint, animated: Bool) {
        let rect = CGRect(x: contentOffset.x, y: contentOffset.y, width: visibleSize.width, height: visibleSize.height)
        guard !rect.contains(point) else {
            return
        }
        self.scrollToPoint(point: point, animated: animated)
    }
}
