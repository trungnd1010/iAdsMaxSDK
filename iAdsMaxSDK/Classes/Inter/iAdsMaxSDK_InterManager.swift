//
//  MonetCoreSDK_Dependency_AdsMaxIntertitialManagerProtocolAdsMaxIntertitialManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import AppLovinSDK
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsMaxSDK_InterManager: NSObject, iAdsCoreSDK_IntertitialProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    var completionShow: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false
    
    private var interstitialAd = MAInterstitialAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdMax"
    private var adsId: String = ""
    
    private var dateStartLoad: Double = Date().timeIntervalSince1970
    
    public static func make() -> iAdsCoreSDK_IntertitialProtocol {
        return iAdsMaxSDK_InterManager()
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
        
        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: adsId)
        self.interstitialAd.delegate = self
        self.interstitialAd.revenueDelegate = self
        
        // Load the first ad
        self.interstitialAd.load()
    }
    
    public func showAds(vc        : UIViewController,
                        placement : String,
                        priority  : Int,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        self.completionShow = completion
        interstitialAd.show()
    }
}

//GADFullScreenContentDelegate
extension iAdsMaxSDK_InterManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {}
    
    public func didCollapse(_ ad: MAAd) {}
    
    public func didLoad(_ ad: MAAd) {
        isHasAds = true
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .loaded,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: self.adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "",
                                       message: "",
                                       time: iComponentsSDK_Date.getElapsedTime(startTime: self.dateStartLoad),
                                       priority: self.priority,
                                       recall_ad: .no)
        
        completionLoad?(.success(()))
        completionLoad = nil
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "\(error.code.rawValue)",
                                       message: error.message,
                                       time: iComponentsSDK_Date.getElapsedTime(startTime: self.dateStartLoad),
                                       priority: self.priority,
                                       recall_ad: .no)
        completionLoad?(.failure(NSError.init(domain: error.message, code: error.code.rawValue)))
        completionLoad = nil
    }
    
    public func didDisplay(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .showed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
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
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        completionShow?(.success(()))
        completionShow = nil
    }
    
    public func didClick(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .show_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "\(error.code)",
                                       message: error.message,
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
        completionShow?(.failure(NSError(domain: error.message, code: error.code.rawValue)))
        completionShow = nil
    }
}

extension iAdsMaxSDK_InterManager: MAAdRevenueDelegate, MAAdDelegate  {
    public func didPayRevenue(for ad: MAAd) {
        let revenue = ad.revenue
        self.adNetwork = ad.networkName
        
        iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADMAX,
                                      currency: "USD",
                                      value: revenue,
                                      ad_unit_name: adsId,
                                      ad_network: adNetwork,
                                      ad_format: .Interstitial,
                                      sub_ad_format: .inter,
                                      placement: placement,
                                      ad_id: "",
                                      source: .AdSourceAdjust_AppLovinMAX)
        
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
}
