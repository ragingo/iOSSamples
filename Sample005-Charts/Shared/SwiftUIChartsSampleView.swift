//
//  SwiftUIChartsSampleView.swift
//  Sample005-Charts
//
//  Created by ragingo on 2023/06/17.
//

import Charts
import SwiftUI

struct SwiftUIChartsSampleView: View {
    @State private var weatherData: WeatherData?
    @State private var selectedHour: Date?
    @State private var balloonXPosition: CGFloat?

    var body: some View {
        Chart {
            if let weatherData {
                ForEach(weatherData.hourly, id: \.date) { hour in
                    LineMark(
                        x: .value("Hour", hour.date),
                        y: .value("Temperature", hour.temperature)
                    )
                    .symbol {
                        if hour.temperature > 30 {
                            flameIcon
                                .frame(width: 16)
                                .offset(y: -16)
                        }
                    }
                }

                let average = weatherData.hourly.map(\.temperature).reduce(0.0, +) / Double(weatherData.hourly.count)

                RuleMark(y: .value("Average", average))
                    .lineStyle(.init(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.green)
                    .annotation(alignment: .leading) {
                        Text("AVG: \((average * 10).rounded(.down) / 10.0, specifier: "%.1f")℃")
                    }
                RuleMark(y: .value("Max", weatherData.daily.maxTemperature))
                    .lineStyle(.init(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.red)
                    .annotation(alignment: .leading) {
                        Text("MAX: \(weatherData.daily.maxTemperature, specifier: "%.1f")℃")
                    }
                RuleMark(y: .value("Min", weatherData.daily.minTemperature))
                    .lineStyle(.init(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.blue)
                    .annotation(alignment: .leading) {
                        Text("MIN: \(weatherData.daily.minTemperature, specifier: "%.1f")℃")
                    }
                RuleMark(x: .value("Sunrise", weatherData.daily.sunrise))
                    .lineStyle(.init(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.orange)
                    .annotation {
                        sunriseIcon
                            .frame(width: 20)
                    }
                RuleMark(x: .value("Sunset", weatherData.daily.sunset))
                    .lineStyle(.init(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.orange)
                    .annotation {
                        sunsetIcon
                            .frame(width: 20)
                    }
            }
        }
        .chartLegend(.visible)
        .chartXAxis(.visible)
        .chartYAxis(.visible)
        .chartXAxis {
            AxisMarks(
                preset: .aligned,
                values: .automatic(desiredCount: weatherData?.hourly.count ?? 0)
            ) { value in
                if let date = value.as(Date.self) {
                    let xAxisHour = Calendar.current.component(.hour, from: date)
                    let currentHour = Calendar.current.component(.hour, from: .now)
                    let sameHour = xAxisHour == currentHour
                    AxisValueLabel()
                        .foregroundStyle(sameHour ? .primary : .secondary)
                        .font(.system(size: 12, weight: sameHour ? .bold : .regular))
                }
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisGridLine()
                    .foregroundStyle(.gray)
                AxisValueLabel()
            }
        }
        .chartOverlay { chartProxy in
            GeometryReader { _ in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(dragGesture(chartProxy: chartProxy))
            }
        }
        .onAppear {
            weatherData = fetchWeatherData()
        }
        .overlay(alignment: .bottom) {
            let temperature = weatherData?.hourly.first(where: { $0.date == selectedHour })?.temperature

            GeometryReader { geo in
                if let balloonXPosition, let temperature {
                    Balloon {
                        Text("\(Int(temperature))℃")
                            .foregroundStyle(.black)
                    }
                    .frame(maxHeight: geo.size.height)
                    .position(x: balloonXPosition, y: geo.size.height / 2)
                }
            }
        }
        .padding(50)
    }

    private func dragGesture(chartProxy: ChartProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let xValue = chartProxy.value(atX: value.location.x, as: Date.self) else {
                    selectedHour = nil
                    balloonXPosition = nil
                    return
                }

                // 前後 30m は hour を切り替えない
                let minute = Calendar.current.dateComponents([.minute], from: xValue).minute ?? 0
                let addindHour = minute > 30 ? 1 : 0

                // X軸の余計な情報を捨てる
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: xValue)
                guard let date = Calendar.current.date(from: components) else {
                    selectedHour = nil
                    balloonXPosition = nil
                    return
                }

                selectedHour = Calendar.current.date(byAdding: .hour, value: addindHour, to: date)
                balloonXPosition = value.location.x
            }
            .onEnded { _ in
                selectedHour = nil
                balloonXPosition = nil
            }
    }

    private var flameIcon: some View {
        Image(systemName: "flame.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.red)
    }

    private var sunriseIcon: some View {
        Image(systemName: "sunrise")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.orange)
    }

    private var sunsetIcon: some View {
        Image(systemName: "sunset")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.blue)
    }
}

private struct Balloon<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            content()
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                }
            Rectangle()
                .frame(width: 1)
                .frame(maxHeight: .infinity)
        }
    }
}

