//
//  HomeView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {

        ScrollView{
            
            
            ZStack{
                
                
                VStack{
                    
                    Spacer()
                    
                    
                    Text("Home")                        .font(.custom("IslandMoments-Regular",  size: UIScreen.main.bounds.width * 0.3)).opacity(0.9)
                    

                
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    
                }
                
                
                
                WaterShipView()
                    .offset(y: -58)
                
                
                IconView()
                
                
                
                
                
                
                VStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    
                    
                    
                    VStack{
              
                        ZStack{
                            Rectangle().opacity(0.8).colorInvert().cornerRadius(90).opacity(0.3).frame(width: min(UIScreen.main.bounds.width * 0.4, 2000),
                                                                                                       height: min(UIScreen.main.bounds.width * 0.1, 2000))
                            
                            Text("Recent Catches").font(.system(size: UIScreen.main.bounds.width * 0.05)).opacity(0.8)
                            
                            
                        }
                        
                        
                        
                        HStack{
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            //make a button
                            
                            
                            ZStack{
                                
                                
                                
                                
                                Rectangle().opacity(0.8).colorInvert().cornerRadius(30).opacity(0.3).frame(width: min(UIScreen.main.bounds.width * 0.825, 2000),
                                                                                                           height: min(UIScreen.main.bounds.width * 0.475, 2000))
                                
                                Image("PictureFish").resizable().aspectRatio(contentMode: .fit).cornerRadius(20).frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                                                                                                       height: min(UIScreen.main.bounds.width * 0.5, 2000))
                                
                                
                                
                                
                            }
                            
                            
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            
                        }
                        
                    }.padding(.bottom, 50)
                    
                 
                    
           
            
             
                    
                    
                    
                }
                
            }}
        
        
    }
}

#Preview {
    HomeView()
}
