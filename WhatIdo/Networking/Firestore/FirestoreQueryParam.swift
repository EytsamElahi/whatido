//
//  FirestoreQueryParam.swift
//  WhatIdo
//
//  Created by eytsam elahi on 13/05/2025.
//

import Foundation

struct FirestoreQueryParam {
    let key: String
    let value: Any
}

struct FirestoreDateFilter {
    let key: String
    let from: Date
    let to: Date
}
