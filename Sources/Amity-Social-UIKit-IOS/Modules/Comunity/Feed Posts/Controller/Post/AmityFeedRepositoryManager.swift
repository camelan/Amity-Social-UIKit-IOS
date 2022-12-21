//
//  AmityPostFetchFeedController.swift
//  AmityUIKit
//
//  Created by sarawoot khunsri on 2/14/21.
//  Copyright © 2021 Amity. All rights reserved.
//

import UIKit
import AmitySDK

public enum AmityPostFeedType: Equatable {
    case globalFeed
    case customPostRankingGlobalFeed
    case myFeed
    case userFeed(userId: String)
    case communityFeed(communityId: String)
    case pendingPostsFeed(communityId: String)
}

protocol AmityFeedRepositoryManagerProtocol: AnyObject {
    func retrieveFeed(withFeedType type: AmityPostFeedType, completion: ((Result<[AmityPostModel], AmityError>) -> Void)?)
    func loadMore() -> Bool
}

final class AmityFeedRepositoryManager: AmityFeedRepositoryManagerProtocol {
    
    private let repository = AmityFeedRepository(client: AmityUIKitManagerInternal.shared.client)
    private var collection: AmityCollection<AmityPost>?
    private var token: AmityNotificationToken?
    private var participation: AmityCommunityParticipation?
    
    func loadMore() -> Bool {
        guard let collection = collection else { return false }
        switch collection.loadingStatus {
        case .loaded:
            if collection.hasNext {
                collection.nextPage()
                return true
            }
            return false
        default:
            return false
        }
    }
    
    func retrieveFeed(withFeedType type: AmityPostFeedType, completion: ((Result<[AmityPostModel], AmityError>) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch type {
            case .globalFeed:
                self.collection = self.repository.getGlobalFeed()
            case .customPostRankingGlobalFeed:
                self.collection = self.repository.getCustomPostRankingGlobalfeed()
            case .myFeed:
                self.collection = self.repository.getMyFeedSorted(by: .lastCreated, includeDeleted: false)
            case .userFeed(let userId):
                // If current userId is passing through .userFeed, handle this case as .myFeed type.
                if userId == AmityUIKitManagerInternal.shared.currentUserId {
                    self.collection = self.repository.getMyFeedSorted(by: .lastCreated, includeDeleted: false)
                } else {
                    self.collection = self.repository.getUserFeed(userId, sortBy: .lastCreated, includeDeleted: false)
                }
            case .communityFeed(let communityId):
                self.collection = self.repository.getCommunityFeed(withCommunityId: communityId, sortBy: .lastCreated, includeDeleted: false, feedType: .published)
            case .pendingPostsFeed(let communityId):
                self.collection = self.repository.getCommunityFeed(withCommunityId: communityId, sortBy: .lastCreated, includeDeleted: false, feedType: .reviewing)
            }
            
            
            self.token?.invalidate()
            self.token = self.collection?.observe { [weak self] (collection, change, error) in
                guard let strongSelf = self else { return }
                if let error = AmityError(error: error) {
                    completion?(.failure(error))
                    AmityUIKitManager.logger?(.error(error))
                } else {
                    completion?(.success(strongSelf.prepareDataSource(feedType: type)))
                }
            }
        }
    }
    
    private func prepareDataSource(feedType: AmityPostFeedType) -> [AmityPostModel] {
        guard let collection = collection else { return [] }
        var models = [AmityPostModel]()
        for i in 0..<collection.count() {
            guard let post = collection.object(at: i), !post.isDeleted else { continue }
            
            let model = AmityPostModel(post: post)
            if let communityId = model.targetCommunity?.communityId {
                participation = AmityCommunityParticipation(client: AmityUIKitManagerInternal.shared.client, andCommunityId: communityId)
                model.isModerator = participation?.getMember(withId: post.postedUserId)?.hasModeratorRole ?? false
                switch feedType {
                case .communityFeed(let feedCommunityId), .pendingPostsFeed(let feedCommunityId):
                    model.appearance.shouldShowCommunityName = communityId != feedCommunityId
                default:
                    break
                }
            }
            models.append(model)
        }
        return models
    }
}
