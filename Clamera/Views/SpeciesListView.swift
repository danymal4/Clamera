//
//  SpeciesListView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct SpeciesListView: View {
    var body: some View {
        ZStack {
            WaterView()
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
                    .padding(.horizontal)
                    
                }
                ScrollView {
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
        }
    }
}

#Preview {
    SpeciesListView()
}
