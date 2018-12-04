//
//  Constants.swift
//  SuperChat
//
//  Created by Christopher Batin on 29/11/2018.
//  Copyright © 2018 Christopher Batin. All rights reserved.
//

import Foundation
import PusherChatkit

let url = "http://localhost:8080"
struct Constants {
    static let createUserURL = URL.init(string: "\(url)/api/users/new")!
    static let loginURL = URL.init(string: "\(url)/api/users/login")!
    static let tokenProvider = PCTokenProvider.init(url: "https://us1.pusherplatform.io/services/chatkit_token_provider/v1/1848b958-7926-4708-8959-aad6ca8cfdd9/token")
    static let chatkitInstance = "v1:us1:1848b958-7926-4708-8959-aad6ca8cfdd9"
}
