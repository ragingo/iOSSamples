//
//  EffectTestView.swift
//  Sample007-ImageProcessing
//
//  Created by ragingo on 2022/09/10.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Combine

struct EffectTestView: View {
    private let originalImage = UIImage(named: "cat")!
    @State private var image: Image? = nil
    @State private var blurRadius = 0.0
    @State private var blurOpaque = false
    @State private var brightnessAmount = 0.0
    @State private var contrastAmount = 1.0
    @State private var saturationAmount = 1.0
    @State private var grayscaleAmount = 0.0

    @State private var selectedFilter: CIFilter? = nil
    private let context = CIContext()

    private let imageSubject = PassthroughSubject<CGImage, Never>()

    var body: some View {
        ScrollView {
            Expander(title: { Text("パラメータ調整") }) {
                makeMenus()
            }

            if let image {
                image
                    .frame(height: 300)
                    .blur(radius: blurRadius, opaque: blurOpaque)
                    .brightness(brightnessAmount)
                    .contrast(contrastAmount)
                    .saturation(saturationAmount)
                    .grayscale(grayscaleAmount)
            }
        }
        .onAppear {
            image = Image(uiImage: originalImage)
        }
        .padding()
    }

    @ViewBuilder
    private func makeMenus() -> some View {
        Group {
            Expander(title: { Text("blur(ぼかし、ガウシアンブラー)") }) {
                makeSliderMenu(label: "radius(ぼかし半径)", value: $blurRadius, range: 0.0...100.0, step: 1)
                Toggle("opaque(不透明)", isOn: $blurOpaque)
            }

            Expander(title: { Text("brightness(明度)") }) {
                makeSliderMenu(label: "value", value: $brightnessAmount, range: 0.0...1.0, step: 0.01)
            }

            Expander(title: { Text("saturation(彩度)") }) {
                makeSliderMenu(label: "value", value: $saturationAmount, range: 0.0...10.0, step: 0.01)
            }

            Expander(title: { Text("contrast(コントラスト)") }) {
                makeSliderMenu(label: "value", value: $contrastAmount, range: -10.0...10.0, step: 0.01)
            }

            Expander(title: { Text("grayscale(グレースケール)") }) {
                makeSliderMenu(label: "value", value: $grayscaleAmount, range: 0.0...1.0, step: 0.01)
            }

            Expander(title: { Text("CoreImage ビルトインフィルタ") }) {
                makeCoreImageBuiltInFilterSelector()
            }
        }
        .padding()
    }

    @ViewBuilder
    private func makeSliderMenu(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        HStack {
            Text("\(label): \(value.wrappedValue, specifier: "%.3f")")
            Slider(value: value, in: range, step: step)
        }
    }

    @ViewBuilder
    private func makeCoreImageBuiltInFilterSelector() -> some View {
        let filters = availableFilters()
        VStack {
            HStack {
                Menu("選択") {
                    ForEach(filters, id: \.name) { filter in
                        Button {
                            selectedFilter = filter
                            image = Image(uiImage: originalImage)
                            filter.setDefaults()
                        } label: {
                            Text(filter.name)
                        }
                    }
                }
                Text(selectedFilter?.name ?? "")
            }
            if let selectedFilter = selectedFilter {
                makeFilterInputParameters(selectedFilter)
            }
        }
    }

    @ViewBuilder
    private func makeFilterInputParameters(_ filter: CIFilter) -> some View {
        let params = extractFilterParameters(filter)
        ForEach(params, id: \.key) { param in
            if param.isSupported {
                Expander(title: { Text("\(param.key)") }) {
                    Text(String(describing: param))

                    if let value = param.value as? Double,
                       let min = param.sliderMin as? Double,
                       let max = param.sliderMax as? Double {
                        FilterNumberParameterView(name: param.key, value: value, range: min...max, step: max / 100.0) { newValue in
                            onFilterParameterChanged(filter: filter, value: newValue, parameterKey: param.key)
                        }
                        .onReceive(imageSubject.receive(on: DispatchQueue.main)) { cgImage in
                            image = Image(uiImage: UIImage(cgImage: cgImage))
                        }
                    }
                }
            }
        }
    }

    private let imageProcessingQueue = DispatchQueue(label: "image processing", qos: .userInitiated)

