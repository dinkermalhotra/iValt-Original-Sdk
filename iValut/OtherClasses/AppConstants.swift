import UIKit
import Foundation

let NOTIFICATION_SUCCESS = "NOTIFICATION_SUCCESS"
let NOTIFICATION_FAILURE = "NOTIFICATION_FAILURE"

// App constants
struct AppConstants {
    static let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
    static let PORTRAIT_SCREEN_WIDTH  = UIScreen.main.bounds.size.width
    static let PORTRAIT_SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let CURRENT_IOS_VERSION = UIDevice.current.systemVersion
    static let errSomethingWentWrong  = NSError(domain: Alert.ALERT_SOMETHING_WENT_WRONG, code: 0, userInfo: nil)
}

enum FaceID {
    static let appleId = "appleId"
}

struct iValtFonts {
    static let FONT_LATO_REGULAR_16 = UIFont.init(name: "Lato-Regular", size: 16)
    static let FONT_MONTSERRAT_REGULAR_16 = UIFont.init(name: "Montserrat-Regular", size: 16)
}

// CELLIDS
struct CellIds {
    static let LinkedAppsCell               = "LinkedAppsCell"
    static let ViewLogsCell                 = "ViewLogsCell"
}

// Color Constants
struct iVaultColors {
    static let LIGHT_BLUE_COLOR             = UIColor.init(hex: "5e8fb5")
}

// Font Constants
struct iVaultFonts {
    static let FONT_LATO_REGULAR_10         = UIFont.init(name: "Lato-Regular", size: 10)
}

struct Strings {
    static let WORDPRESS                    = "wordpress"
    static let LOGIN                        = "login"
    static let GLOBAL                       = "global"
    static let kSecAttrAccount              = "kSecAttrAccount"
    static let kSecAttrService              = "kSecAttrService"
}

struct Alert {
    static let OK                           = "Ok"
    static let ERROR                        = "Error"
    static let ALERT                        = "Alert"
    static let CANCEL                       = "Cancel"
    static let ALERT_SOMETHING_WENT_WRONG   = "Something went wrong"
}
