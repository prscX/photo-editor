//
//  PhotoEditor+StickersViewController.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {
    func addGifsStickersViewController() {
        gifsStickersVCIsVisible = true
        self.canvasImageView.isUserInteractionEnabled = false
        gifsStickersViewController.gifsStickersViewControllerDelegate = self
        
        self.addChild(gifsStickersViewController)
        self.view.addSubview(gifsStickersViewController.view)
        gifsStickersViewController.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        gifsStickersViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeStickersView() {
        gifsStickersVCIsVisible = false
        self.canvasImageView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.gifsStickersViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.gifsStickersViewController.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.gifsStickersViewController.view.removeFromSuperview()
            self.gifsStickersViewController.removeFromParent()
            self.hideToolbar(hide: false)
        })
    }    
}

extension PhotoEditorViewController: GifsStickersViewControllerDelegate {
    func onLoadMore() {
        gifsStickersViewController!.loadMoreData()
    }
    
    func didSelectGif(gif: String, width: Int, height: Int) {
        self.removeStickersView()
        
        var imageView: UIImageView? = nil
        
        if (!gifsImages.isEmpty &&  gifsImages.count > 4) {
            imageView = gifsImages[gifsImages.count - 1]
        } else {
            imageView = UIImageView()
        }
        
        let loader = UIActivityIndicatorView.init(style: .gray)
        
        if let image = imageView {
            image.setGifFromURL(URL.init(string: gif)!, customLoader: loader)
            image.contentMode = .scaleAspectFit
            image.frame.size = CGSize(width: width, height: height)
            image.center = canvasImageView.center
            image.layer.cornerRadius = 10
            image.clipsToBounds = true
            
            if (!gifsImages.contains(image)) {
                self.canvasImageView.addSubview(image)
                addGestures(view: image)
                gifsImages.append(image)
            }
        }
    }
    
    func stickersViewDidDisappear() {
        gifsStickersVCIsVisible = false
        hideToolbar(hide: false)
    }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(PhotoEditorViewController.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(PhotoEditorViewController.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(PhotoEditorViewController.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
        
        view.addGestureRecognizer(tapGesture)
    }
}
