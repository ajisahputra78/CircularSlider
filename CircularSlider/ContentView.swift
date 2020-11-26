//
//  ContentView.swift
//  CircularSlider
//
//  Created by Aji_sahputra on 24/11/20.
//

import SwiftUI

func colorMix (percent  : Int) -> Color {
  let p                          = Double(percent)
  let tempB                      = (100.0 - p) / 100
  let b                 : Double = tempB < 0 ? 0 : tempB
  let tempR                      = 1 + (p - 100) / 100.0
  let r                 : Double = tempR < 0 ? 0 : tempR
  return Color.init(red : r, green : 0, blue : b)
}

struct ContentView                              : View {
  
  @State var temp                               : CGFloat = 0
  
    var body                                    : some View {
      ZStack {
        Rectangle()
          .fill(colorMix(percent                : Int(temp)))
          .opacity(0.7)
          .edgesIgnoringSafeArea(.all)
        
        TemperatureControlView(temperatureView  : $temp)
      }
    }
}

struct Config {
  let minimumValue : CGFloat
  let maximumValue : CGFloat
  let totalValue   : CGFloat
  let knobRadius   : CGFloat
  let radius       : CGFloat
}

struct TemperatureControlView : View {
  @Binding var temperatureView : CGFloat
  @State var angleValue : CGFloat = 0.0
  let config = Config( minimumValue : 0.0,
                       maximumValue : 100.0,
                       totalValue  : 100.0,
                       knobRadius   : 15.0,
                       radius       : 125.0)
  var body: some View {
    ZStack {
      Circle()
        .frame(width: config.radius * 2, height: config.radius * 2)
        .scaleEffect(1.2)
      
      Circle()
        .stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash:[3, 23.18]))
        .frame(width: config.radius * 2, height: config.radius * 2)
      
      Circle()
        .trim(from: 0.0, to: temperatureView/config.totalValue)
        .stroke(colorMix(percent: Int(temperatureView)), lineWidth: 4)
        .frame(width: config.radius * 2, height: config.radius * 2)
        .rotationEffect(.degrees(-90))
      
      Circle()
        .fill(colorMix(percent: Int(temperatureView)))
        .frame(width: config.knobRadius * 2, height: config.knobRadius * 2)
        .padding(10)
        .offset(y: -config.radius)
        .rotationEffect(Angle.degrees(Double(angleValue)))
        .gesture(DragGesture(minimumDistance: 0.0)
                  .onChanged({value in
                    change(location: value.location)
                  }))
      
      Text("\(String.init(format: "%.0f", temperatureView)) ")
        .font(.system(size: 60))
        .foregroundColor(.white)
    }
  }
  
  private func change(location: CGPoint) {
    
    // membuat vektor dari titik lokasi
    let vector = CGVector(dx: location.x, dy: location.y)
    
    //mendapatkan angel dalam radian perlu mengurangi radius knob dan padding dari dy dan dx
    let angel = atan2(vector.dy - (config.knobRadius + 10), vector.dx - (config.knobRadius + 10)) + .pi/2.0
    
    // ubah rentang angel dari (-pi ke pi) hingga (0 hingga 2pi)
    let fixedAngel = angel < 0.0 ? angel + 2.0 * .pi : angel
    
    // mengubah nilai angel menjadi nilai suhu
    let value = fixedAngel / (2.0 * .pi) * config.totalValue
    
    if value >= config.minimumValue && value <= config.maximumValue {
      temperatureView = value
      angleValue = fixedAngel * 180 / .pi
    }
  }
}

struct ContentView_Previews : PreviewProvider {
    static var previews     : some View {
        ContentView()
    }
}
