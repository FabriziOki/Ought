pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Current conditions
    property real tempC: 0
    property real feelsLikeC: 0
    property int humidity: 0
    property real uvIndex: 0
    property real windspeed: 0
    property int weatherCode: 0

    // Today's hourly rain probability (24 values)
    property var hourlyRainProb: []

    // 3-day forecast
    property var dailyMax: []
    property var dailyMin: []
    property var dailyCode: []
    property var dailyRainMax: []
    property var dailyUvMax: []
    property var dailySunrise: []
    property var dailySunset: []

    // Human-readable description from WMO weather code
    function descFromCode(code) {
        if (code === 0)            return "stock_weather-sunny.svg"         // Clear      
        if (code <= 2)             return "stock_weather-few-clouds.svg" // Partly Cloud     
        if (code === 3)            return "stock_weather-cloudy.svg"      // Overcast
        if (code <= 48)            return "stock_weather-fog.svg"         // Foggy
        if (code <= 57)            return "stock_weather-showers.svg"       // Drizzle 
        if (code <= 67)            return "weather-showers-scattered.svg"          // Rain
        if (code <= 77)            return "stock_weather-snow.svg"          // Snow
        if (code <= 82)            return "weather-freezing-rain.svg"       // Showers     
        if (code <= 99)            return "stock_weather-storm.svg"  // Thunderstorm 
        return "weather-none-available.svg"
    }

    Component.onCompleted: weather.running = true

    Process {
        id: weather
        command: [
            "curl", "-sL",
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=25.05&longitude=121.53" +
            "&current=temperature_2m,apparent_temperature,relativehumidity_2m,weathercode,uv_index,windspeed_10m" +
            "&hourly=precipitation_probability" +
            "&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max,sunrise,sunset" +
            "&timezone=Asia%2FTaipei" +
            "&forecast_days=3"
        ]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => weather.buffer += data + "\n"
        }

        onExited: {
            if (weather.buffer.trim() === "") return

            try {
                const w = JSON.parse(weather.buffer)

                // Current conditions
                const c = w.current
                root.tempC      = c.temperature_2m
                root.feelsLikeC = c.apparent_temperature
                root.humidity   = c.relativehumidity_2m
                root.uvIndex    = c.uv_index
                root.windspeed  = c.windspeed_10m
                root.weatherCode = c.weathercode

                // Hourly rain probability — slice only today's 24 hours
                root.hourlyRainProb = w.hourly.precipitation_probability.slice(0, 24)

                // 3-day daily forecast
                root.dailyMax     = w.daily.temperature_2m_max
                root.dailyMin     = w.daily.temperature_2m_min
                root.dailyCode    = w.daily.weathercode
                root.dailyRainMax = w.daily.precipitation_probability_max
                root.dailyUvMax   = w.daily.uv_index_max
                root.dailySunrise = w.daily.sunrise
                root.dailySunset  = w.daily.sunset

            } catch (e) {
                console.error("Weather parse error:", e)
            }

            weather.buffer = ""
        }
    }

    Timer {
        interval: 2700000  // 45 minutes
        running: true
        repeat: true
        onTriggered: weather.running = true
    }
}
