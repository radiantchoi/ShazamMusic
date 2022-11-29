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
                    let info = "Title: \(song.title ?? "NO TITLE"), Artist: \(song.artist ?? "NO ARTIST")"
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
        shazamSession.start()
        DispatchQueue.main.async {
            self.infoLabel.text = "Searching..."
            self.mainStackView.backgroundColor = .systemTeal
        }
    }
    
    private func playTapped() {
        musicSession.fetchMusic()
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
