//
//  SocialView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/17/26.
//

import SwiftUI
struct SocialView: View {
    var body: some View {
        ZStack {
            WaterView()
                .offset(y: -190)
            
            IconView()
            
            VStack(spacing: 40) {
                
                Text("Social")
                    .font(.custom("IslandMoments-Regular",
                                  size: UIScreen.main.bounds.width * 0.22))
                    .opacity(0.9)
                    .foregroundStyle(.blue)
                    .padding(.top, 60).padding(.bottom, 10)
                
                VStack(spacing: 30) {
                    
                    Button {
                        
                        
                    }
                    
                    label: {
                   
                        ZStack{
                       
                            socialCard()
                            
                            HStack{
                            Image("friends").resizable()  .frame(
                                width: min(UIScreen.main.bounds.width * 0.15, 180),
                                height: min(UIScreen.main.bounds.width * 0.15, 180)
                            ).colorMultiply(.black)
                            
                            Text("Friends").bold().foregroundStyle(.black).padding(.horizontal)
                            Spacer()
                        }.padding(.horizontal)
                        
                       
                       
                        }
                      
                    }
                    Button{
                        
                    }
                    
                    label: {
                   
                        ZStack{
                       
                            socialCard()
                            
                            HStack{
                            Image("Trophy").resizable()  .frame(
                                width: min(UIScreen.main.bounds.width * 0.15, 180),
                                height: min(UIScreen.main.bounds.width * 0.15, 180)
                            ).opacity(0.9)
                            Text("Leaderboard").bold().foregroundStyle(.black).padding(.horizontal)
                            Spacer()
                        }.padding(.horizontal)
                        
                       
                        
                    
                          
                        }
                        
                    }
                    
                    Button {
                        
                    }
                    
                    label: {
                    
                        ZStack {
                      
                            socialCard()

                        HStack{
                            Image("Shop").resizable()  .frame(
                                width: min(UIScreen.main.bounds.width * 0.15, 180),
                                height: min(UIScreen.main.bounds.width * 0.15, 180)
                            )
                            Text("Shop").bold().foregroundStyle(.black).padding(.horizontal)
                            Spacer()
                        }.padding(.horizontal)
                        
                     
                        }
                        
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: 83)
            }.edgesIgnoringSafeArea(.bottom)
        )
    }
    
    private func socialCard() -> some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(Color.white.opacity(0.6))
            .frame(height: UIScreen.main.bounds.width * 0.35)
            .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

#Preview {
    SocialView()
}
