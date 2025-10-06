//
//  SettingsViewType.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

enum SettingsType:String,CaseIterable,Identifiable{
    case icon = "菜单栏显示"
    case about = "关于"
    
    var id:String {self.rawValue}
    
    @ViewBuilder
    var view:some View {
        switch self {
        case .icon:
            SettingsIconView()
        case .about:
            SettingsAboutView()
        }
    }
}
