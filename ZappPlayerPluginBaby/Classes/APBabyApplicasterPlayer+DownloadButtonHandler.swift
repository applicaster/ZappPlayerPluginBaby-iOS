//
//  APBabyApplicasterPlayer+DownloadButtonHandler.swift
//  ZappPlayerPluginBaby
//
//  Created by Roi Kedarya on 08/07/2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import Foundation

extension APBabyApplicasterPlayer : ZPHqmeButtonDelegate {
    
    @objc public func addDownloadButton(forDownloadableItem item: ZPHqmeSupportingItemProtocol) {
        if let playerController = self.playerControlsView as? GAPlayerControlsViewAdvancedPlayer,
            let hqmeButtonContainer = playerController.hqmeButtonContainerView,
            item.isValidForHqme?() == true,
            let downloadButton = ZAAppConnector.sharedInstance().hqmeDelegate?.createHqmeButton(withDelegate: self, size: hqmeButtonContainer.bounds.size) {
            if let button = downloadButton as? UIView {
                hqmeButtonContainer.isHidden = false
                hqmeButtonContainer.removeAllSubviews()
                hqmeButtonContainer.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                let views = ["button": button]
                hqmeButtonContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: .alignAllCenterX, metrics: nil, views: views))
                hqmeButtonContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: .alignAllCenterX, metrics: nil, views: views))
                
                if let itemOfflineState = ZAAppConnector.sharedInstance().hqmeDelegate?.getState(for: item) {
                    switch itemOfflineState {
                    case .completed:
                        downloadButton.hqmeStateChange(to: .completed)
                        break
                    case .inProgress:
                        downloadButton.hqmeStateChange(to: .inProgress)
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    public func hqmeButton(_ button: ZPHqmeButtonProtocol, stateChanged state: ZPHqmeButtonState) {
        let currentItem = getCurrentHqmeSupportingItem()
        guard let playableItem = currentItem else {
            return
        }
        
        switch state {
        case .error:
            ZAAppConnector.sharedInstance().hqmeDelegate?.cancelProcess(for: playableItem)
            
        default:
            break
        }
    }
    
    public func hqmeButton(_ button: ZPHqmeButtonProtocol, tappedWithState state: ZPHqmeButtonState) {
        let currentItem = getCurrentHqmeSupportingItem()
        guard let playableItem = currentItem else {
            return
        }
        
        switch state {
        case .completed:
            self.presentPostDownloadAlert(for: button, model: playableItem)
            break
        case .initial:
            if ZAAppConnector.sharedInstance().connectivityDelegate.getCurrentConnectivityState() == .cellular {
                self.presentPreDownloadOn3gAlert(for: button, model: playableItem)
            }
            else {
                self.continueDownloadFlow(for: button, model: playableItem)
            }
            break
        case .inProgress:
            ZAAppConnector.sharedInstance().hqmeDelegate?.cancelProcess(for: playableItem)
            //update state to initial after cleanp
            button.hqmeStateChange(to: .initial)//downloadStateChange(to: .startDownload)
            break
        case .error:
            self.presentPostErrorAlert(for: button, model: playableItem)
            break
        default:
            break
            //do nothing
        }
    }
    
    public func hqmeStateChangeNotificationName() -> String? {
        let currentItem = getCurrentHqmeSupportingItem()
        guard let playableItem = currentItem,
            let identifier = playableItem.objectIdentifier?() else {
                return nil
        }
        return "AssetHqmeStateChanged"+identifier.md5Hash()
    }
    
    public func hqmeInProgressChangeNotificationName() -> String? {
        let currentItem = getCurrentHqmeSupportingItem()
        guard let playableItem = currentItem,
            let identifier = playableItem.objectIdentifier?() else {
                return nil
        }
        return "AssetHqmeProgressChanged"+identifier.md5Hash()
    }
    
    public func hqmeButtonCustomImagesSuffix() -> String? {
        return "_baby_player"
    }
    
    private func continueDownloadFlow(for downloadButton: ZPHqmeButtonProtocol, model: ZPHqmeSupportingItemProtocol) {
        
        if let atomEntry = model as? APAtomEntry {
            atomEntry.fetchContentUrl(completion: {
                self.continueDownloadFlow(for: downloadButton, model: model, fetchedUrl: true)
            })
        }
        else {
            self.continueDownloadFlow(for: downloadButton, model: model, fetchedUrl: true)
        }
    }
    
    private func continueDownloadFlow(for downloadButton: ZPHqmeButtonProtocol, model: ZPHqmeSupportingItemProtocol, fetchedUrl: Bool) {
        //download the item
        ZAAppConnector.sharedInstance().hqmeDelegate?.startProcess(for: model)
        //update state to pending
        downloadButton.hqmeStateChange(to: .pending)
    }
    
    
    private func presentPreDownloadOn3gAlert(for downloadButton: ZPHqmeButtonProtocol, model: ZPHqmeSupportingItemProtocol) {
        let download: NSString = "Download"
        let cancel: NSString = "Cancel"
        
        let title: NSString = "Download using cellular data plan"
        let message: NSString = "It is recommended to download VODs only when using Wi-Fi"
        
        let alert = UIAlertController(title: title.withKey("HqmeDownloadItem3gTitle"),
                                      message: message.withKey("HqmeDownloadItem3gMessage"),
                                      preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: cancel.withKey("CommonAlertCancel"),
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: nil)
        })
        
        let okButton = UIAlertAction(title: download.withKey("HqmeDownloadItem3gButtonDownload"),
                                     style: .default,
                                     handler: { _ in
                                        self.continueDownloadFlow(for: downloadButton, model: model)
        })
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        APApplicasterController.sharedInstance()?.rootViewController.topmostModal()?.present(alert,
                                                                                             animated: true,
                                                                                             completion: nil)
    }
    
    private func presentPostDownloadAlert(for downloadButton: ZPHqmeButtonProtocol, model: ZPHqmeSupportingItemProtocol) {
        let ok: NSString = "OK"
        let cancel: NSString = "Cancel"
        
        let title: NSString = "Delete Item"
        let message: NSString = "Are you sure to delete the downloaded item?"
        
        let alert = UIAlertController(title: title.withKey("HqmeDownloadedItemDeleteTitle"),
                                      message: message.withKey("HqmeDownloadedItemDeleteMessage"),
                                      preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: cancel.withKey("CommonAlertCancel"),
                                         style: .default,
                                         handler: { _ in
                                            alert.dismiss(animated: true, completion: nil)
        })
        
        let okButton = UIAlertAction(title: ok.withKey("CommonAlertOK"),
                                     style: .default,
                                     handler: { _ in
                                        
                                        ZAAppConnector.sharedInstance().hqmeDelegate?.dataStoreDeleteItem(model)
                                        //update state to initial after cleanp
                                        downloadButton.hqmeStateChange(to: .initial)
        })
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        APApplicasterController.sharedInstance()?.rootViewController.topmostModal()?.present(alert,
                                                                                             animated: true,
                                                                                             completion: nil)
    }
    
    private func presentPostErrorAlert(for downloadButton: ZPHqmeButtonProtocol, model: ZPHqmeSupportingItemProtocol) {
        let delete: NSString = "Delete"
        let retry: NSString = "Retry"
        
        let title: NSString = "Action"
        let message: NSString = "Are you sure to delete or try to download the item again?"
        
        let alert = UIAlertController(title: title.withKey("HqmeFailedItemDeleteRetryTitle"),
                                      message: message.withKey("HqmeFailedItemDeleteRetryMessage"),
                                      preferredStyle: .alert)
        
        let retryButton = UIAlertAction(title: retry.withKey("HqmeFailedItemRetryTitle"),
                                        style: .default,
                                        handler: { _ in
                                            //reset state
                                            downloadButton.hqmeStateChange(to: .initial)
                                            //download again
                                            ZAAppConnector.sharedInstance().hqmeDelegate?.startProcess(for: model)
                                            
        })
        
        let deleteButton = UIAlertAction(title: delete.withKey("HqmeFailedItemDeleteTitle"),
                                         style: .default,
                                         handler: { _ in
                                            //delete
                                            ZAAppConnector.sharedInstance().hqmeDelegate?.dataStoreDeleteItem(model)
                                            //update state to initial after cleanp
                                            downloadButton.hqmeStateChange(to: .initial)
        })
        
        alert.addAction(retryButton)
        alert.addAction(deleteButton)
        
        APApplicasterController.sharedInstance()?.rootViewController.topmostModal()?.present(alert,
                                                                                             animated: true,
                                                                                             completion: nil)
    }
    
    func addDownloadButton() {
        if let _ = self.playerControlsView as? GAPlayerControlsViewAdvancedPlayer,
            let downloadableItem = getCurrentHqmeSupportingItem() {
            self.addDownloadButton(forDownloadableItem: downloadableItem)
        }
    }
    
    private func getCurrentHqmeSupportingItem() -> ZPHqmeSupportingItemProtocol? {
        var retVal: ZPHqmeSupportingItemProtocol?
        if let playerViewController = playerViewController,
            let currentItem = playerViewController.playerController.currentItem {
            if let downloadableItem = currentItem as? ZPHqmeSupportingItemProtocol {
                retVal = downloadableItem
            } else if let atomEntryPlayable = currentItem as? APAtomEntryPlayable {
                retVal = atomEntryPlayable.atomEntry
            }
        }
        return retVal
    }
}
