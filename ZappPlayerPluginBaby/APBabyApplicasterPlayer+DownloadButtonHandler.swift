//
//  APBabyApplicasterPlayer+DownloadButtonHandler.swift
//  ZappPlayerPluginBaby
//
//  Created by Roi Kedarya on 08/07/2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import Foundation

extension APBabyApplicasterPlayer : ZPDownloadButtonDelegate {
    
    @objc public func addDownloadButton(forDownloadableItem item: ZPDownloadableItemProtocol) {
        if let playerController = self.playerControlsView as? GAPlayerControlsViewAdvancedPlayer,
            let downloadButtonContainer = playerController.downloadButtonContainerView,
            item.isValidForDownload?() == true,
            let downloadButton = ZAAppConnector.sharedInstance().hqmeDelegate?.createDownloadButton(withDelegate: self, size: downloadButtonContainer.bounds.size) {
            if let button = downloadButton as? UIView {
                downloadButtonContainer.isHidden = false
                downloadButtonContainer.removeAllSubviews()
                downloadButtonContainer.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                let views = ["button": button]
                downloadButtonContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: .alignAllCenterX, metrics: nil, views: views))
                downloadButtonContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: .alignAllCenterX, metrics: nil, views: views))
                
                if let itemOfflineState = ZAAppConnector.sharedInstance().hqmeDelegate?.getItemOfflineState(forItem: item) {
                    switch itemOfflineState {
                    case .downloaded:
                        downloadButton.downloadStateChange(to: .downloaded)
                        break
                    case .downloadInProgress:
                        downloadButton.downloadStateChange(to: .downloading)
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    public func downloadButton(_ downloadButton: ZPDownloadButtonProtocol, stateChanged state: ZPDownloadButtonState) {
        let currentItem = getCurrentDownloadableItem()
        guard let playableItem = currentItem else {
            return
        }
        
        switch state {
        case .error:
            ZAAppConnector.sharedInstance().hqmeDelegate?.cancelDownloading(playableItem)
            
        default:
            break
        }
    }
    
    public func downloadButton(_ downloadButton: ZPDownloadButtonProtocol, tappedWithState state: ZPDownloadButtonState) {
        let currentItem = getCurrentDownloadableItem()
        guard let playableItem = currentItem else {
            return
        }
        
        switch state {
        case .downloaded:
            self.presentPostDownloadAlert(for: downloadButton, model: playableItem)
            break
        case .startDownload:
            if ZAAppConnector.sharedInstance().connectivityDelegate.getCurrentConnectivityState() == .cellular {
                self.presentPreDownloadOn3gAlert(for: downloadButton, model: playableItem)
            }
            else {
                self.continueDownloadFlow(for: downloadButton, model: playableItem)
            }
            break
        case .downloading:
            ZAAppConnector.sharedInstance().hqmeDelegate?.cancelDownloading(playableItem)
            //update state to initial after cleanp
            downloadButton.downloadStateChange(to: .startDownload)
            break
        case .error:
            self.presentPostErrorAlert(for: downloadButton, model: playableItem)
            break
        default:
            break
            //do nothing
        }
    }
    
    public func downloadStateChangeNotificationName() -> String? {
        let currentItem = getCurrentDownloadableItem()
        guard let playableItem = currentItem,
            let identifier = playableItem.objectIdentifier?() else {
                return nil
        }
        return "AssetDownloadStateChanged"+identifier.md5Hash()
    }
    
    public func downloadingProgressChangeNotificationName() -> String? {
        let currentItem = getCurrentDownloadableItem()
        guard let playableItem = currentItem,
            let identifier = playableItem.objectIdentifier?() else {
                return nil
        }
        return "AssetDownloadProgressChanged"+identifier.md5Hash()
    }
    
    public func downloadButtonCustomImagesSuffix() -> String? {
        return "_baby_player"
    }
    
    private func continueDownloadFlow(for downloadButton: ZPDownloadButtonProtocol, model: ZPDownloadableItemProtocol) {
        
        if let atomEntry = model as? APAtomEntry {
            atomEntry.fetchDownloadUrl(completion: {
                self.continueDownloadFlow(for: downloadButton, model: model, fetchedUrl: true)
            })
        }
        else {
            self.continueDownloadFlow(for: downloadButton, model: model, fetchedUrl: true)
        }
    }
    
    private func continueDownloadFlow(for downloadButton: ZPDownloadButtonProtocol, model: ZPDownloadableItemProtocol, fetchedUrl: Bool) {
        //download the item
        ZAAppConnector.sharedInstance().hqmeDelegate?.download(model)
        //update state to pending
        downloadButton.downloadStateChange(to: .pending)
    }
    
    
    private func presentPreDownloadOn3gAlert(for downloadButton: ZPDownloadButtonProtocol, model: ZPDownloadableItemProtocol) {
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
    
    private func presentPostDownloadAlert(for downloadButton: ZPDownloadButtonProtocol, model: ZPDownloadableItemProtocol) {
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
                                        downloadButton.downloadStateChange(to: .startDownload)
                                        //update collection view to remove the deleted item if offline and presenting offline content
                                        //                                        if let parentComponentModelUiTag = self.componentModel.parentModel?.uiTag {
                                        //                                            let updateData:[String : Any] = [kUpdateComponentsUiTagTypeKey:parentComponentModelUiTag,
                                        //                                                                             kUpdateComponentsSendModelTypeKey: true]
                                        //                                            self.componentModel.actions = [kActionRefreshTypeKey: [updateData]]
                                        //                                            CAFactory.perform(.refreshComponents,
                                        //                                                              componentModel: self.componentModel as? CAComponentModel,
                                        //                                                              withModel: self.selectedModel,
                                        //                                                              withSelectedModel: nil,
                                        //                                                              in: self.parent,
                                        //                                                              with: self.parent?.view)
                                        //                                        }
        })
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        APApplicasterController.sharedInstance()?.rootViewController.topmostModal()?.present(alert,
                                                                                             animated: true,
                                                                                             completion: nil)
    }
    
    private func presentPostErrorAlert(for downloadButton: ZPDownloadButtonProtocol, model: ZPDownloadableItemProtocol) {
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
                                            downloadButton.downloadStateChange(to: .startDownload)
                                            //download again
                                            ZAAppConnector.sharedInstance().hqmeDelegate?.download(model)
                                            
        })
        
        let deleteButton = UIAlertAction(title: delete.withKey("HqmeFailedItemDeleteTitle"),
                                         style: .default,
                                         handler: { _ in
                                            //delete
                                            ZAAppConnector.sharedInstance().hqmeDelegate?.dataStoreDeleteItem(model)
                                            //update state to initial after cleanp
                                            downloadButton.downloadStateChange(to: .startDownload)
        })
        
        alert.addAction(retryButton)
        alert.addAction(deleteButton)
        
        APApplicasterController.sharedInstance()?.rootViewController.topmostModal()?.present(alert,
                                                                                             animated: true,
                                                                                             completion: nil)
    }
    
    func addDownloadButton() {
        if let _ = self.playerControlsView as? GAPlayerControlsViewAdvancedPlayer,
            let downloadableItem = getCurrentDownloadableItem() {
            self.addDownloadButton(forDownloadableItem: downloadableItem)
        }
    }
    
    private func getCurrentDownloadableItem() -> ZPDownloadableItemProtocol? {
        var retVal: ZPDownloadableItemProtocol?
        if let playerViewController = playerViewController,
            let currentItem = playerViewController.playerController.currentItem {
            if let downloadableItem = currentItem as? ZPDownloadableItemProtocol {
                retVal = downloadableItem
            } else if let atomEntryPlayable = currentItem as? APAtomEntryPlayable {
                retVal = atomEntryPlayable.atomEntry
            }
        }
        return retVal
    }
}
