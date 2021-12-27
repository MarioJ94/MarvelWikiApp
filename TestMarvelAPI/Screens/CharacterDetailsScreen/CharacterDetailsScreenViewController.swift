//
//  CharacterDetailsScreenViewController.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation
import UIKit
import Combine
import SDWebImage

fileprivate enum CharacterDetailsScreenLayoutType {
    case horizontal
    case vertical
    case imageOnBackground
}

final class CharacterDetailsScreenViewController : UIViewController {
    var viewModel : CharacterDetailsScreenViewModelUseCase?
    private var detailsViewModelSubscription : AnyCancellable? = nil
    
    private weak var characterImageHorizontalModeContainer: UIView?
    private weak var backgroundView : UIView?
    private weak var backgroundGradientView : CustomGradientView?
    private weak var characterImage : UIImageView?
    private weak var dataView: CharacterDetailsMainInfoDataView?
    private weak var appearancesDataView: CharacterDetailsAppearancesInfoView?
    private weak var scrollView: UIScrollView?
    private weak var stackView: UIStackView?
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []
    private var imageInBackgroundLayoutConstraints: [NSLayoutConstraint] = []
    private var characterImageAspectConstraint : NSLayoutConstraint?
    
    private let spinner: UIActivityIndicatorView = {
        let newSp = UIActivityIndicatorView(style: .large)
        newSp.color = .defaultBackgroundSpinnerColor
        newSp.hidesWhenStopped = true
        newSp.translatesAutoresizingMaskIntoConstraints = true
        newSp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return newSp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureBinding()
        self.configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isBeingPresented || self.isMovingToParent {
            self.stackView?.alpha = 0
            self.spinner.startAnimating()
            self.viewModel?.updateData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.adaptGradient()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.willAdaptCharacterImageCornerRadius()
        self.adaptCharacterImageCornerRadius()
        self.adaptGradient()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.adaptGradient()
        self.assignCharacterImageBorderWidth()
        if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
            self.assignCharacterImageBorderColor()
            self.adaptGradientColors()
        }
    }
    
    private func configureBinding() {
        self.detailsViewModelSubscription = self.viewModel?.dataPublisher().sink(receiveValue: { [weak self] result in
            self?.spinner.stopAnimating()
            switch result {
            case .failure(let error):
                self?.handleError(error: error)
            case .success(let model):
                self?.displayModel(model: model)
            }
            self?.stackView?.alpha = 1
        })
    }
    
    private func layoutModeToApplyWith(traitCollectionToUse: UITraitCollection) -> CharacterDetailsScreenLayoutType {
        switch traitCollectionToUse.userInterfaceIdiom {
        case .carPlay:
            return .horizontal
        case .mac:
            return .horizontal
        case .pad:
            if traitCollectionToUse.verticalSizeClass == .compact {
                return .horizontal
            } else if traitCollectionToUse.horizontalSizeClass == .compact {
                return .vertical
            } else {
                return .imageOnBackground
            }
        case .phone:
            if traitCollectionToUse.verticalSizeClass == .compact {
                return .horizontal
            } else {
                return .vertical
            }
        case .tv:
            return .horizontal
        case .unspecified:
            return .horizontal
        @unknown default:
            return .horizontal
        }
    }
    
    private func configureViews() {
        self.title = "Character Details"
        self.view.backgroundColor = .adaptativeColor(lightMode: .white, darkMode: UIColor(cgColor: .init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)) )
        self.view.insetsLayoutMarginsFromSafeArea = true
        
        // Background view
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.backgroundView = backgroundView
        
