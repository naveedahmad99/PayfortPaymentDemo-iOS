//
//  Configuration.swift
//  PayfortPayment
//
//  Created by Thabresh on 22/01/18.
//  Copyright © 2018 Vivid. All rights reserved.
//

import UIKit

struct Configuration {
    
    //StartSDK
    
    static var startSDKUrl = "https://api.start.payfort.com/tokens/"
    static let startSDKDevUrl = "https://api.start.payfort.com/tokens/"
    static let startSDKProductionUrl = "https://api.start.payfort.com/tokens/"
    
    
    // Payfort
    static var payfortUrl = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    static let payfortDevUrl = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    static let payfortProductionUrl = "https://paymentservices.payfort.com/FortAPI/paymentApi"
    
    static var requestPhrase = "xxxxxxxx"
    static var accessCode = "xxxxxxxx"
    static var merchantID = "xxxxxxxx"
    
    static let payfortDevPhrase = "xxxxxxxx"
    static let payfortDevAccessCode = "xxxxxxxx"
    static let payfortDevMerchantID = "xxxxxxxx"
    
    static let payfortProductPhrase = "xxxxxxxx"
    static let payfortProductAccessCode = "xxxxxxxx"
    static let payfortProductMerchantID = "xxxxxxxx"
    
    static let authCommand = "AUTHORIZATION"
    static let purchaseCommand = "PURCHASE"
    static let sdkTokenCommand = "SDK_TOKEN"
    static let payfortCurreny = "SAR"
    static let payfortLanguage = "en"
    
    
    
    
}
