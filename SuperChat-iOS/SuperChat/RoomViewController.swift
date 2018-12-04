//
//  RoomViewController.swift
//  SuperChat
//
//  Created by Christopher Batin on 26/11/2018.
//  Copyright © 2018 Christopher Batin. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import MessageInputBar
import PusherChatkit
import NotificationBannerSwift

class RoomViewController: MessagesViewController, PCRoomDelegate {
    var messages: [Message] = []
    var room: [String: Any] = [:]
    var currentRoom: PCRoom? = nil
    var currentUser: PCCurrentUser? = nil

    var chatManager: ChatManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureMessageKit()

        navigationItem.title = currentRoom?.name

        chatManager = ChatManager.init(instanceLocator: Constants.chatkitInstance,
                                       tokenProvider: Constants.tokenProvider,
                                       userID: currentUser!.id)
        
        currentUser?.subscribeToRoom(room: currentRoom!, roomDelegate: self, completionHandler: { (error) in
            if error != nil {
                print(error as Any)
            }
            self.fetchMessages()
        })
    }

    func configureMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        // Input bar
        messageInputBar = MessageInputBar()
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.isTranslucent = false
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 249/255, green: 250/255, blue: 252/255, alpha: 1)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 192/255, green: 204/255, blue: 218/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0
        reloadInputViews()

        // Keyboard and send btn
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    func onMessage(_ message: PCMessage) {
        let msg = Message(
            text: message.text,
            sender: Sender(id: message.sender.id, displayName: message.sender.displayName),
            messageId: String(describing: message.id),
            date: ISO8601DateFormatter().date(from: message.createdAt)!
        )

        DispatchQueue.main.async {
            self.messages.append(msg)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
        }
    }

    func fetchMessages() {
        currentUser?.fetchMessagesFromRoom(currentRoom!, completionHandler: { (roomMessages, error) in
            if error != nil {
                print(error as Any)
            }
            guard let roomMessages = roomMessages else { return }
            DispatchQueue.main.async {
                for message in roomMessages {
                    let sender = Sender.init(id: message.sender.id,
                                             displayName: message.sender.displayName)
                    self.messages.append(Message.init(text: message.text ,
                                                      sender: sender,
                                                      messageId: String(message.id),
                                                      date: message.createdAtDate))
                }
                self.messagesCollectionView.reloadData()
            }
        })
    }
}


extension RoomViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message)
            ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

extension RoomViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        guard let room = currentRoom else { return }

        currentUser?.sendMessage(roomID: room.id, text: text) { msgId, error in
            if error == nil {
                DispatchQueue.main.async { inputBar.inputTextView.text = String() }
            }
        }
    }
}

extension RoomViewController: MessagesLayoutDelegate {
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .natural, vertical: .messageBottom)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let stringFromCharacter = String(message.sender.displayName.first ?? "?")
        avatarView.set(avatar: Avatar.init(image: nil, initials: stringFromCharacter))
    }

    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        return isFromCurrentSender(message: message)
            ? UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
            : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
}


extension RoomViewController: MessagesDataSource {
    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender == currentSender()
    }

    func currentSender() -> Sender {
        return Sender(id: currentUser!.id, displayName: (currentUser!.name)!)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messages.count
    }

}
