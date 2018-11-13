//
//  VideoPlayerViewController.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 7/18/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit
import Alamofire

protocol VideoPlayerDelegate{
    func reloadTable(_ objectName: String)
}

class VideoPlayerViewController: UIViewController, PlayerDelegate {
    
    var player: Player!
    var playUrl:String!
    
    //The object name for deletion purposes
    var objectName: String!
    
    //Delegate
    var delegate : VideoPlayerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize the player
        self.player = Player()
        self.player.delegate = self

        //This may be the reason it is not going full screen in the view
        self.player.view.frame = self.view.bounds
        
        //Sets the video player to full screen
        self.player.fillMode = AVLayerVideoGravityResizeAspect
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMove(toParentViewController: self)
        
        //TODO: Put an if else statement on this to check if the user even has any profile videos
        let videoUrl: URL = URL(string: playUrl)!
        self.player.setUrl(videoUrl)
        
        
        self.player.playFromBeginning()
        self.player.playbackLoops = false
        
        //Add tap gesture to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(VideoPlayerViewController.dismissPlayer))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func deleteVideo(_ objectName: String){
        var selfBucket = SessionManager.sharedInstance.user?.userBucket
        if selfBucket == nil {
            selfBucket = DAO.getBucketNameForLoggedInUser()
        }
        let url = "https://final-questor-app.appspot.com/deleteVideo/watched"
        let params = ["selfBucket" : selfBucket!, "objectname": objectName]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            //Do Nothing
            print(response)
        }

    }
    
    func dismissPlayer(){
        playerPlaybackDidEnd(self.player)
    }
    
    // MARK: Player Delegete
    func playerReady(_ player: Player){
        
    }
    func playerPlaybackStateDidChange(_ player: Player){
        
    }
    func playerBufferingStateDidChange(_ player: Player){
        print(self.player.bufferingState.description)
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player){
        print("Video started playing")
        
    }
    func playerPlaybackDidEnd(_ player: Player){
        //Delete Video when video is done playing or if the screen is tapped
        self.deleteVideo(objectName)
        if delegate != nil{
            delegate?.reloadTable(objectName)
        }
        self.dismiss(animated: false, completion: nil)
        print("The Video has come to an end")
    }
    


}