private func fetchWeatherData() -> WeatherData? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
        guard let data = weatherDataJson.data(using: .utf8) else {
            return nil
        }
        let weatherData = try decoder.decode(WeatherData.self, from: data)
        return weatherData
    } catch {
        print(error)
        return nil
    }
}

private let weatherDataJson = """
{
  "latitude": 35.658584,
  "londitude": 139.7454316,
  "daily": {
    "maxTemperature": 34,
    "minTemperature": 10,
    "sunrise": "2023-06-17T04:00:00+09:00",
    "sunset":  "2023-06-17T18:00:00+09:00"
  },
  "hourly": [
    { "date": "2023-06-17T00:00:00+09:00", "temperature": 10.0 },
    { "date": "2023-06-17T01:00:00+09:00", "temperature": 11.0 },
    { "date": "2023-06-17T02:00:00+09:00", "temperature": 12.0 },
    { "date": "2023-06-17T03:00:00+09:00", "temperature": 13.0 },
    { "date": "2023-06-17T04:00:00+09:00", "temperature": 14.0 },
    { "date": "2023-06-17T05:00:00+09:00", "temperature": 15.0 },
    { "date": "2023-06-17T06:00:00+09:00", "temperature": 20.0 },
    { "date": "2023-06-17T07:00:00+09:00", "temperature": 22.0 },
    { "date": "2023-06-17T08:00:00+09:00", "temperature": 24.0 },
    { "date": "2023-06-17T09:00:00+09:00", "temperature": 26.0 },
    { "date": "2023-06-17T10:00:00+09:00", "temperature": 28.0 },
    { "date": "2023-06-17T11:00:00+09:00", "temperature": 30.0 },
    { "date": "2023-06-17T12:00:00+09:00", "temperature": 32.0 },
    { "date": "2023-06-17T13:00:00+09:00", "temperature": 34.0 },
    { "date": "2023-06-17T14:00:00+09:00", "temperature": 34.0 },
    { "date": "2023-06-17T15:00:00+09:00", "temperature": 34.0 },
    { "date": "2023-06-17T16:00:00+09:00", "temperature": 32.0 },
    { "date": "2023-06-17T17:00:00+09:00", "temperature": 30.0 },
    { "date": "2023-06-17T18:00:00+09:00", "temperature": 25.0 },
    { "date": "2023-06-17T19:00:00+09:00", "temperature": 20.0 },
    { "date": "2023-06-17T20:00:00+09:00", "temperature": 18.0 },
    { "date": "2023-06-17T21:00:00+09:00", "temperature": 16.0 },
    { "date": "2023-06-17T22:00:00+09:00", "temperature": 14.0 },
    { "date": "2023-06-17T23:00:00+09:00", "temperature": 12.0 }
  ]
}
"""

private struct WeatherData: Decodable {
    let latitude: Double
    let londitude: Double
    let daily: DailyWeather
    let hourly: [HourlyWeather]
}

private struct DailyWeather: Decodable {
    let maxTemperature: Double
    let minTemperature: Double
    let sunrise: Date
    let sunset: Date
}

private struct HourlyWeather: Decodable {
    let date: Date
    let temperature: Double
}

struct SwiftUIChartsSampleView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIChartsSampleView()
    }
}
