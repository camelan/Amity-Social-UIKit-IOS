//
//  AmityPostFooterProtocolHandler.swift
//  AmityUIKit
//
//  Created by sarawoot khunsri on 2/15/21.
//  Copyright © 2021 Amity. All rights reserved.
//

import Foundation
enum AmityPostFooterProtocolHandlerAction {
    case tapLike
    case tapComment
}
protocol AmityPostFooterProtocolHandlerDelegate: AnyObject {
    func footerProtocolHandlerDidPerformAction(_ handler: AmityPostFooterProtocolHandler, action: AmityPostFooterProtocolHandlerAction, withPost post: AmityPostModel)
}

final class AmityPostFooterProtocolHandler: AmityPostFooterDelegate {
    weak var delegate: AmityPostFooterProtocolHandlerDelegate?
    
    private weak var viewController: AmityViewController?
    
    init(viewController: AmityViewController) {
        self.viewController = viewController
    }
    
    func didPerformAction(_ cell: AmityPostFooterProtocol, action: AmityPostFooterAction) {
        guard let post = cell.post else { return }
        switch action {
        case .tapLike:
            delegate?.footerProtocolHandlerDidPerformAction(self, action: .tapLike, withPost: post)
        case .tapComment:
            delegate?.footerProtocolHandlerDidPerformAction(self, action: .tapComment, withPost: post)
        case .tapShare:
            handleShareOption(post: post)
        }
    }
    
    private func handleShareOption(post: AmityPostModel) {
        guard let viewController = viewController else { return }
        AmityFeedEventHandler.shared.sharePostDidTap(from: viewController, postId: post.postId)
    }
}
