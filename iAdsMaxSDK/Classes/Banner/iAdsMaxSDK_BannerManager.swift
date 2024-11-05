//
//  MonetCoreSDK_Dependency_AdsBannerManagerProtocolAdsBannerManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import UIKit
import AppLovinSDK
import iAdsCoreSDK
import iComponentsSDK

public class iAdsMaxSDK_BannerManager: NSObject, iAdsCoreSDK_BannerProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false

    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdMax"
    private var adsId: String = ""
    
    private var bannerAd: MAAdView?
    
    public static
    func make() -> iAdsCoreSDK_BannerProtocol {
        return iAdsMaxSDK_BannerManager()
    }
    
    //Max
    public func loadAds(vc: UIViewController,
                        collapsible: String?,
                        isMrec: Bool?,
                        adsId: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsMaxSDK_Error.adsIdIsLoading))
            return
        }
        self.completionLoad = completion
        self.isLoading = true
        self.adsId = adsId
        DispatchQueue.main.async {
            if isMrec ?? false {
                self.bannerAd = MAAdView(adUnitIdentifier: adsId, adFormat: .mrec)
            } else {
                self.bannerAd = MAAdView(adUnitIdentifier: adsId, adFormat: (UIDevice.current.userInterfaceIdiom == .pad) ? .leader : .banner)
            }
            
            
            self.bannerAd?.delegate = self
            self.bannerAd?.revenueDelegate = self
            
            self.bannerAd?.loadAd()
        }
    }
    
    @MainActor
    public func showAds(containerView: UIView,
                        placement    : String,
                        priority     : Int,
                        completion   : @escaping (Result<Void, Error>) -> Void) {
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        
        guard let bannerAd = bannerAd else {
            completion(.failure(iAdsMaxSDK_Error.noAdsToShow))
            return
        }
        
        containerView.iComponentsSDK_removeAllSubviews()
        containerView.addSubview(bannerAd)
//        containerView.iComponentsSDK_addSubView(subView: bannerAd)
        bannerAd.translatesAutoresizingMaskIntoConstraints = false
        bannerAd.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        bannerAd.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .showed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
        
        completion(.success(()))
    }
}

extension iAdsMaxSDK_BannerManager: MAAdViewAdDelegate {
    public func didExpand(_ ad: MAAd) {
        
    }
    
    public func didCollapse(_ ad: MAAd) {
        
    }
    
    public func didLoad(_ ad: MAAd) {
        if completionLoad == nil {
            return
        }
        isHasAds = true
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .loaded,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
        completionLoad?(.success(()))
        completionLoad = nil
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isHasAds = false
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
        completionLoad?(.failure(NSError.init(domain: error.message, code: error.code.rawValue)))
        completionLoad = nil
    }
    
    public func didDisplay(_ ad: MAAd) {
    
    }
    
    public func didHide(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .closed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func didClick(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        isHasAds = false
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
}

extension iAdsMaxSDK_BannerManager: MAAdRevenueDelegate  {
    public func didPayRevenue(for ad: MAAd) {
        let revenue = ad.revenue
        self.adNetwork = ad.networkName
        
        iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADMAX,
                                      currency: "USD",
                                      value: revenue,
                                      ad_unit_name: adsId,
                                      ad_network: adNetwork,
                                      ad_format: .Banner,
                                      sub_ad_format: .banner,
                                      placement: placement,
                                      ad_id: "")
        
        iAdsCoreSDK_AdTrack().tracking(placement: "",
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: .banner,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
}


