//
//  EmojisCollectionViewDelegate.swift
//  Photo Editor
//
//  Created by Adam Podsiadlo on 21/07/2020.
//

import UIKit
import SwiftyGif

class GifsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var gifsStickersViewControllerDelegate : GifsStickersViewControllerDelegate?
    
    let gifManager = SwiftyGifManager(memoryLimit:100)
    let width = (CGFloat) ((UIScreen.main.bounds.size.width - 30) / 2.0)
    var data: [GiphyObject] = []
    
    func setData(data: [GiphyObject]) {
        self.data = data
    }
    
    func insertData(data: [GiphyObject]) {
        self.data.append(contentsOf: data)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastRowIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            gifsStickersViewControllerDelegate?.onLoadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectRatio = CGFloat(Double(data[indexPath.item].height!)! / Double(data[indexPath.item].width!)!)
        
        return CGSize(width: width, height: width * aspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gifsStickersViewControllerDelegate?.didSelectGif(gif: data[indexPath.item].url!, width: Int((collectionView.cellForItem(at: indexPath)?.frame.width)!), height: Int((collectionView.cellForItem(at: indexPath)?.frame.height)!))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCollectionViewCell", for: indexPath) as! GifCollectionViewCell
        
        
        if let url = URL.init(string: data[indexPath.item].url!) {
            let loader = UIActivityIndicatorView.init(style: .gray)
            cell.gifImageView.setGifFromURL(url, customLoader: loader)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        let aspectRatio = CGFloat(Double(data[indexPath.item].height!)! / Double(data[indexPath.item].width!)!)
        
        return CGFloat(width * aspectRatio)
    }
}
