//
//  WikiApiManager.swift
//  WhatFlower
//
//  Created by Huang Yan on 8/27/22.
//

import Foundation
protocol WikiApiManagerDelegate {
    func updateUI (_ result: WikiDescriptionData)
}
struct WikiApiManager {
    //  https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=barberton%20daisy&indexpageids&redirects=1
    let baseUrl = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&indexpageids&redirects=1"
    var delegate: WikiApiManagerDelegate? = nil
    
    func fetchData (flowerName: String) {
        let urlString = baseUrl + "&titles=\(flowerName)"
        print(urlString)
        let url = URL(string: urlString)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url!) { data, response, error in
            if let data = data {
                let result = self.decodeJson(data)
                if let result = result {
                    self.delegate?.updateUI(result)
                }
            } else {
                print("error occured getting api\(String(describing: error))")
            }
            
        }
        task.resume()
    }
    func decodeJson(_ data: Data) -> WikiDescriptionData?{
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(WikiDescriptionData.self, from: data)
        }catch {
            print(error)
        }
        return nil
    }
}
