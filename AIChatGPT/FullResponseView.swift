//
//  FullResponseVIew.swift
//  AIChatGPT
//
//  Created by John goodstadt on 21/11/2023.
//

import SwiftUI

struct FullResponseView: View {
	var responseMessage:String?
	
    var body: some View {
		Text(responseMessage ?? "Message goes here")
		Spacer()
    }
}

#Preview {
	FullResponseView(responseMessage: "")
}
