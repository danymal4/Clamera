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
            IconView()
            WaterView()
            VStack{
                ZStack{
                    Rectangle()
                        .frame(width: 300, height: 400)
                        .foregroundStyle(Color.gray.opacity(0.5))
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
                }
                HStack{
                    VStack{
                        Image("CameraIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: min(UIScreen.main.bounds.width * 0.3, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.3, 2000))
                        Text("Take Photo")
                            .bold()
                    }
                    VStack{
                        Image("UploadImageIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .frame(width: min(UIScreen.main.bounds.width * 0.4, 2000),
                                   height: min(UIScreen.main.bounds.width * 0.4, 2000))
                            .padding(.top, -15)
                        Text( "Upload Image")
                            .padding(.top, -25)
                            .bold()
                        
                    }
                }
                HStack{
                    VStack{
                        
                        Text("Species name")
                            .padding()
                            .bold()
                        Rectangle()
                            .frame(width: 120, height: 40)
                            .foregroundStyle(Color.white.opacity(0.3))
                            .cornerRadius(20)
                         
                    }
                    VStack{
                        Text("Description")
                            .padding()
                            .bold()
                        Rectangle()
                            .frame(width: 120, height: 40)
                            .foregroundStyle(Color.white.opacity(0.3))
                            .cornerRadius(20)
                    }
                      
                    
                }
            }
        }
    }
}

#Preview {
    CatchView()
}
