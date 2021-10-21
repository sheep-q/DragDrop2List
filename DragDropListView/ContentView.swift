import SwiftUI

struct Fruit: Identifiable {
    let id = UUID()
    let name: String
    let image: String
}

struct ContentView: View {
    @State var selection: Set<UUID> = []
    
    @State private var fruitsTop = [
        Fruit(name: "Apple", image: "apple"),
        Fruit(name: "Banana", image: "banana"),
        Fruit(name: "Grapes", image: "grapes"),
        Fruit(name: "Peach", image: "peach"),
        Fruit(name: "Kiwi", image: "kiwi"),
    ]

    @State private var fruitsBottom = [
        Fruit(name: "Peach", image: "peach"),
        Fruit(name: "Kiwi", image: "kiwi"),
    ]
    
    var body: some View {

        HStack {

                List(selection: $selection) {
                    ForEach(fruitsTop) { fruit in
                        HStack {
                            Image(fruit.image)
                                .resizable()
                                .frame(width: 30, height: 30)

                            Text(fruit.name)
                        }
                        .onDrag {
                            let provider = NSItemProvider(object: UIImage(named: fruit.image) ?? UIImage())
                            provider.suggestedName = fruit.name
                            return provider
                        }
                    }.onInsert(of: ["public.image"]) { self.insertFruit(position: $0, itemProviders: $1, top: true) }
                }
            
                List(selection: $selection) {
                    ForEach(fruitsBottom) { fruit in
                        HStack {
                            Image(fruit.image)
                                .resizable()
                                .frame(width: 30, height: 30)

                            Text(fruit.name)
                        }
                        .onDrag {
                            let provider = NSItemProvider(object: UIImage(named: fruit.image) ?? UIImage())
                            provider.suggestedName = fruit.name
                            return provider
                        }

                    }.onInsert(of: ["public.image"]) { self.insertFruit(position: $0, itemProviders: $1, top: false) }
                }
        }
    }
    
    func insertFruit(position: Int, itemProviders: [NSItemProvider], top: Bool) {
        for item in itemProviders.reversed() {

            item.loadObject(ofClass: UIImage.self) { image, error in
                if let _ = image as? UIImage {

                    DispatchQueue.main.async {
                        let f = Fruit(name: item.suggestedName ?? "Unknown",
                                      image: item.suggestedName?.lowercased() ?? "unknown")
                        
                        if top {
                            self.fruitsTop.insert(f, at: position)
                        } else {
                            self.fruitsBottom.insert(f, at: position)
                        }
                    }
                }
            }
        }
    }
}
