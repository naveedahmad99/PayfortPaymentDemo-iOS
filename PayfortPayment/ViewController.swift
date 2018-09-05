//
//  ViewController.swift
//  PayfortPayment
//
//  Created by Thabresh on 22/01/18.
//  Copyright © 2018 Vivid. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    
    let payFort = PayFortController.init(enviroment: KPayFortEnviromentSandBox)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tappedPaynow(_ sender: Any) {
        generateAccessToken()
    }
    
    func generateAccessToken(){
        
        let headers = [
            "Content-Type": "application/json"
        ]

        let newSDKToken = PayfortSdkToken()
        newSDKToken.access_code = Configuration.payfortDevAccessCode
        newSDKToken.device_id = UIDevice.current.identifierForVendor?.uuidString
        newSDKToken.language = Configuration.payfortLanguage
        newSDKToken.merchant_identifier = Configuration.payfortDevMerchantID
        newSDKToken.service_command = Configuration.sdkTokenCommand
        newSDKToken.signature = getSignatureStr(newSDKToken)
        
        let parameters = getSdkTokenParams(newSDKToken)
        
        let postdata: Data? = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: Configuration.payfortDevUrl)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postdata
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (responseData, response, error) -> Void in
            if (error != nil) {
                print(error?.localizedDescription as Any)
            } else {
                do {
                    let jsondata = try JSON(data: responseData!)
                    print(jsondata)
                    let response_message:String = jsondata["response_message"].string!
                    if response_message == "Success" {
                        let sdkToken:String = jsondata["sdk_token"].string!
                        OperationQueue.main.addOperation {
                            self.connectPaymentGateway(token: sdkToken)
                        }
                    }
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
            }
        })
        dataTask.resume()
    }
   
    func connectPaymentGateway(token:String){
        
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        let merchant_reference = "12586" + "_" + String(format: "%0.2d", currentTime)
        
        let request = NSMutableDictionary.init()
        
        request.setValue("20", forKey: "amount")
        request.setValue("AUTHORIZATION", forKey: "command")
        request.setValue("SAR", forKey: "currency")
        request.setValue("email@gmail.com", forKey: "customer_email")
        request.setValue("en", forKey: "language")
        request.setValue(merchant_reference, forKey: "merchant_reference")
        request.setValue(token , forKey: "sdk_token")
        request.setValue("" , forKey: "payment_option")
        
        OperationQueue.main.addOperation {
            self.payFort?.callPayFort(withRequest: request, currentViewController: self,
                                 success: { (requestDic, responeDic) in
                                    
                print("success")
                print("responeDic=\(String(describing: responeDic))")
                
                                    
                                    let payResponse:PayfortResponse = self.getBookingByResponse(responeDic! as NSDictionary)
                print(payResponse)

                                    print(payResponse.response_message as Any)
                                    
                if payResponse.response_message == "Success"{
                    print("Payment Success")
                    let alert = UIAlertController(title: "Alert", message: "Payment Successful", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            },canceled: { (requestDic, responeDic) in
                print("canceled")
                print("responeDic=\(String(describing: responeDic))")
            },faild: { (requestDic, responeDic, message) in
                print("faild")
                print("responeDic=\(String(describing: responeDic))")
                print("message=\(String(describing: message))")
                
                let alert = UIAlertController(title: "Alert", message: "Payment Failed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    //Set Booking values by response data
    func getBookingByResponse(_ responseDic: NSDictionary) -> PayfortResponse{
        
        let responseData = PayfortResponse()
        
        responseData.fort_id = responseDic["fort_id"] as? String
        responseData.merchant_reference = responseDic["merchant_reference"] as? String
        responseData.expiry_date = responseDic["expiry_date"] as? String
        responseData.authorization_code = responseDic["authorization_code"] as? String
        responseData.token_name = responseDic["token_name"] as? String
        responseData.sdk_token = responseDic["sdk_token"] as? String
        responseData.customer_email = responseDic["customer_email"] as? String
        responseData.eci = responseDic["eci"] as? String
        responseData.payment_option = responseDic["payment_option"] as? String
        responseData.card_number = responseDic["card_number"] as? String
        responseData.customer_ip = responseDic["customer_ip"] as? String
        responseData.currency = responseDic["currency"] as? String
        responseData.amount = responseDic["amount"] as? String
        responseData.command = responseDic["command"] as? String
        responseData.response_message = responseDic["response_message"] as? String

        return responseData
        
    }
    func getSdkTokenParams(_ payfortToken: PayfortSdkToken) -> [String: AnyObject] {
        return [
            "service_command": (payfortToken.service_command == nil ? "" : payfortToken.service_command! ) as AnyObject,
            "access_code": (payfortToken.access_code == nil ? "" : payfortToken.access_code!) as AnyObject,
            "merchant_identifier": (payfortToken.merchant_identifier == nil ? "" : payfortToken.merchant_identifier!) as AnyObject,
            "language": (payfortToken.language == nil ? "" : payfortToken.language!) as AnyObject,
            "device_id": (payfortToken.device_id == nil ? "" : payfortToken.device_id!) as AnyObject,
            "signature": (payfortToken.signature == nil ? "" : payfortToken.signature!) as AnyObject,
            
        ]
    }
    
    func getSignatureStr(_ newToken: PayfortSdkToken) -> String {
        var signature = Configuration.payfortDevPhrase + "access_code=" + newToken.access_code! + "device_id=" + newToken.device_id! + "language=" + newToken.language!
        signature += "merchant_identifier=" + newToken.merchant_identifier! + "service_command=SDK_TOKEN" + Configuration.payfortDevPhrase
        return signature.sha256()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension String {
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}
