//
//  WikiDescriptionData.swift
//  WhatFlower
//
//  Created by Huang Yan on 8/27/22.
//

import Foundation
class WikiDescriptionData: Codable{ //traditional way to parse
    let query: Query
}
class Query: Codable{
    let pageids: [Int]
    let pages: [Items]
}
class Items: Codable{
    let title: String
    let extract: String
}