        // Background view gradient
        let backgroundGradientView = CustomGradientView()
        backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.insertSubview(backgroundGradientView, at: 1)
        NSLayoutConstraint.activate([
            backgroundGradientView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            backgroundGradientView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            backgroundGradientView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            backgroundGradientView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
        self.backgroundGradientView = backgroundGradientView
        
        // Horizontal Stack view
        let modesStackView = UIStackView()
        modesStackView.translatesAutoresizingMaskIntoConstraints = false
        modesStackView.spacing = 0
        
        self.view.addSubview(modesStackView)
        modesStackView.axis = .horizontal
        modesStackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            modesStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            modesStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            modesStackView.topAnchor.constraint(equalTo: self.view.topAnchor),
            modesStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Horizontal Mode Image Container
        let characterImageHorizontalModeContainer = UIView()
        characterImageHorizontalModeContainer.translatesAutoresizingMaskIntoConstraints = false
        modesStackView.addArrangedSubview(characterImageHorizontalModeContainer)
        characterImageHorizontalModeContainer.isHidden = true
        NSLayoutConstraint.activate([
            characterImageHorizontalModeContainer.widthAnchor.constraint(equalTo: modesStackView.widthAnchor, multiplier: 0.45)
        ])
        self.characterImageHorizontalModeContainer = characterImageHorizontalModeContainer
        
        // Main Scroll View
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        modesStackView.addArrangedSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.delegate = self
        self.scrollView = scrollView
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: modesStackView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: modesStackView.bottomAnchor)
        ])
        
        // ScrollView content view
        let scrollContentView = UIView()
        scrollView.addSubview(scrollContentView)
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor)
        ])
        
        // StackView of ScrollView
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        
        scrollContentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        self.stackView = stackView
        
        let stackViewVerticalModeConstraints = [stackView.leadingAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.leadingAnchor).withPriority(.defaultHigh),
                                                stackView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollContentView.safeAreaLayoutGuide.leadingAnchor),
                                                stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 15),
                                                stackView.trailingAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.trailingAnchor).withPriority(.defaultHigh),
                                                stackView.trailingAnchor.constraint(lessThanOrEqualTo: scrollContentView.safeAreaLayoutGuide.trailingAnchor),
                                                stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -15),
                                                stackView.topAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.topAnchor, constant: 15),
                                                stackView.bottomAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.bottomAnchor, constant: -15)]
        self.verticalLayoutConstraints.append(contentsOf: stackViewVerticalModeConstraints)
        let stackViewHorizontalModeConstraints = [stackView.leadingAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.leadingAnchor),
                                                  stackView.trailingAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.trailingAnchor).withPriority(.defaultHigh),
                                                  stackView.trailingAnchor.constraint(lessThanOrEqualTo: scrollContentView.safeAreaLayoutGuide.trailingAnchor),
                                                  stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -15),
                                                  stackView.topAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.topAnchor, constant: 15),
                                                  stackView.bottomAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.bottomAnchor, constant: -15)]
        self.horizontalLayoutConstraints.append(contentsOf: stackViewHorizontalModeConstraints)
        
        let stackViewImageOnBackgroundConstraints = [stackView.leadingAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.leadingAnchor).withPriority(.defaultHigh),
                                                     stackView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollContentView.safeAreaLayoutGuide.leadingAnchor),
                                                     stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 15),
                                                     stackView.trailingAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.trailingAnchor).withPriority(.defaultHigh),
                                                     stackView.trailingAnchor.constraint(lessThanOrEqualTo: scrollContentView.safeAreaLayoutGuide.trailingAnchor),
                                                     stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -15),
                                                     stackView.topAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.topAnchor),
                                                     stackView.bottomAnchor.constraint(equalTo: scrollContentView.safeAreaLayoutGuide.bottomAnchor, constant: -15)]
        self.imageInBackgroundLayoutConstraints.append(contentsOf: stackViewImageOnBackgroundConstraints)
        
        // Character Image
        let characterImage = UIImageView()
        characterImage.contentMode = .scaleAspectFill
        characterImage.clipsToBounds = true
        characterImage.translatesAutoresizingMaskIntoConstraints = false
        self.characterImage = characterImage
        
        let characterImageAspectRatioConstraint = characterImage.widthAnchor.constraint(equalTo: characterImage.heightAnchor, multiplier: 1)
        NSLayoutConstraint.activate([characterImageAspectRatioConstraint])
        self.characterImageAspectConstraint = characterImageAspectRatioConstraint
        
        let imageInVerticalModeConstraints = [characterImage.leadingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.leadingAnchor),
                                              characterImage.trailingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.trailingAnchor)]
        self.verticalLayoutConstraints.append(contentsOf: imageInVerticalModeConstraints)
        
        let imageInHorizontalModeConstraints = [characterImage.leadingAnchor.constraint(greaterThanOrEqualTo: characterImageHorizontalModeContainer.safeAreaLayoutGuide.leadingAnchor, constant: 15),
                                                characterImage.trailingAnchor.constraint(lessThanOrEqualTo: characterImageHorizontalModeContainer.safeAreaLayoutGuide.trailingAnchor, constant: -15),
                                                characterImage.topAnchor.constraint(greaterThanOrEqualTo: characterImageHorizontalModeContainer.safeAreaLayoutGuide.topAnchor, constant: 15),
                                                characterImage.bottomAnchor.constraint(lessThanOrEqualTo: characterImageHorizontalModeContainer.safeAreaLayoutGuide.bottomAnchor, constant: -15),
                                                characterImage.centerXAnchor.constraint(equalTo: characterImageHorizontalModeContainer.safeAreaLayoutGuide.centerXAnchor).withPriority(.defaultHigh),
                                                characterImage.centerYAnchor.constraint(equalTo: characterImageHorizontalModeContainer.safeAreaLayoutGuide.centerYAnchor).withPriority(.defaultHigh)]
        self.horizontalLayoutConstraints.append(contentsOf: imageInHorizontalModeConstraints)
        
        let imageInImageOnBackgroundModeConstraints = [characterImage.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                                                       characterImage.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                                                       characterImage.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                                                       characterImage.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)]
        self.imageInBackgroundLayoutConstraints.append(contentsOf: imageInImageOnBackgroundModeConstraints)
        
        // Main Info Container
        let mainInfoContainer = UIView()
        mainInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(mainInfoContainer)
        
        NSLayoutConstraint.activate([
            mainInfoContainer.trailingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.trailingAnchor),
            mainInfoContainer.leadingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.leadingAnchor),
        ])
        
        // Main Info spacer view
        let mainInfoSpacerView = UIView()
        mainInfoSpacerView.translatesAutoresizingMaskIntoConstraints = false
        mainInfoContainer.addSubview(mainInfoSpacerView)
        
        let mainInfoSpacerVerticalConstraints = [mainInfoSpacerView.heightAnchor.constraint(equalToConstant: 25)]
        self.verticalLayoutConstraints.append(contentsOf: mainInfoSpacerVerticalConstraints)
        
        let mainInfoSpacerHorizontalConstraints = [mainInfoSpacerView.heightAnchor.constraint(equalToConstant: 0)]
        self.horizontalLayoutConstraints.append(contentsOf: mainInfoSpacerHorizontalConstraints)
        
        let mainInfoSpacerImageOnBackgroundConstraints = [mainInfoSpacerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5)]
        self.imageInBackgroundLayoutConstraints.append(contentsOf: mainInfoSpacerImageOnBackgroundConstraints)
        
        NSLayoutConstraint.activate([mainInfoSpacerView.topAnchor.constraint(equalTo: mainInfoContainer.topAnchor),
                                     mainInfoSpacerView.trailingAnchor.constraint(equalTo: mainInfoContainer.trailingAnchor),
                                     mainInfoSpacerView.leadingAnchor.constraint(equalTo: mainInfoContainer.leadingAnchor)])
        
        // Main Info Data View
        let mainInfo = CharacterDetailsMainInfoDataView()
        mainInfo.translatesAutoresizingMaskIntoConstraints = false
        mainInfoContainer.addSubview(mainInfo)
        
        NSLayoutConstraint.activate([mainInfo.topAnchor.constraint(equalTo: mainInfoSpacerView.bottomAnchor),
                                     mainInfo.trailingAnchor.constraint(equalTo: mainInfoContainer.trailingAnchor),
                                     mainInfo.leadingAnchor.constraint(equalTo: mainInfoContainer.leadingAnchor),
                                     mainInfo.bottomAnchor.constraint(equalTo: mainInfoContainer.bottomAnchor, constant: -10)])
        
        self.dataView = mainInfo
        
        // Appearances Data Container
        let appearancesDataContainer = UIView()
        mainInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(appearancesDataContainer)

        NSLayoutConstraint.activate([
            appearancesDataContainer.trailingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.trailingAnchor),
            appearancesDataContainer.leadingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.leadingAnchor)
        ])

        // Apperances Data view
        let appearancesDataView = CharacterDetailsAppearancesInfoView()
        appearancesDataView.translatesAutoresizingMaskIntoConstraints = false
        appearancesDataContainer.addSubview(appearancesDataView)

        NSLayoutConstraint.activate([appearancesDataView.topAnchor.constraint(equalTo: appearancesDataContainer.topAnchor, constant: 10),
                                     appearancesDataView.trailingAnchor.constraint(equalTo: appearancesDataContainer.trailingAnchor),
                                     appearancesDataView.leadingAnchor.constraint(equalTo: appearancesDataContainer.leadingAnchor),
                                     appearancesDataView.bottomAnchor.constraint(equalTo: appearancesDataContainer.bottomAnchor)])

        appearancesDataView.setAppearanceItemInteractionDelegate(delegate: self)
        appearancesDataView.setHandlerDelegate(delegate: self)
        self.appearancesDataView = appearancesDataView
        
        // Spinner
        self.view.addSubview(self.spinner)
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.spinner.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.spinner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.spinner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.spinner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.adaptLayout()
        self.assignCharacterImageBorderWidth()
        self.assignCharacterImageBorderColor()
        self.adaptGradientColors()
    }
    
    private func willAdaptCharacterImageCornerRadius() {
        switch self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) {
        case .imageOnBackground:
            self.characterImageHorizontalModeContainer?.layoutIfNeeded()
        case .vertical, .horizontal:
            self.stackView?.layoutIfNeeded()
        }
    }
    
    private func adaptCharacterImageCornerRadius() {
        let cornerMultiplier : CGFloat
        switch self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) {
        case .imageOnBackground:
            cornerMultiplier = 0
        case .vertical, .horizontal:
            cornerMultiplier = 0.03
        }
        self.characterImage?.layer.cornerRadius = (self.characterImage?.frame.height ?? 0) * cornerMultiplier
    }
    
    private func displayModel(model: CharacterDetailsScreenModel) {
        self.dataView?.setTitle(title: model.name)
        self.dataView?.setDescription(desc: model.description)
        self.appearancesDataView?.setComicAppearances(comics: model.comicsAppearances,
                                                      series: model.seriesAppearances,
                                                      stories: model.storiesAppearances,
                                                      events: model.eventsAppearances)
        self.setBackgroundImageURL(urlString: model.thumbnail)
    }
    
    private func handleError(error: CharacterDetailsScreenViewModelError) {
        switch error {
        case .fetchDetailsError:
            let popup = UIAlertController(title: "Error", message: "There was an error with the data", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] act in
                self?.navigationController?.popViewController(animated: true)
            }
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let previousMode = self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection)
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            UIView.performWithoutAnimation {
                guard let self = self else {
                    return
                }
                self.adaptLayout()
                if self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) != previousMode {
                    self.characterImage?.alpha = 0
                    self.stackView?.alpha = 0
                    self.backgroundGradientView?.alpha = 0
                }
                self.view.layoutIfNeeded()
                self.adaptGradient()
            }
        } completion: { [weak self] context in
            UIView.animate(withDuration: 0.35) {
                guard let self = self else {
                    return
                }
                if self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) != previousMode {
                    self.characterImage?.alpha = 1
                    self.stackView?.alpha = 1
                    self.backgroundGradientView?.alpha = 1
                }
            }
            self?.view.layoutIfNeeded()
            self?.adaptGradient()
        }
    }
    
    private func adaptLayout() {
        let layoutType = self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection)
        switch layoutType {
        case .horizontal:
            self.configureViewsForHorizontalLayout()
        case .vertical:
            self.configureViewsForVerticalLayout()
        case .imageOnBackground:
            self.configureViewsForImageOnBackgroundLayout()
        }
    }
    
    private func configureViewsForHorizontalLayout() {
        if let characterImage = self.characterImage {
            if let imageInStackView = self.stackView?.arrangedSubviews.first(where: { $0 == characterImage }) {
                self.stackView?.removeArrangedSubview(imageInStackView)
                imageInStackView.removeFromSuperview()
            } else if let backgroundView = self.backgroundView, characterImage.isDescendant(of: backgroundView) {
                characterImage.removeFromSuperview()
            }
            self.characterImageHorizontalModeContainer?.addSubview(characterImage)
        }
        
        let colorOfElementsDisplayedAboveBackgroundColor : UIColor = .adaptativeColor(lightMode: .black, darkMode: .white)
        
        self.dataView?.setTitleColor(titleColor: colorOfElementsDisplayedAboveBackgroundColor)
        self.dataView?.setDescriptionColor(descColor: colorOfElementsDisplayedAboveBackgroundColor)
        
        // Apperances config
        self.appearancesDataView?.setTitleColor(titleColor: .adaptativeColor(lightMode: .black, darkMode: .white))
        self.appearancesDataView?.setMessageTextColor(textColor: .adaptativeColor(lightMode: .black, darkMode: .white))
        let completeLinkColor = colorOfElementsDisplayedAboveBackgroundColor
        let incompleteLinkColor = UIColor.adaptativeColor(lightMode: .systemGray2, darkMode: .systemGray2)
        self.appearancesDataView?.setAppearancesListItemsTextColors(completeLinkColor: completeLinkColor,
                                                                    incompleteLinkColor: incompleteLinkColor)
        let division : CharacterDetailsAppearancesInfoView.ItemDivision = .max
        self.appearancesDataView?.setItemsDivision(itemsDivision: division)
        self.appearancesDataView?.setAppearancesViewMoreButtonColors(titleColor: .adaptativeColor(lightMode: .black, darkMode: .black),
                                                                     backgroundColor: .adaptativeColor(lightMode: .systemGray4, darkMode: .lightGray))
        
        self.characterImageAspectConstraint?.isActive = true
        self.backgroundView?.isHidden = true
        self.characterImageHorizontalModeContainer?.isHidden = false
        self.verticalLayoutConstraints.forEach({ $0.isActive = false })
        self.imageInBackgroundLayoutConstraints.forEach({ $0.isActive = false })
        self.horizontalLayoutConstraints.forEach({ $0.isActive = true })
    }
    
    private func configureViewsForVerticalLayout() {
        if let characterImage = self.characterImage {
            if let characterImageHorizontalModeContainer = self.characterImageHorizontalModeContainer, characterImage.isDescendant(of: characterImageHorizontalModeContainer) {
                characterImage.removeFromSuperview()
            } else if let backgroundView = self.backgroundView, characterImage.isDescendant(of: backgroundView) {
                characterImage.removeFromSuperview()
            }
            self.stackView?.insertArrangedSubview(characterImage, at: 0)
        }
        
        let colorOfElementsDisplayedAboveBackgroundColor : UIColor = .adaptativeColor(lightMode: .black, darkMode: .white)
        
        self.dataView?.setTitleColor(titleColor: colorOfElementsDisplayedAboveBackgroundColor)
        self.dataView?.setDescriptionColor(descColor: colorOfElementsDisplayedAboveBackgroundColor)
        
        // Apperances config
        self.appearancesDataView?.setTitleColor(titleColor: colorOfElementsDisplayedAboveBackgroundColor)
        self.appearancesDataView?.setMessageTextColor(textColor: colorOfElementsDisplayedAboveBackgroundColor)
        let completeLinkColor = colorOfElementsDisplayedAboveBackgroundColor
        let incompleteLinkColor = UIColor.adaptativeColor(lightMode: .systemGray2, darkMode: .systemGray2)
        self.appearancesDataView?.setAppearancesListItemsTextColors(completeLinkColor: completeLinkColor,
                                                                    incompleteLinkColor: incompleteLinkColor)
        let division : CharacterDetailsAppearancesInfoView.ItemDivision = .max
        self.appearancesDataView?.setItemsDivision(itemsDivision: division)
        self.appearancesDataView?.setAppearancesViewMoreButtonColors(titleColor: .adaptativeColor(lightMode: .black, darkMode: .black),
                                                                     backgroundColor: .adaptativeColor(lightMode: .systemGray4, darkMode: .lightGray))
        
        self.characterImageAspectConstraint?.isActive = true
        self.backgroundView?.isHidden = true
        self.characterImageHorizontalModeContainer?.isHidden = true
        self.horizontalLayoutConstraints.forEach({ $0.isActive = false })
        self.imageInBackgroundLayoutConstraints.forEach({ $0.isActive = false })
        self.verticalLayoutConstraints.forEach({ $0.isActive = true })
    }
    
    private func configureViewsForImageOnBackgroundLayout() {
        if let characterImage = self.characterImage {
            if let imageInStackView = self.stackView?.arrangedSubviews.first(where: { $0 == characterImage }) {
                self.stackView?.removeArrangedSubview(imageInStackView)
                imageInStackView.removeFromSuperview()
            } else if let characterImageHorizontalModeContainer = self.characterImageHorizontalModeContainer, characterImage.isDescendant(of: characterImageHorizontalModeContainer) {
                characterImage.removeFromSuperview()
            } else if let backgroundView = self.backgroundView, characterImage.isDescendant(of: backgroundView) {
                characterImage.removeFromSuperview()
            }
            self.backgroundView?.insertSubview(characterImage, at: 0)
        }
        
        let colorOfElementsDisplayedAboveBackgroundColor : UIColor = .adaptativeColor(lightMode: .white, darkMode: .white)
        
        self.dataView?.setTitleColor(titleColor: colorOfElementsDisplayedAboveBackgroundColor)
        self.dataView?.setDescriptionColor(descColor: colorOfElementsDisplayedAboveBackgroundColor)
        
        // Apperances config
        self.appearancesDataView?.setTitleColor(titleColor: colorOfElementsDisplayedAboveBackgroundColor)
        self.appearancesDataView?.setMessageTextColor(textColor: colorOfElementsDisplayedAboveBackgroundColor)
        let completeLinkColor = colorOfElementsDisplayedAboveBackgroundColor
        let incompleteLinkColor = UIColor.adaptativeColor(lightMode: .systemGray2, darkMode: .systemGray2)
        self.appearancesDataView?.setAppearancesListItemsTextColors(completeLinkColor: completeLinkColor,
                                                                    incompleteLinkColor: incompleteLinkColor)
        let division : CharacterDetailsAppearancesInfoView.ItemDivision = .max
        self.appearancesDataView?.setItemsDivision(itemsDivision: division)
        self.appearancesDataView?.setAppearancesViewMoreButtonColors(titleColor: .adaptativeColor(lightMode: .black, darkMode: .black),
                                                                     backgroundColor: .adaptativeColor(lightMode: .systemGray4, darkMode: .lightGray))
        
        self.characterImageAspectConstraint?.isActive = false
        self.backgroundView?.isHidden = false

        self.characterImageHorizontalModeContainer?.isHidden = true
        self.horizontalLayoutConstraints.forEach({ $0.isActive = false })
        self.verticalLayoutConstraints.forEach({ $0.isActive = false })
        self.imageInBackgroundLayoutConstraints.forEach({ $0.isActive = true })
    }
    
    private func adaptAspectRatioCharacterImage() {
        var multiplier : CGFloat = 1
        if let image = characterImage?.image {
            multiplier = image.size.width / image.size.height
        }
        switch self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) {
        case .horizontal, .vertical:
            self.characterImage?.layer.borderColor = UIColor.adaptativeColor(lightMode: .black, darkMode: .white).cgColor
            self.characterImage?.layer.borderWidth = 1
        case .imageOnBackground:
            self.characterImage?.layer.borderColor = nil
            self.characterImage?.layer.borderWidth = 0
        }
        let wasActive = self.characterImageAspectConstraint?.isActive ?? false
        let newAspectConstraint = self.characterImageAspectConstraint?.copyWithMultiplier(multiplier: multiplier)
        self.characterImageAspectConstraint?.isActive = false
        self.characterImageAspectConstraint = newAspectConstraint
        newAspectConstraint?.isActive = wasActive
    }
    
    private func assignCharacterImageBorderWidth() {
        switch self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) {
        case .horizontal, .vertical:
            self.characterImage?.layer.borderWidth = 1
        case .imageOnBackground:
            self.characterImage?.layer.borderWidth = 0
        }
    }
    
    private func assignCharacterImageBorderColor() {
        switch self.layoutModeToApplyWith(traitCollectionToUse: self.traitCollection) {
        case .horizontal, .vertical:
            self.characterImage?.layer.borderColor = UIColor.adaptativeColor(lightMode: .black, darkMode: .white).cgColor
        case .imageOnBackground:
            self.characterImage?.layer.borderColor = nil
        }
    }
}

