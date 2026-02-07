//
//  CatchView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct CatchView: View {
    var body: some View {
        
    
            ZStack{
            
                
                
                
                
                WaterView().offset(y: -375)
                IconView().offset(y: 85)
                
                
                
                
                
                
                
                
                
                
                
                VStack{
                    ZStack{
                        Rectangle().frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                          height: min(UIScreen.main.bounds.width * 1.2, 2000))
                            
                            .foregroundStyle(Color.gray.opacity(0.5)).compositingGroup()
                            .cornerRadius(20)
                        HStack{
                            Text("Fish Image")
                                .font(.custom("HelveticaNeue-Thin", size: 20))
                                .bold()
                            Image("FishIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: min(UIScreen.main.bounds.width * 0.3, 2000),
                                       height: min(UIScreen.main.bounds.width * 0.3, 2000))
                            
                        }
                    }.padding(.top, -30)
                    HStack{
                        VStack{
                            Image("CameraIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: min(UIScreen.main.bounds.width * 0.25, 2000),
                                       height: min(UIScreen.main.bounds.width * 0.3, 2000)).opacity(0.9)
                            
                        }.padding(.horizontal, 35)
                        VStack{
                            ZStack{
                                
                            
                             
                                    Circle().frame(width: min(UIScreen.main.bounds.width * 0.45, 2000),
                                                   height: min(UIScreen.main.bounds.width * 0.26, 2000)).foregroundColor(.white).opacity(0.9)
                                
                                
                                
                                
                                Circle().frame(width: min(UIScreen.main.bounds.width * 0.4, 2000),
                                                height: min(UIScreen.main.bounds.width * 0.22, 2000)).opacity(0.9)
                              
                                Button {
                                    
                                }
                                
                                label: {
                                    
                                    
                                    Image("UploadImageIcon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit).background(Circle().fill(Color.white))
                                    
                                        .frame(width: min(UIScreen.main.bounds.width * 0.45, 2000),
                                               height: min(UIScreen.main.bounds.width * 0.18, 2000))
                                }
                              
                                     
                                
                            }
                            
                        }
                    }.padding(.top, -5)
                        
                    
                    
                    
                }.padding(.top, 110)
                
                
          
            }
            
            
        
        
   
                      Spacer()
                      Rectangle()
                          .fill(Color.white.opacity(0.6))
                          .frame(height: 83).padding(.top, 810)
                           // or safeAreaInset if you want


            
    }
    
    
    
}

#Preview {
    CatchView()
}
