//
//  GiphyGifsApi.swift
//  iOSPhotoEditor
//
//  Created by Adam Podsiadlo on 23/07/2020.
//

import Foundation

struct Pagination: Decodable, Hashable {
    let offset: Int
}

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
    let pagination: Pagination?
}

enum GiphyType: String {
    case gifs = "gifs"
    case stickers = "stickers"
    
    func toSring() -> String {
        return self.rawValue
    }
}

enum ApiType: String {
    case trending = "trending"
    case search = "search"
    
    func toSring() -> String {
        return self.rawValue
    }
}

class GiphyApiManager {
    let offsetDefault = 25
    private var giphyType: GiphyType = GiphyType.gifs
    private var apiType: ApiType = ApiType.trending
    private var page: Int = 0
    private var searchTask: DispatchWorkItem?
    private var offset = 0
    private var searchPhrase = ""
    var giphyApiManagerDelegate: GiphyApiManagerDelegate!
    
    init (apiType: GiphyType) {
        giphyType = apiType
    }
    
    private func search(search: String) {
        apiType = ApiType.search
        
        if let apiUrl = buildApiUrl(search: search) {
            let task = URLSession.shared.dataTask(with: apiUrl) {(data, response, error) in
                guard let data = data else { return }
                
                let decodedData = self.decodeData(data: data)
                self.giphyApiManagerDelegate.onLoadData(data: decodedData, type: self.giphyType)
            }
            
            task.resume()
        }
    }
    
    private func decodeData(data: Data) -> [GiphyObject] {
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
    
    private func buildApiUrl(search: String? = nil, offset: Int = 0) -> URL? {
        var url = "https://api.giphy.com/v1/\(giphyType.toSring())/\(apiType.toSring())?api_key=K60P8olEveFJVYWFp87IlgqT4CmXcMUe"
        
        if let query = search {
            url = url + "&q=" + query
        }
        
        if offset > 0 {
            url = url + "&offset=\(offset)"
        }
        
        return URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    func fetchTrendingPage() {
        searchPhrase = ""
        apiType = ApiType.trending
        
        if let apiUrl = buildApiUrl() {
            let task = URLSession.shared.dataTask(with:apiUrl) {(data, response, error) in
                guard let data = data else { return }
                
                let decodedData = self.decodeData(data: data)
                self.giphyApiManagerDelegate.onLoadData(data: decodedData, type: self.giphyType)
            }
            
            task.resume()
        }
    }
    
    func searchGif(phrase: String) {
        searchPhrase = phrase
        offset = 0
        searchTask?.cancel()
        
        searchTask = DispatchWorkItem { [weak self] in
            self?.search(search: phrase)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: searchTask!)
    }
    
    func loadMore() {
        offset += offsetDefault
        
        if let apiUrl = buildApiUrl(search: searchPhrase, offset: offset) {
            let task = URLSession.shared.dataTask(with:apiUrl) {(data, response, error) in
                guard let data = data else { return }
                
                let decodedData = self.decodeData(data: data)
                self.giphyApiManagerDelegate.onLoadMoreData(data: decodedData, type: self.giphyType)
            }
            
            task.resume()
        }
    }
}
