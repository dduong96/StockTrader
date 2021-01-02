//
//  DetailView.swift
//  Stock Trader
//
//  Created by Daisy Duong on 11/22/20.
//

import SwiftUI
import Foundation
import KingfisherSwiftUI

struct DetailView: View {
    
    let ticker: String
    let name: String
    @ObservedObject var stockVM = StockViewModel()
    @State private var isExpanded: Bool = false
    @State var showNotice: Bool = false
    @State var showSheet: Bool = false
    @Binding var isAdded: Bool
    @AppStorage("favorites") var favorites = Favorites()
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack (alignment: .leading){
                    // Top section
                    top
                    
                    // Chart
                    VStack {
                        Chart(ticker: self.ticker)
                    } .padding(.bottom, 8)
                    
                    
                    // Portfolio section
                    VStack (alignment: .leading){
                        Spacer()
                        Text("Portfolio")
                            .font(.title2)
                        HStack {
                            ForEach (stockVM.prices) { prices in
                            if let data = UserDefaults.standard.value(forKey:"portfolio") as? Data {
                                var stock = try? PropertyListDecoder().decode([Bought].self, from: data)
                                let check = stock!.firstIndex(where: {$0.id == self.ticker})
                            VStack (alignment: .leading){
                                Spacer()
                                Spacer()
                                if check != nil {
                                    Text("Shares owned: \(stock![check!].shares, specifier: "%.4f")")
                                    Spacer()
                                    Text("Market Value: $\(stock![check!].shares * prices.last, specifier: "%.2f")")

                                }
                                else {
                                    Text("Shares owned: 0.0000")
                                    Spacer()
                                    Text("Market Value: $0.00")
                                }
                            }.font(.caption)
                            Spacer()
                            Button (action: {
                                self.showSheet = true
                            }){
                                Text("Trade")
                                    .bold()
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 15)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .cornerRadius(40)
                                    
                            } .padding(.trailing, 8)
                            .sheet(isPresented: $showSheet, content: {
                                TradeSheet(showSheet: $showSheet, price: prices.last, ticker: self.ticker, name: self.name, change: (prices.last - prices.prevClose))
                            })
                        }
                        }
                        }
                    } .onAppear {
                        self.stockVM.fetchPrice(ticker: self.ticker)
                    }
                    // Stats section
                    ScrollView (.horizontal) {
                    VStack (alignment: .leading){
                        ForEach (stockVM.prices) { price in
                            Spacer()
                            Spacer()
                            Text("Stats")
                                .font(.title2)
                            Spacer()
                            Spacer()
                            HStack {
                                VStack (alignment: .leading){
                                    Text("Current Price: \(price.last, specifier: "%.2f")")
                                    Spacer()
                                    Text("Open Price: \(price.open, specifier: "%.2f")")
                                    Spacer()
                                    Text("High: \(price.high, specifier: "%.2f")")
                                }
                                Spacer()
                                    .frame(width: 40)
                                VStack (alignment: .leading){
                                    Text("Low: \(price.low, specifier: "%.2f")")
                                    Spacer()
                                    Text("Mid: \(price.mid ?? 0.00, specifier: "%.2f")")
                                    Spacer()
                                    Text("Volume: \(price.volume)")
                                }
                                Spacer()
                                    .frame(width: 40)
                                VStack (alignment: .leading){
                                    Text("Bid Price: \(price.bidPrice ?? 0.00, specifier: "%.2f")")
                                    Spacer()
                                }
                            } .font(.caption)
                        }
                        }
                }
                    
                    // About section
                    VStack (alignment: .leading){
                        ForEach (stockVM.details) {detail in
                        Spacer()
                        Spacer()
                        Text("About")
                            .font(.title2)
                        Spacer()
                        Spacer()
                        Text("\(detail.description)")
                            .font(.caption)
                            .lineLimit(isExpanded ? nil : 2)
                        HStack {
                            Spacer()
                            Button(action: {
                                isExpanded.toggle()
                            }) {
                                Text(isExpanded ? "Show less" : "Show more")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                                    .background(Color.white)
                            }
                        }
                        }
                    } .onAppear {
                        self.stockVM.fetchDetail(ticker: self.ticker)
                    
                    }
                    
