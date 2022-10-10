//
//  AmityCategoryListScreenViewModel.swift
//  AmityUIKit
//
//  Created by Nontapat Siengsanor on 24/9/2563 BE.
//  Copyright © 2563 Amity. All rights reserved.
//

import AmitySDK

class AmityCategoryListScreenViewModel: AmityCategoryListScreenViewModelType {
    
    weak var delegate: AmityCategoryListScreenViewModelDelegate?
    
    private let categoryRepository = AmityCommunityRepository(client: AmityUIKitManagerInternal.shared.client)
    private var categoryCollection: AmityCollection<AmityCommunityCategory>?
    private var categoryToken: AmityNotificationToken?
    
    init() {
        setupCollection()
    }
    
    private func setupCollection() {
        categoryCollection = categoryRepository.getCategories(sortBy: .displayName, includeDeleted: false)
        categoryToken = categoryCollection?.observe { [weak self] collection, _, error in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.screenViewModelDidUpdateData(strongSelf)
        }
    }
    
    // MARK: - Data Source
    
    func numberOfItems() -> Int {
        return Int(categoryCollection?.count() ?? 0)
    }
    
    func item(at indexPath: IndexPath) -> AmityCommunityCategory? {
        return categoryCollection?.object(at: UInt(indexPath.row))
    }
    
    func loadNext() {
        guard let collection = categoryCollection else { return }
        switch collection.loadingStatus {
        case .loaded:
            collection.nextPage()
        default:
            break
        }
    }
    
}
