//
//  PhotoEditor+Export.swift
//  appcenter-analytics
//
//  Created by Adam Podsiadlo on 28/07/2020.
//

import Foundation
import UIKit

struct GifImage {
    let image: UIImageView
    let url: String
    
    init(image: UIImageView, url: String) {
        self.image = image
        self.url = url
    }
}

struct Size: Codable, Hashable {
    let height: Int
    let width: Int
    
    init(width: Int = 0, height: Int = 0) {
        self.width = width
        self.height = height
    }
}

struct Point: Codable, Hashable {
    var x: CGFloat
    var y: CGFloat
    
    init(x: CGFloat = 0, y: CGFloat = 0) {
        self.x = x
        self.y = y
    }
}

struct ExpressionLayer: Codable, Hashable {
    var size: Size?
    var center: Point
    var aspectRatio: Int?
    var zIndex: Int?
    var angle: Int?
    var text: String?
    var textColor: String?
    var textStyle: String?
    var textSize: CGFloat?
    var contentUrl: String?
    
    init(size: Size? = nil, center: Point = Point(), aspectRatio: Int? = nil, zIndex: Int? = nil, angle: Int? = nil,
         text: String? = nil, textColor: String? = nil, textSize: CGFloat? = nil, textStyle: String? = nil, contentUrl: String? = nil) {
        self.size = size
        self.center = center
        self.aspectRatio = aspectRatio
        self.zIndex = zIndex
        self.angle = angle
        self.text = text
        self.textColor = textColor
        self.textStyle = textStyle
        self.textSize = textSize
        self.contentUrl = contentUrl
    }
}

struct Expression: Codable, Hashable {
    var backgroundColor: String?
    var backgroundImage: String?
    var layers: [ExpressionLayer]
    
    init(backgroundColor: String? = nil, backgroundImage: String? = nil, layers: [ExpressionLayer] = []) {
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.layers = layers
    }
}

extension PhotoEditorViewController {
    public func exportExpression () -> String? {
        var expression = Expression()
        
        if let imageUrl = imageBgUrl {
            expression.backgroundImage = imageUrl
        } else {
            expression.backgroundColor = imageBg.backgroundColor?.hexString
        }
        
        if let textView = activeTextView {
            var textLayer = ExpressionLayer()
            textLayer.textColor = textView.textColor?.hexString
            textLayer.textStyle = textView.font?.familyName
            textLayer.textSize = textView.font?.pointSize
            textLayer.zIndex = canvasImageView.subviews.index(of: textView)
            textLayer.center = Point(x: textView.layer.position.x, y: textView.layer.position.y)
            textLayer.text = textView.text
            
            if (textLayer.text != nil && !textLayer.text!.isEmpty) {
                expression.layers.append(textLayer)
            }
        }
        
        for gif in gifsSources {
            var gifLayer = ExpressionLayer()
            gifLayer.contentUrl = gif.url
            gifLayer.zIndex = canvasImageView.subviews.index(of: gif.image)
            gifLayer.center = Point(x: gif.image.layer.position.x, y: gif.image.layer.position.y)
            
            expression.layers.append(gifLayer)
        }
        
        var jsonData: String? = nil
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(expression)
            jsonData = String(data: data, encoding: .utf8)
        } catch {
            print(error)
        }
        
        
        
        print(jsonData!)
        return jsonData
    }
}
