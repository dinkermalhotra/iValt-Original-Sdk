
import Foundation
import Alamofire

class WSManager {
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    // MARK: LOGIN USER
    class func wsCallLogin(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.sendSMS, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if (responseValue[WSResponseParams.WS_RESP_PARAM_STATUS] as? String != WSResponseParams.WS_RESP_PARAM_ERROR) {
                    completion(true, "")
                } else {
                    if let responseMessage = responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String {
                        completion(false, responseMessage)
                    }
                }
            } else {
                completion(false, "No parameters found")
            }
        })
    }
    
    // MARK: REGISTER USER
    class func wsCallRegister(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.register, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if let status = (responseValue[WSResponseParams.WS_RESP_PARAM_STATUS]) as? Bool {
                    if !status {
                        if let responseMessage = responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String {
                            completion(false, responseMessage)
                        }
                    } else {
                        if let userId = responseValue[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                            Helper.setIntPREF(userId, key: UserDefaultsConstants.PREF_USERID)
                        }
                        completion(true, "")
                    }
                } else {
                    if let userId = responseValue[WSResponseParams.WS_RESP_PARAM_ID] as? Int {
                        Helper.setIntPREF(userId, key: UserDefaultsConstants.PREF_USERID)
                    }
                    completion(true, "")
                }
            } else {
                completion(false, "No parameters found")
            }
        })
    }
    
    // MARK: REGISTER FOR FACETECH
    class func wsCallRegisterConfirmation(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.registerConfirmation, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                completion(true, "")
            } else {
                completion(false, "")
            }
        })
    }
    
    // MARK: LOGIN FOR FACETECH
    class func wsCallLoginConfirmation(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.loginConfirmation, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                completion(true, "")
            } else {
                completion(false, "")
            }
        })
    }
    
    // MARK: GLOBAL AUTHENTICATION
    class func wsCallGlobalAuthentication(_ requestParams: [String: Any], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.global, method: .get, parameters: requestParams, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                completion(true, "")
            } else {
                completion(false, "")
            }
        })
    }
    
    // MARK: REGISTER USER DETAILS
    class func wsCallRegisterUserDetails(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String, _ userDetails: [[String: AnyObject]])->()) {
        Alamofire.request(WebService.registeredUserDetail, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if responseValue[WSResponseParams.WS_RESP_PARAM_STATUS] as? String == WSResponseParams.WS_RESP_PARAM_SUCCESS {
                    if let userDetails = responseValue[WSResponseParams.WS_RESP_PARAM_USER_DETAILS] as? [[String: AnyObject]] {
                        completion(true, "", userDetails)
                    }
                } else {
                    if let responseMessage = responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String {
                        completion(false, responseMessage, [])
                    }
                }
            } else {
                completion(false, "No parameters found", [])
            }
        })
    }
    
    // MARK: UPDATE TOKEN
    class func wsCallUpdateToken(_ requestParams: [String: AnyObject]) {
        Alamofire.request(WebService.updateToken, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
            }
        })
    }
    
    // MARK: DELETE USER
    class func wsCallDeleteUser(_ requestParams: [String: AnyObject], completion:@escaping (_ isSuccess: Bool, _ message: String)->()) {
        Alamofire.request(WebService.deleteUser, method: .post, parameters: requestParams, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(responseData) -> Void in
            print(responseData.result)
            if let responseValue = responseData.result.value as? [String: AnyObject] {
                print(responseValue)
                if responseValue[WSResponseParams.WS_RESP_PARAM_STATUS] as? String == WSResponseParams.WS_RESP_PARAM_SUCCESS {
                    completion(true, responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String ?? "")
                } else {
                    if let responseMessage = responseValue[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String {
                        completion(false, responseMessage)
                    }
                }
            } else {
                completion(false, "No parameters found")
            }
        })
    }
}
