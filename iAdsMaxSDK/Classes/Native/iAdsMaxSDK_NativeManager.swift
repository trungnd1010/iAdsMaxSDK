//
//  MonetCoreSDK_Dependency_AdsNativeManagerProtocolAdsNativeManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import UIKit
import AppLovinSDK
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsMaxSDK_NativeManager: NSObject, iAdsCoreSDK_NativeProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    var completionShow: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false

    private var nativeAdLoader: MANativeAdLoader = .init(adUnitIdentifier: "YOUR_AD_UNIT")
    private var nativeAdViewCustom: MANativeAdView!
    private var nativeAdContainerView: UIView?
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdMax"
    private var adsId: String = ""
    
    private var nativeAd: MAAd?
    
    private var dateStartLoad: Double = Date().timeIntervalSince1970
    
    public static
    func make() -> iAdsCoreSDK_NativeProtocol {
        return iAdsMaxSDK_NativeManager()
    }
    
    //Max
    public func loadAds(vc: UIViewController,
                        adsId: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsMaxSDK_Error.adsIdIsLoading))
            return
        }
        self.dateStartLoad = Date().timeIntervalSince1970
        self.completionLoad = completion
        self.isLoading = true
        self.adsId = adsId
        
        nativeAdLoader = .init(adUnitIdentifier: adsId)
        nativeAdLoader.placement = placement
        nativeAdLoader.nativeAdDelegate = self
        
        nativeAdLoader.loadAd()
        
    }
    
    public func showAds(containerView: UIView,
                        nativeAdmobView: UIView? = nil,
                        nativeMaxView: UIView?,
                        placement    : String,
                        priority     : Int,
                        completion   : @escaping (Result<Void, Error>) -> Void) {
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        self.completionShow = completion
        
        nativeAdLoader.revenueDelegate = self
        nativeAdLoader.nativeAdDelegate = self
        
        if let nativeAd = nativeAd, let nativeMaxView = nativeMaxView as? BaseMAXNativeView {
            if nativeAd.nativeAd?.isExpired ?? false
            {
                nativeAdLoader.destroy(nativeAd)
                nativeAdLoader.loadAd()
                return
            }
           
            let adViewBinder = MANativeAdViewBinder(builderBlock: { builder in
                builder.titleLabelTag = 1001
                builder.advertiserLabelTag = 1002
                builder.bodyLabelTag = 1003
                builder.iconImageViewTag = 1004
                builder.optionsContentViewTag = 1005
                builder.mediaContentViewTag = 1006
                builder.callToActionButtonTag = 1007
                builder.starRatingContentViewTag = 1008
            })
            nativeMaxView.bindViews(with: adViewBinder)
            nativeAdLoader.renderNativeAdView(nativeMaxView, with: nativeAd)
            containerView.iComponentsSDK_removeAllSubviews()
            containerView.iComponentsSDK_addSubView(subView: nativeMaxView)
            
            iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                           ad_status: .showed,
                                           ad_unit_name: adsId,
                                           ad_action: .show,
                                           script_name: .show_xx,
                                           ad_network: adNetwork,
                                           ad_format: .Native,
                                           sub_ad_format: .native,
                                           error_code: "",
                                           message: "",
                                           time: "",
                                           priority: "",
                                           recall_ad: .no)
            
        } else {
            
            iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                           ad_status: .show_failed,
                                           ad_unit_name: adsId,
                                           ad_action: .show,
                                           script_name: .show_xx,
                                           ad_network: adNetwork,
                                           ad_format: .Native,
                                           sub_ad_format: .native,
                                           error_code: String(iAdsMaxSDK_Error.noAdsToShow.code),
                                           message: iAdsMaxSDK_Error.noAdsToShow.code.description,
                                           time: "",
                                           priority: "",
                                           recall_ad: .no)
            completion(.failure(iAdsMaxSDK_Error.noAdsToShow))
        }
    }
}

extension iAdsMaxSDK_NativeManager: MANativeAdDelegate {
    public func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        isHasAds = true
        isLoading = false
        nativeAd = ad
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .loaded,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: iComponentsSDK_Date.getElapsedTime(startTime: self.dateStartLoad),
                                       priority: "",
                                       recall_ad: .no)
        nativeAdLoader.nativeAdDelegate = nil
        completionLoad?(.success(()))
    }
    
    public func didClickNativeAd(_ ad: MAAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isHasAds = false
        isLoading = false
        nativeAdLoader.nativeAdDelegate = nil
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "\(error.code.rawValue)",
                                       message: error.message,
                                       time: iComponentsSDK_Date.getElapsedTime(startTime: self.dateStartLoad),
                                       priority: "",
                                       recall_ad: .no)
        completionLoad?(.failure(NSError.init(domain: error.message, code: error.code.rawValue)))
    }
    
    public func didExpireNativeAd(_ ad: MAAd) {
        //TODO: Chưa xử lý
    }
}

extension iAdsMaxSDK_NativeManager: MAAdRevenueDelegate  {
    public func didPayRevenue(for ad: MAAd) {
        completionShow?(.success(()))
        let revenue = ad.revenue
        self.adNetwork = ad.networkName
        
        iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADMAX,
                                      currency: "USD",
                                      value: revenue,
                                      ad_unit_name: adsId,
                                      ad_network: adNetwork,
                                      ad_format: .Native,
                                      sub_ad_format: .native,
                                      placement: placement,
                                      ad_id: "",
                                      source: .AdSourceAdjust_AppLovinMAX)
        
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
}

@objc open class BaseMAXNativeView: MANativeAdView {
    public override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        _loadViewFromNib()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        _loadViewFromNib()
    }
    
    func _loadViewFromNib() {
        let nib = UINib(nibName: self.iComponentsSDK_fullClassName, bundle: .main)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        addSubview(nibView)
        nibView.translatesAutoresizingMaskIntoConstraints = false
        nibView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nibView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        nibView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        nibView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sendSubviewToBack(nibView)
    }
}

