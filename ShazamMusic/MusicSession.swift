//
//  MusicSession.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2022/11/30.
//

import Foundation
import MusicKit

final class MusicSession {
    private var songs = [SongInfo]()
    
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
                    let request = MusicCatalogSearchRequest(term: term.title, types: [Song.self])
                    
                    let response = try await request.response()
                    songs = response.songs.compactMap {
                        SongInfo(title: $0.title, artist: $0.artistName, album: $0.albumTitle)
                    }
                    print(songs)
                } catch (let error) {
                    print(error.localizedDescription)
                }
            default:
                debugPrint("no")
            }
        }
    }
    
    // 음악을 검색하는 함수
    func searchMusic() {
        
    }
    
    // 음악을 재생하는 함수
    func playMusic() {
        
    }
}

struct SongInfo {
    let title: String
    let artist: String
    let album: String?
}
