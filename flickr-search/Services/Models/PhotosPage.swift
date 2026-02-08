//
//  PhotosPage.swift
//  flickr-search
//
//  Created by Jonas Bylund on 2026-02-08.
//

import Foundation

struct PhotosPage {
    let photos: [PhotoEntry]
    let page: Int
    let pages: Int
    let total: Int
}

struct PhotoEntry: Identifiable, Equatable {
    let id = UUID()
    let imageURL: URL
    let title: String
}
