//
//  AmityPostDeleteController.swift
//  AmityUIKit
//
//  Created by sarawoot khunsri on 2/13/21.
//  Copyright © 2021 Amity. All rights reserved.
//

import UIKit
import AmitySDK

protocol AmityPostDeleteControllerProtocol {
    func delete(withPostId postId: String, parentId: String?, completion: AmityRequestCompletion?)
}

final class AmityPostDeleteController: AmityPostDeleteControllerProtocol {
    private let repository = AmityFeedRepository(client: AmityUIKitManagerInternal.shared.client)
    
    func delete(withPostId postId: String, parentId: String?, completion: AmityRequestCompletion?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.repository.deletePost(withPostId: postId, parentId: parentId, completion: completion)
        }
    }
}
