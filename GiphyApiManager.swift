//
//  GiphyGifsApi.swift
//  iOSPhotoEditor
//
//  Created by Adam Podsiadlo on 23/07/2020.
//

import Foundation

struct GiphyObject: Decodable, Hashable {
    let url: String?
    let height: String?
    let width: String?
}

struct GiphyDownsize: Decodable, Hashable {
    let downsized: GiphyObject?
}

struct GiphyImages: Decodable, Hashable {
    let images: GiphyDownsize
}

struct GiphyResponse: Decodable {
    let data: [GiphyImages]
}

enum GiphyType {
    case gifs, stickers
}

class GiphyApiManager {
    var giphyApiManagerDelegate: GiphyApiManagerDelegate!
    var giphyType: GiphyType = GiphyType.gifs
    var apiUrl: String = ""
    var page: Int = 0
    
    init (apiType: GiphyType) {
        if (apiType == GiphyType.gifs) {
            apiUrl = "https://api.giphy.com/v1/gifs/trending?api_key=K60P8olEveFJVYWFp87IlgqT4CmXcMUe"
        } else {
            giphyType = GiphyType.stickers
            apiUrl = "https://api.giphy.com/v1/stickers/trending?api_key=K60P8olEveFJVYWFp87IlgqT4CmXcMUe"
        }
    }
    
    func fetchTrendingPage() {
        let url = URL(string: apiUrl)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            
            let decodedData = self.decodeData(data: data)
            self.giphyApiManagerDelegate.onLoadData(data: decodedData, type: self.giphyType)
        }
        
        task.resume()
    }
    
    func decodeData(data: Data) -> [GiphyObject] {
        let gifs: GiphyResponse = try! JSONDecoder().decode(GiphyResponse.self, from: data)
        
        var giphyGifs: [GiphyObject] = []
        
        for image in gifs.data {
            if let downsized = image.images.downsized {
                if downsized.url != nil && downsized.width != nil && downsized.height != nil {
                    giphyGifs.append(downsized)
                }
            }
        }
        
        return giphyGifs
    }
}
