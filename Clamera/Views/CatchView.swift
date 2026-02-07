//
//  CatchView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct CatchView: View {
   
    @State var editState: EditState = .notEditing
    
    
    var body: some View {
        
        if editState == .notEditing {
            ZStack{
                
                
                
                
                
                WaterView().offset(y: -375)
                IconView().offset(y: 85)
                
                
                
                
                
                
                
                
                
                
                
                VStack{
                    ZStack{
                        Rectangle().frame(width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                          height: min(UIScreen.main.bounds.width * 1.2, 2000))
                        
                        .foregroundStyle(Color.gray.opacity(0.4)).compositingGroup()
                        .cornerRadius(20)
                        HStack{
                            Text("Fish image")
                                .font(.custom("HelveticaNeue-Thin", size: 20))
                                .bold()
                            Image("FishIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: min(UIScreen.main.bounds.width * 0.3, 2000),
                                       height: min(UIScreen.main.bounds.width * 0.3, 2000))
                            
                        }
                    }.padding(.top, -40)
                    HStack{
                        VStack{
                            
                            
                            Image("CameraIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: min(UIScreen.main.bounds.width * 0.25, 2000),
                                       height: min(UIScreen.main.bounds.width * 0.3, 2000)).opacity(0.9)
                            
                        }.padding(.horizontal, 25)
                        VStack{
                            ZStack{
                                
                                
                                
                                Button {
                                    editState = .editing
                                }
                                
                                label: {
                                    
                                    
                                    Image("uploadIcon")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    
                                        .frame(width: min(UIScreen.main.bounds.width * 0.36, 2000),
                                               height: min(UIScreen.main.bounds.width * 0.36, 2000)).padding(.top, 40)
                                }
                                
                                
                                
                            }
                            
                        }
                    }.padding(.top, -30)
                    
                    
                    
                    
                }.padding(.top, 135)
                
                
                
            }
            
            
            
            
            
            Spacer()
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(height: 83).padding(.top, 810)
            // or safeAreaInset if you want
            
            
            
        }
        
        else{
            CatchManageView(editState: $editState)
        }
        
    }
    
}

#Preview {
    CatchView()
}
