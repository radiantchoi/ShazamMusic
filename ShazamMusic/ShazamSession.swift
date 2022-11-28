//
//  ShazamSession.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2022/11/29.
//

import Foundation
import ShazamKit

import RxSwift

typealias ShazamSearchResult = Result<ShazamSong, ShazamError>

final class ShazamSession: NSObject {
    var result = PublishSubject<ShazamSearchResult>()
    
    private lazy var audioSession: AVAudioSession = .sharedInstance()
    private lazy var session: SHSession = .init()
    private lazy var audioEngine: AVAudioEngine = .init()
    private lazy var inputNode = audioEngine.inputNode
    private lazy var bus: AVAudioNodeBus = 0
    
    override init() {
        super.init()
        
        session.delegate = self
    }
    
    func start() {
        switch audioSession.recordPermission {
        case .granted:
            record()
        case .denied:
            result.onNext(.failure(.recordDenied))
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                if granted {
                    self.record()
                } else {
                    self.result.onNext(.failure(.recordDenied))
                }
            }
        @unknown default:
            result.onNext(.failure(.unknown))
        }
    }
    
    func stop() {
        audioEngine.stop()
        inputNode.removeTap(onBus: bus)
    }
    
    private func record() {
        do {
            let format = inputNode.outputFormat(forBus: bus)
            inputNode.installTap(onBus: bus, bufferSize: 2048, format: format) { buffer, time in
                self.session.matchStreamingBuffer(buffer, at: time)
            }
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            result.onNext(.failure(.unknown))
        }
    }
}

extension ShazamSession: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first,
              let shazamSong = ShazamSong(mediaItem: mediaItem) else {
            result.onNext(.failure(.matchFailed))
            return
        }
        
        result.onNext(.success(shazamSong))
        stop()
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        result.onNext(.failure(.matchFailed))
        stop()
    }
}

struct ShazamSong: Equatable {
    let title: String?
    let artist: String?
    let album: String?
    let imageURL: URL?
    
    init?(mediaItem: SHMatchedMediaItem) {
        guard let title = mediaItem.title,
              let artist = mediaItem.artist,
              let album = mediaItem.album
        else { return nil }
        
        self.title = title
        self.artist = artist
        self.album = album
        self.imageURL = mediaItem.artworkURL
    }
}

extension SHMediaItemProperty {
    static let album = SHMediaItemProperty("sh_albumName")
}

extension SHMediaItem {
    var album: String? {
        return self[.album] as? String
    }
}

enum ShazamError: Error, LocalizedError {
    case recordDenied
    case unknown
    case matchFailed
    
    var errorDescription: String {
        switch self {
        case .recordDenied:
            return "Record permission is denied. Please enable it in Settings."
        case .matchFailed:
            return "No song found or internet connection is bad."
        case .unknown:
            return "Unknown error occured."
        }
    }
}