                    // News Section
                    VStack (alignment: .leading){
                        Spacer()
                        Spacer()
                        Text("News")
                            .font(.title2)
                        Spacer()
                        Spacer()
                        if stockVM.news.count > 0 {
                            news1
                            Divider()
                            allNews
                        }
                        
                    } .onAppear {
                        self.stockVM.fetchNews(ticker: self.ticker)
                    }
                    
                    // Pop-up notice for adding/removing to favorites
                   
                } .padding()
                
            } .toast(showNotice: $showNotice, ticker: self.ticker, isAdded: $isAdded)
            .navigationBarTitle(self.ticker)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // add button
                    Button(action: {
                        
                        self.isAdded.toggle()
                        
                        withAnimation {
                            self.showNotice = true
                        }
                        if self.isAdded == true {
                            let favorite = Added(id: self.ticker, name: self.name, added: self.isAdded)
                            favorites.append(favorite)
                        }
                        else {
                            let favorite = Added(id: self.ticker, name: self.name, added: true)
                            if let indexToRemove = favorites.firstIndex(of: favorite) {
                                favorites.remove(at: indexToRemove)
                            }
                        }
                    }) {
                        Image(systemName: self.isAdded == true ? "plus.circle.fill" : "plus.circle")
                            .imageScale(.large)
                    }
                    .onAppear {
                        let item = Added(id: self.ticker, name: self.name, added: true)
                        let indexToCheck = favorites.firstIndex(of: item)
                        if indexToCheck != nil {
                            self.isAdded = true
                        }
                        else {
                            self.isAdded = false
                        }
                    }
                }
            }
            
            if stockVM.newsLoad == false {
                ProgressView("Fetching Data...")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
            }
    }
    
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Chart(ticker: "aapl")
        }
    }
}

struct Added: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let added: Bool
}

typealias Favorites = [Added]

