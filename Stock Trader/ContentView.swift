//
//  ContentView.swift
//  Stock Trader
//
//  Created by Daisy Duong on 11/10/20.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var stockVM = StockViewModel()
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @AppStorage("favorites") var favorites = Favorites()
    @State var isAdded: Bool = false
    @State var call: String = ""
    @State var portfolio: [Bought] = []
    @State var currentValue: Double = 0.00
    
    let userDefaults = UserDefaults.standard
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    static let dateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()

        var today = Date()
    
    var body: some View {
        ZStack {
        //ProgressView("Fetching Data...")
            NavigationView {
                List {
                        // Filtered list of names
                        if searchBar.text.isEmpty == false {
                            ForEach(stockVM.choices) { i in
                                NavigationLink(destination: DetailView(ticker: i.ticker, name: i.name, isAdded: $isAdded)) {
                                    VStack (alignment: .leading){
                                        Text(i.ticker)
                                            .bold()
                                        Text(i.name)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        if searchBar.text.isEmpty {
                            Text("\(today, formatter: Self.dateFormat)")
                                .foregroundColor(.secondary)
                                .bold()
                                .font(.title)
                            
                            // Portfolio section
                            Section(header: Text("Portfolio")) {
                                VStack (alignment: .leading){
                                    Text("Net Worth")
                                        .font(.title)
                                        .onAppear {
                                            self.currentValue = 0.00
                                        }
                                    let uninvested = userDefaults.double(forKey: "budget")
                                    Text("\(uninvested + self.currentValue, specifier: "%.2f")")
                                            .bold()
                                            .font(.title)
                                    
                                }
                                    ForEach(portfolio) { item in
                                        NavigationLink(destination: DetailView(ticker: item.id, name: item.name, isAdded: $isAdded)) {
                                            HStack {
                                                VStack (alignment: .leading){
                                                    Text(item.id)
                                                        .bold()
                                                    Text("\(item.shares, specifier: "%.2f") shares")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                VStack (alignment: .trailing){
                                                    ForEach(stockVM.prices) { price in
                                                        if price.id == item.id {
                                                            let change = price.last - price.prevClose
                                                            
                                                            Text("\(price.last, specifier: "%.2f")")
                                                                .bold()
                                                                .font(.subheadline)
                                                                .onAppear {
                                                                    self.currentValue += (price.last * item.shares)
                                                                }
                                                            HStack {
                                                                if change == 0 {
                                                                    Text("\(change, specifier: "%.2f")")
                                                                        .font(.subheadline)
                                                                        .foregroundColor(.secondary)
                                                                }
                                                                if change < 0 {
                                                                    Image(systemName: "arrow.down.right")
                                                                        .foregroundColor(.red)
                                                                    Text("\(change, specifier: "%.2f")")
                                                                        .font(.subheadline)
                                                                        .foregroundColor(.red)
                                                                }
                                                                if change > 0 {
                                                                    Image(systemName: "arrow.up.right")
                                                                        .foregroundColor(.green)
                                                                    Text("\(change, specifier: "%.2f")")
                                                                        .font(.subheadline)
                                                                        .foregroundColor(.green)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            
                                        }
                                    }.onAppear {
                                        self.call += ",\(item.id)"
                                        
                                    }
                                }
                                 .onMove(perform: movePort)
                            } .onAppear {
                                if userDefaults.double(forKey: "budget") == 0.00 {
                                    userDefaults.set(20000.00, forKey: "budget")
                                }
                                stockVM.fetchPrice(ticker: self.call)
                                
                                if let data = UserDefaults.standard.value(forKey:"portfolio") as? Data {
                                    var stock = try? PropertyListDecoder().decode([Bought].self, from: data)
                                    self.portfolio = stock!
                                }
                            }
                            //Favorites section
                            Section(header: Text("Favorites")) {
                                favorite
                                    HStack {
                                        Spacer()
                                        Link("Powered by Tiingo", destination: URL(string: "https://www.tiingo.com")!)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                            }
                        
                        }
                    }
                    .navigationBarTitle(Text("Stocks"))
                    .add(self.searchBar)
                    .toolbar {
                        ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                            EditButton()
                        }
                    }
        } .onChange(of: searchBar.text, perform: { value in
            if (searchBar.text.count > 2) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.stockVM.fetchAuto(ticker: searchBar.text)
                })
            }
        })
            if stockVM.priceLoad == false {
                ProgressView("Fetching Data...")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
            }
        } .onReceive(timer) { timer in
            stockVM.fetchPrice(ticker: self.call)
            print("Updated home \(timer)")
        }
    }
    func deleteItems(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
    }
    func moveFav(from source: IndexSet, to destination: Int) {
        favorites.move(fromOffsets: source, toOffset: destination)
    }
    func movePort(from source: IndexSet, to destination: Int) {
            portfolio.move(fromOffsets: source, toOffset: destination)
            print(portfolio)
            userDefaults.set(try? PropertyListEncoder().encode(portfolio), forKey: "portfolio")
    }
}

extension ContentView {
    var favorite: some View {
        ForEach(favorites) { id in
            NavigationLink(destination: DetailView(ticker: id.id, name: id.name, isAdded: $isAdded)) {
                if let data = UserDefaults.standard.value(forKey:"portfolio") as? Data {
                    let stock = try? PropertyListDecoder().decode([Bought].self, from: data)
                HStack {
                    VStack (alignment: .leading){
                        Text(id.id)
                            .bold()
                        let check = stock!.firstIndex(where: {$0.id == id.id})
                        if check == nil {
                            Text(id.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        else {
                            Text("\(stock![check!].shares, specifier: "%.2f") shares")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    VStack (alignment: .trailing){
                        ForEach(stockVM.prices) { price in
                            if price.id == id.id {
                                let change = price.last - price.prevClose
                                Text("\(price.last, specifier: "%.2f")")
                                    .bold()
                                    .font(.subheadline)
                                HStack {
                                    if change == 0 {
                                        Text("\(change, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    if change < 0 {
                                        Image(systemName: "arrow.down.right")
                                            .foregroundColor(.red)
                                        Text("\(change, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                    if change > 0 {
                                        Image(systemName: "arrow.up.right")
                                            .foregroundColor(.green)
                                        Text("\(change, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            } .onAppear {
                self.call += ",\(id.id)"
            }
        }
        .onDelete(perform: deleteItems)
        .onMove(perform: moveFav)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //ContentView(isAdded: false)
        }
    }
}


