//
//  TouchableStackView.swift
//  CollectionViewWaterfallLayout
//
//  Created by Adam Podsiadlo on 24/07/2020.
//

import UIKit
import Foundation

@available(iOS 9.0, *)
class TouchableStackView: UIStackView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
}
