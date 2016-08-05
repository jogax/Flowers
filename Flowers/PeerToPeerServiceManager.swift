
//
//  PeerToPeerManager.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 20/07/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RealmSwift


class PeerToPeerServiceManager: NSObject {

    let separator = "°"
    var identifier: String
    struct MessageContent {
        var command: PeerToPeerCommands
        var messages: [String]
        var answers: [String]
        var fromPeerIndex: Int
        var closed: Bool
        var timeStamp: NSDate
   }
    private let peerToPeerType: String
//    static private let CardFootballName:String = "CardFootball on "
    
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().identifierForVendor!.UUIDString)//.name)
    
    private let serviceBrowser : MCNearbyServiceBrowser
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    var delegate : PeerToPeerServiceManagerDelegate?
    
    var messageArray = [Int:MessageContent]()
    var answerArray = [Int:MessageContent]()
    var messageNr = 0

    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()

    init(peerType: String, identifier: String, deviceName: String) {
        peerToPeerType = peerType
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: peerToPeerType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: peerToPeerType)
        self.identifier = identifier
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func hasOtherPlayers() -> Bool {
        return self.session.connectedPeers.count != 0
    }
    
    func countPartners() -> Int {
        return session.connectedPeers.count
    }
    
    func getPartnerName()->([String]) {  // partnerName, deviceName
        var names = [String]()
        for index in 0..<session.connectedPeers.count {
            names.append((session.connectedPeers[index].name!))
        }
        return names
    }
    
    func changeIdentifier(newIdentifier: String) {
        self.identifier = newIdentifier
        for index in 0..<session.connectedPeers.count {
            sendInfo(.MyNameIs, message: [identifier], toPeer: session.connectedPeers[index])
        }
    }
    
    func sendData(command: PeerToPeerCommands, messageNr: Int, message : [String], new: Bool = true, toPeer: MCPeerID? = nil, toPeerIndex: Int = 0, answer: Bool = false) {
        var peer = toPeer
        if toPeer == nil {
            peer = session.connectedPeers[toPeerIndex]
        }
        if session.connectedPeers.count > 0 {
            do {
                var stringToSend = (command.commandName + separator + String(messageNr) + separator + String(new))
                for index in 0..<message.count {
                    stringToSend += separator + message[index]
                }
                messageArray[messageNr] = MessageContent(command: command, messages: message, answers: [String](), fromPeerIndex: 0, closed: false, timeStamp: NSDate())
                let myNSData = (stringToSend as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
//                print("sendMessage: \(stringToSend) to \(peer!.displayName)")
                
                try self.session.sendData(myNSData, toPeers: [peer!], withMode: MCSessionSendDataMode.Reliable)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func sendInfo(command: PeerToPeerCommands, message : [String], new: Bool = true, toPeer: MCPeerID? = nil, toPeerIndex: Int = 0) {
        sendData(command, messageNr: messageNr, message: message, new: true, toPeer: toPeer, toPeerIndex: toPeerIndex, answer: false)
        messageArray.removeValueForKey(messageNr)
        messageNr += 1
    }

    func sendMessage(command: PeerToPeerCommands, message : [String], toPeer: MCPeerID? = nil, toPeerIndex: Int = 0)->[String] {
        let myMessageNr = messageNr
        messageNr += 1
        sendData(command, messageNr: myMessageNr, message: message, new: true, toPeer: toPeer, toPeerIndex: toPeerIndex, answer: false)
        var counter = 0
        let maxTime: Double = 20 // sec
        let startAt = NSDate()
        var answersToReturn: [String]
        while !messageArray[myMessageNr]!.closed && NSDate().timeIntervalSinceDate(startAt) < maxTime {
            sleep(0.1)
            counter += 1
        }
        if NSDate().timeIntervalSinceDate(startAt) < maxTime {
            answersToReturn = messageArray[myMessageNr]!.answers
        } else {
            answersToReturn = [GV.timeOut]
        }
        messageArray.removeValueForKey(myMessageNr)
        
        return answersToReturn
    }

    func sendAnswer(messageNr: Int, answer : [String]) {
        
        let command = answerArray[messageNr]!.command
        let toPeerIndex = answerArray[messageNr]!.fromPeerIndex
        sendData(command, messageNr: messageNr, message: answer, new: false, toPeerIndex: toPeerIndex, answer: true)
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
    
    
    
}


extension PeerToPeerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, error: NSError) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?,  invitationHandler: (Bool, MCSession) -> Void) {
        invitationHandler(true, self.session)
//        print("from \(myPeerId.displayName): in PeerToPeerServiceManager")
    }

}

extension PeerToPeerServiceManager : MCNearbyServiceBrowserDelegate {

    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }

    

    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        if peerID.displayName.containsString(PeerToPeerServiceManager.CardFootballName) {
            browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
//            print("new connection found: \(peerID.displayName), countConnections: \(self.session.connectedPeers.count)")
//        }
    }

    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        connectionLost(
        print("connections lost: \(peerID.displayName), count connections: \(self.session.connectedPeers.count)")
    }
}

extension PeerToPeerServiceManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        //        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        if state == .Connected {
            sendInfo(.MyNameIs, message:  [identifier], toPeer: peerID)
        }
//        print("peer \(peerID.displayName) didChangeState: \(state.stringValue())")
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let receivedString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        let stringTable = receivedString.componentsSeparatedByString(separator)
        let command = PeerToPeerCommands.decodeCommand(stringTable[0])
        let messageNr = Int(stringTable[1])
        let new = stringTable[2] == "true" ? true : false
        var parameterString = [String]()
        for index in 3..<stringTable.count {
            parameterString.append(stringTable[index])
        }
        
        var fromPeerIndex = -1
        for index in 0..<session.connectedPeers.count {
            if session.connectedPeers[index] == peerID {
                fromPeerIndex = index
                break
            }
        }
        if fromPeerIndex != -1 {
            if command == .MyNameIs {
                peerID.name = parameterString[0]
//                self.delegate!.messageReceived(fromPeerIndex, command: command, message: parameterString, messageNr: messageNr!)
            } else {
                if new { // new message from Partner
                    answerArray[messageNr!] = MessageContent(command: command, messages: parameterString, answers: [String](), fromPeerIndex: fromPeerIndex, closed: false, timeStamp: NSDate())
                    self.delegate!.messageReceived(fromPeerIndex, command: command, message: parameterString, messageNr: messageNr!)
                } else { // answer to my Message
                    messageArray[messageNr!]!.answers = parameterString
                    print("used time: \(NSDate().timeIntervalSinceDate(messageArray[messageNr!]!.timeStamp)), \(parameterString)")
                    messageArray[messageNr!]!.closed = true
                }
            }
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("from \(myPeerId.displayName):didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("from \(myPeerId.displayName):didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("from \(myPeerId.displayName):didStartReceivingResourceWithName")
    }
    

    
}

extension MCPeerID {

    private struct AssociatedKeys {
        static var partnerName:String?
        static var index: Int?
    }
    
    var name: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.partnerName) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.partnerName, newValue as String?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

//    var index: Int? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.index) as? Int
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &AssociatedKeys.index, newValue as Int, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
    
}

protocol PeerToPeerServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : PeerToPeerServiceManager, connectedDevices: [String])
    func messageReceived(fromPeerIndex : Int, command: PeerToPeerCommands, message: [String], messageNr: Int)
//    func connectionLost(fromPeerIndex : Int, command: PeerToPeerCommands, message: [String], messageNr: Int)
    
}

