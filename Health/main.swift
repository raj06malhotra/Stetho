//
//  main.swift
//  Stetho
//
//  Created by HW-Anil on 12/9/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import Foundation
import UIKit
//CommandLine.unsafeArgv
//UIApplicationMain(CommandLine.argc, (CommandLine.unsafeArgv!), NSStringFromClass(TIMERUIApplication), NSStringFromClass(AppDelegate))


//UIApplicationMain(CommandLine.argc, UnsafeMutablePointer<UnsafeMutablePointer<CChar>>(CommandLine.unsafeArgv), NSStringFromClass(TIMERUIApplication), NSStringFromClass(AppDelegate))




UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(TIMERUIApplication.self),
    NSStringFromClass(AppDelegate.self)
)

//UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(TIMERUIApplication), NSStringFromClass(AppDelegate))
