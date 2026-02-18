//
//  ProfileView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        ZStack{
        
            WaterView().offset(y: -120)
   
            
            VStack{
                
                
                
                
                Text("Profile")                        .font(.custom("IslandMoments-Regular",  size: UIScreen.main.bounds.width * 0.2)).foregroundStyle(Color.blue).opacity(0.9).padding().padding(.bottom, -55)
                
                Image("fisherman")
                    .resizable().aspectRatio(contentMode: .fit) .clipShape(Circle()).overlay(Circle().stroke(Color.blue, lineWidth: 5).opacity(0.2)).frame(width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                                                                                                                                            height: min(UIScreen.main.bounds.width * 0.9, 2000)).padding(.bottom, -10)
                
                Text("Ellis").padding(.top, -38).font(.system(size: UIScreen.main.bounds.width * 0.06)).opacity(0.8).bold().padding(.top, 10).opacity(0.9)
                
                
                Text("John Smith").padding(.top, -38).font(.system(size: UIScreen.main.bounds.width * 0.06)).opacity(0.8).bold().padding(.top, -5).opacity(0.9)
             
                ZStack {
                    
                    HStack{
                        Spacer()
                        Rectangle().colorInvert()
                            .cornerRadius(30)
                        
                            .opacity(0.3)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                height: min(UIScreen.main.bounds.width * 0.54, 390)
                            )
                        Spacer()
                        Spacer()
                        Spacer()
                    }.padding(.top, -20)
                    HStack(){
                        
                        VStack{
                            Text("email:     s069420@​gmail.com ")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .opacity(0.8)
                                .bold().padding(.bottom).frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    alignment: .leading
                                )
                            
                            
                            Text("password:   ******")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .opacity(0.8)
                                .bold().padding(.bottom).frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    alignment: .leading
                                )
                            
                            Text("Fish Caught:   230")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .opacity(0.8)
                                .bold().padding(.bottom).frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    alignment: .leading
                                )
                            
                            Text("Species Caught:  12/200")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .opacity(0.8)
                                .bold().padding(.bottom).frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    alignment: .leading
                                )
                            
                            HStack{
                                Text("Clam Points:   ∞")
                                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                    .opacity(0.8)
                                    .bold().padding(.bottom, 4).frame(
                                        width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                        alignment: .leading
                                    )
                                
                                
                            }
                        }  .padding(.top, -10).padding()
                        
                        Spacer()
                        
                        
                    }.padding(.leading, 23)
                    
                    HStack {
                       Spacer()
                        Button{
                            
                        }
                        label: {
                            Text("Logout").opacity(0.8)
                        }
                    }.padding(.top, 230).padding(.horizontal)
                }
                
                
                
            }
           
            
        }.padding(.top, 40)
        VStack {
                      Spacer()
                      Rectangle()
                          .fill(Color.white.opacity(0.6))
                          .frame(height: 83)
                 
                  }
              
              .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ProfileView()
}
