//
//  MusicSession.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2022/11/30.
//

import Foundation
import MusicKit

final class MusicSession {
    private var song: SongInfo?
    
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Happy", types: [Song.self])
        request.limit = 1
        return request
    }()
    
    func fetchMusic(term: SongInfo?) {
        guard let term else { return }
        
        Task {
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                do {
                    let request = MusicCatalogResourceRequest<Song>(matching: \.isrc, equalTo: term.isrc)
                    let response = try await request.response()
                    if let item = response.items.first {
                        song = SongInfo(isrc: item.isrc!, title: item.title, artist: item.artistName, album: item.albumTitle)
                    }
                    
                    print(song ?? "NO SONG")
                } catch (let error) {
                    print(error.localizedDescription)
                }
            default:
                debugPrint("no")
            }
        }
    }
    
    // 음악을 재생하는 함수
    func playMusic() {
        
    }
}

struct SongInfo {
    let isrc: String
    let title: String
    let artist: String
    let album: String?
}
