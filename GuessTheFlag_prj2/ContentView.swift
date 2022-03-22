//
//  ContentView.swift
//  GuessTheFlag_prj2
//
//  Created by Peter Fischer on 3/4/22.
//

import SwiftUI

struct FlagImage : View {
    
    var withName : String
    
    var body : some View {
        Image(withName)
            .renderingMode(.original)
            .clipShape((Capsule()))
            .shadow(radius: 5)
    }
}

struct LargeBlueText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundColor(.blue)
    }
}

extension View {
    func makeBigBlue() -> some View {
        modifier(LargeBlueText())
    }
}



struct ContentView: View {
    
    @State private var showingScore = false
    @State private var scoreTitle = ""
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var numGamesPlayed = 0
    @State private var numCorrect = 0
    
    @State private var alertString : String = ""
    @State private var answeredCorrectly = false
    @State private var selectedFlag : Int = 0
    
    @State private var rotationAmount = [0.0, 0.0, 0.0]
    @State private var opacity = [1.0, 1.0, 1.0]
    @State private var scale = [1.0, 1.0, 1.0]
    
        
    private let maxNumGames = 8
    
    
    var body: some View {

        return ZStack {

            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.03),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.03)
            ],center: .top, startRadius: 350, endRadius: 700)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                Text("Guess The Flag")
                    .makeBigBlue()
                
                VStack(spacing: 15) {

                    VStack {
                        Text("Tap The Flag Of:")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(withName: countries[number])
                            
                        }
                        .rotation3DEffect(.degrees(rotationAmount[number]), axis: (x: 0, y: 1, z:0))
                        .opacity(opacity[number])
                        .scaleEffect(scale[number])
                        

                    }
            
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                Spacer()
                Spacer()
                
                Text("Score \(numCorrect)/\(numGamesPlayed)")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Spacer()
            }.padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            
            Button("Continue") {
                askQuestion()
            }
        } message: {
            Text(buildAlertString())
        }
        
    }
    
    func flagTapped(_ number : Int) {
        numGamesPlayed = numGamesPlayed + 1
        selectedFlag = number
        
        withAnimation {
            rotationAmount[number] += 360.0
            for flag in 0..<3 {
                if flag != number {
                    opacity[flag] = 0.25
                    scale[flag] = 0.75
                }
            }
        }

        if ( number == correctAnswer) {
            scoreTitle = "Correct"
            numCorrect += 1
            answeredCorrectly = true
        } else {
            scoreTitle = "Incorrect"
            answeredCorrectly = false
        }
        
        showingScore = true
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        
        if numGamesPlayed == maxNumGames {
            numGamesPlayed = 0
            numCorrect = 0
        }
        
        for flag in 0..<3 {
            rotationAmount[flag] = 0.0
            withAnimation {
                opacity[flag] = 1.0
                scale[flag] = 1.0
            }
        }
        
    }
    
    func buildAlertString() -> String {
        
        let scoreString = "Your Score is \(numCorrect)/\(numGamesPlayed)"
        let closingQuestion = numGamesPlayed == maxNumGames ? "Play a new set of eight?" : "Next Question"
        var answered = ""
        var returnString = ""
        if answeredCorrectly == false {
            answered = "Sorry, you selected \(countries[selectedFlag])"
        }
        
        if answeredCorrectly {
            returnString = """
                \(scoreString)
                \(closingQuestion)
            """
        } else {
            returnString = """
                \(scoreString)
                \(answered)
                \(closingQuestion)
            """
        }
        
        return returnString
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ContentView()
        }
.previewInterfaceOrientation(.portrait)
    }
}
