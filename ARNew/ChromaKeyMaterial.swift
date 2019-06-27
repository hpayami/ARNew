//
//  ChromaKeyMaterial.swift
//  ARNew
//
//  Created by Hossein Payami on 2/25/1398 AP.
//  Copyright © 1398 Hossein Payami. All rights reserved.
//

import SceneKit

public class ChromaKeyMaterial: SCNMaterial {

    public var backgroundColor: UIColor {
        didSet { didSetBackgroundColor() }
    }

    public var thresholdSensitivity: Float {
        didSet { didSetThresholdSensitivity() }
    }

    public var smoothing: Float  {
        didSet { didSetSmoothing() }
    }

    public init(backgroundColor: UIColor = .green, thresholdSensitivity: Float = 0.50, smoothing: Float = 0.001) {

        self.backgroundColor = backgroundColor
        self.thresholdSensitivity = thresholdSensitivity
        self.smoothing = smoothing

        super.init()

        didSetBackgroundColor()
        didSetThresholdSensitivity()
        didSetSmoothing()

        // chroma key shader is based on GPUImage
        // https://github.com/BradLarson/GPUImage/blob/master/framework/Source/GPUImageChromaKeyFilter.m

        let surfaceShader =
        """
uniform vec3 c_colorToReplace;
uniform float c_thresholdSensitivity;
uniform float c_smoothing;

#pragma transparent
#pragma body

vec3 textureColor = _surface.diffuse.rgb;

float maskY = 0.2989 * c_colorToReplace.r + 0.5866 * c_colorToReplace.g + 0.1145 * c_colorToReplace.b;
float maskCr = 0.7132 * (c_colorToReplace.r - maskY);
float maskCb = 0.5647 * (c_colorToReplace.b - maskY);

float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
float Cr = 0.7132 * (textureColor.r - Y);
float Cb = 0.5647 * (textureColor.b - Y);

float blendValue = smoothstep(c_thresholdSensitivity, c_thresholdSensitivity + c_smoothing, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));

float a = blendValue;
_surface.transparent.a = a;
"""

        //_surface.transparent.a = a;

        shaderModifiers = [
            .surface: surfaceShader,
        ]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //setting background color to be keyed out
    private func didSetBackgroundColor() {
        //getting pixel from background color
        //let rgb = backgroundColor.cgColor.components!.map{Float($0)}
        //let vector = SCNVector3(x: rgb[0], y: rgb[1], z: rgb[2])
        let vector = SCNVector3(x: 0.0, y: 1.0, z: 0.0)
        setValue(vector, forKey: "c_colorToReplace")
    }

    private func didSetSmoothing() {
        setValue(smoothing, forKey: "c_smoothing")
    }

    private func didSetThresholdSensitivity() {
        setValue(thresholdSensitivity, forKey: "c_thresholdSensitivity")
    }
}
