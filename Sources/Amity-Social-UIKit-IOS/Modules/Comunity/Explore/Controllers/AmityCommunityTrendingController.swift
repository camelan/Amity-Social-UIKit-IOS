//
//  AmityCommunityTrendingController.swift
//  AmityUIKit
//
//  Created by sarawoot khunsri on 2/24/21.
//  Copyright © 2021 Amity. All rights reserved.
//

import UIKit
import AmitySDK

protocol AmityCommunityTrendingControllerProtocol {
    func retrieve(_ completion: ((Result<[AmityCommunityModel], AmityError>) -> Void)?)
}

final class AmityCommunityTrendingController: AmityCommunityTrendingControllerProtocol {
    
    private let repository = AmityCommunityRepository(client: AmityUIKitManagerInternal.shared.client)
    private var collection: AmityCollection<AmityCommunity>?
    private var token: AmityNotificationToken?
    private let maxTrending: UInt = 5
    
    func retrieve(_ completion: ((Result<[AmityCommunityModel], AmityError>) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collection = self.repository.getTrendingCommunities()
            self.token = self.collection?.observe { [weak self] (collection, change, error) in
                if collection.dataStatus == .fresh {
                    guard let strongSelf = self else { return }
                    if let error = AmityError(error: error) {
                        AmityUIKitManager.logger?(.error(error))
                        completion?(.failure(error))
                    } else {
                        completion?(.success(strongSelf.prepareDataSource()))
                    }
                } else {
                    let error = AmityError(error: error) ?? .unknown
                    AmityUIKitManager.logger?(.error(error))
                    completion?(.failure(error))
                }
            }
        }
        
    }
    
    private func prepareDataSource() -> [AmityCommunityModel] {
        guard let collection = collection else { return [] }
        var community: [AmityCommunityModel] = []
        for index in 0..<min(collection.count(), maxTrending) {
            guard let object = collection.object(at: index) else { continue }
            let model = AmityCommunityModel(object: object)
            community.append(model)
        }
        return community
    }

}
