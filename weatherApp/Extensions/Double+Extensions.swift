//
//  Double+Extensions.swift
//  weatherApp
//
//  Created by Yasemin YEL on 21.02.2021.
//  Copyright © 2021 Sifa. All rights reserved.
//

import Foundation

extension Double {
    
    func toString() -> String {
        return String(format: "%.1f", self)
    }
    func toInt() -> Int {
        return Int(self)
    }
}
