//
//  LoginViewController.swift
//  SuperChat
//
//  Created by Christopher Batin on 09/11/2018.
//  Copyright © 2018 Christopher Batin. All rights reserved.
//

import UIKit
import Alamofire
import PusherChatkit
import NotificationBannerSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!

    struct CurrentUser: Codable {
        var id: String
        var name: String
    }
    var currentUser: CurrentUser?

    @IBAction func loginButtonTapped(_ sender: Any) {
        signInUser()
    }

    @IBAction func createUserButtonTapped(_ sender: Any) {
        createNewUser()
    }

    private func createNewUser() {
        guard let username = usernameField.text else {
            let banner = StatusBarNotificationBanner(title: "You need to provide a user name!", style: .danger)
            banner.show()
            return
        }
        let parameters: Parameters = [
            "name": username
        ]
        Alamofire.request(Constants.createUserURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let statusCode = response.response?.statusCode ?? -1
            if 200 ... 299 ~= statusCode {
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder.init()
                        self.currentUser = try decoder.decode(CurrentUser.self, from: data)
                        self.performSegue(withIdentifier: "toRooms", sender: self)
                    } catch {}
                }
            } else {
                let banner = StatusBarNotificationBanner(title: "Something went wrong, this user may already exist!", style: .danger)
                banner.show()
            }
        }
    }

    private func signInUser() {
        guard let username = usernameField.text else {
            let banner = StatusBarNotificationBanner(title: "You need to provide a user name!", style: .danger)
            banner.show()
            return
        }
        let parameters: Parameters = [
            "name": username
        ]
        Alamofire.request(Constants.loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            let statusCode = response.response?.statusCode ?? -1
            if 200 ... 299 ~= statusCode {
                if let data = response.data {
                    do {
                        let decoder = JSONDecoder.init()
                        self.currentUser = try decoder.decode(CurrentUser.self, from: data)
                        self.performSegue(withIdentifier: "toRooms", sender: self)
                    } catch {}
                }
            }else {
                let banner = StatusBarNotificationBanner(title: "Something went wrong, this user may not exist yet!", style: .danger)
                banner.show()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRooms" {
            let vc = segue.destination as? RoomsTableViewController
            vc?.currentUserId = currentUser?.id
        }
    }
}
