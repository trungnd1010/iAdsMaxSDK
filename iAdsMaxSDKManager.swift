//
//  iAdsMaxSDKManager.swift
//  iAdsMaxSDK
//
//  Created by Nguyễn Trung on 4/11/24.
//

import AppLovinSDK

public class iAdsMaxSDKManager {
    public static let shared = iAdsMaxSDKManager()
    private init() {}
    
    public func setup(sdkKey: String, isTestAds: Bool) {
        let initConfig = ALSdkInitializationConfiguration(sdkKey: sdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
            if isTestAds, let currentIDFV = UIDevice.current.identifierForVendor?.uuidString {
                builder.testDeviceAdvertisingIdentifiers = [currentIDFV]
            }
        }
        ALSdk.shared().initialize(with: initConfig) { _ in }
    }
}
