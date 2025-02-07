//
//  CachedImage.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/2/6.
//
import SwiftUI
import FirebaseStorage

struct CachedImage: View {

    let storageReference: StorageReference
    @State private var cachedURL: URL?
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            if let url = cachedURL {
                // pass the local URL to AsyncImage
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                    @unknown default:
                        EmptyView()
                    }
                }
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "exclamationmark.triangle")
            }
        }
        .task {
            do {
                let localURL =
                try await MediaCacheManager.fetchCachedAssetURL(
                    for: storageReference,
                    fileType: .image
                )
                
                cachedURL = localURL
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}
