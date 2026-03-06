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
      
            
            IconView()
            
            VStack(spacing: 40) {
                
                Text("Social")
                    .font(.custom("AkayaTelivigala-regular",
                                  size: UIScreen.main.bounds.width * 0.22))
                    .opacity(0.8)
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
                    NavigationLink(
                        destination: LeaderboardView()
                    ) {
                        ZStack {
                            socialCard()
                            
                            HStack {
                                Image("Trophy")
                                    .resizable()
                                    .frame(
                                        width: min(UIScreen.main.bounds.width * 0.15, 180),
                                        height: min(UIScreen.main.bounds.width * 0.15, 180)
                                    )
                                    .opacity(0.9)
                                
                                Text("Leaderboard")
                                    .bold()
                                    .foregroundStyle(.black)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
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
        }.background(Color.blue.opacity(0.01))
       
    }
    
    private func socialCard() -> some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(Color.white.opacity(0.9))
            .frame(height: UIScreen.main.bounds.width * 0.35)
            .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

#Preview {
    SocialView()
}
