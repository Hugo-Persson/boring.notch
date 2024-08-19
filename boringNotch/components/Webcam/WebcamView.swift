    //
    //  WebcamView.swift
    //  boringNotch
    //
    //  Created by Harsh Vardhan  Goswami  on 19/08/24.
    //

import SwiftUI
import AVFoundation

struct CircularPreviewView: View {
    @ObservedObject var webcamManager: WebcamManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewLayer = webcamManager.previewLayer {
                    CameraPreviewLayerView(previewLayer: previewLayer)
                        .clipShape(Circle())
                        .frame(width: geometry.size.width, height: geometry.size.width)
                }
                
                if !webcamManager.isSessionRunning {
                    ZStack {
                        Circle()
                            .fill(Color(red: 20/255, green: 20/255, blue: 20/255))
                            .frame(width: geometry.size.width, height: geometry.size.width)
                        VStack (spacing: 8){
                            Image(systemName: "web.camera").foregroundStyle(.gray).font(.system(size: geometry.size.width / 3.5))
                            Text("Mirror").font(.caption2).foregroundColor(.gray)
                        }}
                    }
                }
                    .onTapGesture {
                        if webcamManager.isSessionRunning {
                            webcamManager.stopSession()
                        } else {
                            webcamManager.startSession()
                        }
                    }
                    .onDisappear {
                        webcamManager.stopSession()
                    }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
    
    struct CameraPreviewLayerView: NSViewRepresentable {
        let previewLayer: AVCaptureVideoPreviewLayer
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView(frame: .zero)
            previewLayer.frame = view.bounds
            view.layer = previewLayer
            view.wantsLayer = true
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {
            previewLayer.frame = nsView.bounds
        }
    }
    
    #Preview {
        CircularPreviewView(webcamManager: WebcamManager())
    }
