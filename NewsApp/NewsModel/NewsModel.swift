//  NewsModel.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import Foundation
import SwiftUI

struct NewsResponse: Decodable {
    let results: [News]
}

struct News: Decodable, Identifiable, Comparable {
    static func < (lhs: News, rhs: News) -> Bool {
        lhs.title.lowercased() < rhs.title.lowercased()
    }
    
    static func == (lhs: News, rhs: News) -> Bool {
        lhs.title.lowercased() == rhs.title.lowercased()
    }
    
    let id             : Int64
    let url            : String
    let publishedDate  : String
    let section        : String
    let subsection     : String
    let title          : String
    let byline         : String
    let abstract       : String
    let media          : [NewsMedia]
    
    init(entity: NewsEntity) {
        id = entity.id
        url = entity.url ?? ""
        publishedDate = entity.publishedDate ?? ""
        section = entity.section ?? ""
        subsection = entity.subsection ?? ""
        title = entity.title ?? ""
        byline = entity.byline ?? ""
        abstract = entity.abstract ?? ""
        media = []
    }
}

struct NewsMedia: Decodable {
    let metadata : [NewsMetadata]
    let type     : String
    
    enum CodingKeys: String, CodingKey {
        case metadata = "media-metadata"
        case type
    }
}

struct NewsMetadata: Decodable {
    let url      : URL
    var format   : String
    var height   : Int
    let width    : Int
}
