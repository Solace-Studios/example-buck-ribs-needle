# HotFix for build issues with RIBs 9 and buck

To freshly make project first time:

make carth
make update_cocoapods
Fixed compiler errors, 
- Add import Foundation to 
  - Carthage/Checkouts/RxSwift/Sources/RxTest/DeprecationWarner.swift
  - Pods/RIBs/ios/RIBs/Classes/LeakDetector/LeakDetector.swift
  - Pods/RIBs/ios/RIBs/Classes/LeakDetector/Executor.swift
  - Pods/RIBs/ios/RIBs/Classes/DI/Component.swift
- Add import UIKit to 
  - Pods/RIBs/ios/RIBs/Classes/LeakDetector/LeakDetector.swift

make build
make project
Then fix signing issue in Xcode under project, signing, and add team.

Done!
