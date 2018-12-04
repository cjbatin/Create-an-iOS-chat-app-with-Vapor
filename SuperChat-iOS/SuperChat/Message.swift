//
//  Message.swift
//  SuperChat
//
//  Created by Christopher Batin on 26/11/2018.
//  Copyright © 2018 Christopher Batin. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind

    init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
}