// MARK: - CharacterImage Image
extension CharacterDetailsScreenViewController {
    private func setBackgroundImageURL(urlString: String?) {
        let defaultImage = UIImage.characterImageLoadFallbackImage
        guard let urlString = urlString else {
            self.characterImage?.image = defaultImage
            return
        }
        let url = URL(string: urlString)
        self.characterImage?.sd_setImage(with: url, placeholderImage: nil, options: [.refreshCached], context: nil, progress: nil) { [weak self] image, err, type, url in
            if let err = err {
                if let error = err as? SDWebImageError {
                    switch error.code {
                    case .cancelled:
                        break
                    default:
                        self?.characterImage?.image = defaultImage
                    }
                } else {
                    self?.characterImage?.image = defaultImage
                }
            }
            self?.adaptAspectRatioCharacterImage()
        }
    }
}

extension CharacterDetailsScreenViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.adaptGradient()
    }
    
    private func adaptGradientColors() {
        self.backgroundGradientView?.setStartPointColor(color: .adaptativeColor(lightMode: .clear,
                                                                                darkMode: .black.withAlphaComponent(0.2)))
        self.backgroundGradientView?.setEndPointColor(color: .adaptativeColor(lightMode: .black.withAlphaComponent(0.5),
                                                                              darkMode: .black.withAlphaComponent(0.6)))
    }
    
    private func adaptGradient() {
        if let data = dataView {
            let point = data.convert(CGPoint.zero, to: self.view)
            let y = point.y
            let relativeY = y / self.view.frame.height
            let gradientFadoutDistance : CGFloat = 100
            let relativeFadeoutStartY = relativeY - (gradientFadoutDistance / self.view.frame.height)
            
            self.backgroundGradientView?.setStartPoint(point: CGPoint(x: 0, y: relativeFadeoutStartY))
            self.backgroundGradientView?.setEndPoint(point: CGPoint(x: 0, y: relativeY))
        }
    }
}

