//
//  HomeView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ZStack {
                    
                    VStack {
                        Spacer()
                        
                        Text("Home")
                            .font(.custom(
                                "IslandMoments-Regular",
                                size: min(geo.size.width * 0.3, 220) // cap max font size
                            ))
                            .opacity(0.9)
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    WaterShipView()
                        .offset(y: -geo.size.height * 0.078) // slightly deeper offset
                    
                    IconView()
                        .padding(.horizontal, 15)
                    
                    VStack {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        VStack {
                            ZStack {
                                Rectangle()
                                    .opacity(0.8)
                                    .colorInvert()
                                    .cornerRadius(90)
                                    .opacity(0.3)
                                    .frame(width: min(geo.size.width * 0.5, 2000),
                                           height: min(geo.size.width * 0.1, 2000))
                                
                                Text("Recent Catches")
                                    .font(.system(size: geo.size.width * 0.06))
                                    .opacity(0.8)
                                    .bold()
                            }
                            
                            HStack {
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                
                                ZStack {
                                    Rectangle()
                                        .opacity(0.8)
                                        .colorInvert()
                                        .cornerRadius(30)
                                        .opacity(0.3)
                                        .frame(width: min(geo.size.width * 0.845, 2000),
                                               height: min(geo.size.width * 0.495, 2000))
                                    
                                    Image("PictureFish")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(20)
                                        .frame(width: min(geo.size.width * 0.8, 2000),
                                               height: min(geo.size.width * 0.5, 2000))
                                }
                                
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                            }
                        }
                        .padding(.bottom, geo.size.height * 0.08)
                    }
                }
            }
            .padding(.bottom, -geo.size.height * 2)
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: geo.size.height * 0.112)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    HomeView().environmentObject(TabRouter())
}
