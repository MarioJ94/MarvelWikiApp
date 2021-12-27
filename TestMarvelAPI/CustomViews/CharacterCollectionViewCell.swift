//
//  CharacterCollectionViewCell.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation
import SDWebImage

final class CharacterCollectionViewCell : UICollectionViewCell {
    let label : UILabel = {
        let v = UILabel()
        v.textColor = .adaptativeColor(lightMode: .black, darkMode: .white)
        v.numberOfLines = 1
        v.textAlignment = .left
        v.font = v.font.withSize(18)
        return v
    }()
    
    let thumbnail : UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
            self.assignThumbnailBorder()
        }
    }
    
    private func configureViews() {
        self.clipsToBounds = true
        self.configureBackground()
        self.configureDetailsViews()
        self.assignThumbnailBorder()
    }
    
    private func configureBackground() {
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.adaptThumbnailCornerRadius()
    }
    
    private func assignThumbnailBorder() {
        self.thumbnail.layer.borderColor = UIColor.adaptativeColor(lightMode: .black, darkMode: .white).cgColor
        self.thumbnail.layer.borderWidth = 1
    }
    
    
    private func adaptThumbnailCornerRadius() {
        self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height * 0.07
    }
    
    private func configureDetailsViews() {
        // thumbnail
        self.addSubview(thumbnail)
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: self.topAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            thumbnail.heightAnchor.constraint(equalTo: thumbnail.widthAnchor).withPriority(UILayoutPriority(999)) // This avoids constraint conflict for self-sizable cells
        ])
        
        // label
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
    
    func loadImage(url: String?) {
        let defaultImage = UIImage.characterImageLoadFallbackImage
        guard let url = url else {
            self.thumbnail.image = defaultImage
            return
        }
        let urlToUse = URL(string: url)
        self.thumbnail.sd_setImage(with: urlToUse, placeholderImage: nil, options: [.refreshCached], context: nil, progress: nil) { [weak self] image, err, typ, usedUrl in
            if let err = err {
                if let error = err as? SDWebImageError {
                    switch error.code {
                    case .cancelled:
                        break
                    default:
                        self?.thumbnail.image = defaultImage
                    }
                } else {
                    self?.thumbnail.image = defaultImage
                }
            }
        }
    }
}
