//
//  ColorSelectionView.swift
//  TwoCents
//
//  Created by jonathan on 8/12/23.
//

import SwiftUI

struct ColorSelectionView: View {
    


    var body: some View {
        
                    VStack{
                        Rectangle()
                            .fill(.red)
                            .frame(height: 100)
                            .cornerRadius(10)
                        
                        Rectangle()
                            .fill(.orange)
                            .frame(height: 100)
                            .cornerRadius(10)
                        
                        Rectangle()
                            .fill(.yellow)
                            .frame(height: 100)
                            .cornerRadius(10)
                        
                        Rectangle()
                            .fill(.green)
                            .frame(height: 100)
                            .cornerRadius(10)
                        
                        Rectangle()
                            .fill(.cyan)
                            .frame(height: 100)
                            .cornerRadius(10)
                        
                        
                        Rectangle()
                            .fill(.purple)
                            .frame(height: 100)
                            .cornerRadius(10)
                    }
                    .padding()
                
            }
            
            
        }
        
        

struct ColorSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelectionView()
    }
}
