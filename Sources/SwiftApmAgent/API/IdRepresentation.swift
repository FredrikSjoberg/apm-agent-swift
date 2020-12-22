//
//  Copyright © 2020 SJ AB. All rights reserved.
//

import Foundation

public protocol IdRepresentation {
    var bytes: [UInt8] { get }
    var data: Data { get }
    var hexString: String { get }
}
