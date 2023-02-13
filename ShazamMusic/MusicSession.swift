//
//  MusicSession.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2022/11/30.
//

import MusicKit
import RxSwift

final class MusicSession {
    private var songInfo: SongInfo?
    
    private lazy var player = ApplicationMusicPlayer.shared
    private lazy var playerState = player.state
    private var isQueueSet = false
    
    private var isPlaying: Bool {
        return playerState.playbackStatus == .playing
    }
    
    private var playbackStatus = BehaviorSubject(value: false)
    var playbackStatusObservable: Observable<Bool> {
        return playbackStatus.asObservable()
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
                        player.queue = [item]
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
    func togglePlayer() {
        isPlaying ? pauseMusic() : playMusic()
    }
    
    func playMusic() {
        Task {
            do {
                try await player.play()
                playbackStatus.onNext(true)
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    func pauseMusic() {
        player.stop()
        playbackStatus.onNext(false)
    }
}

struct SongInfo {
    let isrc: String
    let title: String
    let artist: String
    let album: String?
}
