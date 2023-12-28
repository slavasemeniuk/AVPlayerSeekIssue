//
//  ContentView.swift
//  SeekIssue
//
//  Created by Semeniuk Slava on 28.12.2023.
//

import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    
    @State private var compositionStore = CompositionStore()

    var body: some View {
        ZStack {
            Color.yellow
            if let composition = compositionStore.asset {
                VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(asset: composition)))
                    .frame(height: 400)
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                try await compositionStore.build()
            } catch {
                fatalError()
            }
        }
    }
}

@Observable
final class CompositionStore {

    var asset: AVMutableComposition?
    private let urls: [URL] = [
        Bundle.main.url(forResource: "IMG_1375", withExtension: "MOV")!,
        Bundle.main.url(forResource: "IMG_1376", withExtension: "MOV")!,
    ]

    func build() async throws {
        let composition = AVMutableComposition()
        var currentTime = CMTime.zero

        for url in urls {
            let asset = AVURLAsset(url: url)
            let duration = try await asset.load(.duration)
            try await composition.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                of: asset,
                at: currentTime
            )
            currentTime = composition.duration
        }

        asset = composition
        print(composition.tracks)
    }
}

#Preview {
    ContentView()
}