extension CharacterDetailsScreenViewController : AppearanceItemInteractionDelegate {
    func didTap(appearanceInfo: AppearanceRef) {
        guard let url = appearanceInfo.url else {
            let popup = UIAlertController(title: "Error", message: "There is no info for \"\(appearanceInfo.name)\" available", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
            return
        }
        let message = "This is not implemented.\nTrying to access:\nName: \(appearanceInfo.name)\nURL:\(url)"
        let popup = UIAlertController(title: "Not implemented", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        popup.addAction(okAction)
        self.present(popup, animated: true, completion: nil)
    }
}

extension CharacterDetailsScreenViewController : AppearancesInfoHandlerDelegate {
    func didChangeList() {
        guard let scrollView = self.scrollView else {
            return
        }
        guard let localFrame = self.appearancesDataView?.frame, let frameToFocus = self.appearancesDataView?.superview?.convert(localFrame, to: scrollView) else {
            return
        }
        let adjustedInsets = scrollView.adjustedContentInset
        let pointToFocus = CGPoint(x: frameToFocus.origin.x - adjustedInsets.left, y: frameToFocus.origin.y - adjustedInsets.top)
        guard pointToFocus.y > scrollView.contentOffset.y else {
            return
        }
        
        self.scrollView?.scrollToPoint(point: pointToFocus, animated: true)
    }
    
    func didSelectViewMore(with appearancesModel: CharacterAppearancesModel) {
        guard let url = appearancesModel.link else {
            let popup = UIAlertController(title: "Error", message: "There is no collection link for current appearances", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            popup.addAction(okAction)
            self.present(popup, animated: true, completion: nil)
            return
        }
        let message = "This is not implemented.\nTrying to access:\nURL:\(url)"
        let popup = UIAlertController(title: "Not implemented", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        popup.addAction(okAction)
        self.present(popup, animated: true, completion: nil)
    }
}
