//
//  ViewController.swift
//  SelfieShare
//
//  Created by My Nguyen on 8/17/16.
//  Copyright © 2016 My Nguyen. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var images = [UIImage]()
    // identify each user uniquely in a session
    var peerID: MCPeerID!
    // handle all multi-peer connectivity
    var mcSession: MCSession!
    // upon a new session, advertise to other apps and handle invitations
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    let serviceType = "My-Selfie-Share"

    override func viewDidLoad() {
        super.viewDidLoad()

        // give the title a name
        title = "Selfie Share"
        // add a right bar button with the system's camera icon
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(importPicture))
        // add a left bar Add button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(showConnectionPrompt))

        /// initialize MCSession
        
        / create an MCPeerID based on the name of the current device
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        // create an MCSession based on the ID
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .Required)
        mcSession.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // return the number of cells in the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // fetch the cell with reuse identifier "ImageView"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageView", forIndexPath: indexPath)

        // fetch the image view with tag 1000 inside the cell
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }

        return cell
    }

    // see project NamesToFaces, method ViewController.addNewPerson() for a detailed description
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }

    // see project NamesToFaces for a detailed description of this method
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage

        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        dismissViewControllerAnimated(true, completion: nil)

        images.insert(newImage, atIndex: 0)
        collectionView.reloadData()
    }

    // see project NamesToFaces for a detailed description of this method
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // prompt the user for a connection
    func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .Default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .Default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }

    func startHosting(action: UIAlertAction!) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction!) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        presentViewController(mcBrowser, animated: true, completion: nil)
    }
}

