//
//  PhotoListRowView.swift
//  flickr-search
//
//  Created by Jonas Bylund on 2026-02-08.
//

import SwiftUI

struct PhotoListRowView: View {
    var entry: PhotoEntry
    
    var body: some View {
        HStack {
            AsyncImage(url: entry.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(entry.title)
                .font(.headline)
                .lineLimit(2)
        }
    }
}

#Preview {
    PhotoListRowView(entry: PhotoEntry(imageURL: URL(string: "https://example.com/photo.jpg")!, title: "Sample Photo"))
}
