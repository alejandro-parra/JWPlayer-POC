//
//  ViewController.swift
//  JWPlayer
//
//  Created by Alejandro Parra on 28/08/20.
//  Copyright © 2020 Alejandro Parra. All rights reserved.
//

import UIKit
import JWPlayer_iOS_SDK

class ViewController: UIViewController {
    var player: JWPlayerController?
    let HLSvideoURL = "https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
    let offlineImageURL = "https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"
    let HLSliveURL = "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"
    let HLSMultilanguageVideo = "https://d3rlna7iyyu8wu.cloudfront.net/skip_armstrong/skip_armstrong_multi_language_subs.m3u8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Instance JWPlayerController object
        createPlayer()
        if let containerView = view,
            let playerView = player?.view {
            containerView.addSubview(playerView)
            // Turn off translatesAutoresizingMaskIntoConstraints property to use Auto Layout to dynamically calculate the size and position
            playerView.translatesAutoresizingMaskIntoConstraints = false
            // Add constraints to center the playerView
            playerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            playerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            playerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        }
        
    }
    
    func createPlayer() {
        if let player = JWPlayerController(config: createConfig(), delegate: self) {
            // Force fullscreen on landscape and vice versa
            player.forceFullScreenOnLandscape = true
            player.forceLandscapeOnFullScreen = true
            self.player = player
        }
    }
    
    func createConfig() -> JWConfig {
        let skinStyling = JWSkinStyling()
        // Instance JWConfig object to setup the video
        let config = JWConfig.init(contentUrl: HLSMultilanguageVideo)
        config.image = offlineImageURL
        config.autostart = true
        config.repeat = true
        config.skin = skinStyling
        let sliderConfig = JWTimesliderStyling()
        sliderConfig.rail = .blue
        sliderConfig.progress = .red
        skinStyling.timeslider = sliderConfig
        /*config.tracks = [JWTrack (file: "https://content.jwplatform.com/tracks/sample01", label: "English", isDefault: true),
        JWTrack (file: "https://content.jwplatform.com/tracks/sample02.vtt", label: "Spanish"),
        JWTrack (file: "https://content.jwplatform.com/tracks/sample03.vtt", label: "Russian")]*/
        return config
    }



}

extension ViewController: JWPlayerDelegate {
    // Optionally implement methods to track the JWPlayerController behavior
}


