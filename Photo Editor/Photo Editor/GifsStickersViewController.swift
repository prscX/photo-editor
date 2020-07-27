//
//  StickersViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//  Credit https://github.com/AhmedElassuty/IOS-BottomSheet

import UIKit
import CollectionViewWaterfallLayout

class GifsStickersViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var holdView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedView: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    
    var stickersCollectionView: UICollectionView!
    var gifsCollectionView: UICollectionView!
    
    var gifsDelegate: GifsCollectionViewDelegate!
    var stickersDelegate: GifsCollectionViewDelegate!
    
    var gifs: [GiphyObject] = []
    var stickers: [GiphyObject] = []
    var gifsStickersViewControllerDelegate : GifsStickersViewControllerDelegate?
    
    var gifsApiManager: GiphyApiManager!
    var stickersApiManager: GiphyApiManager!
    
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
        
        self.hideKeyboardWhenTappedAround()
        initGiphy()
        initSearchField()
        configureCollectionViews()
        
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width,
                                        height: scrollView.frame.size.height)
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentedView.setTitle("STICKERS", forSegmentAt: 0)
        segmentedView.setTitle("GIFS", forSegmentAt: 1)
        
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
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(GifsStickersViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    @IBAction func onSearchChanged(_ sender: UITextField) {
        if let searchText = sender.text {
            if !searchText.isEmpty {
                if (segmentedView.selectedSegmentIndex == 0) {
                    stickersApiManager.searchGif(phrase: searchText)
                } else {
                    gifsApiManager.searchGif(phrase: searchText)
                }
            } else {
                if (segmentedView.selectedSegmentIndex == 0) {
                    stickersApiManager.fetchTrendingPage()
                } else {
                    gifsApiManager.fetchTrendingPage()
                }
            }
        }
    }
    
    @IBAction func segmentedControlButtonClickAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.scrollView.contentOffset = CGPoint(x: 0, y:0);
                }, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                    self.scrollView.contentOffset = CGPoint(x:self.scrollView.frame.size.width, y:0);
                }, completion: nil)
            }
        }
        
        onPageChange(page: sender.selectedSegmentIndex)
    }
    
    func initSearchField () {
        searchTextField.layer.cornerRadius = 10
        searchTextField.clipsToBounds = true
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: searchTextField.frame.height))
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = UIReturnKeyType.search
    }
    
    func initGiphy () {
        gifsApiManager = GiphyApiManager(apiType: GiphyType.gifs);
        gifsApiManager.giphyApiManagerDelegate = self
        gifsApiManager.fetchTrendingPage()
        
        stickersApiManager = GiphyApiManager(apiType: GiphyType.stickers);
        stickersApiManager.giphyApiManagerDelegate = self
        stickersApiManager.fetchTrendingPage()
    }
    
    func onPageChange (page: Int) {
        if (page == 0) {
            searchTextField.text = stickersApiManager.getSearchPhrase()
        } else {
            searchTextField.text = gifsApiManager.getSearchPhrase()
        }
        
        searchTextField.endEditing(true)
    }
    
    func configureCollectionViews() {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: UIScreen.main.bounds.width,
                           height: scrollView.frame.height)
        
        let stickerslayout: CollectionViewWaterfallLayout = CollectionViewWaterfallLayout()
        stickerslayout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: bottomPadding, right: 12)
        
        
        stickersCollectionView = UICollectionView(frame: frame, collectionViewLayout: stickerslayout)
        stickersCollectionView.backgroundColor = .clear
        scrollView.addSubview(stickersCollectionView)
        
        stickersDelegate = GifsCollectionViewDelegate()
        stickersDelegate.gifsStickersViewControllerDelegate = gifsStickersViewControllerDelegate
        stickersCollectionView.delegate = stickersDelegate
        stickersCollectionView.dataSource = stickersDelegate
        stickersCollectionView.register(
            UINib(nibName: "GifCollectionViewCell", bundle: Bundle(for: GifCollectionViewCell.self)),
            forCellWithReuseIdentifier: "GifCollectionViewCell")
        stickersCollectionView.keyboardDismissMode =  UIScrollView.KeyboardDismissMode.onDrag
        
        //-----------------------------------
        let frameGifs = CGRect(x: scrollView.frame.size.width,
                               y: 0,
                               width: UIScreen.main.bounds.width,
                               height: scrollView.frame.height)
        
        let gifslayout: CollectionViewWaterfallLayout = CollectionViewWaterfallLayout()
        gifslayout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: bottomPadding, right: 12)
        
        gifsCollectionView = UICollectionView(frame: frameGifs, collectionViewLayout: gifslayout)
        gifsCollectionView.backgroundColor = .clear
        scrollView.addSubview(gifsCollectionView)
        
        gifsDelegate = GifsCollectionViewDelegate()
        gifsDelegate.gifsStickersViewControllerDelegate = gifsStickersViewControllerDelegate
        gifsCollectionView.delegate = gifsDelegate
        gifsCollectionView.dataSource = gifsDelegate
        gifsCollectionView.register(
            UINib(nibName: "GifCollectionViewCell", bundle: Bundle(for: GifCollectionViewCell.self)),
            forCellWithReuseIdentifier: "GifCollectionViewCell")
        gifsCollectionView.keyboardDismissMode =  UIScrollView.KeyboardDismissMode.onDrag
    }
    
    func loadMoreData() {
        if (segmentedView.selectedSegmentIndex == 0) {
            stickersApiManager.loadMore()
        } else {
            gifsApiManager.loadMore()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
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
        stickersCollectionView.frame = CGRect(x: 0,
                                              y: 0,
                                              width: UIScreen.main.bounds.width,
                                              height: scrollView.frame.height)
        
        gifsCollectionView.frame = CGRect(x: scrollView.frame.size.width,
                                          y: 0,
                                          width: UIScreen.main.bounds.width,
                                          height: scrollView.frame.height)
        
        scrollView.contentSize = CGSize(width: 2.0 * screenSize.width,
                                        height: scrollView.frame.size.height)
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
            self.gifsStickersViewControllerDelegate?.stickersViewDidDisappear()
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

extension GifsStickersViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ sender: UIScrollView) {
        if (sender.tag == 1) {
            let pageWidth = scrollView.bounds.width
            let pageFraction = scrollView.contentOffset.x / pageWidth
            segmentedView.selectedSegmentIndex = Int(round(pageFraction))
            
            onPageChange(page: Int(round(pageFraction)))
        }
    }
}
