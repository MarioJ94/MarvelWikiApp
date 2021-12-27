//
//  CharacterDetailsAppearancesInfoView.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 5/1/22.
//

import Foundation
import UIKit

protocol AppearancesInfoHandlerDelegate : AnyObject {
    func didChangeList()
    func didSelectViewMore(with appearancesModel: CharacterAppearancesModel)
}

final class CharacterDetailsAppearancesInfoView : UIView {
    // MARK: - Definitions
    private enum LabelTextDefinitions {
        static let viewMoreText = "View more"
        static let noInfoText = "No info"
        static let errorText = "Error"
    }
    
    enum ItemDivision {
        case number(amount: Int)
        case max
    }
    
    // MARK: - Dependencies
    private weak var handlerDelegate : AppearancesInfoHandlerDelegate?
    
    // MARK: - View definitions
    private let titleLabel : UILabel = {
        let v = UILabel()
        v.textAlignment = .natural
        let size : CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            size = 22
        } else {
            size = 30
        }
        v.font = UIFont.boldSystemFont(ofSize: size)
        return v
    }()
    
    private let baseStackView : UIStackView = {
        let v = UIStackView()
        v.distribution = .fill
        v.alignment = .top
        v.axis = .vertical
        return v
    }()
    
    private let buttonsStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    private let messageLabel : UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        let size : CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            size = 25
        } else {
            size = 30
        }
        v.font = UIFont.systemFont(ofSize: size, weight: .light)
        return v
    }()
    
    private let appearanceList : AppearancesList = {
        let v = AppearancesList()
        return v
    }()
    
    private var messageLabelConstraints : [NSLayoutConstraint] = []
    private var baseStackViewConstraints : [NSLayoutConstraint] = []
    private var itemArrangementDivision : ItemDivision = .max
    private let appearancesButtonsSpacing : CGFloat = 10
    
    private let comicsView : CharacterDetailsAppearancesButton = {
        let v = CharacterDetailsAppearancesButton()
        return v
    }()
    
    private let seriesView : CharacterDetailsAppearancesButton = {
        let v = CharacterDetailsAppearancesButton()
        return v
    }()
    
    private let storiesView : CharacterDetailsAppearancesButton = {
        let v = CharacterDetailsAppearancesButton()
        return v
    }()
    
    private let eventsView : CharacterDetailsAppearancesButton = {
        let v = CharacterDetailsAppearancesButton()
        return v
    }()
    
    private var comicsAppearancesModel : CharacterAppearancesModel?
    private var seriesAppearancesModel : CharacterAppearancesModel?
    private var storiesAppearancesModel : CharacterAppearancesModel?
    private var eventsAppearancesModel : CharacterAppearancesModel?
    private var currentAppearancesOpened : (model: CharacterAppearancesModel, view: CharacterDetailsAppearancesButton)?
    
    private let viewMoreButton : UIButton = {
        let v = UIButton()
        v.setTitle(LabelTextDefinitions.viewMoreText, for: .normal)
        v.titleLabel?.textAlignment = .center
        let size : CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            size = 25
        } else {
            size = 30
        }
        v.titleLabel?.font = UIFont.boldSystemFont(ofSize: size)
        v.setTitleColor(.blue, for: .normal)
        return v
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureEverything()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureEverything()
    }
    
    private func configureEverything() {
        self.clipsToBounds = true
        
        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.text = "Appearances"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        // Container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // Message label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageLabel)
        self.messageLabelConstraints = [messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                        messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
                                        messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                        messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)]
        NSLayoutConstraint.activate(self.messageLabelConstraints)
        messageLabel.text = LabelTextDefinitions.noInfoText
        
        // Stack Info
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(baseStackView)
        self.baseStackViewConstraints = [baseStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                                         baseStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
                                         baseStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                                         baseStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)]
        
        // Buttons StackView
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        baseStackView.addArrangedSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: baseStackView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: baseStackView.trailingAnchor)
        ])
        baseStackView.setCustomSpacing(30, after: buttonsStackView)
        
        // Button taps
        self.comicsView.configureTap(target: self, action: #selector(didTapButton(sender:)))
        self.seriesView.configureTap(target: self, action:  #selector(didTapButton(sender:)))
        self.storiesView.configureTap(target: self, action: #selector(didTapButton(sender:)))
        self.eventsView.configureTap(target: self, action: #selector(didTapButton(sender:)))
        
        // Appearance list
        appearanceList.translatesAutoresizingMaskIntoConstraints = false
        appearanceList.isHidden = true
        baseStackView.addArrangedSubview(appearanceList)
        NSLayoutConstraint.activate([
            appearanceList.leadingAnchor.constraint(equalTo: baseStackView.leadingAnchor),
            appearanceList.trailingAnchor.constraint(equalTo: baseStackView.trailingAnchor)
        ])
        baseStackView.setCustomSpacing(30, after: appearanceList)
        
        // View more button
        viewMoreButton.translatesAutoresizingMaskIntoConstraints = false
        viewMoreButton.isHidden = true
        baseStackView.addArrangedSubview(viewMoreButton)
        viewMoreButton.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            viewMoreButton.leadingAnchor.constraint(equalTo: baseStackView.leadingAnchor),
            viewMoreButton.trailingAnchor.constraint(equalTo: baseStackView.trailingAnchor)
        ])
        viewMoreButton.addTarget(self, action: #selector(didTapViewMore), for: .touchUpInside)
        
        // Additional
        self.buttonsStackView.spacing = self.appearancesButtonsSpacing
        self.arrangeViews()
        self.setAppearancesButtonsTextColor(color: .black)
        self.setAppearancesButtonsNumberColor(color: .black)
        self.setAppearancesButtonsBackgroundColors(selected: .gray, unselected: .lightGray)
    }
    
    func displayError() {
        self.messageLabel.text = LabelTextDefinitions.errorText
        self.baseStackViewConstraints.forEach({ $0.isActive = false })
        self.messageLabelConstraints.forEach({ $0.isActive = true })
        self.baseStackView.isHidden = true
        self.messageLabel.isHidden = false
    }
    
    func setComicAppearances(comics: CharacterAppearancesModel,
                             series: CharacterAppearancesModel,
                             stories: CharacterAppearancesModel,
                             events: CharacterAppearancesModel) {
        self.comicsAppearancesModel = comics
        self.seriesAppearancesModel = series
        self.storiesAppearancesModel = stories
        self.eventsAppearancesModel = events
        
        comicsView.setTitleText(text: "Comics")
        seriesView.setTitleText(text: "Series")
        storiesView.setTitleText(text: "Stories")
        eventsView.setTitleText(text: "Events")
        
        let comicsCountDescriptor = comics.count.asNSNumber.abbreviatedDescription(withMaxDecimals: 1)
        self.setInfoToAppearanceButton(with: comicsCountDescriptor, to: comicsView)
        
        let seriesCountDescriptor = series.count.asNSNumber.abbreviatedDescription(withMaxDecimals: 1)
        self.setInfoToAppearanceButton(with: seriesCountDescriptor, to: seriesView)
        
        let storiesCountDescriptor = stories.count.asNSNumber.abbreviatedDescription(withMaxDecimals: 1)
        self.setInfoToAppearanceButton(with: storiesCountDescriptor, to: storiesView)
        
        let eventsCountDescriptor = events.count.asNSNumber.abbreviatedDescription(withMaxDecimals: 1)
        self.setInfoToAppearanceButton(with: eventsCountDescriptor, to: eventsView)
        
        self.messageLabel.isHidden = true
        self.messageLabelConstraints.forEach({ $0.isActive = false })
        self.baseStackViewConstraints.forEach({ $0.isActive = true })
        self.baseStackView.isHidden = false
    }
    
    private func setInfoToAppearanceButton(with countDescriptor: NSNumber.NumberAbbreviationDescriptor, to button: CharacterDetailsAppearancesButton) {
        let signToUse = countDescriptor.positive ? "" : "-"
        switch countDescriptor.type {
        case .infinite:
            button.setNumberText(text: "\(signToUse)Inf.")
        case .noSuffixNeeded(let number):
            let value = Int(number.doubleValue.rounded(.towardZero))
            button.setNumberText(text: "\(signToUse)\(value)")
        case .withSuffix(let number, let suffix):
            button.setNumberText(text: "\(signToUse)\(number)\(suffix)")
        }
    }
    
    private func arrangeViews() {
        let views = [self.comicsView, self.seriesView, self.storiesView, self.eventsView]
        let numberOfItemsPerRow : Int
        switch self.itemArrangementDivision {
        case .number(let amount):
            numberOfItemsPerRow = amount
        case .max:
            numberOfItemsPerRow = views.count
        }
        let chunkedViews = views.chunked(into: max(numberOfItemsPerRow, 1))
        self.buttonsStackView.arrangedSubviews.forEach({
            buttonsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        for chunk in chunkedViews {
            let outterStack = UIStackView()
            outterStack.alignment = .fill
            outterStack.distribution = .fill
            outterStack.axis = .horizontal
            buttonsStackView.addArrangedSubview(outterStack)
            outterStack.addArrangedSubview(UIView())
            
            let innerStack = UIStackView()
            innerStack.alignment = .fill
            innerStack.distribution = .fillEqually
            innerStack.axis = .horizontal
            innerStack.spacing = self.appearancesButtonsSpacing
            
            outterStack.addArrangedSubview(innerStack)
            
            outterStack.addArrangedSubview(UIView())
            
            NSLayoutConstraint.activate([
                innerStack.centerXAnchor.constraint(equalTo: outterStack.centerXAnchor)
            ])
            
            for chunkView in chunk {
                innerStack.addArrangedSubview(chunkView)
            }
        }
    }
    
    func setItemsDivision(itemsDivision: ItemDivision) {
        switch itemsDivision {
        case .number(let amount):
            if amount < 1 {
                self.itemArrangementDivision = .number(amount: 1)
            } else {
                self.itemArrangementDivision = itemsDivision
            }
        case .max:
            self.itemArrangementDivision = itemsDivision
        }
        self.arrangeViews()
    }
    
    func setTitleColor(titleColor: UIColor) {
        self.titleLabel.textColor = titleColor
    }
    
    func setMessageTextColor(textColor: UIColor) {
        self.messageLabel.textColor = textColor
    }
    
    func setAppearancesButtonsTitleFont(font: UIFont) {
        self.comicsView.setTitleFont(titleLabelFont: font)
        self.seriesView.setTitleFont(titleLabelFont: font)
        self.storiesView.setTitleFont(titleLabelFont: font)
        self.eventsView.setTitleFont(titleLabelFont: font)
    }
    
    func setAppearancesButtonsCountFont(font: UIFont) {
        self.comicsView.setNumberFont(numberLabelFont: font)
        self.seriesView.setNumberFont(numberLabelFont: font)
        self.storiesView.setNumberFont(numberLabelFont: font)
        self.eventsView.setNumberFont(numberLabelFont: font)
    }
    
    func setAppearancesButtonsBackgroundColors(selected: UIColor,  unselected: UIColor) {
        self.comicsView.setBackgroundColors(selected: selected, unselected: unselected)
        self.seriesView.setBackgroundColors(selected: selected, unselected: unselected)
        self.storiesView.setBackgroundColors(selected: selected, unselected: unselected)
        self.eventsView.setBackgroundColors(selected: selected, unselected: unselected)
    }
    
    func setAppearancesButtonsTextColor(color: UIColor) {
        self.comicsView.setTitleTextColor(color: color)
        self.seriesView.setTitleTextColor(color: color)
        self.storiesView.setTitleTextColor(color: color)
        self.eventsView.setTitleTextColor(color: color)
    }
    
    func setAppearancesButtonsNumberColor(color: UIColor) {
        self.comicsView.setNumberTextColor(color: color)
        self.seriesView.setNumberTextColor(color: color)
        self.storiesView.setNumberTextColor(color: color)
        self.eventsView.setNumberTextColor(color: color)
    }
    
    func setAppearancesViewMoreButtonColors(titleColor: UIColor, backgroundColor: UIColor) {
        self.viewMoreButton.setTitleColor(titleColor, for: .normal)
        self.viewMoreButton.backgroundColor = backgroundColor
    }
    
    func setAppearancesListItemsTextColors(completeLinkColor: UIColor, incompleteLinkColor: UIColor) {
        self.appearanceList.setItemsColors(completeLink: completeLinkColor, incompleteLink: incompleteLinkColor)
    }
    
    @objc
    func didTapButton(sender: UITapGestureRecognizer) {
        let senderView = sender.view
        switch senderView {
        case self.comicsView:
            self.selected(model: self.comicsAppearancesModel, relatedTo: self.comicsView)
        case self.seriesView:
            self.selected(model: self.seriesAppearancesModel, relatedTo: self.seriesView)
        case self.storiesView:
            self.selected(model: self.storiesAppearancesModel, relatedTo: self.storiesView)
        case self.eventsView:
            self.selected(model: self.eventsAppearancesModel, relatedTo: self.eventsView)
        default:
            print("Unrecognized button")
            break
        }
    }
    
    private func selected(model: CharacterAppearancesModel?, relatedTo view: CharacterDetailsAppearancesButton) {
        guard let appearancesSelectionModel = model else {
            self.closeAppearancesList()
            return
        }
        
        let appearancesSelection = (model: appearancesSelectionModel, view: view)
        
        guard appearancesSelection.model.appearancesList.count > 0 else {
            if self.currentAppearancesOpened?.model != nil {
                self.closeAppearancesList()
            }
            return
        }
        if let currentAppearancesOpened = currentAppearancesOpened, currentAppearancesOpened == appearancesSelection {
            self.closeAppearancesList()
        } else {
            self.openListWith(appearancesSelection: appearancesSelection)
        }
    }
    
    private func deselectCurrentAppearancesButton() {
        self.currentAppearancesOpened?.view.markUnselected()
    }
    
    private func selectCurrentAppearancesButton() {
        self.currentAppearancesOpened?.view.markSelected()
    }
    
    private func openListWith(appearancesSelection: (model: CharacterAppearancesModel, view: CharacterDetailsAppearancesButton)) {
        self.deselectCurrentAppearancesButton()
        self.currentAppearancesOpened = appearancesSelection
        self.selectCurrentAppearancesButton()
        self.appearanceList.setList(appearances: appearancesSelection.model.appearancesList)
        self.appearanceList.isHidden = false
        let showViewMore = appearancesSelection.model.count > appearancesSelection.model.appearancesList.count
        self.viewMoreButton.isHidden = !showViewMore
        
        self.appearanceList.layoutIfNeeded()
        self.handlerDelegate?.didChangeList()
    }
    
    func closeAppearancesList() {
        self.deselectCurrentAppearancesButton()
        self.currentAppearancesOpened = nil
        self.appearanceList.setList(appearances: [])
        self.appearanceList.isHidden = true
        self.viewMoreButton.isHidden = true

        self.appearanceList.layoutIfNeeded()
        self.handlerDelegate?.didChangeList()
    }
    
    func setAppearanceItemInteractionDelegate(delegate: AppearanceItemInteractionDelegate?) {
        self.appearanceList.setDelegate(touchDelegate: delegate)
    }
    
    func setHandlerDelegate(delegate: AppearancesInfoHandlerDelegate?) {
        self.handlerDelegate = delegate
    }
    
    @objc
    func didTapViewMore() {
        guard let currentAppearancesOpened = currentAppearancesOpened else {
            return
        }
        self.handlerDelegate?.didSelectViewMore(with: currentAppearancesOpened.model)
    }
}
