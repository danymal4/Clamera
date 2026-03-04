//
//  ProfileView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var user: User
    @EnvironmentObject var speciesStore: SpeciesStore
    
    var body: some View {
        
        ZStack{
        
            WaterView().opacity(0.3)
   
            
            VStack{
                
                
                
                
                Text("Profile")                        .font(.custom("AkayaTelivigala-regular",  size: UIScreen.main.bounds.width * 0.175)).foregroundStyle(Color.blue).opacity(0.9).padding().padding(.bottom, -55)
                
                Image("fisherman")
                    .resizable().aspectRatio(contentMode: .fit) .clipShape(Circle()).overlay(Circle().stroke(Color.blue, lineWidth: 5).opacity(0.2)).frame(width: min(UIScreen.main.bounds.width * 0.9, 2000),
                                                                                                                                                            height: min(UIScreen.main.bounds.width * 0.9, 2000)).padding(.bottom, -10)
                
                Text("Ellis").padding(.top, -38).font(.system(size: UIScreen.main.bounds.width * 0.06)).opacity(0.8).bold().padding(.top, 10).opacity(0.9)
                
                
             
                ZStack {
                    
                    HStack{
                        Spacer()
                        Rectangle().colorInvert()
                            .cornerRadius(30)
                        
                            .opacity(0.5)
                            .frame(
                                width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                height: min(UIScreen.main.bounds.width * 0.54, 390)
                            ) .shadow(color: .black.opacity(0.1), radius: 10)
                        Spacer()
                        Spacer()
                        Spacer()
                    }.padding(.top, -20)
                    HStack(){
                        
                        VStack{
                            Text("email:     s019204@gmail.com ")
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
                            
                            Text("Fish Caught:   \(speciesStore.getFish())")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .opacity(0.8)
                                .bold().padding(.bottom).frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    alignment: .leading
                                )
                            
                            Text("Species Caught:  \(speciesStore.getSpecies())/\(speciesStore.speciesList.count)")
                                .font(.system(size: UIScreen.main.bounds.width * 0.04))
                                .opacity(0.8)
                                .bold().padding(.bottom).frame(
                                    width: min(UIScreen.main.bounds.width * 0.8, 2000),
                                    alignment: .leading
                                )
                            
                            HStack{
                                Text("Clam Points:   \(speciesStore.totalClamPoints)")
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
                        }.padding(.bottom, 5)
                    }.padding(.top, 230).padding(.horizontal)
                }
                
                
                
            }.padding(.bottom, 60)
            VStack {
                          Spacer()
                          Rectangle()
                              .fill(Color.white.opacity(0.6))
                              .frame(height: 83).shadow(color: .black.opacity(0.1), radius: 10)
                     
                      }
                  
                  .edgesIgnoringSafeArea(.bottom)
            
        }
       .background(Color.blue.opacity(0.08))
    }
}

#Preview {
    ProfileView()
        .environmentObject(SpeciesStore())
        .environmentObject(User())
}
