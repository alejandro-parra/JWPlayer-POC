//
//  ViewController.swift
//  JWPlayer
//
//  Created by Alejandro Parra on 28/08/20.
//  Copyright © 2020 Alejandro Parra. All rights reserved.
//

import UIKit
import JWPlayer_iOS_SDK
import AVKit
import MediaPlayer
import GoogleCast

class ViewController: UIViewController {
    //Chromecast variables
    var avilableDevices: [JWCastingDevice] = []
    var castController: JWCastController? = nil
    var castingButton: UIButton? = nil
    var casting = false {
        didSet {
            castingButton?.tintColor = casting ? UIColor.green : UIColor.blue
        }
    }
    var barButtonItem: UIBarButtonItem? = nil
    
    
    //General player controller
    var player: JWPlayerController?
    
    
    //URLs of different Video Formats to stream
    let HLSvideoURL = "https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
    let offlineImageURL = "https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"
    let HLSliveURL = "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"
    let HLSMultilanguageVideo = "https://d3rlna7iyyu8wu.cloudfront.net/skip_armstrong/skip_armstrong_multi_language_subs.m3u8"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Instance JWPlayerController object
        player?.config.autostart = false
        createPlayer()
        setupAirPlayButton()
            
        // Setup JWCastController object
        setupCastController()
        
        //insert player in layout, create constraints
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
    
    // MARK: - Airplay method
    
    
    func setupAirPlayButton() {
        
        /*
         NOTAS: El boton de Airplay tiene que ser separado del player, el player como tal no tiene una opción de poner un boton de airplay embebido
         */
        
        
        
        var buttonView: UIView? = nil
        let buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        // It's highly recommended use the AVRoutePickerView in order to avoid AirPlay issues after iOS 11.
        if #available(iOS 11.0, *) {
            let airplayButton = AVRoutePickerView(frame: buttonFrame)
            airplayButton.activeTintColor = UIColor.blue
            airplayButton.tintColor = UIColor.gray
            buttonView = airplayButton
        } else {
            // If you still supporting previous iOS versions you can use MPVolumeView
            let airplayButton = MPVolumeView(frame: buttonFrame)
            airplayButton.showsVolumeSlider = false
            buttonView = airplayButton
        }
        
        // If there is not AirPlay devices available, the button will not being displayed.
        let buttonItem = UIBarButtonItem(customView: buttonView!)
        self.navigationItem.setRightBarButton(buttonItem, animated: true)
    }
    
    // MARK: - Chromecast setup methods
    
    func setupCastController() {
        guard let player = self.player else { return }
        
        let castController = JWCastController(player: player)
        castController.chromeCastReceiverAppID = kGCKDefaultMediaReceiverApplicationID
        castController.delegate = self
        castController.scanForDevices()
        self.castController = castController
    }
    
    func setupCastingButton() {
        let buttonFrame = CGRect(x: 0, y: 0, width: 22, height: 22)
        let castingButton = UIButton(frame: buttonFrame)
        castingButton.addTarget(self, action: #selector(castButtonTapped(sender:)), for: .touchUpInside)
        
        // Load images for button's animation
        let connectingImages = [UIImage(named: "cast_connecting0")?.withRenderingMode(.alwaysTemplate),
                                UIImage(named: "cast_connecting1")?.withRenderingMode(.alwaysTemplate),
                                UIImage(named: "cast_connecting2")?.withRenderingMode(.alwaysTemplate),
                                UIImage(named: "cast_connecting1")?.withRenderingMode(.alwaysTemplate)]
        // Compact map to avoid nil UIImage objects
        castingButton.imageView?.animationImages = connectingImages.compactMap {$0}
        castingButton.imageView?.animationDuration = 2
        
        let barButtonItem = UIBarButtonItem(customView: castingButton)
        self.navigationItem.setLeftBarButton(barButtonItem, animated: true)
        
        castingButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        castingButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        self.castingButton = castingButton
        self.barButtonItem = barButtonItem
        
        self.casting = false
    }
    
    // MARK: - Casting Status Helpers
    
    func startConnectingAnimation() {
        castingButton?.tintColor = UIColor.white
        castingButton?.imageView?.startAnimating()
    }
    
    func stopConnectingAnimation(connected: Bool) {
        castingButton?.imageView?.stopAnimating()
        let castingImage = connected ? "cast_on" : "cast_off"
        castingButton?.setImage(UIImage(named: castingImage)?.withRenderingMode(.alwaysTemplate), for: .normal)
        castingButton?.tintColor = UIColor.blue
    }

    @objc func castButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let device = castController?.connectedDevice {
            alertController.title = device.name
            alertController.message = "Select an action"
            
            let disconnetAction = UIAlertAction(title: "Disconnect", style: .destructive) { [weak self] (action) in
                guard let self = self else { return }
                self.castController?.disconnect()
            }
            
            if self.casting {
                alertController.addAction(UIAlertAction(title: "Stop casting", style: .default, handler: { [weak self] (action) in
                    guard let self = self else { return }
                    self.castController?.stopCasting()
                }))
            } else {
                alertController.addAction(UIAlertAction(title: "Cast", style: .default, handler: { [weak self] (action) in
                    guard let self = self else { return }
                    self.castController?.cast()
                }))
            }
            alertController.addAction(disconnetAction)
        } else {
            alertController.title = "Connect to"
            self.castController?.availableDevices.forEach({ (castingDevice) in
                let deviceSelection = UIAlertAction(title: castingDevice.name, style: .default, handler: { [weak self] (action) in
                    guard let self = self else { return }
                    self.castController?.connect(to: castingDevice)
                    self.startConnectingAnimation()
                })
                alertController.addAction(deviceSelection)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }




}

extension ViewController: JWPlayerDelegate {
    // Optionally implement methods to track the JWPlayerController behavior
}

// MARK: JWCastingDelegate implementation
extension ViewController: JWCastingDelegate {
    
    func onCastingDevicesAvailable(_ devices: [JWCastingDevice]) {
        self.avilableDevices = devices
        if devices.isEmpty {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else if barButtonItem == nil {
            self.setupCastingButton()
            self.stopConnectingAnimation(connected: false)
        }
    }
    
    func onConnected(to device: JWCastingDevice) {
        self.stopConnectingAnimation(connected: true)
    }
    
    func onDisconnected(fromCastingDevice error: Error?) {
        if let error = error { print("Casting error: ", error) }
        self.stopConnectingAnimation(connected: false)
    }
    
    func onConnectionTemporarilySuspended() {
        self.startConnectingAnimation()
    }
    
    func onConnectionRecovered() {
        self.stopConnectingAnimation(connected: true)
    }
    
    func onConnectionFailed(_ error: Error) {
        print("Casting error: ", error)
        self.stopConnectingAnimation(connected: false)
    }
    
    func onCasting() {
        self.casting = true
    }
    
    func onCastingEnded(_ error: Error?) {
        if let error = error { print("Casting error: ", error) }
        self.casting = false
    }
    
    func onCastingFailed(_ error: Error) {
        print("Casting error: ", error)
        self.casting = false
    }
    
    
}



