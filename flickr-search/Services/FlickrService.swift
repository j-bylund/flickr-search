//
//  FlickrService.swift
//  flickr-search
//
//  Created by Jonas Bylund on 2026-02-08.
//

import Foundation

protocol FlickrServing {
    func searchPhotos(query: String, page: Int) async throws -> PhotosPage
}

class FlickrService: FlickrServing {
    private let apiKey = "5a2cc90782760b3a6b3eca570dfaf5c3"
    private let baseURL = "https://www.flickr.com/services/rest/"
    
    func searchPhotos(query: String, page: Int) async throws -> PhotosPage {
        guard let url = URL(string: "\(baseURL)?method=flickr.photos.search&api_key=\(apiKey)&text=\(query)&format=json&nojsoncallback=1") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        let flickrResponse = try decoder.decode(FlickrPhotosResponse.self, from: data)
        
        let photosPage = PhotosPage(
            photos: mapToPhotoEntries(flickrResponse: flickrResponse),
            page: flickrResponse.photos.page,
            pages: flickrResponse.photos.pages,
            total: flickrResponse.photos.total
        )
        
        return photosPage
    }
    
    private func mapToPhotoEntries(flickrResponse: FlickrPhotosResponse) -> [PhotoEntry] {
        return flickrResponse.photos.photo.compactMap { photo in
            if let imageURL = constructImageURL(photo: photo) {
                return PhotoEntry(imageURL: imageURL, title: photo.title)
            }
            return nil
        }
    }
    
    private func constructImageURL(photo: FlickrPhotoResponse) -> URL? {
        let urlString = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg"
        return URL(string: urlString)
    }
}
