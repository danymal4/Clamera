//
//  AlbumView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct AlbumView: View {
    var body: some View {
        ZStack {
            WaterView().offset(y: -2000)
            VStack {
                Text("Album")
                    .font(.custom("IslandMoments-Regular", size: 90))
                    .foregroundStyle(.blue)
                    .padding()
                HStack {
                    HStack {
                        Text("Search")
                            .padding()
                        Spacer()
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.gray, lineWidth: 2)
                    }
                    .padding(.leading)
                    .padding(.trailing, 5)
                    VStack {
                        Text("Filter")
                            .font(.custom("HelveticaNeue-Thin", size: 15))
                        Image(systemName: "line.horizontal.3.decrease")
                            
                    }.padding(.trailing)
                    
                }
                ScrollView {
                    HStack {
                        VStack {
                           
                            Button {
                                
                            }
                            
                            label:{
                                Rectangle()
                                    .aspectRatio(contentMode: .fit)
                            }
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                        
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                    }
                    HStack {
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                        
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                    }
                    HStack {
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                        
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                    }
                    HStack {
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                        
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                    }
                    HStack {
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                        
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                    }
                    HStack {
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                        
                        VStack {
                            Rectangle()
                                .aspectRatio(contentMode: .fit)
                            Text("Fish")
                                .font(Font(Constants.tabFont))
                        }.padding()
                    }
                }
            }
        }.padding(.bottom, -4000)
        VStack {
                      Spacer()
                      Rectangle()
                          .fill(Color.white.opacity(0.6))
                          .frame(height: 83)
                           // or safeAreaInset if you want
                  }
              
              .edgesIgnoringSafeArea(.bottom)
        
      
    }
}

#Preview {
    AlbumView()
}
