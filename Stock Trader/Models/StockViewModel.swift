//
//  StockViewModel.swift
//  Stock Trader
//
//  Created by Daisy Duong on 11/18/20.
//

import Foundation

class StockViewModel: ObservableObject {
    
    let apiDetail = "https://nodejsserver-294803.wn.r.appspot.com/api/details/"
    let apiPrice = "https://nodejsserver-294803.wn.r.appspot.com/api/price/"
    let apiChart = "https://nodejsserver-294803.wn.r.appspot.com/api/chart/"
    let apiNews = "https://nodejsserver-294803.wn.r.appspot.com/api/news/"
    let apiAuto = "https://nodejsserver-294803.wn.r.appspot.com/api/autocomplete/"
    
    @Published var choices = [Choice]()
    @Published var prices = [Price]()
    @Published var details = [Detail]()
    @Published var news = [Article]()
    @Published var chart = [Values]()
    @Published var newsLoad: Bool = false
    @Published var priceLoad: Bool = false
    
    func fetchAuto(ticker: String) {
        if let url = URL(string: apiAuto + ticker) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode([Choice].self, from: safeData)
                            DispatchQueue.main.async{
                                self.choices = results
                            }
                        } catch DecodingError.keyNotFound(let key, let context) {
                            print("could not find key \(key) in JSON: \(context.debugDescription)")
                        } catch DecodingError.valueNotFound(let type, let context) {
                            print("could not find type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.typeMismatch(let type, let context) {
                            print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.dataCorrupted(let context) {
                            print("data found to be corrupted in JSON: \(context.debugDescription)")
                        } catch let error as NSError {
                            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                        }
                    }
                }
                
            }
            task.resume()
        }
}
    
    func fetchPrice(ticker: String) {
        if let url = URL(string: apiPrice + ticker) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode([Price].self, from: safeData)
                            DispatchQueue.main.async{
                                self.prices = results
                                self.priceLoad = true
                            }
                        } catch DecodingError.keyNotFound(let key, let context) {
                            Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                        } catch DecodingError.valueNotFound(let type, let context) {
                            Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.typeMismatch(let type, let context) {
                            Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.dataCorrupted(let context) {
                            Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                        } catch let error as NSError {
                            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                        }
                    }
                }
                
            }
            task.resume()
        }
}
    
    func fetchDetail(ticker: String) {
        if let url = URL(string: apiDetail + ticker) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(Detail.self, from: safeData)
                            DispatchQueue.main.async{
                                self.details.append(results)
                            }
                        } catch DecodingError.keyNotFound(let key, let context) {
                            Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                        } catch DecodingError.valueNotFound(let type, let context) {
                            Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.typeMismatch(let type, let context) {
                            Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.dataCorrupted(let context) {
                            Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                        } catch let error as NSError {
                            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                        }
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func fetchNews(ticker: String) {
        if let url = URL(string: apiNews + ticker) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(Articles.self, from: safeData)
                            DispatchQueue.main.async{
                                self.news = results.articles
                                self.newsLoad = true
                            }
                        } catch DecodingError.keyNotFound(let key, let context) {
                            Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                        } catch DecodingError.valueNotFound(let type, let context) {
                            Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.typeMismatch(let type, let context) {
                            Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.dataCorrupted(let context) {
                            Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                        } catch let error as NSError {
                            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                        }
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func fetchChart(ticker: String) {
        if let url = URL(string: apiChart + ticker + "/2020-05-11") {
            print(url)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode([Values].self, from: safeData)
                            DispatchQueue.main.async{
                                self.chart = results
                            }
                        } catch DecodingError.keyNotFound(let key, let context) {
                            Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                        } catch DecodingError.valueNotFound(let type, let context) {
                            Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.typeMismatch(let type, let context) {
                            Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                        } catch DecodingError.dataCorrupted(let context) {
                            Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                        } catch let error as NSError {
                            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                        }
                    }
                }
                
            }
            task.resume()
        }
}
    
}
    
struct Choice: Decodable, Identifiable {
    var id: String {
        return ticker
    }
    let ticker: String
    let name: String
}

struct Price: Decodable, Identifiable {
    var id: String {
        return ticker
    }
    let ticker: String
    let last: Double
    let high: Double
    let low: Double
    let bidPrice: Double?
    let open: Double
    let mid: Double?
    let prevClose: Double
    let volume: Int
}

struct Detail: Decodable, Identifiable {
    var id: String {
        return ticker
    }
    let ticker: String
    let description: String
}

struct Values: Decodable {
    let high: Double
    let low: Double
    let close: Double
    let open: Double
    let volume: Int
}

struct Articles: Decodable {
    let articles: [Article]
}

struct Article: Decodable, Identifiable {
    var name: String
    private enum RootCodingKeys: String, CodingKey {
        case title, publishedAt, urlToImage, url, source = "source"
        enum NestedCodingKeys: String, CodingKey {
            case name
        }
    }
    let title: String
    let publishedAt: String
    let urlToImage: String
    let url: String
    let id = UUID()
    
        init(from decoder: Decoder) throws {

            let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
            let userDataContainer = try rootContainer.nestedContainer(keyedBy: RootCodingKeys.NestedCodingKeys.self, forKey: .source)
            
            self.title = try rootContainer.decode(String.self, forKey: .title)
            self.publishedAt = try rootContainer.decode(String.self, forKey: .publishedAt)
            self.url = try rootContainer.decode(String.self, forKey: .url)
            self.urlToImage = try rootContainer.decode(String.self, forKey: .urlToImage)

            self.name = try userDataContainer.decode(String.self, forKey: .name)
        }
}








 

