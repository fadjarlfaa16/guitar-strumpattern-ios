//
//  AppDelegate.swift
//  guitar-strumpattern-detection-ios
//
//  Created by Farhan Izzaz on 05/06/26.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Orientation Lock
    /// Set this from any SwiftUI view using .onAppear / .onDisappear.
    /// Defaults to portrait — change per-screen as needed.
    static var orientationLock: UIInterfaceOrientationMask = .portrait

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
//
