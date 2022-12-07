//
//  ViewController.swift
//  ShazamMusic
//
//  Created by Gordon Choi on 2022/11/28.
//

import UIKit

import MarqueeLabel
import RxCocoa
import RxSwift
import SnapKit

final class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let shazamSession = ShazamSession()
    private let musicSession = MusicSession()
    
    private var songInfo: SongInfo?
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .systemGray
        stackView.distribution = .equalSpacing
        stackView.contentMode = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.circle.fill")
        return imageView
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Search", for: .normal)
        return button
    }()
    
    private lazy var infoLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.text = "Try!"
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindAction()
        bindView()
        bindSearchResult()
    }

    private func setupView() {
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.edges.equalTo(view)
                .offset(32)
                .inset(32)
        }
        
        setupStackView()
    }
    
    private func setupStackView() {
        mainStackView.addArrangedSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.height.equalTo(300)
        }
        
        mainStackView.addArrangedSubview(searchButton)
        
        mainStackView.addArrangedSubview(infoLabel)
        infoLabel.snp.makeConstraints {
            $0.centerX.equalTo(mainStackView)
        }
        
        mainStackView.addArrangedSubview(playButton)
    }
    
    private func bindView() {
        shazamSession.isSearching
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { searchState in
                switch searchState {
                case true:
                    self.infoLabel.text = "Searching..."
                    self.mainStackView.backgroundColor = .systemTeal
                case false:
                    self.infoLabel.text = "Not searching"
                    self.mainStackView.backgroundColor = .systemGray
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAction() {
        searchButton.rx.tap
            .withUnretained(self)
            .bind { _ in
                self.searchTapped()
            }
            .disposed(by: disposeBag)
        
        playButton.rx.tap
            .withUnretained(self)
            .bind { _ in
                self.playTapped()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindSearchResult() {
        shazamSession.result
            .subscribe(onNext: { result in
                switch result {
                case .success(let song):
                    let isrc = song.isrc ?? "NO ISRC"
                    let title = song.title ?? "NO TITLE"
                    let artist = song.artist ?? "NO ARTIST"
                    let album = song.album ?? "NO ALBUM"
                    
                    let info = "Title: \(title), Artist: \(artist)"
                    let songInfo = SongInfo(isrc: isrc, title: title, artist: artist, album: album)
                    self.songInfo = songInfo
                    
                    self.musicSession.fetchMusic(term: songInfo)
                    
                    DispatchQueue.main.async {
                        self.mainStackView.backgroundColor = .systemCyan
                        self.infoLabel.text = info
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.mainStackView.backgroundColor = .systemRed
                        self.infoLabel.text = error.localizedDescription
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func searchTapped() {
//        shazamSession.toggleSearch()
        makeCancelOKAlert(title: "검색한다", message: "진짜 한다") { _ in
            self.shazamSession.toggleSearch()
        }
    }
    
    private func playTapped() {
        musicSession.playMusic()
    }
}

enum DeviceType {
    case iPhone14Pro
    
    func name() -> String {
        switch self {
        case .iPhone14Pro:
            return "iPhone 14 Pro"
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
extension UIViewController {
    
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func showPreview(_ deviceType: DeviceType = .iPhone14Pro) -> some View {
        Preview(viewController: self).previewDevice(PreviewDevice(rawValue: deviceType.name()))
    }
}
#endif

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        ViewController().showPreview(.iPhone14Pro)
    }
}
#endif