    private func onFilterParameterChanged(filter: CIFilter, value: Double, parameterKey: String) {
        imageProcessingQueue.async {
            guard let cgInputImage = originalImage.cgImage else {
                return
            }

            let ciInputImage = CIImage(cgImage: cgInputImage)
            filter.setValue(ciInputImage, forKey: kCIInputImageKey)
            filter.setValue(value, forKey: parameterKey)

            guard let ciOutputImage = filter.outputImage else {
                return
            }

            if let cgImage = context.createCGImage(ciOutputImage, from: ciOutputImage.extent) {
                imageSubject.send(cgImage)
            }
        }
    }

    struct CIFilterParam: CustomStringConvertible {
        let key: String
        let value: Any?
        let `default`: Any?
        let type: Any?
        let min: Any?
        let max: Any?
        let sliderMin: Any?
        let sliderMax: Any?

        var isSupported: Bool {
            value is NSNumber && sliderMin is NSNumber && sliderMax is NSNumber
        }

        var description: String {
            "key: \(key), value: \(value ?? "nil"), default: \(`default` ?? "nil"), type: \(type ?? "nil"), min: \(min ?? "nil"), max: \(max ?? "nil"), sliderMin: \(sliderMin ?? "nil"), sliderMax: \(sliderMax ?? "nil")"
        }
    }

    private func inputKeyAttribute(filter: CIFilter, inputKey: String, parameterKey: String) -> Any? {
        guard let attrs = filter.attributes[inputKey] as? [String: Any] else {
            return nil
        }
        return attrs[parameterKey]
    }

    private func extractFilterParameters(_ filter: CIFilter) -> [CIFilterParam] {
        let inputParams = filter.inputKeys
            .filter { key in
                key != kCIInputImageKey
            }
            .map { key in
                CIFilterParam(
                    key: key,
                    value: filter.value(forKey: key),
                    default: inputKeyAttribute(filter: filter, inputKey: key, parameterKey: kCIAttributeDefault),
                    type: inputKeyAttribute(filter: filter, inputKey: key, parameterKey: kCIAttributeType),
                    min: inputKeyAttribute(filter: filter, inputKey: key, parameterKey: kCIAttributeMin),
                    max: inputKeyAttribute(filter: filter, inputKey: key, parameterKey: kCIAttributeMax),
                    sliderMin: inputKeyAttribute(filter: filter, inputKey: key, parameterKey: kCIAttributeSliderMin),
                    sliderMax: inputKeyAttribute(filter: filter, inputKey: key, parameterKey: kCIAttributeSliderMax)
                )
            }
        return inputParams
    }

    private func availableFilters() -> [CIFilter] {
        let names = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        let filters = names
            .compactMap { name in
                CIFilter(name: name)
            }
            .filter { filter in
                let hasInputImage = filter.inputKeys.contains(where: { key in
                    key == kCIInputImageKey
                })
                let hasNumericParameters = filter.inputKeys.contains(where: { key in
                    filter.value(forKey: key) is NSNumber
                })
                return hasInputImage && hasNumericParameters
            }
            .sorted(by: { a, b in a.name < b.name })
        return filters
    }
}

struct FilterNumberParameterView: View {
    private let name: String
    private let range: ClosedRange<Double>
    private let step: Double
    private let onEditChanged: ((Double) -> Void)?

    @State private var value: Double

    init(name: String, value: Double, range: ClosedRange<Double>, step: Double, onEditChanged: ((Double) -> Void)? = nil) {
        self.name = name
        self._value = State(initialValue: value)
        self.range = range
        self.step = step
        self.onEditChanged = onEditChanged
    }

    var body: some View {
        HStack {
            Text(name)
            Divider()
            VStack {
                Slider(
                    value: $value,
                    in: range,
                    step: step,
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            onEditChanged?(value)
                        }
                    },
                    minimumValueLabel: Text("\(range.lowerBound, specifier: "%.2f")"),
                    maximumValueLabel: Text("\(range.upperBound, specifier: "%.2f")"),
                    label: {}
                )
                Text("\(value, specifier: "%.3f")")
            }
        }
    }
}

struct EffectTestView_Previews: PreviewProvider {
    static var previews: some View {
        EffectTestView()
    }
}
