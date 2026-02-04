//
//  IconView.swift
//  Clamera
//
//  Created by Ellis Kamplain (student LM) on 2/3/26.
//

import SwiftUI

struct IconView: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                Spacer()
                Image("fisherman")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle()).overlay(Circle().stroke(Color.white, lineWidth: 1))
               
            }
            .padding(.horizontal, 23)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

#Preview {
    IconView()
}
