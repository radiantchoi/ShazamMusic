//
//  MusicSession.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2022/11/30.
//

import MusicKit

final class MusicSession {
    private var songInfo: SongInfo?
    private var song: Song?
    
    private lazy var player = ApplicationMusicPlayer.shared
    private lazy var playerState = player.state
    private var isQueueSet = false
    
    private var isPlaying: Bool {
        return playerState.playbackStatus == .playing
    }

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
                        song = item
                        songInfo = SongInfo(isrc: item.isrc!, title: item.title, artist: item.artistName, album: item.albumTitle)
                    }
                    
                    print(songInfo ?? "NO SONG")
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
        guard let song else { return }
        if !isPlaying {
            if !isQueueSet {
                player.queue = [song]
                isQueueSet = true
            }
            
            Task {
                do {
                    try await player.play()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            player.pause()
        }
    }
}

struct SongInfo {
    let isrc: String
    let title: String
    let artist: String
    let album: String?
}
