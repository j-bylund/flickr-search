//
//  PhotosListView.swift
//  flickr-search
//
//  Created by Jonas Bylund on 2026-02-08.
//

import SwiftUI

struct PhotosListView: View {
    @Bindable var viewModel: PhotosListViewModel = PhotosListViewModel()
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .initial:
                    ContentUnavailableView("Nothing to show",
                                           systemImage: "photo",
                                           description: Text("Enter a search term."))
                case .loading:
                    ProgressView()
                case .error(let message):
                    ContentUnavailableView("Error",
                                           systemImage: "exclamationmark.triangle", description: Text(message))
                case .empty:
                    ContentUnavailableView("No results",
                                           systemImage:
                                            "magnifyingglass",
                                           description: Text("Try a different search term."))
                case .loaded:
                    Text("Found \(viewModel.totalPhotos) photos")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    List(viewModel.photos) { photoEntry in
                        PhotoListRowView(entry: photoEntry)
                            .onAppear() {
                                if viewModel.isLastPhoto(photoEntry) {
                                    loadNextPage()
                            }
                        }
                    }
                    if viewModel.isLoadingNextPage {
                        ProgressView()
                            .frame(height: 50)
                            .padding()
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                placement: .toolbar,
                prompt: "Type here to search"
            )
            .task(id: viewModel.searchText) {
                // Debounce the search input
                try? await Task.sleep(for: .seconds(0.3))
                if Task.isCancelled { return }
                await viewModel.search()
                
            }            
        }
    }
    
    private func loadNextPage() {
        Task {
            await viewModel.loadNextPage()
        }
    }
}

#Preview("Inital") {
    PhotosListView(viewModel: PhotosListViewModel.makePreview(for: .initial))
}

#Preview("Loading") {
    PhotosListView(viewModel: PhotosListViewModel.makePreview(for: .loading))
}

#Preview("Empty") {
    PhotosListView(viewModel: PhotosListViewModel.makePreview(for: .loaded, photosPages: [PhotosPage(photos: [], page: 1, pages: 1, total: 0)]))
}

#Preview("Some") {
    PhotosListView(viewModel: PhotosListViewModel.makePreview(for: .loaded, photosPages: [PhotosPage(photos: [
        PhotoEntry(imageURL: URL(string: "https://picsum.photos/100")!, title: "Random image"),
        PhotoEntry(imageURL: URL(string: "https://picsum.photos/100")!, title: "Another random image")
    ],                                                                                      page: 1, pages: 1, total: 2)]))
}

#Preview("Error") {
    PhotosListView(viewModel: PhotosListViewModel.makePreview(for: .error("Something went wrong")))
}
