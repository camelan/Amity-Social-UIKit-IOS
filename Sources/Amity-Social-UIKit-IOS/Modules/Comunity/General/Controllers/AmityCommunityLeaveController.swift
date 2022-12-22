//
//  AmityCommunityLeaveController.swift
//  AmityUIKit
//
//  Created by sarawoot khunsri on 1/8/21.
//  Copyright © 2021 Amity. All rights reserved.
//

import UIKit
import AmitySDK

protocol AmityCommunityLeaveControllerProtocol {
    func leave(_ completion: @escaping (AmityError?) -> Void)
}

final class AmityCommunityLeaveController: AmityCommunityLeaveControllerProtocol {
    
    private let repository: AmityCommunityRepository
    private let communityId: String
    
    init(withCommunityId _communityId: String) {
        communityId = _communityId
        repository = AmityCommunityRepository(client: AmityUIKitManagerInternal.shared.client)
    }
    
    func leave(_ completion: @escaping (AmityError?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.repository.leaveCommunity(withId: self.communityId) { (success, error) in
                if success {
                    completion(nil)
                } else {
                    let error = AmityError(error: error) ?? .unknown
                    AmityUIKitManager.logger?(.error(error))
                    completion(error)
                }
            }
        }
        
    }
    
}

