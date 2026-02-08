//
//  PhotosListViewModel.swift
//  flickr-search
//
//  Created by Jonas Bylund on 2026-02-08.
//

import SwiftUI

@Observable class PhotosListViewModel {
    var state = State.initial
    var searchText = ""
    var totalPhotos = 0
    var isLoadingNextPage = false
    
    private var photosPages: [PhotosPage] = [] {
        didSet {
            // To avoid repeatedly recalculating the id
            lastPhotoId = photosPages.last?.photos.last?.id
            totalPhotos = photosPages.last?.total ?? 0
        }
    }
    private var flickrService: FlickrServing
    private var lastPhotoId: UUID?

    var photos: [PhotoEntry] {
        guard state == .loaded else {
            return []
        }
        return photosPages.flatMap { $0.photos }
    }
    
    init(flickrService: FlickrServing = FlickrService()) {
        self.flickrService = flickrService
    }
    
    func search() async {
        guard !searchText.isEmpty else { return }
        state = .loading
        photosPages = []
        do {
            let photosPage = try await flickrService.searchPhotos(query: searchText, page: 1)
            photosPages.append(photosPage)
            if photosPage.total == 0 {
                state = .empty
            } else {
                state = .loaded
            }
            UIAccessibility.post(notification: .announcement, argument: "\(photosPage.total) photos in search result")
        } catch {
            // Don't show an error if the search was cancelled
            guard !error.isCancellationError else { return}
            state = .error(error.localizedDescription)
        }
    }
    
    func loadNextPage() async {
        guard state == .loaded,
                let lastPage = photosPages.last,
              lastPage.page < lastPage.pages else {
            return
        }
        isLoadingNextPage = true
        do {
            let nextPage = try await flickrService.searchPhotos(query: searchText, page: lastPage.page + 1)
            photosPages.append(nextPage)
            state = .loaded
        } catch {
            // Don't show an error if the search was cancelled
            guard !error.isCancellationError else { return}
            state = .error(error.localizedDescription)
        }
        isLoadingNextPage = false
    }
    
    func isLastPhoto(_ photo: PhotoEntry) -> Bool {
        return photo.id == lastPhotoId
    }
}

extension PhotosListViewModel {
    enum State: Equatable {
        case initial
        case loading
        case loaded
        case empty
        case error(String)
    }
}

extension PhotosListViewModel {
    static func makePreview(for state: State, photosPages: [PhotosPage] = []) -> PhotosListViewModel {
        let viewModel = PhotosListViewModel()
        viewModel.state = state
        viewModel.photosPages = photosPages
        return viewModel
    }
}

private extension Error {
    var isCancellationError: Bool {
        self is CancellationError || (self as NSError).domain == NSURLErrorDomain && (self as NSError).code == NSURLErrorCancelled
    }
}
    
