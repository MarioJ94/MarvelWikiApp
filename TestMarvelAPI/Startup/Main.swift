//
//  Main.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation
import UIKit

class Main : UIViewController {
    private var rootView: UINavigationController!
    private var goToCharactersListButton: UIButton! = nil
    
    class func initializer() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "Main")
    }
    
    private var defaultSupportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
    
    private var defaultShouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return rootView?.topViewController?.supportedInterfaceOrientations ?? self.defaultSupportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return rootView?.topViewController?.shouldAutorotate ?? self.defaultShouldAutorotate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureContentView()
    }
    
    private func configureView() {
        self.view.backgroundColor = .white
    }
    
    private func configureContentView() {
        let firstScreen = Assembly.shared.provideCharacterListViewerWithSearch()
        let v = UINavigationController(rootViewController: firstScreen)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .defaultNavBarColor
        appearance.shadowColor = .defaultNavBarColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.defaultNavBarTextColor]
        v.navigationBar.compactAppearance = appearance
        v.navigationBar.standardAppearance = appearance
        v.navigationBar.scrollEdgeAppearance = appearance
        
        self.add(v, inContainerView: self.view, withAutolayoutMatch: true)
        v.view.backgroundColor = .clear
        self.rootView = v
    }
}
