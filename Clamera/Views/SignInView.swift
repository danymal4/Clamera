//
//  SignInView.swift
//  Clamera
//
//  Created by Dany Malaeb (student LM) on 1/28/26.
//

import SwiftUI

struct SignInView: View {
    var body: some View{


        WaterView()
            .offset(y: 200)
            
        HStack {
            
            VStack{
                HStack {
                    Text("Clamera")
                        .font(.custom("IslandMoments-Regular", size: 70))
                        .bold()
                    
                }
                HStack {
                    Text("Create an account")
                        .font(.custom("HelveticaNeue-Thin", size: 30))
                    
                }
                HStack {
                    Text("Enter your email to sign up for this app")
                        .font(.custom("HelveticaNeue-Thin", size: 20))
                    
                }
                
            }
            
        } .offset(y:-700)

        
        WaterView()
        
        
        }
    }



#Preview {
    SignInView()
}
