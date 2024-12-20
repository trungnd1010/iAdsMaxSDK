//
//  MonetCoreSDK_Dependency_AdsMaxRewardedManagerProtocolAdsMaxRewardedManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import AppLovinSDK
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsMaxSDK_RewardedManager: NSObject, iAdsCoreSDK_RewardedProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    var completionShow: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false
    
    private var didEarn: Bool = false
    
    private var openAd = MARewardedAd.shared(withAdUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdMax"
    private var adsId: String = ""
    
    private var dateStartLoad: Double = Date().timeIntervalSince1970
    
    public static func make() -> iAdsCoreSDK_RewardedProtocol {
        return iAdsMaxSDK_RewardedManager()
    }
    
    public func loadAds(adsId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsMaxSDK_Error.adsIdIsLoading))
            return
        }
        self.dateStartLoad = Date().timeIntervalSince1970
        self.isLoading = true
        self.adsId = adsId
        self.completionLoad = completion
        
        self.openAd = MARewardedAd.shared(withAdUnitIdentifier: adsId)
        self.openAd.delegate = self
        self.openAd.revenueDelegate = self
        
        // Load the first ad
        self.openAd.load()
    }
    
    public func showAds(vc        : UIViewController,
                        placement : String,
                        priority  : Int,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        self.isHasAds = false
        self.didEarn = false
        self.priority = "\(priority)"
        self.placement = placement
        self.completionShow = completion
        openAd.show()
    }
}

//GADFullScreenContentDelegate
extension iAdsMaxSDK_RewardedManager: MARewardedAdDelegate {
    public func didRewardUser(for ad: MAAd, with reward: MAReward) {
        self.didEarn = true
    }
    
    public func didExpand(_ ad: MAAd) {}
    
    public func didCollapse(_ ad: MAAd) {}
    
    public func didLoad(_ ad: MAAd) {
        isLoading = false
        isHasAds = true
        
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .loaded,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: self.adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: iComponentsSDK_Date.getElapsedTime(startTime: self.dateStartLoad),
                                       priority: "",
                                       recall_ad: .no)
        
        completionLoad?(.success(()))
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "\(error.code.rawValue)",
                                       message: error.message,
                                       time: iComponentsSDK_Date.getElapsedTime(startTime: self.dateStartLoad),
                                       priority: "",
                                       recall_ad: .no)
        completionLoad?(.failure(NSError.init(domain: error.message, code: error.code.rawValue)))
    }
    
    public func didDisplay(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .showed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func didHide(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .closed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        if didEarn {
            completionShow?(.success(()))
        } else {
            completionShow?(.failure(iAdsCoreSDK_Error.closeNoReward))
        }
        
    }
    
    public func didClick(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .show_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "\(error.code)",
                                       message: error.message,
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        completionShow?(.failure(NSError(domain: error.message, code: error.code.rawValue)))
    }
}

extension iAdsMaxSDK_RewardedManager: MAAdRevenueDelegate, MAAdDelegate  {
    public func didPayRevenue(for ad: MAAd) {
        let revenue = ad.revenue
        self.adNetwork = ad.networkName
        
        iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADMAX,
                                      currency: "USD",
                                      value: revenue,
                                      ad_unit_name: adsId,
                                      ad_network: adNetwork,
                                      ad_format: .Rewarded_Video,
                                      sub_ad_format: .rewarded_inter,
                                      placement: placement,
                                      ad_id: "",
                                      source: .AdSourceAdjust_AppLovinMAX)
        
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
}
