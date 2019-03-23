//
//  ViewController.swift
//  PayTMPaymentIntegration
//
//  Created by chander bhushan on 23/03/19.
//  Copyright © 2019 Educational. All rights reserved.
//

import UIKit
import PaymentSDK
class ViewController: UIViewController {

    var checkSum:CheckSumModel?
    var txnController = PGTransactionViewController()
    var serv = PGServerEnvironment()
    var params = [String:String]()
    var order_ID:String?
    var cust_ID:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        order_ID = randomString(length: 5)
        cust_ID = randomString(length: 6)
        params = ["MID": PaytmConstants.MID,
                  "ORDER_ID": order_ID,
                  "CUST_ID": cust_ID,
                  "MOBILE_NO": "7777777777",
                  "EMAIL": "username@emailprovider.com",
                  "CHANNEL_ID":PaytmConstants.CHANNEL_ID,
                  "INDUSTRY_TYPE_ID":PaytmConstants.INDUSTRY_TYPE_ID,
                  "WEBSITE": PaytmConstants.WEBSITE,
                  "TXN_AMOUNT": "10.00",
                  "CALLBACK_URL" :PaytmConstants.CALLBACK_URL+order_ID!
            ] as! [String : String]
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func getCheckSumAPICall(){
        let apiStruct = ApiStruct(url: "http://192.168.43.136:8888/PHP/generateChecksum.php", method: .post, body: params)
        WSManager.shared.getJSONResponse(apiStruct: apiStruct, success: { (checkSumModel: CheckSumModel) in
            self.setupPaytm(checkSum: checkSumModel.CHECKSUMHASH!, params: self.params)
        }) { (error) in
            print(error)
        }
    }
    
    
    private func setupPaytm(checkSum:String,params:[String:String]) {
        serv = serv.createStagingEnvironment()
        let type :ServerType = .eServerTypeStaging
        let order = PGOrder(orderID: "", customerID: "", amount: "", eMail: "", mobile: "")
        order.params = params
        //"CHECKSUMHASH":"oCDBVF+hvVb68JvzbKI40TOtcxlNjMdixi9FnRSh80Ub7XfjvgNr9NrfrOCPLmt65UhStCkrDnlYkclz1qE0uBMOrmu
        order.params["CHECKSUMHASH"] = checkSum
        self.txnController =  (self.txnController.initTransaction(for: order) as? PGTransactionViewController)!
        self.txnController.title = "Paytm Payments"
        self.txnController.setLoggingEnabled(true)
        
        if(type != ServerType.eServerTypeNone) {
            self.txnController.serverType = type;
        } else {
            return
        }
        self.txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
        self.txnController.delegate = self
        self.navigationController?.pushViewController(self.txnController
            , animated: true)
    }
    
    
    @IBAction func payButtonClicked(_ sender: Any) {
        getCheckSumAPICall()
    }
}



extension ViewController : PGTransactionDelegate {
    //this function triggers when transaction gets finished
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        let msg : String = responseString
        var titlemsg : String = ""
        if let data = responseString.data(using: String.Encoding.utf8) {
            do {
                if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
                    titlemsg = jsonresponse["STATUS"] as? String ?? ""
                }
            } catch {
                print("Something went wrong")
            }
        }
        let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
            action -> Void in
            controller.navigationController?.popViewController(animated: true)
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    //this function triggers when transaction gets cancelled
    func didCancelTrasaction(_ controller : PGTransactionViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    //Called when a required parameter is missing.
    func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
        controller.navigationController?.popViewController(animated: true)
    }
}

