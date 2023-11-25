//
//  FullResponseVIew.swift
//  AIChatGPT
//
//  Created by John goodstadt on 21/11/2023.
//

import SwiftUI

struct FullRequestView: View {
	var requestMessage:String?
	
    var body: some View {
		Text(requestMessage ?? "Message goes here")
			.padding(.top,50)
			.padding()
		
		Spacer()
    }
}

#Preview {
	FullRequestView(requestMessage: "")
}
