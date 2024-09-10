//
//  ContentView.swift
//  BetterRest
//
//  Created by Adailton Lucas on 08/09/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUpTime = defaultWakeTime
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form {
                VStack(alignment: .leading, spacing: 10){
                    Text("Qual horário deseja acordar?")
                        .font(.headline)
                    DatePicker("Insira a data que deseja acordar:", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Quantas horas deseja dormir?")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) Horas dormidas", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Quantas xícaras de café você toma por dia?")
                        .font(.headline)
                    Stepper("\(coffeAmount.formatted()) xícara\(coffeAmount > 1 ? "s" : "")", value: $coffeAmount, in: 1...20)
                }

            }
            .navigationTitle("BetterRest")
            .toolbar(){
                Button("Calcular", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert){
                Button("Ok"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (timeComponents.hour ?? 0) * 60 * 60
            let minute = (timeComponents.minute ?? 0) * 60
            
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleeptime = wakeUpTime - prediction.actualSleep
            
            alertTitle = "Hora ideal para dormir..."
            alertMessage = sleeptime.formatted(date: .omitted, time: .shortened)
        } catch{
            alertTitle = "Erro!"
            alertMessage = "Erro ao processar os dados."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
