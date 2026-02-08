//
//  PhotosListViewModelTests.swift
//  flickr-searchTests
//
//  Created by Jonas Bylund on 2026-02-08.
//

@testable import flickr_search
import XCTest

final class PhotosListViewModelTests: XCTestCase {
    let photosEntry1 = PhotoEntry(imageURL: URL(string: "https://picsum.photos/100")!, title: "Random image")
    let photosEntry2 = PhotoEntry(imageURL: URL(string: "https://picsum.photos/200")!, title: "Another random image")

    @MainActor
    func testWhenSearchReturnsErrorStateShouldBeError() async throws {
        let flickerService = MockFlickrService()
        flickerService.error = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let viewModel = PhotosListViewModel(flickrService: flickerService)
        viewModel.searchText = "test"
        await viewModel.search()
        XCTAssertEqual(viewModel.state, .error("Test error"))
    }
    
    @MainActor
    func testWhenSearchReturnsEmptyStateShouldBeEmpty() async throws {
        let flickerService = MockFlickrService()
        flickerService.photosPage = PhotosPage(photos: [], page: 1, pages: 1, total: 0)
        let viewModel = PhotosListViewModel(flickrService: flickerService)
        viewModel.searchText = "test"
        await viewModel.search()
        XCTAssertEqual(viewModel.state, .empty)
    }
    
    @MainActor
    func testWhenSearchReturnsPhotosStateShouldBeLoaded() async throws {
        let flickerService = MockFlickrService()
        flickerService.photosPage = PhotosPage(photos: [
            photosEntry1,
            photosEntry2
        ], page: 1, pages: 1, total: 2)
        let viewModel = PhotosListViewModel(flickrService: flickerService)
        viewModel.searchText = "test"
        await viewModel.search()
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.photos, [photosEntry1, photosEntry2])
    }
    
    @MainActor
    func testWhenLoadingNextPageUpdatesPhotos() async throws {
        let flickerService = MockFlickrService()
        flickerService.photosPage = PhotosPage(photos: [
            photosEntry1,
            photosEntry2
        ], page: 1, pages: 2, total: 4)
        let viewModel = PhotosListViewModel(flickrService: flickerService)
        viewModel.searchText = "test"
        await viewModel.search()
        
        // Simulate loading next page
        flickerService.photosPage = PhotosPage(photos: [photosEntry1, photosEntry2], page: 2, pages: 2, total: 4)
        
        await viewModel.loadNextPage()
        
        XCTAssertEqual(viewModel.photos, [photosEntry1, photosEntry2, photosEntry1, photosEntry2])
    }
}
