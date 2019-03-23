//
//  File.swift
//  PayTMPaymentIntegration
//
//  Created by chander bhushan on 23/03/19.
//  Copyright © 2019 Educational. All rights reserved.
//

import Foundation

public struct CheckSumModel :Decodable {
    public var CHECKSUMHASH : String?
    public  var ORDER_ID : String?
    public var payt_STATUS : String?
}
