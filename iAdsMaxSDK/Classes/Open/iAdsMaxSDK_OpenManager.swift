//
//  MonetCoreSDK_Dependency_AdsMaxOpenManagerProtocolAdsMaxOpenManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import AppLovinSDK
import iAdsCoreSDK
import iComponentsSDK


public class iAdsMaxSDK_OpenManager: NSObject, iAdsCoreSDK_OpenProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    var completionShow: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false
    
    private var openAd = MAAppOpenAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdMax"
    private var adsId: String = ""
    
    private var dateStartLoad: Date = Date()
    
    public static func make() -> iAdsCoreSDK_OpenProtocol {
        return iAdsMaxSDK_OpenManager()
    }
    
    public func loadAds(adsId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsMaxSDK_Error.adsIdIsLoading))
            return
        }
        self.dateStartLoad = Date()
        self.isLoading = true
        self.adsId = adsId
        self.completionLoad = completion
        
        self.openAd = MAAppOpenAd(adUnitIdentifier: adsId)
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
        self.priority = "\(priority)"
        self.placement = placement
        self.completionShow = completion
        openAd.show()
    }
}

//GADFullScreenContentDelegate
extension iAdsMaxSDK_OpenManager: MAAdViewAdDelegate {
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
                                       ad_format: .Open_Ad,
                                       sub_ad_format: .open,
                                       error_code: "",
                                       message: "",
                                       time: "\(Date().timeIntervalSince1970 - dateStartLoad.timeIntervalSince1970)",
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
                                       ad_format: .Open_Ad,
                                       sub_ad_format: .open,
                                       error_code: "\(error.code.rawValue)",
                                       message: error.message,
                                       time: "\(Date().timeIntervalSince1970 - dateStartLoad.timeIntervalSince1970)",
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
                                       ad_format: .Open_Ad,
                                       sub_ad_format: .open,
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
                                       ad_format: .Open_Ad,
                                       sub_ad_format: .open,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        completionShow?(.success(()))
    }
    
    public func didClick(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Open_Ad,
                                       sub_ad_format: .open,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        completionShow?(.failure(NSError(domain: error.message, code: error.code.rawValue)))
    }
}

extension iAdsMaxSDK_OpenManager: MAAdRevenueDelegate, MAAdDelegate  {
    public func didPayRevenue(for ad: MAAd) {
        let revenue = ad.revenue
        self.adNetwork = ad.networkName
        
        iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADMAX,
                                      currency: "USD",
                                      value: revenue,
                                      ad_unit_name: adsId,
                                      ad_network: adNetwork,
                                      ad_format: .Open_Ad,
                                      sub_ad_format: .open,
                                      placement: placement,
                                      ad_id: "")
        
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Open_Ad,
                                       sub_ad_format: .open,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
}
