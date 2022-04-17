//  NewsService.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import Foundation
import Alamofire
import UIKit

class NewsService {
    
    enum NewsType: String {
        case mostEmailed = "emailed"
        case mostShared  = "shared"
        case mostViewed  = "viewed"
    }
    
    static let shared = NewsService()
    
    private init() { }
    private let baseUrl = "https://api.nytimes.com/svc/mostpopular/v2/%@/30.json?api-key=f5ZMvuD2FVn2zHs2RFDAWi3dtvgvhCMm"
    private let jsonDecoder = APIDecoder.jsonDecoder
    
    func fetchNews(for type: NewsType, completion: @escaping (Result<NewsResponse, NewsError>) -> Void) {
        guard let url = URL(string: String(format: baseUrl, type.rawValue)) else { return }
        let _ = AF.request(url, method: .get).validate().response { response in
            guard let data = response.data else {
                completion(.failure(.noData))
                return
            }
            do {
                let news = try self.jsonDecoder.decode(NewsResponse.self, from: data)
                completion(.success(news))
            } catch {
                print("error: ", error)
            }
        }
    }
}
