//
//  MockFlickrService.swift
//  flickr-searchTests
//
//  Created by Jonas Bylund on 2026-02-08.
//

@testable import flickr_search
import Foundation

class MockFlickrService: FlickrServing {
    var photosPage: PhotosPage?
    var error: Error?
    
    func searchPhotos(query: String, page: Int) async throws -> PhotosPage {
        if let error = error {
            throw error
        }
        return photosPage ?? PhotosPage(photos: [], page: 1, pages: 10, total: 0)
    }
}
