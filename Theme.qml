pragma Singleton

import QtQuick
import Quickshell

Singleton {
  
  // 1. We type 'get' as our new custom component (GruvboxThemeSettings) instead of a generic 'Item'
  property GruvboxThemeSettings get: GruvboxThemeSettings {
    
    // Assign all your values here just like before!
    barBgColor: "transparent"  
    barBorderColor: "c0504945"  
    barBorderWidth: 0  

    buttonBorderColor: "#504238"  
    buttonBorderColorIN: "transparent"  
    buttonBorderShadow: false

    onTop: true

    iconColor: "orange"
    iconPressedColor: "orange"

    popupBgColor: "#d01b1814"
    popupBorderColor: "#504238"    
    popupItemBgOnColor: "#a0262321"
    popupBorderSize: 0
    popupItemHeight: 45

    progressBarBg: "#504238"
    
    barGradient: Gradient {
      GradientStop { position: 0.0; color: "#d01b1814" }  
    }
    
    buttonInactiveGradientV: Gradient {
      GradientStop { position: 0.0; color: "transparent" }
      GradientStop { position: 0.8; color: "transparent" }  
    }
    
    buttonInactiveGradientH: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: "transparent" }
    }
    
    buttonActiveGradient: Gradient {
      GradientStop { position: 0.0; color: "#504238" }  
    }
  }

  // 2. THE BLUEPRINT: This explicitly tells qmllint that these properties legally exist
  component GruvboxThemeSettings: Item {
    property string barBgColor
    property string barBorderColor
    property int barBorderWidth
    property string buttonBorderColor
    property string buttonBorderColorIN
    property bool buttonBorderShadow
    property bool onTop
    property string iconColor
    property string iconPressedColor
    property string popupBgColor
    property string popupBorderColor
    property string popupItemBgOnColor
    property int popupBorderSize
    property int popupItemHeight
    property string progressBarBg
    property Gradient barGradient
    property Gradient buttonInactiveGradientV
    property Gradient buttonInactiveGradientH
    property Gradient buttonActiveGradient
  }
}
