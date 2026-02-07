//
//  FishDetailsView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct FishDetailsView: View {
    var body: some View {
        
      
        
        ZStack{
          
            IconView()
            WaterView().offset(y: -170)
           
          
            
            ZStack{
                Rectangle()
                    .cornerRadius(20)
                    .foregroundStyle(.white)
                    .opacity(0.4)
                    .frame(width: 365, height: 200)
                    .padding(.top, 320)
            }
           
            HStack{
                Spacer()
                Image("clownFish").resizable().frame(width: min(UIScreen.main.bounds.width * 0.13, 180),
                                                     height: min(UIScreen.main.bounds.width * 0.13, 180)).padding(.trailing, 45).padding(.top, 325).opacity(0.9)
            }
            
            
            HStack{
                Spacer()
                Image("clownFish").resizable().frame(width: min(UIScreen.main.bounds.width * 0.13, 180),
                                                                  height: min(UIScreen.main.bounds.width * 0.13, 180)).padding(.trailing, 45).padding(.top, 435).colorMultiply(.gray).opacity(0.2)
            }
            
            
            
            
            Text("Nemo")
                .font(.custom("IslandMoments-Regular",  size: UIScreen.main.bounds.width * 0.3)).opacity(0.9).padding(.top, -360).foregroundStyle(.blue)
                
            HStack{
                Text("Species: Clownfish").font(.system(size: UIScreen.main.bounds.width * 0.03)).opacity(0.8).padding(.top, 550)
           
                Spacer()
            }.padding().padding()
                
              
            HStack{
             Spacer()
                Text("Caught: 02/30/1976").font(.system(size: UIScreen.main.bounds.width * 0.03)).opacity(0.8)
                    
                  .padding(.top, 550)
                
            }.padding().padding()
                
           
            
            Rectangle()
                .cornerRadius(30)
                .foregroundStyle(.white)
                .opacity(0.3)
                .frame(width: 365, height: 290).padding(.bottom, 210)
            
           
            
            Text("Image Not Found")
                .font(.custom("", size: 40))
                .foregroundStyle(.red).padding(.bottom, 210)
            
            Image("nemo 1")
                .resizable()
                .scaledToFill()
                .frame(width: 335, height: 265)
                .clipShape(RoundedRectangle(cornerRadius: 20)).padding(.bottom, 210)
            
           
            HStack{
                Spacer()
                
                
            
                Circle().frame(width: min(UIScreen.main.bounds.width * 0.13, 180),
                               height: min(UIScreen.main.bounds.width * 0.13, 180)).padding(.trailing, 20).padding(.top, -255).colorInvert().opacity(0.8)
            }
                 
            HStack {
                Spacer()
            
           
                Button {
                    
                }
                
                label: {
                    Image("pinned").resizable().frame(width: min(UIScreen.main.bounds.width * 0.13, 180),
                                                      height: min(UIScreen.main.bounds.width * 0.13, 180)).padding(.trailing, 15).padding(.top, -255)
                    
                }
                    
                
                }
            
            
            VStack{
                
                Text("Description").font(.title2).bold().padding(.top, 8)
                    
                    
             
                Text("cool fish I found with sam").opacity(0.6)
                
                    Text("Add to Aquarium")
                        .font(.system(size: UIScreen.main.bounds.width * 0.04))
                        .opacity(0.8)
                        .bold().padding(.bottom).frame(
                            width: min(UIScreen.main.bounds.width * 0.8, 2000),
                            alignment: .leading
                        ).padding()
                    
         
                
                    
               
                   
                
                    Text("Remove From Aquarium")
                        .font(.system(size: UIScreen.main.bounds.width * 0.04))
                        .opacity(0.8)
                        .bold().padding(.bottom).frame(
                            width: min(UIScreen.main.bounds.width * 0.8, 2000),
                            alignment: .leading
                        )
                    
                    
                    
          
                    
                
            }.padding(.top, 300)
    
            Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(height: 83).padding(.top, 730)
                 
        }.padding(.top, 80)
  
     
                      
                      
                  
        
    }
}

#Preview {
    FishDetailsView()
}
