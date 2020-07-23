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
    
    func didSelectGif(gif: String, width: Int, height: Int) {
        self.removeStickersView()
        
        
        let loader = UIActivityIndicatorView.init(style: .gray)
        
        let imageView = UIImageView()
        imageView.setGifFromURL(URL.init(string: gif)!, customLoader: loader)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: width, height: height)
        imageView.center = canvasImageView.center
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        self.canvasImageView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }
    
    func didSelectSticker(image: UIImage) {
        self.removeStickersView()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = canvasImageView.center
        
        self.canvasImageView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
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
        
        // For v1 pinch is disabled
        //        let pinchGesture = UIPinchGestureRecognizer(target: self,
        //                                                    action: #selector(PhotoEditorViewController.pinchGesture))
        //        pinchGesture.delegate = self
        
        //view.addGestureRecognizer(pinchGesture)
        
        //For v1 rotation is disabled
        //        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
        //                                                                    action:#selector(PhotoEditorViewController.rotationGesture) )
        //        rotationGestureRecognizer.delegate = self
        
        //        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
        
        view.addGestureRecognizer(tapGesture)
    }
}
