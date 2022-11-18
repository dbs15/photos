//
//  ContentView.swift
//  Photo
//
//  Created by David Baena Sierra on 3/11/22.
//

import SwiftUI
import PhotosUI


final class ViewModel: ObservableObject {
    @Published var images: [Image] = [Image(systemName: "photo.on.rectangle.angled")]
    @Published var base64Images = [String]()
    @Published var photoSelection: PhotosPickerItem? {
        didSet {
            if let photoSelection {
                loadTransferable(from: photoSelection)
            }
        }
    }
    
    private func loadTransferable(from photoSelection:PhotosPickerItem){
        photoSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard photoSelection == self.photoSelection else {return}
                switch result {
                case .success(let data):
                    let uiImage = UIImage(data: data!)
                    let base64Image = self.convertImageToBase64(uiImage!)
                    self.images.append(Image(uiImage: uiImage!))
                    self.base64Images.append(base64Image)
                    print(self.base64Images.count)
                    //print(base64Image)
                case . failure(let error):
                    print("Error de carga \(error)")
                    self.images.append(Image(systemName: "multiply.ricle.fill"))
                }
                
                
            }
        }
    }
    
    func convertImageToBase64(_ image: UIImage) -> String {
        let imageData: NSData = image.jpegData(compressionQuality: 0.7)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)

        return strBase64
     }
    
    
}

extension Image: Identifiable {
    public var id: String { UUID().uuidString }
}


struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Section("Seleccionar Foto"){
                VStack{
                    ForEach(viewModel.images){image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                    }
                    Divider()
                    PhotosPicker(selection: $viewModel.photoSelection, matching: .images, photoLibrary: .shared()) {
                        Label("Selecciona Una Foto", systemImage: "photo.on.rectangle.angled")
                    }
                }
                

            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
