//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController {
    
    //To hold background image
    @IBOutlet weak var imageBg: UIImageView!
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textSizeSlider: UISlider!
    @IBOutlet weak var continueButton: UIButton!
    
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var font1Button: UIButton!
    @IBOutlet weak var font2Button: UIButton!
    @IBOutlet weak var font3Button: UIButton!
    @IBOutlet weak var font4Button: UIButton!
    
    @objc public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    @objc public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    @objc public var colors  : [UIColor] = []
    /**
     Array of Background colors  that the user will choose from
     */
    @objc public var bgColors : [String] = []
    /**
     Array of Background Images that the user will choose from
     */
    @objc public var bgImages : [String] = []
    
    @objc public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    @objc public var hiddenControls : [NSString] = []
    
    var backgroundVCIsVisible = false
    var gifsStickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    var gifsImages: [UIImageView] = []
    
    var gifsStickersViewController: GifsStickersViewController!
    var backgroundViewController: BackgroundViewController!
    
    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let bgImage = image {
            self.setBackgroundImage(image: bgImage)
        }
        
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
        name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureCollectionView()
        gifsStickersViewController = GifsStickersViewController(nibName: "GifsStickersViewController", bundle: Bundle(for: GifsStickersViewController.self))
        
        backgroundViewController = BackgroundViewController(nibName: "BackgroundViewController", bundle: Bundle(for: BackgroundViewController.self))
        hideControls()
        openTextTool()
    }
    
    @IBAction func slider(_ sender: Any) {
        if let textView = activeTextView {
            lastTextViewFont = lastTextViewFont?.withSize(CGFloat(Int(textSizeSlider.value)))
            textView.font = lastTextViewFont
            let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width, height:CGFloat.greatestFiniteMagnitude))
            
            textView.bounds.size = CGSize(width: UIScreen.main.bounds.size.width,
                                          height: sizeToFit.height)
            textView.setNeedsDisplay()
        }
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func setImageView(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }
    
    func setBackgroundImage(image: UIImage) {
        imageBg.image = image
    }
    
    func setBackgroundColor(color: String) {
        self.imageBg.image = nil
        self.imageBg.backgroundColor = UIColor(hexString: color)
    }
    
    func setBackgroundImage(image: String) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: image)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageBg.image = image
                    }
                }
            }
        }
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
        continueButton.isHidden = isTyping ? true : hide
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}
