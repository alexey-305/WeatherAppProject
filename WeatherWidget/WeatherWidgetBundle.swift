//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Алексей Кузнецов on 30.06.2026.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        WeatherWidgetControl()
        WeatherWidgetLiveActivity()
    }
}
