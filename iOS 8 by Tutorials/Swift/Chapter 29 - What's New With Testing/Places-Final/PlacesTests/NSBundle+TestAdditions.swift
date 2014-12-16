//
//  NSBundle+TestAdditions.swift
//  Places
//
//  Created by Scott Atkinson on 7/31/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation

class Dummy {}

extension NSBundle {
    class func testBundle() -> NSBundle! {
        return NSBundle(forClass: Dummy.self)
    }
}
