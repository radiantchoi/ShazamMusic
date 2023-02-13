//
//  MusicVerifier.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2023/02/13.
//

import StoreKit

import RxSwift

final class MusicVerifier {
    private var subscribedAppleMusic = PublishSubject<Bool>()
    
    var subscribeStateObservable: Observable<Bool> {
        return subscribedAppleMusic.asObservable()
    }
    
    func isSubscribedToAppleMusic() -> Single<Bool> {
        let serviceController = SKCloudServiceController()
        
        return Single.create { observer in
            serviceController.requestCapabilities { capabilities, error in
                if let error = error {
                    observer(.failure(error))
                } else {
                    if capabilities.contains(.musicCatalogPlayback) {
                        // User is subscribed to Apple Music
                        observer(.success(true))
                    } else {
                        // User is not subscribed to Apple Music
                        observer(.success(false))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
