//
//  LoginPluginListener.swift
//  LoggedInPlugin
//
//  Created by Angel Cortez on 4/22/20.
//

import Foundation

public protocol LoginPluginListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func done()
}
