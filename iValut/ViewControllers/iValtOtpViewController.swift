import UIKit

class iValtOtpViewController: UIViewController {

    @IBOutlet weak var txtOtp: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var deviceToken = ""
    var strCode: String?
    var strNumber: String?
    var supplierId = ""
    var supplier = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - UIBUTTON ACTIONS
extension iValtOtpViewController {
    @IBAction func backClicked(_ sender: UIButton) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func resendCodeClicked(_ sender: UIButton) {
        registrationViewControllerDelegate?.resendOtp(Helper.getPREF(UserDefaultsConstants.PREF_MOBILE_NUMBER) ?? "")
    }
    
    @IBAction func btn_submit(_ sender: UIButton) {
        if(txtOtp.text?.isEmpty ?? true) {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.ENTER_OTP)
        } else {
            self.loader.startAnimating()
            
            do {
                try KeychainWrapper.init().storeDeviceIdFor(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
                let deviceId = try KeychainWrapper.init().getDeviceId()
                
                userRegistration(deviceId)
            }
            catch let error {
                var data: [AnyHashable: Any] = [:]
                data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = error.localizedDescription
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
            }
        }
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension iValtOtpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - API CALL
extension iValtOtpViewController {
    func userRegistration(_ deviceId: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: strNumber as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_COUNTRY_CODE: strCode as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_USER_CODE: txtOtp.text as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_DEVICE_TOKEN: deviceToken as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_PLATFORM: "iOS" as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_EMAIL: Helper.getPREF(UserDefaultsConstants.PREF_EMAIL) as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_NAME: Helper.getPREF(UserDefaultsConstants.PREF_NAME) as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_IMEI: deviceId as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_SUPPLIER_ID: supplierId as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_SUPPLIER: supplier as AnyObject]
            WSManager.wsCallRegister(params, completion: { (isSuccess, message) in
                self.loader.stopAnimating()
                
                if isSuccess {
                    if let vc = ViewControllerHelper.getViewController(ofType: .iValtMainViewController) as? iValtMainViewController {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    var data: [AnyHashable: Any] = [:]
                    data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = message
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                }
            })
        } else {
            
        }
    }
}
