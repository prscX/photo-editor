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
            }
        } else {
            self.stickersDelegate.setData(data: data)
            
            DispatchQueue.main.async{
                self.stickersCollectionView.reloadData()
            }
        }
    }
}
