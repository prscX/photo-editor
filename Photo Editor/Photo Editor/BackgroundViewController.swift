//
//  BackgroundViewController.swift
//  iOSPhotoEditor
//
//  Created by Adam Podsiadlo on 17/07/2020.
//

import UIKit

class BackgroundViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    
    var collectionView: UICollectionView!
    var imagesCollectionView: UICollectionView!
    
    var imageDelegate: ImageCollectionViewDelegate!
    
    var bgImages : [String] = []
    var bgColors : [String] = []
    var backgroundViewControllerDelegate : BackgroundViewControllerDelegate?
    
    let screenSize = UIScreen.main.bounds.size
    
    let fullView: CGFloat = 100 // remainder of screen height
    
    var bottomPadding: CGFloat {
        var topPadding:CGFloat? = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top
        }
        
        return topPadding!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionViews()
        scrollView.showsHorizontalScrollIndicator = false
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        segmentedView.setTitle("IMAGES", forSegmentAt: 0)
        segmentedView.setTitle("COLORS", forSegmentAt: 1)
        
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let path = UIBezierPath(roundedRect: self.view.bounds,
                                    byRoundingCorners: [.topRight, .topLeft],
                                    cornerRadii: CGSize(width: 20, height: 20))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            self.view.layer.mask = maskLayer
        }
        
        holdView.layer.cornerRadius = 3
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BackgroundViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
    }
    
    @IBAction func segmentedControlButtonClickAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.scrollView.contentOffset = CGPoint(x: 0, y:0);
                }, completion: nil)
            }
            
        }
        else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.scrollView.contentOffset = CGPoint(x:self.scrollView.frame.size.width, y:0);
                }, completion: nil)
            }
            
        }
    }
    
    func configureCollectionViews() {
        let frame = CGRect(x: scrollView.frame.size.width,
                           y: 0,
                           width: UIScreen.main.bounds.width,
                           height: view.frame.height - 40)
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: bottomPadding, right: 12)
        let width = (CGFloat) ((screenSize.width - 36) / 4.0)
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            UINib(nibName: "StickerCollectionViewCell", bundle: Bundle(for: StickerCollectionViewCell.self)),
            forCellWithReuseIdentifier: "StickerCollectionViewCell")
        
        //-----------------------------------
        
        let imagesFrame = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: view.frame.height - 40)
        
        let imageslayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        imageslayout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: bottomPadding, right: 12)
        
        let imageWidth = (CGFloat) ((screenSize.width - 36) / 2)
        imageslayout.itemSize = CGSize(width: imageWidth, height: imageWidth * 1.3)
        
        imagesCollectionView = UICollectionView(frame: imagesFrame, collectionViewLayout: imageslayout)
        imagesCollectionView.backgroundColor = .clear
        scrollView.addSubview(imagesCollectionView)
        scrollView.addSubview(collectionView)
        imageDelegate = ImageCollectionViewDelegate()
        
        imageDelegate.bgImages = bgImages
        
        
        imageDelegate.backgroundViewControllerDelegate = backgroundViewControllerDelegate
        
        imagesCollectionView.delegate = imageDelegate
        imagesCollectionView.dataSource = imageDelegate
        
        imagesCollectionView.register(
            UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: ImageCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let `self` = self else { return }
            let frame = self.view.frame
            let yComponent = self.bottomPadding
            self.view.frame = CGRect(x: 0,
                                     y: yComponent,
                                     width: frame.width,
                                     height: UIScreen.main.bounds.height - self.bottomPadding)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: scrollView.frame.size.width,
                                     y: 0,
                                     width: UIScreen.main.bounds.width,
                                     height: view.frame.height - 100)
        
        imagesCollectionView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.width,
                                           height: view.frame.height - 100)
        
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width,
                                        height: scrollView.frame.size.height - 100)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Pan Gesture
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if y + translation.y >= fullView {
            let newMinY = y + translation.y
            self.view.frame = CGRect(x: 0, y: newMinY, width: view.frame.width, height: UIScreen.main.bounds.height - newMinY )
            self.view.layoutIfNeeded()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((bottomPadding - y) / velocity.y )
            duration = duration > 1.3 ? 1 : duration
            //velocity is direction of gesture
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    if y + translation.y >= self.bottomPadding  {
                        self.removeBottomSheetView()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.bottomPadding, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.bottomPadding)
                        self.view.layoutIfNeeded()
                    }
                } else {
                    if y + translation.y >= self.bottomPadding  {
                        self.view.frame = CGRect(x: 0, y: self.bottomPadding, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.bottomPadding)
                        self.view.layoutIfNeeded()
                    } else {
                        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: UIScreen.main.bounds.height - self.fullView)
                        self.view.layoutIfNeeded()
                    }
                }
                
            }, completion: nil)
        }
    }
    
    func removeBottomSheetView() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.backgroundViewControllerDelegate?.backgroundViewDidDisappear()
        })
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
}

extension BackgroundViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ sender: UIScrollView) {
        if (sender.tag == 1) {
            let pageWidth = scrollView.bounds.width
            let pageFraction = scrollView.contentOffset.x / pageWidth
            segmentedView.selectedSegmentIndex = Int(round(pageFraction))
        }
    }
}

// MARK: - UICollectionViewDataSource
extension BackgroundViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bgColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        backgroundViewControllerDelegate?.didSelectColorBackground(color: bgColors[indexPath.item])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "StickerCollectionViewCell"
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! StickerCollectionViewCell
        cell.stickerImage.backgroundColor = UIColor(hexString: bgColors[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


