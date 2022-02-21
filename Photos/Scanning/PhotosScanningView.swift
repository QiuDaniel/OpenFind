//
//  PhotosScanningView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosScanningView: View {
    @ObservedObject var model: PhotosViewModel
    var body: some View {
        PhotosScanningViewHeader(model: model)
    }
}

struct PhotosScanningViewHeader: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                /// Header
                Container(description: "Find works completely offline, so your photos and other data never leave your phone.") {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            PhotosScanningProgressView(
                                scannedPhotosCount: model.scannedPhotosCount,
                                totalPhotosCount: model.totalPhotosCount,
                                lineWidth: 4
                            )
                                .frame(width: 32, height: 32)

                            HStack {
                                Text("\(model.scannedPhotosCount)")
                                    .foregroundColor(.accent)
                                    +
                                    Text("/")
                                    .foregroundColor(.accent.opacity(0.75))
                                    +
                                    Text("\(model.totalPhotosCount)")
                                    .foregroundColor(.accent.opacity(0.75))

                                Text("Scanned")
                                    .foregroundColor(.accent.opacity(0.75))
                                    .font(.largeTitle.weight(.regular))
                            }
                            .font(.largeTitle.weight(.semibold))

                            Spacer()
                        }

                        HStack {
                            PhotosScanningButton(image: "pause.fill", title: "Pause") {}

                            PhotosScanningButton(image: "speedometer", title: "Turbo") {}
                        }
                    }
                    .padding(PhotosScanningConstants.padding)
                    .background(Color.accent.opacity(0.1))
                    .cornerRadius(PhotosScanningConstants.cornerRadius)
                }

                PhotoScanningRow(
                    model: model,
                    title: "Scan on Launch",
                    description: "Find will start scanning photos as soon as you open the app.",
                    binding: \PhotosViewModel.$scanOnLaunch
                )

                PhotoScanningRow(
                    model: model,
                    title: "Background Scanning",
                    description: "Find will scan photos when the app is inactive and in the background.",
                    binding: \PhotosViewModel.$scanInBackground
                )

                PhotoScanningRow(
                    model: model,
                    title: "Scan While Charging",
                    description: "Find will scan photos when your phone is plugged in.",
                    binding: \PhotosViewModel.$scanWhileCharging
                )

                Spacer()
            }
            .padding(PhotosScanningConstants.padding)
        }
    }
}

struct PhotosScanningButton: View {
    var image: String?
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let image = image {
                    Image(systemName: image)
                }

                Text(title)
            }
            .foregroundColor(Color.accent)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.accent.opacity(0.15))
            .cornerRadius(PhotosScanningConstants.innerCornerRadius)
        }
    }
}

struct Container<Content: View>: View {
    var description: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 10) {
            content

            Text(description)
                .foregroundColor(UIColor.secondaryLabel.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, PhotosScanningConstants.padding)
        }
    }
}

struct PhotoScanningRow: View {
    @ObservedObject var model: PhotosViewModel
    var title: String
    var description: String
    var binding: KeyPath<PhotosViewModel, Binding<Bool>>

    var body: some View {
        Container(description: description) {
            HStack {
                Text(title)
                Spacer()
                Toggle(isOn: model[keyPath: binding]) {
                    EmptyView()
                }
                .labelsHidden()
            }
            .padding(PhotosScanningConstants.padding)
            .background(UIColor.secondarySystemBackground.color)
            .cornerRadius(PhotosScanningConstants.cornerRadius)
        }
    }
}