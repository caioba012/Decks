//
//  ContentView.swift
//  Decks
//
//  Created by CAIO CHIQUETO on 01/12/23.
//

import SwiftUI

struct ContentView: View {
    @State private var cards: [CardInfo] = []
    
    var copas = Image(systemName: "suit.heart.fill")
    var trevo = Image(systemName: "suit.club.fill")
    var ouros = Image(systemName: "suit.diamond.fill")
    var espadas = Image(systemName: "suit.spade.fill")

    var body: some View {
        VStack {
            Text("Bem vindo ao sortador de cartas!")
                .font(.title).bold()
                .multilineTextAlignment(.center)
            Text("\(trevo)") .foregroundColor(.black) .font(.system(size: 20, weight: .bold, design: .rounded))
            +
            Text("\(copas)") .foregroundColor(.red) .font(.system(size: 20, weight: .bold, design: .rounded))
            +
            Text("\(espadas)") .foregroundColor(.black) .font(.system(size: 20, weight: .bold, design: .rounded))
            +
            Text("\(ouros)") .foregroundColor(.red) .font(.system(size: 20, weight: .bold, design: .rounded))

            HStack {
                ForEach(cards) { card in
                    VStack {
                        AsyncImage(url: URL(string: card.image), content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 150)
                        }, placeholder: {
                            Text("Loading...")
                        })

                        Text("\(card.value) de \(card.suit)")
                            .foregroundColor(.primary)
                            .font(.caption)
                    }
                }
            }

            Button("Sortear Cartas") {
                generateCards()
            }
            .buttonStyle(CustomButtonStyle())
        }
        .padding()
    }

    private func generateCards() {
        guard let url = URL(string: "https://www.deckofcardsapi.com/api/deck/qoak2o8losi4/draw/?count=3") else {
            fatalError("Invalid URL")
        }

        let urlRequest = URLRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Error:", error)
                return
            }

            guard let data = data else {
                print("Data is nil")
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Card.self, from: data)

                if result.success {
                    DispatchQueue.main.async {
                        self.cards = result.cards
                    }
                } else {
                    print("Request unsuccessful")
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }.resume()
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardInfo: Identifiable, Decodable {
    var id: String { code }
    var code: String
    var image: String
    var value: String
    var suit: String
}

struct Card: Decodable {
    var success: Bool
    var cards: [CardInfo]
}

