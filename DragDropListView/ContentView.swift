import SwiftUI

struct Fruit: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    var side: Int
}

struct ContentView: View {
    @State var selection: Set<UUID> = []
    
    @State private var rightFruit = [
        Fruit(name: "fruit 1", image: "fruit 1", side: 1),
        Fruit(name: "fruit 2", image: "fruit 2", side: 1),
        Fruit(name: "fruit 3", image: "fruit 3", side: 1),
        Fruit(name: "fruit 4", image: "fruit 4", side: 1),
        Fruit(name: "fruit 5", image: "fruit 5", side: 1),
    ]
    
    @State private var leftFruit = [
        Fruit(name: "fruit -1", image: "fruit -1", side: -1),
        Fruit(name: "fruit -2", image: "fruit -2", side: -1),
        Fruit(name: "fruit -3", image: "fruit -3", side: -1)
    ]
    
    @State var side: Int = 0
    @State var indexth: Int?
    
    var body: some View {
        
        HStack {
            
            List(selection: $selection) {
                ForEach(leftFruit) { fruit in
                    HStack {
                        Image(fruit.image)
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(fruit.name)
                    }
                    .onDrag {
                        let provider = NSItemProvider(object: UIImage(named: fruit.image) ?? UIImage())
                        provider.suggestedName = fruit.name
                        side = fruit.side
                        indexth = leftFruit.firstIndex(where: { $0.name == fruit.name })
                        return provider
                    }
                }.onInsert(of: ["public.image"]) {
                    self.insertFruit(position: $0, itemProviders: $1, left: true)
                }
            }
            
            List(selection: $selection) {
                ForEach(rightFruit) { fruit in
                    HStack {
                        Image(fruit.image)
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        Text(fruit.name)
                    }
                    .onDrag {
                        let provider = NSItemProvider(object: UIImage(named: fruit.image) ?? UIImage())
                        provider.suggestedName = fruit.name
                        indexth = rightFruit.firstIndex { $0.name == fruit.name } ?? nil
                        side = fruit.side
                        return provider
                    }
                }.onInsert(of: ["public.image"]) {
                    self.insertFruit(position: $0, itemProviders: $1, left: false)
                }
            }
        }
    }
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)

        return arr
    }
    
    func insertFruit(position: Int, itemProviders: [NSItemProvider], left: Bool) {
        for item in itemProviders.reversed() {
            
            item.loadObject(ofClass: UIImage.self) { image, error in
                if let _ = image as? UIImage {
                    
                    DispatchQueue.main.async {
                        let f = Fruit(name: item.suggestedName ?? "Unknown",
                                      image: item.suggestedName?.lowercased() ?? "unknown",
                                      side: side)
                        if left {
                            if f.side == -1 {
                                guard let indexth = indexth else {
                                    return
                                }
                                leftFruit = rearrange(array: leftFruit, fromIndex: indexth, toIndex: position)
                            } else {
                                leftFruit.insert(f, at: position)
                                leftFruit[position].side = -1
                            }
                        } else {
                            if f.side == 1 {
                                guard let indexth = indexth else {
                                    return
                                }
                                rightFruit = rearrange(array: rightFruit, fromIndex: indexth, toIndex: position)
                            } else {
                                rightFruit.insert(f, at: position)
                                rightFruit[position].side = 1
                            }
                        }
                    }
                }
            }
        }
    }
}
