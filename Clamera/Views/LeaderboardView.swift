//
//  LeaderboardView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct LeaderboardView: View {
    var Hshift = 180
    var Vshift = 300
    var body: some View {
        
        ZStack{
            IconView()
            
            VStack{
                Text("Leaderboard")
                    .padding()
                    .font(.custom("IslandMoments-Regular", size: 90))
                    .foregroundStyle(.blue)
                WaterView()
                    .padding(.bottom, 450)
            }
            //rectangles used as thin lines
            ScrollView{
                ZStack{
                    //Main rectangle
                    Rectangle()
                        .frame( width: 350, height: 550)
                        .padding(.top, 150)
                        .foregroundStyle(Color.clameraBlue)
                        .cornerRadius(20)
                    
                    
                    Rectangle()
                        .frame( width: 2, height: 550)
                        .padding(.top, 150)
                        .foregroundStyle(Color.black)
                    Rectangle()
                        .frame( width: 350, height: 1)
                        .padding(.top, 50)
                        .foregroundStyle(Color.black)
                    Rectangle()
                        .frame( width: 350, height: 1)
                        .padding(.top, 500)
                        .foregroundStyle(Color.black)
                    
                    Rectangle()
                        .frame( width: 350, height: 1)
                        .padding(.top, 280)
                        .foregroundStyle(Color.black)
                    Rectangle()
                        .frame( width: 350, height: 1)
                        .padding(.bottom, 200)
                        .foregroundStyle(Color.black)
                    
                    
                    Section{
                        Text("Name")
                            .padding(.trailing, CGFloat(Hshift))
                        
                        
                        Text("Clam Points")
                            .padding(.leading, CGFloat(Hshift))
                    }.padding(.bottom, CGFloat(Vshift))
                    
                    
                    Section{
                        Text("FishMaster69")
                            .padding(.trailing, CGFloat(Hshift))
                        Text("18,000")
                            .padding(.leading, CGFloat(Hshift))
                    }.padding(.bottom, CGFloat(Vshift - 225))
                    
                    Section{
                        Text("FishNChips10")
                            .padding(.trailing, CGFloat(Hshift))
                        Text("13,000")
                            .padding(.leading, CGFloat(Hshift))
                    }.padding(.top, CGFloat(-Vshift + 450))
                    
                    Section{
                        Text("Ellis")
                            .padding(.trailing, CGFloat(Hshift))
                        Text("8,000")
                            .padding(.leading, CGFloat(Hshift))
                    }.padding(.top, CGFloat(-Vshift + 675))
                    
                    Section{
                        Text("NotUrBaitBro")
                            .padding(.trailing, CGFloat(Hshift))
                        Text("7,500")
                            .padding(.leading, CGFloat(Hshift))
                    }.padding(.top, CGFloat(-Vshift + 900))
                    
                    
                    
                }
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
