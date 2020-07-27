//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - Control
public enum control: String {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
    
    public func string() -> String {
        return self.rawValue
    }
}

extension PhotoEditorViewController {
    
    //MARK: Top Toolbar
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Abandon your Expression", message: "Leaving mid-edit just deletes your in-progress Expression.", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.photoEditorDelegate?.canceledEditing()
            self.dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func cropButtonTapped(_ sender: UIButton) {
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        addGifsStickersViewController()
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        isDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        colorPickerView.isHidden = false
        hideToolbar(hide: true)
    }
    
    @IBAction func textButtonTapped(_ sender: Any) {
        openTextTool()
    }    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        hideToolbar(hide: false)
        isDrawing = false
    }
    
    //MARK: Bottom Toolbar
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        if let popoverController = activity.popoverPresentationController {
            popoverController.barButtonItem = UIBarButtonItem(customView: sender)
        }
        
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        //clear drawing
        canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let image = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundButtonTapper(_ sender: Any) {
        addBackgroundViewController()
    }
    
    @IBAction func onStylePressed(sender: UIButton) {
        font1Button.setTitleColor(UIColor.init(hexString: "#D0D0D0"), for: .normal)
        font2Button.setTitleColor(UIColor.init(hexString: "#D0D0D0"), for: .normal)
        font3Button.setTitleColor(UIColor.init(hexString: "#D0D0D0"), for: .normal)
        font4Button.setTitleColor(UIColor.init(hexString: "#D0D0D0"), for: .normal)
        
        if (sender.tag ==  0) {
            font1Button.setTitleColor(UIColor.init(hexString: "#646464"), for: .normal)
            lastTextViewFont = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(Int(textSizeSlider.value)))
        } else if (sender.tag ==  1) {
            font2Button.setTitleColor(UIColor.init(hexString: "#646464"), for: .normal)
            lastTextViewFont = UIFont(name: "AmericanTypewriter", size: CGFloat(Int(textSizeSlider.value)))
        }else if (sender.tag ==  2) {
            font3Button.setTitleColor(UIColor.init(hexString: "#646464"), for: .normal)
            lastTextViewFont = UIFont(name: "Arial-BoldMT", size: CGFloat(Int(textSizeSlider.value)))
        } else if (sender.tag ==  3) {
            font4Button.setTitleColor(UIColor.init(hexString: "#646464"), for: .normal)
            lastTextViewFont = UIFont(name: "BradleyHandITCTT-Bold", size: CGFloat(Int(textSizeSlider.value)))
        }
        
        activeTextView?.font = lastTextViewFont
    }
    
    //MAKR: helper methods
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openTextTool () {
        hideToolbar(hide: true)
        // For V1 only one text is available, to use multiple texts remove if / else case
        if (activeTextView == nil || !self.canvasImageView.subviews.contains(activeTextView!)) {
            isTyping = true
            let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                    width: UIScreen.main.bounds.width, height: 30))
            
            textView.textAlignment = .center
            textView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 30)
            textView.textColor = textColor
            textView.layer.shadowColor = UIColor.black.cgColor
            textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
            textView.layer.shadowOpacity = 0.2
            textView.layer.shadowRadius = 1.0
            textView.layer.backgroundColor = UIColor.clear.cgColor
            textView.autocorrectionType = .no
            textView.isScrollEnabled = false
            textView.delegate = self
            self.canvasImageView.addSubview(textView)
            addGestures(view: textView)
            textView.becomeFirstResponder()
        } else {
            activeTextView?.becomeFirstResponder()
        }
    }
    
    func hideControls() {
        let controls = hiddenControls
        
        for control in controls {
            if (control == "clear") {
                clearButton.isHidden = true
            } else if (control == "crop") {
                cropButton.isHidden = true
            } else if (control == "draw") {
                drawButton.isHidden = true
            } else if (control == "save") {
                saveButton.isHidden = true
            } else if (control == "share") {
                shareButton.isHidden = true
            } else if (control == "sticker") {
                stickerButton.isHidden = true
            } else if (control == "text") {
                textButton.isHidden = true
            }
        }
    }
}