extension Favorites: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(
                                Favorites.self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension DetailView {
    var top: some View {
        VStack (alignment: .leading){
            ForEach (stockVM.prices) { price in
                let change = price.last - price.prevClose
                Text(self.name)
                    .foregroundColor(.secondary)
                HStack (alignment: .bottom){
                    Text("$\(price.last, specifier: "%.2f")")
                        .bold()
                        .font(.title)
                    if change == 0 {
                        Text("($\(change, specifier: "%.2f"))")
                            .padding(.bottom, 3)
                            .foregroundColor(.secondary)
                    }
                    if change < 0 {
                        Text("($\(change, specifier: "%.2f"))")
                            .padding(.bottom, 3)
                            .foregroundColor(.red)
                    }
                    else {
                        Text("($\(change, specifier: "%.2f"))")
                            .padding(.bottom, 3)
                            .foregroundColor(.green)
                    }
                }
            }
        } .onAppear {
            self.stockVM.fetchPrice(ticker: self.ticker)
        }
    }
    
    var news1: some View {
        Button (action: {
            print("Opened news")
            if let url = URL(string: "\(stockVM.news[0].url)") {
                   UIApplication.shared.open(url)
               }
        }) {
            VStack (alignment: .leading){
                
                    KFImage(URL(string: "\(stockVM.news[0].urlToImage)")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                    HStack {
                    Text(stockVM.news[0].name)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                        Text(dateDiff(date: "\(stockVM.news[0].publishedAt)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    Spacer()
                }
                    Text(stockVM.news[0].title)
                        .bold()
                        .foregroundColor(.black)
             }
            }
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contextMenu(
                ContextMenu {
                    Button(action: {
                        if let url = URL(string: "\(stockVM.news[0].url)") {
                               UIApplication.shared.open(url)
                           }
                    }) {
                        Label("Open in Safari", systemImage: "safari")
                    }
                    Button(action: {
                        if let url = URL(string: "https://twitter.com/intent/tweet?text=Check%20out%20this%20link:%20\(stockVM.news[0].url)&hashtags=StockTrader") {
                               UIApplication.shared.open(url)
                           }
                    }) {
                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
                    }
                }
            )
    }
    
    var allNews: some View {
        ForEach (1 ..< stockVM.news.count) { i in
            Button (action: {
                print("Opened news")
                if let url = URL(string: "\(stockVM.news[i].url)") {
                       UIApplication.shared.open(url)
                   }
            }) {
                HStack {
                    VStack (alignment: .leading){
                        HStack {
                        Text(stockVM.news[i].name)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.secondary)
                        Text(dateDiff(date: "\(stockVM.news[i].publishedAt)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        }
                        Text(stockVM.news[i].title)
                            .bold()
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .lineLimit(3)
                    }
                    KFImage(URL(string: "\(stockVM.news[i].urlToImage)")!)
                        .resizable()
                        .frame(width:75, height: 75)
                        .cornerRadius(10)
                        .padding(10)
                }
            } .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contextMenu(
                ContextMenu {
                    Button(action: {
                        if let url = URL(string: "\(stockVM.news[i].url)") {
                               UIApplication.shared.open(url)
                           }
                    }) {
                        Label("Open in Safari", systemImage: "safari")
                    }
                    Button(action: {
                        if let url = URL(string: "https://twitter.com/intent/tweet?text=Check%20out%20this%20link:%20\(stockVM.news[i].url)&hashtags=CSCI571StockApp") {
                               UIApplication.shared.open(url)
                           }
                    }) {
                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
                    }
                }
            )
        }
    }
    
}

struct FloatingNotice<Presenting>: View where Presenting: View {
    @Binding var showNotice: Bool
    @Binding var isAdded: Bool
    let presenting: () -> Presenting
    var ticker: String

    var body: some View {
        if self.showNotice {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                withAnimation {
                    self.showNotice = false
                }
            })
        }
        
        return GeometryReader { geometry in
            ZStack (alignment: .bottom){
              self.presenting()
                VStack (alignment: .center, spacing: 8) {
                    if isAdded == true {
                    Text("Adding \(ticker) to Favorites")
                        .padding(.horizontal, 80)
                        .padding(.vertical, 20)
                        .foregroundColor(.white)
                        .font(.subheadline)
                    }
                    else {
                        Text("Removing \(ticker) from Favorites")
                            .padding(.horizontal, 80)
                            .padding(.vertical, 20)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .background(Color.gray)
                .cornerRadius(40)
                .opacity(self.showNotice ? 1 : 0)
            } .animation(.easeInOut)
        }
    }
}

extension View {
    func toast(showNotice: Binding<Bool>, ticker: String, isAdded: Binding<Bool>) -> some View {
            FloatingNotice(showNotice: showNotice, isAdded: isAdded, presenting: { self }, ticker: ticker)
        }
}


struct Bought: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    var shares: Double
    
}


struct TradeSheet: View {
    let userDefaults = UserDefaults.standard
    @State var message: String = ""
    @State var showError: Bool = false
    @State var valid: Bool = false
    @Binding var showSheet: Bool
    var price: Double
    @State var action: String = ""
    var ticker: String
    var name: String
    var change: Double
    @State var input = ""
    var body: some View {
            VStack  {
                VStack {
                VStack {
                    HStack {
                        Button (action: {
                            self.showSheet = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                        .padding()
                        Spacer()
                    }
                    VStack {
                    Text("Trade \(self.name) shares")
                        .bold()
                    }
                }
                Spacer()
                VStack (alignment: .trailing){
                    HStack (alignment: .bottom){
                        TextField("0", text: $input)
                            .keyboardType(.decimalPad)
                            .font(Font.system(size: 90, design: .default))
                            .padding()
                        Spacer()
                        Text("Shares")
                            .font(.title)
                            .padding()
                    }
                    let total = self.price * (Double(input) ?? 0.00)
                    Text("x $\(self.price, specifier: "%.2f")/share = $\(total, specifier: "%.2f")")
                        .padding()
                }
                  
                Spacer()
                VStack {
                    
                    let total = self.price * (Double(input) ?? 0.00)
                    let budget = userDefaults.double(forKey: "budget")
                    let leftover = budget - total
                    Text("$\(leftover, specifier: "%.2f") available to buy \(self.ticker)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                    HStack {
                        Button (action: {
                            var budget = userDefaults.double(forKey: "budget")
                            self.action = "bought"
                            if Double(input) == nil {
                                self.valid = false
                                self.message = "Please enter a valid amount"
                                self.showError = true
                                return
                            }
                            if Double(input)! <= 0 {
                                self.valid = false
                                self.message = "Cannot buy less than 0 shares"
                                self.showError = true
                                return
                            }
                            
                            if let data = UserDefaults.standard.value(forKey:"portfolio") as? Data {
                                var stock = try? PropertyListDecoder().decode([Bought].self, from: data)
                                print("Retrieved items: \(stock)")
                                
                                
                            let buy = Bought(id: self.ticker, name: self.name, shares: Double(self.input)!)
                                let check = stock!.firstIndex(where: {$0.id == buy.id})
                                if check == nil { // doesn't exist in portfolio
                                if total <= budget {
                                    self.valid = true
                                    stock!.append(buy)
                                    print(stock)
                                    budget -= total
                                    userDefaults.set(budget, forKey: "budget")
                                    userDefaults.set(try? PropertyListEncoder().encode(stock), forKey: "portfolio")
                                }
                                else {
                                    self.valid = false
                                    self.message = "Not enough money to buy"
                                    self.showError = true
                                    return
                                }
                            }
                            else {
                                if total <= budget {
                                    self.valid = true
                                    stock![check!].shares += Double(self.input)!
                                    print(stock)
                                    budget -= total
                                    userDefaults.set(budget, forKey: "budget")
                                    userDefaults.set(try? PropertyListEncoder().encode(stock), forKey: "portfolio")
                                }
                                else {
                                    self.valid = false
                                    self.message = "Not enough money to buy"
                                    self.showError = true
                                    return
                                }
                            }
                        }
                        }){
                            Text("Buy")
                                .bold()
                                .padding(.horizontal, 70)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .cornerRadius(40)
                                
                        } .padding(.trailing, 8)
                        
                        Button (action: {
                            var budget = userDefaults.double(forKey: "budget")
                            self.action = "sold"
                            if Double(input) == nil {
                                self.valid = false
                                self.message = "Please enter a valid amount"
                                self.showError = true
                                return
                            }
                            if Double(input)! <= 0 {
                                self.valid = false
                                self.message = "Cannot sell less than 0 shares"
                                self.showError = true
                                return
                            }
                            
                            if let data = UserDefaults.standard.value(forKey:"portfolio") as? Data {
                                var stock = try? PropertyListDecoder().decode([Bought].self, from: data)
                                print("Retrieved items: \(stock)")
                                
                            let sell = Bought(id: self.ticker, name: self.name, shares: Double(self.input)!)
                            let check = stock!.firstIndex(where: {$0.id == sell.id})
                            let total = self.price * (Double(input) ?? 0.00)
                            
                            if check == nil || stock![check!].shares < Double(input)! { // doesn't exist in portfolio or # of shares less than input
                                self.valid = false
                                self.message = "Not enough shares to sell"
                                self.showError = true
                                return
                            }
                            else {
                                stock![check!].shares -= Double(self.input)!
                                self.valid = true
                                budget += total
                                userDefaults.set(budget, forKey: "budget")
                                if stock![check!].shares == 0 {
                                    stock!.remove(at: check!)
                                    userDefaults.set(try? PropertyListEncoder().encode(stock), forKey: "portfolio")
                                }
                                else {
                                    userDefaults.set(try? PropertyListEncoder().encode(stock), forKey: "portfolio")
                                }
                            }
                        }
                            
                        }){
                            Text("Sell")
                                .bold()
                                .padding(.horizontal, 70)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .cornerRadius(40)
                                
                        } .padding(.leading, 8)
                        
                    }
                }
            } .sheetToast(showError: $showError, message: $message)
            .padding(.bottom, 20)
            } .confirmToast(valid: $valid, showSheet: $showSheet, action: action, ticker: ticker, shares: (Double(input) ?? 0.00))
        }
    }

struct Confirm<Presenting>: View where Presenting: View{
    @Binding var valid: Bool
    @Binding var showSheet: Bool
    var action: String
    var ticker: String
    var shares: Double
    
    let presenting: () -> Presenting
    
    var body: some View {
        return GeometryReader { geometry in
        ZStack {
            self.presenting()
            VStack {
                Spacer()
                VStack {
                    Text("Congratulations!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    Text("You have successfully \(action) \(shares, specifier: "%.2f") shares of \(ticker)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
                VStack {
                    HStack {
                        Button (action: {
                            withAnimation {
                                self.showSheet = false
                                self.valid = false
                            }
                        }) {
                            Text("Done")
                                .bold()
                                .padding(.horizontal, 100)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .cornerRadius(40)
                        }
                        .padding()
                    }
                } .padding(.bottom, 20)
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
        .opacity(self.valid ? 1 : 0)
    } .animation(.easeInOut)
    }
}
}

extension View {
    func confirmToast(valid: Binding<Bool>, showSheet: Binding<Bool>, action: String, ticker: String, shares: Double) -> some View {
        Confirm(valid: valid, showSheet: showSheet, action: action, ticker: ticker, shares: shares, presenting: { self })
    }
}

struct SheetNotice<Presenting>: View where Presenting: View {
    @Binding var showError: Bool
    @Binding var message: String
    
    let presenting: () -> Presenting

    var body: some View {
        if self.showError {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                withAnimation {
                    self.showError = false
                }
            })
        }
        
        return GeometryReader { geometry in
            ZStack (alignment: .bottom){
              self.presenting()
                VStack (alignment: .center, spacing: 8) {
                    Text("\(message)")
                        .padding(.horizontal, 90)
                        .padding(.vertical, 20)
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                }
                .background(Color.gray)
                .cornerRadius(40)
                .opacity(self.showError ? 1 : 0)
            } .animation(.easeInOut)
        }
    }
}

extension View {
    func sheetToast(showError: Binding<Bool>, message: Binding<String>) -> some View {
            SheetNotice(showError: showError, message: message, presenting: { self })
        }
}


struct Chart: View {
    @State var title: String = "High Stocks"
    @State var error: Error? = nil
    var ticker: String
    
    let url = Bundle.main.url(forResource: "chart", withExtension: "html")!

    var body: some View {
        WebView(title: $title, url: url, ticker: ticker)
            .onLoadStatusChanged { loading, error in
                if loading {
                    print("Loading started")
                    self.title = "Loading…"
                    print(url)
                }
                else {
                    print("Done loading.")
                    if let error = error {
                        self.error = error
                        if self.title.isEmpty {
                            self.title = "Error"
                        }
                
                    }
                    else if self.title.isEmpty {
                        self.title = "Some Place"
                    }
                }
        }
            .frame(width: 380, height:400)
    }

}


func dateDiff(date: String) -> String {
    let fmt = ISO8601DateFormatter()
    let now = Date()
    let date = fmt.date(from: date)!

    let diffs = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
    
    if  diffs.day! > 0 {
        return String(diffs.day!) + " days ago"
    }
    else if diffs.minute! > 0 && diffs.hour! == 0 && diffs.day! == 0 {
        return String(diffs.minute!) + " minutes ago"
    }
    else if diffs.hour! > 0 && diffs.day! == 0 {
        return String(diffs.hour!) + " hours ago"
    }
    return "0"
}
