//
//  ContentView.swift
//  AIChatGPT
//
//  Created by John goodstadt on 05/11/2023.
//

import SwiftUI


//johngoodstadt@icloud.com - android verified
private let apiKey = "Your API Key Here"
private let urlStringGPT = "https://api.openai.com/v1/chat/completions"


struct ContentView: View {
	
	@State private var selectedEngineType = "gpt-3.5-turbo"
	@State private var selectedEngine   = "gpt-3.5-turbo"
	@State private var selectedQuestion: String = ""
	@State private var selectedAnswer = ""
	@State private var fullResponse = ""
	@State private var fullRequest = ""
	@State var hideActivityIndicator: Bool = true
	@State var phrase:String = ""
	@State private var selectedBuiltInQuestion = true
	@State private var isResponseButtonDisabled = true
	@State private var showingRequestSheet = false
	@State private var showingResponseSheet = false
	@FocusState private var inFocus: Bool
	
	var questions = ["Hello ChatGPT","Tell me a joke about a physicist, a biologist, and a chemist.",
					 "How has the impact of Artificial Intelligence on Traditional Industries?",
					 "How to Create a Sustainable Urban Garden?",
					 "Can you write a short story involving a detective and a missing heirloom?"]
	
	var body: some View {
		
		VStack {
			
			
			Text("Choose the engine:")
				.font(.subheadline)
				.padding(.bottom,5)
			
			Picker("Engine2:",selection: $selectedEngine) {
				Text("gpt-3.5-turbo").tag("gpt-3.5-turbo").font(.title3)
				Text("gpt-3.5-turbo-16k").tag("gpt-3.5-turbo-16k").font(.title3)
				Text("gpt-4").tag("gpt-4").font(.title3)
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.top,16)
			.padding(.bottom,32)
			.onChange(of: selectedEngine) {	tag in
				print(tag)
				selectedEngineType =  tag
			}
			
			
			VStack (alignment: .trailing){
				Button(action: {
					selectedBuiltInQuestion = true
					inFocus = false
				}) {
					HStack  {
						Image(systemName: selectedBuiltInQuestion ? "largecircle.fill.circle" : "circle")
							.foregroundColor(.blue)
						Text("Choose this question")
						Spacer()
					}
				}
			}//: VSTACK
			
			
			Picker("Select a question", selection: $selectedQuestion) {
				ForEach(questions, id: \.self) {
					//Text("").tag("") //else get message "Picker: the selection "" is invalid and does not have an associated tag, ...
					Text($0)
						.onTapGesture {
							selectedBuiltInQuestion = true
							inFocus = false
						}
				}
			}//: PICKER
			.pickerStyle(.menu)
			.padding([.top,.bottom],16)
			
			VStack (alignment: .leading){
				Button(action: {
					selectedBuiltInQuestion = false
					inFocus = false
				}) {
					HStack  {
						Image(systemName: !selectedBuiltInQuestion ? "largecircle.fill.circle" : "circle")
							.foregroundColor(.blue)
						Text("Choose my question")
						Spacer()
					}
				}
			}//: VSTACK
			
			
			Text("Ask your question:")
				.font(.subheadline)
			
			ZStack(alignment: .leading) {
				
				
				TextEditor( text: $phrase)  //.id(0)
					.font(.custom("Helvetica", size: 16))
					.padding(.all)
					.focused($inFocus,equals: true)
					.frame(height: 100)
					.onChange(of: phrase, perform: { value in
						if selectedBuiltInQuestion {
							selectedBuiltInQuestion = false
						}
					})
					.onTapGesture {
						selectedBuiltInQuestion = false
					}
				
				
			}//: ZSTACK
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke(.gray, lineWidth: 0.6)
			)
			
			HStack {
				Button(action: {
					
					if !selectedBuiltInQuestion && phrase.isEmpty {
						selectedAnswer = "Enter some text before calling openAI"
					}else{
						inFocus = false
						hideActivityIndicator = false
						selectedAnswer = ""
						fullResponse = ""
						
						let engine = selectedEngineType
						let text =  selectedBuiltInQuestion ? selectedQuestion : phrase
						
						
						callOpenAI(text: text,engine: engine)
					}
					
				}) {
					Text("Call open.ai")
						.padding()
				}.overlay(
					RoundedRectangle(cornerRadius: 16)
						.stroke(.blue, lineWidth: 0.6)
				)
				
				
				
				Spacer()
				ActivityIndicatorView(tintColor: .red, scaleSize: 2.0)
					.padding([.bottom,.top],16)
					.hidden(hideActivityIndicator)
				
				Spacer()
				Button(action: {
					showingRequestSheet.toggle()
					inFocus = false
					
				}) {
					Text("request")
						.font(.subheadline)
						.padding()
						.disabled(isResponseButtonDisabled)
				}.overlay(
					RoundedRectangle(cornerRadius: 16)
						.stroke(.blue, lineWidth: 0.6)
				)
				.sheet(isPresented: $showingRequestSheet) {
					FullRequestView(requestMessage: fullRequest)
				}
				
				Spacer()
				
				Button(action: {
					showingResponseSheet.toggle()
					inFocus = false
					
				}) {
					Text("response")
						.font(.subheadline)
						.padding()
						.disabled(isResponseButtonDisabled)
				}.overlay(
					RoundedRectangle(cornerRadius: 16)
						.stroke(.blue, lineWidth: 0.6)
				)
				.sheet(isPresented: $showingResponseSheet) {
					FullResponseView(responseMessage: fullResponse)
				}
			}//: HSTACK
			
			ScrollView {
				Text(selectedAnswer)
					.font(.subheadline)
					.padding()
			}
			
			Spacer()
		}//: VSTACK
		.padding()
		.onAppear{
			selectedQuestion = questions.first ?? ""
		}
		
	}
	struct ActivityIndicatorView: View {
		var tintColor: Color = .blue
		var scaleSize: CGFloat = 1.0
		
		var body: some View {
			ProgressView()
				.scaleEffect(scaleSize, anchor: .center)
				.progressViewStyle(CircularProgressViewStyle(tint: tintColor))
		}
	}
	func callOpenAI(text:String,engine:String){
		
		
		if let url = URL(string: urlStringGPT) {
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
			
			let messages = [
				["role": "system", "content": "answer the question in less than 200 words"],
				["role": "user", "content": text]
			]
			
			
			let parameters: [String: Any] = ["model":engine,"messages":messages]
			print(parameters)
			
			do {
				// Convert the parameters to JSON data
				let jsonData = try JSONSerialization.data(withJSONObject: parameters)
				request.httpBody = jsonData
				fullRequest = "\(parameters)"
				fullRequest = request.debug()
				
				URLSession.shared.dataTask(with: request) { (data, response, error) in
					if let error = error {
						print("Error: \(error.localizedDescription)")
						fullResponse = error.localizedDescription
						selectedAnswer = error.localizedDescription
						isResponseButtonDisabled = false //can be timeout error
						hideActivityIndicator = true
						return
					}
					
					if let data = data {
						// Parse and handle the response data here
						// Typically, this will involve extracting the generated text
						hideActivityIndicator = true
						let chatOutput = String(decoding: data, as: UTF8.self)
						print(chatOutput)
						fullResponse = chatOutput
						do {
							if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
								if let choices = json["choices"] as? [[String: Any]], !choices.isEmpty {
									if let message = choices[0]["message"] as? [String: Any], let answer = message["content"] as? String {
										print("Generated Text: \(answer)")
										selectedAnswer = answer
									}
								}
							}
						} catch {
							print("Error parsing JSON: \(error.localizedDescription)")
						}
						isResponseButtonDisabled = false
					}
				}.resume()
			} catch {
				print("Error converting parameters to JSON: \(error.localizedDescription)")
			}
		}		
	}
}

extension View {
	@ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
		switch shouldHide {
			case true: self.hidden()
			case false: self
		}
	}
}
fileprivate extension URLRequest {
	func debug() -> String {
		
		var returnValue = "\n\(self.httpMethod!) \(self.url!) "
		returnValue += "\n\nHeaders:\n"
		returnValue += "\(String(describing: self.allHTTPHeaderFields))"
		returnValue += "\n\nBody:\n"
		returnValue += String(data: self.httpBody ?? Data(), encoding: .utf8) ?? "default value"
		
		return returnValue
	}
}
#Preview {
	ContentView()
}
