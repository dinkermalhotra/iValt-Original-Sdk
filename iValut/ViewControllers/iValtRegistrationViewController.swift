import UIKit
import CountryPickerView

protocol iValtRegistrationViewControllerDelegate: class
{
    func onSuccess()
    func didFailWithError(_ message: String)
}

protocol iValtRegistrationDelegate {
    func resendOtp(_ userNumber: String)
}

var registrationViewControllerDelegate: iValtRegistrationDelegate?

class iValtRegistrationViewController: UIViewController {

    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var cpvMain: CountryPickerView!
    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    
    var countryCode = ""
    var isSelected = false
    var name = ""
    var email = ""
    var supplierId = ""
    var supplier = ""
    var deviceToken = ""
    weak var delegate: iValtRegistrationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtName.text = name
        txtEmail.text = email
        
        registrationViewControllerDelegate = self
        
        cpvMain.showCountryCodeInView = false
        cpvMain.countryDetailsLabel.font = iValtFonts.FONT_MONTSERRAT_REGULAR_16
        cpvMain.countryDetailsLabel.textColor = UIColor.white
        self.countryCode = cpvMain.countryDetailsLabel.text ?? ""
        cpvMain.delegate = self
        
        lblPrivacyPolicy.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:))))
        setupNotificationManager()
    }
    
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(onSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SUCCESS), object: nil)
        notificationCenter.addObserver(self, selector: #selector(didFailWithError(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_FAILURE), object: nil)
    }
    
    @objc func onSuccess(_ notification: Notification) {
        self.delegate?.onSuccess()
    }
    
    @objc func didFailWithError(_ notification: Notification) {
        if let notificationUserInfo = notification.userInfo {
            if let message = notificationUserInfo[WSResponseParams.WS_RESP_PARAM_MESSAGE] as? String {
                self.delegate?.didFailWithError(message)
            }
        }
    }
}

// MARK: - UIBUTTON ACTION
extension iValtRegistrationViewController {
    @objc func btnDoneOfToolBarPressed() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let text = self.lblPrivacyPolicy.text ?? ""
        let range = (text as NSString).range(of: "Terms and Conditions")
        if sender.didTapAttributedTextInLabel(label: self.lblPrivacyPolicy, inRange: range) {
            print("terms")
            guard let url = URL(string: WebService.privacyPolicy) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnPrivacyPressed(_ sender: UIButton) {
        if isSelected {
            sender.setImage(#imageLiteral(resourceName: "ic_uncheck"), for: UIControl.State())
            isSelected = false
        } else {
            sender.setImage(#imageLiteral(resourceName: "ic_check"), for: UIControl.State())
            isSelected = true
        }
    }
    
    @IBAction func nextClicked(_ sender: UIButton) {
        let emailRegEx = "[a-zA-Z0-9._-]+@[a-z?-]+\\.+[a-z]+"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if countryCode.isEmpty {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.ENTER_COUNTRY_CODE)
        }
        else if(txtMobileNumber.text?.count == 0) {
            Helper.showOKAlert(onVC: self, title: Alert.ERROR, message: AlertMessages.ENTER_MOBILE_NUMBER)
        }
        else if !isSelected {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.ACCEPT_PRIVACY)
        }
        else if txtEmail.text?.isEmpty ?? true {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.EMAIL_REQUIRED)
        }
        else if (emailTest.evaluate(with: self.txtEmail.text?.lowercased()) == false) {
            Helper.showOKAlert(onVC: self, title: Alert.ALERT, message: AlertMessages.ENTER_VALID_EMAIL)
        }  else {
            loader.startAnimating()
            userRegistration(countryCode + (txtMobileNumber.text ?? ""))
        }
    }
}

// MARK: - UITEXTFIELD DELEGATE
extension iValtRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CUSTOM DELEGATE
extension iValtRegistrationViewController: iValtRegistrationDelegate {
    func resendOtp(_ userNumber: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: userNumber as AnyObject]
            WSManager.wsCallLogin(params, completion: { (isSuccess, message) in
                if !isSuccess {
                    var data: [AnyHashable: Any] = [:]
                    data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = message
                    NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                }
            })
        } else {
            
        }
    }
}

// MARK: - COUNTRYPICKER METHODS
extension iValtRegistrationViewController: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.countryCode = country.phoneCode
    }
}

// MARK: - API CALL
extension iValtRegistrationViewController {
    func userRegistration(_ userNumber: String) {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_MOBILE: userNumber as AnyObject]
            WSManager.wsCallLogin(params, completion: { (isSuccess, message) in
                self.loader.stopAnimating()
                
                if isSuccess {
                    if let vc = ViewControllerHelper.getViewController(ofType: .iValtOtpViewController) as? iValtOtpViewController {
                        vc.strCode = self.countryCode
                        vc.strNumber =  self.txtMobileNumber.text ?? ""
                        vc.supplier = self.supplier
                        vc.supplierId = self.supplierId
                        vc.deviceToken = self.deviceToken
                        Helper.setPREF(self.txtEmail.text ?? "", key: UserDefaultsConstants.PREF_EMAIL)
                        Helper.setPREF(userNumber, key: UserDefaultsConstants.PREF_MOBILE_NUMBER)
                        Helper.setPREF(self.txtMobileNumber.text ?? "", key: UserDefaultsConstants.PREF_MOBILE)
                        Helper.setPREF(self.txtName.text ?? "", key: UserDefaultsConstants.PREF_NAME)
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
