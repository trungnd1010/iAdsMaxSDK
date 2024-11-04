//
//  iKameSDK_Error.swift
//  iKameSDK
//
//  Created by Trung Nguyễn on 23/10/24.
//

import Foundation


enum iAdsMaxSDK_Error: Error {
    case adsIdIsLoading
    case noAdsToShow
    case closeNoReward

    // Hàm cung cấp mô tả chi tiết cho mỗi lỗi
    var errorMessage: String {
        switch self {
        case .adsIdIsLoading:
            return "Ads id is loading..."
        case .noAdsToShow:
            return "noAdsToShow"
        case .closeNoReward:
            return "Close no reward"
        }
    }
}
