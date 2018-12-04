//
//  RoomsTableViewController.swift
//  SuperChat
//
//  Created by Christopher Batin on 09/11/2018.
//  Copyright © 2018 Christopher Batin. All rights reserved.
//

import UIKit
import PusherChatkit
class RoomsTableViewController: UITableViewController {

    var chatManager: ChatManager!
    var currentUser: PCCurrentUser?
    var currentUserId: String!
    var rooms: [PCRoom]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var selectedRoom: PCRoom?

    override func viewDidLoad() {
        super.viewDidLoad()
        chatManager = ChatManager.init(instanceLocator: Constants.chatkitInstance,
                                              tokenProvider: Constants.tokenProvider,
                                              userID: currentUserId)
        chatManager.connect(delegate: self) { [unowned self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!.localizedDescription)")
                return
            }
            print("Connected!")

            guard let currentUser = currentUser else { return }
            self.currentUser = currentUser
            self.getRooms()
        }
    }

    private func getRooms() {
        // Must be new user try join general
        if currentUser?.rooms.count != 0 {
            self.rooms = currentUser?.rooms
        } else {
            getJoinableRooms()
        }
    }

    private func getJoinableRooms() {
        self.currentUser?.getJoinableRooms(completionHandler: { (userRooms, error) in
            //No rooms to join lets create one for everyone!
            if userRooms?.count == 0 {
                self.createNewRoom()
            } else {
                // Lets join the general chat (our only room)
                for room in userRooms! where room.name == "general" {
                    self.currentUser?.joinRoom(room, completionHandler: { (room, error) in
                        if error == nil {
                            self.getRooms()
                        }
                    })
                }
            }
        })
    }

    //Create a new public general room
    private func createNewRoom() {
        self.currentUser?.createRoom(name: "general", completionHandler: { (room, error) in
            self.getRooms()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatRoom" {
            let vc = segue.destination as? RoomViewController
            vc?.currentRoom = selectedRoom
            vc?.currentUser = currentUser
        }
    }
}

extension RoomsTableViewController: PCChatManagerDelegate {}

extension RoomsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell") as? RoomCell,
            let room = rooms?[indexPath.row] else {
            return UITableViewCell.init(frame: CGRect.zero)
        }
        cell.roomNameLabel.text = room.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoom = rooms?[indexPath.row]
        performSegue(withIdentifier: "toChatRoom", sender: self)
    }
}
