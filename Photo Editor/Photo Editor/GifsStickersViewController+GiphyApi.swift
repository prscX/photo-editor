//
//  GifsStickersViewController+GiphyApi.swift
//  iOSPhotoEditor
//
//  Created by Adam Podsiadlo on 23/07/2020.
//

import Foundation

extension GifsStickersViewController: GiphyApiManagerDelegate {
    func onLoadData(data: [GiphyObject], type: GiphyType) {
        
        if (type == GiphyType.gifs) {
            self.gifsDelegate.setData(data: data)
            
            DispatchQueue.main.async{
                self.gifsCollectionView.reloadData()
                self.gifsCollectionView.setContentOffset(.zero, animated: false)
            }
        } else {
            self.stickersDelegate.setData(data: data)
            
            DispatchQueue.main.async{
                self.stickersCollectionView.reloadData()
                self.stickersCollectionView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    func onLoadMoreData(data: [GiphyObject], type: GiphyType) {
         if (type == GiphyType.gifs) {
             self.gifsDelegate.insertData(data: data)
             
             DispatchQueue.main.async{
                 self.gifsCollectionView.reloadData()
                self.stickersCollectionView.layoutIfNeeded()
                self.stickersCollectionView.layoutSubviews()
             }
         } else {
             self.stickersDelegate.insertData(data: data)
             
             DispatchQueue.main.async{
                 self.stickersCollectionView.reloadData()
                self.stickersCollectionView.layoutIfNeeded()
             }
         }
     }
}
