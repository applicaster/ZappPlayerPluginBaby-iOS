//
//  APBabyApplicasterPlayer.swift
//  Pods
//
//  Created by Miri on 06/10/2016.
//
//

import Foundation
import ZappPlugins
import ApplicasterSDK
import ZappLoginPluginsSDK

open class APBabyApplicasterPlayer: APPlugablePlayerDefault {
    static let lockButtonPositionJsonValues: Dictionary<String, GAPlayerControlsLockButtonPosition> = [
        "Top Right" : GAPlayerControlsLockButtonPosition.topRight,
        "Top Left" : GAPlayerControlsLockButtonPosition.topLeft,
        "Bottom Left" : GAPlayerControlsLockButtonPosition.bottomLeft,
        "Bottom Right" : GAPlayerControlsLockButtonPosition.bottomRight
    ]
    let kPlayableItems = "playable_items"
    var didCallPrepareToPlay = false
    var payableItems: [ZPPlayable]?
    var playerControlsView: APPlayerControls?
    
    public override static func pluggablePlayerInit(playableItem item: ZPPlayable?) -> ZPPlayerProtocol? {
        if let item = item {
            return self.pluggablePlayerInit(playableItems: [item])
        }
        return nil
    }
    
    public override static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary? = nil) -> ZPPlayerProtocol? {
        let instance = APBabyApplicasterPlayer()
        instance.payableItems = items
        
        if let configurationJson = configurationJSON {
            instance.configurationJSON = configurationJson
            if let playerType = configurationJson.object(forKey: "player_controller") as? String, playerType.isNotEmptyOrWhiteSpaces() {
                if playerType == "advanced_player" {
                    instance.playerControlsView = (Bundle(for: self).loadNibNamed("GAPlayerControlsViewAdvancedPlayer", owner: self, options: nil)?.first) as? UIView & APPlayerControls
                    if let playerControlsView =  instance.playerControlsView as? GAPlayerControlsViewAdvancedPlayer {
                        if let shouldShowInstructionMessage = configurationJson.object(forKey: "should_show_instruction_message") as? String {
                            playerControlsView.shouldShowInstructionMessage = shouldShowInstructionMessage.boolValue()
                        }
                        
                        APPlayerController.setDefaultPlayerControlsInstance(playerControlsView)
                    }
                }
                else if playerType == "basic_player" {
                    if let playerControlsView = (Bundle(for: self).loadNibNamed("GAPlayerControlsViewBasicPlayer", owner: self, options: nil)?.first) as? GAPlayerControlsViewBasicPlayer {
                        if let lockButtonPositionJsonValue = configurationJson.object(forKey: "lock_button_position") as? String {
                            if let lockButtonPosition = lockButtonPositionJsonValues[lockButtonPositionJsonValue] {
                                playerControlsView.lockButtonPosition = lockButtonPosition
                            }
                        }
                        if let shouldCenterLockInstructionMessage = configurationJson.object(forKey: "should_center_lock_instruction_message") as? String  {
                            playerControlsView.shouldCenterLockInstructionMessage = shouldCenterLockInstructionMessage.boolValue()
                        }
                        
                        if let shouldShowInstructionMessage = configurationJson.object(forKey: "should_show_instruction_message") as? String {
                            playerControlsView.shouldShowInstructionMessage = shouldShowInstructionMessage.boolValue()
                        }
                        APPlayerController.setDefaultPlayerControlsInstance(playerControlsView)
                    }
                }
                
            }
        }
        
        instance.currentPlayableItems = items
        instance.playerViewController = APPlayerViewController(playableItems: items)
        
        if let babyPlayerViewController = instance.playerViewController, let configurationJson = configurationJSON {
            if let shouldIgnoreInterruptScreenStringKey = configurationJson.object(forKey: "should_ignore_persistant_resume_screen") as? String  {
                babyPlayerViewController.shouldIgnoreInterruptScreen = shouldIgnoreInterruptScreenStringKey.boolValue()
            }
        }
        
        return instance;
    }
    
    open override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
        
        //If no playable items exist, exit the present method since you don't have anything to show
        guard let playableItems = self.currentPlayableItems else {
            return
        }
        
        guard let firstPlayable = playableItems.first else {
            return
        }
        
        var bypassIsFreeLogic = false
        
        if let config = self.configurationJSON {
            if let value = config["should_bypass_is_free_logic"] as? String {
                bypassIsFreeLogic = value == "1"
            }
        }
        
        //Check that a login plugin exist and the item is not free
        if let loginPlugin = ZPLoginManager.sharedInstance.createWithUserData() as ZPLoginProviderUserDataProtocol?,
            let extensions = [kPlayableItems: self.currentPlayableItems] as? [String : NSObject] {
            
            let doUserComply = { (_ userComply: Bool) -> Void in
                self.handleUserComply(isUserComply: userComply,
                                      loginPlugin: loginPlugin,
                                      rootViewController: rootViewController,
                                      container: nil,
                                      configuration: configuration,
                                      completion: completion)
            }
            
            let doUserComplyFlow = { () -> Void in
                if let isUserComply = loginPlugin.isUserComply?(policies: extensions) {
                    doUserComply(isUserComply)
                } else if let _ = loginPlugin.isUserComply?(policies: extensions, completion: { (isComply) in
                    doUserComply(isComply)
                }) {
                    /*empty brackets - code was executed in the completion */
                } else {
                    self.playerViewController?.playerController.prepareToPlay()
                    self.didCallPrepareToPlay = true
                    self.addDownloadButton()
                    super.presentPlayerFullScreen(rootViewController,
                                                  configuration: configuration,
                                                  completion: completion)
                }
            }
            
            if bypassIsFreeLogic {
                doUserComplyFlow()
            } else {
                if !firstPlayable.isFree() {
                    doUserComplyFlow()
                } else {
                self.playerViewController?.playerController.prepareToPlay()
                self.didCallPrepareToPlay = true
                self.addDownloadButton()
                super.presentPlayerFullScreen(rootViewController,
                                              configuration: configuration,
                                              completion: completion)
                }
            }
        } else {
            self.playerViewController?.playerController.prepareToPlay()
            didCallPrepareToPlay = true
            self.addDownloadButton()
            super.presentPlayerFullScreen(rootViewController,
                                          configuration: configuration,
                                          completion: completion)
        }
    }
    
    open override func pluggablePlayerType() -> ZPPlayerType {
        return APBabyApplicasterPlayer.pluggablePlayerType()
    }
    
    func handleUserComply(isUserComply:Bool, loginPlugin:ZPLoginProviderUserDataProtocol, rootViewController: UIViewController, container: UIView?, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
        if isUserComply {
            self.playerViewController?.playerController.prepareToPlay()
            didCallPrepareToPlay = true
            if let container = container {
                if let configuration = configuration {
                    super.pluggablePlayerAddInline(rootViewController, container: container, configuration: configuration)
                } else {
                    super.pluggablePlayerAddInline(rootViewController, container: container)
                }
            } else {
                self.addDownloadButton()
                super.presentPlayerFullScreen(rootViewController,
                                              configuration: configuration,
                                              completion: completion)
            }
        } else {
            let playableItem = self.playerViewController?.playerController.currentItem
            let pluginModel = ZPPluginManager.pluginModels()?.filter { $0.pluginType == .Login}.first
            if let loginPlugin = ZPLoginManager.sharedInstance.createWithUserData() as ZPLoginProviderUserDataProtocol?,
                let screenModel = ZAAppConnector.sharedInstance().genericDelegate.screenModelForPluginID(pluginID: pluginModel?.identifier, dataSource: playableItem as? NSObject) {
                
                ZAAppConnector.sharedInstance().genericDelegate.hookManager().performPreHook(hookedViewController:self as? UIViewController, screenID:screenModel.screenID , model: payableItems as NSObject?) { continueFlow in
                    if continueFlow {
                        loginPlugin.login([self.kPlayableItems: self.currentPlayableItems as Any],
                                          completion: { (loginStatus) in
                                            if loginStatus == .completedSuccessfully {
                                                self.playerViewController?.playerController.prepareToPlay()
                                                self.didCallPrepareToPlay = true
                                                if let container = container {
                                                    if let configuration = configuration {
                                                        super.pluggablePlayerAddInline(rootViewController, container: container, configuration: configuration)
                                                    } else {
                                                        super.pluggablePlayerAddInline(rootViewController, container: container)
                                                    }
                                                } else {
                                                    self.addDownloadButton()
                                                    super.presentPlayerFullScreen(rootViewController,
                                                                                  configuration: configuration,
                                                                                  completion: completion)
                                                }
                                            }
                        })
                    } else {
                        //Pre hook returned and the rest of the flow will not be continued, so we navigate back to where we were if possible or  to home screen if not and close the pre hook screen
                        if let currentViewController = ZAAppConnector.sharedInstance().navigationDelegate.currentViewController() as? ZPPlugableScreenDelegate {
                            currentViewController.removeScreenPluginFromNavigationStack()
                        } else {
                            ZAAppConnector.sharedInstance().navigationDelegate.navigateToHomeScreen()
                        }
                    }
                }
            }
        }
    }
    
}
