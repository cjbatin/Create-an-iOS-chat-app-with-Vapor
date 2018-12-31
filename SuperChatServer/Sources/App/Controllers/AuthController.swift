//
//  AuthController.swift
//  App
//
//  Created by Christopher Batin on 26/11/2018.
//

import Vapor
import Foundation
import PerfectCrypto

final class AuthController {

    // Creates a JWT token lasting 15 mins
    static func createJWToken() -> String {
        let timeStamp = Int(Date.init().timeIntervalSince1970)
        let tstPayload = ["instance": "YOUR_INSTANCE_ID",
                          "iss": "api_keys/40c9f2ad-51db-4c72-8e64-6dd575ab951c",
                          "exp": timeStamp + (15 * 60),
                          "iat": timeStamp,
                          "sub": "MasterShake",
                          "su":true] as [String : Any]
        let secret = "aPJLGkAuO/TmR1HJU+Zgd2SjixqdN5DZwZejkBsaITo="
        guard let jwt1 = JWTCreator(payload: tstPayload) else {
            return ""
        }
        let token = try! jwt1.sign(alg: .hs256, key: secret)
        return token
    }
}

