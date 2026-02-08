//
//  FlickrPhoto.swift
//  flickr-search
//
//  Created by Jonas Bylund on 2026-02-08.
//

import Foundation

struct FlickrPhotosResponse: Decodable {
    let photos: FlickrPhotoPageResponse
}
struct FlickrPhotoPageResponse: Decodable {
    let photo: [FlickrPhotoResponse]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
}

struct FlickrPhotoResponse: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
