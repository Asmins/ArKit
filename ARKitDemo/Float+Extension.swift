//
//  Float+Extension.swift
//  ARKitDemo
//
//  Created by Eugene on 1/16/19.
//  Copyright © 2019 Eugene. All rights reserved.
//

import Foundation
import ARKit

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
