//
//  MessageViewModel.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 28/10/2023.
//

import Foundation
import Firebase
import FirebaseFirestore


class MessageViewModel: ObservableObject {
    var user: User?
    var currentUser: User
    @Published var messages = [Message]()
    @Published var newMessageText = ""
    @Published var count = 0
    @Published var images: [UIImage] = []
    
    private var listenerRegistration: ListenerRegistration?
    
    init(user: User?, currentUser: User) {
        self.user = user
        self.currentUser = currentUser
    }
    
    func sendNewMessage() {
        let messageTextToSend = self.newMessageText
        self.newMessageText = ""
        
        
        guard let selectedUserUid = user?.uid else { return }
        
        
        
        
        
        let newMessageData = [
            "fromId": currentUser.uid,
            "toId": selectedUserUid,
            "text": messageTextToSend,//newMessageText,
            "timestamp": Timestamp(),
            
            "isImage": false,
            "imageUrl": ""
            
        ] as [String : Any]
        
        let messagesCollection = Firestore.firestore().collection("messages")
        
        // Send a copy to the current user
        messagesCollection
            .document(currentUser.uid)
            .collection(selectedUserUid)
            .addDocument(data: newMessageData) { error in
                if let error = error {
                    print("Failed to send message, \(error.localizedDescription)")
                }
                
                self.persistRecentMessage(
                    fromUid: self.currentUser.uid,
                    toUid: selectedUserUid,
                    username: self.user?.userName ?? "",
                    profileImageUrl: self.user?.profileImageURL ?? "",
                    text: messageTextToSend,//self.newMessageText,
                    timestamp: Timestamp(),
                    isImage: false
                )
                // self.newMessageText = ""
                self.count += 1
            }
        
        // Send a copy to the recipient
        messagesCollection
            .document(selectedUserUid)
            .collection(currentUser.uid)
            .addDocument(data: newMessageData) { error in
                if let error = error {
                    print("Failed to send message to recipient, \(error.localizedDescription)")
                }
                
                print("Successfully sent message to recipient!")
            }
    }
    
    func fetchMessages() {
        guard let selectedUserUid = user?.uid else { return }
        
        let messagesQuery = Firestore.firestore().collection("messages")
            .document(currentUser.uid)
            .collection(selectedUserUid)
            .order(by: "timestamp")
        
        listenerRegistration = messagesQuery.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch messages \(error?.localizedDescription ?? "Unkown error")")
                return
            }
            
            self.messages = querySnapshot.documents.map({ snapshot in
                let data = snapshot.data()
                let id = snapshot.documentID
                let fromId = data["fromId"] as! String
                let toId = data["toId"] as! String
                let text = data["text"] as! String
                let timestamp = data["timestamp"] as! Timestamp
                let date = timestamp.dateValue()
                
                let isImage = data["isImage"] as? Bool ?? false
                let imageUrl = data["imageUrl"] as? String ?? ""
                
                return Message(id: id, fromId: fromId, toId: toId, text: text, date: date, isImage: isImage, imageUrl: imageUrl)
            })
            
            self.count += 1
        }
    }
    
    func sendImages(){
        let imagesToSend = self.images
        self.images.removeAll()
        
        for image in images{
            sendSingleImage(image: image, timestamp: Timestamp())
        }
    }
    
    func sendSingleImage(image: UIImage, timestamp: Timestamp){
        
        
        guard let selectedUserUid = user?.uid else{return}
        
        
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "YY/MM/dd"

        // Convert Date to String
        let timestampStr = dateFormatter.string(from: timestamp.dateValue())
        
        // TODO: Create an unique pathReference for the image
        
        
        
        // TODO: Upload the image and obtain its url
        
        // TODO: Upload the message 
        
        
        
        
        
    }
    
    
    func persistRecentMessage(fromUid: String, toUid: String, username: String, profileImageUrl: String, text: String, timestamp: Timestamp, isImage: Bool) {
        let latestMessageData = [
            "fromUid": fromUid,
            "toUid": toUid,
            "username": username,
            "profileImageUrl": profileImageUrl,
            "text": text,
            "timestamp": timestamp,
            "isImage": isImage
        ] as [String: Any]
        
        let latestMessageCollection = Firestore.firestore().collection("latestMessages")
        
        latestMessageCollection
            .document(fromUid)
            .collection("messages")
            .document(toUid)
            .setData(latestMessageData) { error in
                if let error = error {
                    print("Failed to persist message for sender \(error.localizedDescription)")
                }
            }
        
        let recipientMessageData = [
            "fromUid": fromUid,
            "toUid": toUid,
            "username": currentUser.userName,
            "profileImageUrl": currentUser.profileImageURL,
            "text": text,
            "timestamp": timestamp,
            "isImage": isImage
        ] as [String: Any]
        
        latestMessageCollection
            .document(toUid)
            .collection("messages")
            .document(fromUid)
            .setData(recipientMessageData) { error in
                if let error = error {
                    print("Failed to persist recent message for recipient \(error.localizedDescription)")
                }
            }
    }
    
    func fetchUser(uid: String) async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            
            // guard let user = try? snapshot.data(as: User.self) else { return }
            
            if let data = snapshot.data() {
                let user = User(data: data)
                self.user = user
            }else{
                self.user = nil
                print("Unable to fetch data about the user \(uid)")
            }
            
            fetchMessages()
        } catch {
            print("Error fetching user \(error.localizedDescription)")
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
