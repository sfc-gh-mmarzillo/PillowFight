import UIKit
import SpriteKit

/// Renders character faces using Core Graphics for rich gradients, anti-aliasing,
/// and soft compositing. Produces SKTextures for use in SpriteKit and UIImages for SwiftUI.
class FaceRenderer {
    
    enum Expression: String, CaseIterable {
        case normal, attacking, hurt, happy, dizzy, blink
    }
    
    // MARK: - Cache
    
    private static var cache: [String: SKTexture] = [:]
    
    // MARK: - Layout Constants (80×80 canvas, UIKit coords: Y goes down)
    
    private static let canvasSize: CGFloat = 80
    private static let cx: CGFloat = 40        // center X
    private static let cy: CGFloat = 40        // center Y
    private static let eyeY: CGFloat = 37      // eyes (above center)
    private static let browY: CGFloat = 28     // eyebrows
    private static let noseY: CGFloat = 43     // nose (below center)
    private static let mouthY: CGFloat = 50    // mouth
    private static let cheekY: CGFloat = 45    // cheek blush
    
    // MARK: - Public API
    
    static func texture(for character: GameCharacter, expression: Expression) -> SKTexture {
        let key = "\(character.rawValue)_\(expression.rawValue)"
        if let cached = cache[key] { return cached }
        let image = renderFace(character: character, expression: expression)
        let tex = SKTexture(image: image)
        tex.filteringMode = .linear
        cache[key] = tex
        return tex
    }
    
    static func preloadAll() {
        for char in GameCharacter.allCases {
            for expr in Expression.allCases {
                _ = texture(for: char, expression: expr)
            }
        }
    }
    
    static func uiImage(for character: GameCharacter, expression: Expression = .normal) -> UIImage {
        renderFace(character: character, expression: expression)
    }
    
    // MARK: - Main Render
    
    private static func renderFace(character: GameCharacter, expression: Expression) -> UIImage {
        let size = CGSize(width: canvasSize, height: canvasSize)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { ctx in
            let cg = ctx.cgContext
            
            drawHead(in: cg, character: character)
            drawCheeks(in: cg, character: character)
            drawEyes(in: cg, character: character, expression: expression)
            drawEyebrows(in: cg, character: character, expression: expression)
            drawNose(in: cg, character: character)
            drawMouth(in: cg, character: character, expression: expression)
            drawDetails(in: cg, character: character)
            drawHighlight(in: cg)
        }
    }
    
    // MARK: - Head Shape with Gradient Skin
    
    private static func headPath(for character: GameCharacter) -> UIBezierPath {
        switch character {
        case .theo:
            return UIBezierPath(ovalIn: CGRect(x: cx - 25, y: cy - 25, width: 50, height: 50))
        case .ben:
            let p = UIBezierPath()
            p.move(to: CGPoint(x: cx - 22, y: cy + 4))
            p.addQuadCurve(to: CGPoint(x: cx - 24, y: cy - 8), controlPoint: CGPoint(x: cx - 25, y: cy - 2))
            p.addQuadCurve(to: CGPoint(x: cx, y: cy - 24), controlPoint: CGPoint(x: cx - 24, y: cy - 24))
            p.addQuadCurve(to: CGPoint(x: cx + 24, y: cy - 8), controlPoint: CGPoint(x: cx + 24, y: cy - 24))
            p.addQuadCurve(to: CGPoint(x: cx + 22, y: cy + 4), controlPoint: CGPoint(x: cx + 25, y: cy - 2))
            p.addQuadCurve(to: CGPoint(x: cx - 22, y: cy + 4), controlPoint: CGPoint(x: cx, y: cy + 16))
            p.close()
            return p
        case .chuck:
            return UIBezierPath(ovalIn: CGRect(x: cx - 26, y: cy - 24, width: 52, height: 48))
        case .stella:
            return UIBezierPath(ovalIn: CGRect(x: cx - 22, y: cy - 26, width: 44, height: 52))
        }
    }
    
    private static func drawHead(in cg: CGContext, character: GameCharacter) {
        let skin = character.skinColor
        let skinDark = skin.darker(by: 0.07)
        let path = headPath(for: character)
        
        // Fill with base skin
        cg.addPath(path.cgPath)
        cg.setFillColor(skin.cgColor)
        cg.fillPath()
        
        // Radial gradient overlay: lighter warm center, darker cooler edges
        cg.saveGState()
        cg.addPath(path.cgPath)
        cg.clip()
        
        let skinComps = skinComponents(skin)
        let lightSkin = UIColor(
            red: min(skinComps.r + 0.05, 1),
            green: min(skinComps.g + 0.04, 1),
            blue: min(skinComps.b + 0.02, 1),
            alpha: 1.0
        )
        
        if let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [lightSkin.cgColor, skinDark.cgColor] as CFArray,
            locations: [0.0, 1.0]
        ) {
            cg.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: cx - 4, y: cy - 6),
                startRadius: 0,
                endCenter: CGPoint(x: cx, y: cy),
                endRadius: 32,
                options: [.drawsAfterEndLocation]
            )
        }
        cg.restoreGState()
        
        // Head outline
        cg.addPath(path.cgPath)
        cg.setStrokeColor(skinDark.darker(by: 0.05).cgColor)
        cg.setLineWidth(1.6)
        cg.strokePath()
    }
    
    // MARK: - Cheeks
    
    private static func drawCheeks(in cg: CGContext, character: GameCharacter) {
        let alpha: CGFloat
        let radius: CGFloat
        
        switch character {
        case .theo:  alpha = 0.30; radius = 9
        case .ben:   alpha = 0.18; radius = 7
        case .chuck: alpha = 0.40; radius = 11
        case .stella: alpha = 0.14; radius = 6
        }
        
        let blushColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: alpha)
        let blushClear = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.0)
        
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [blushColor.cgColor, blushClear.cgColor] as CFArray,
            locations: [0.0, 1.0]
        ) else { return }
        
        for side: CGFloat in [-1, 1] {
            let cheekCenter = CGPoint(x: cx + side * 16, y: cheekY)
            cg.saveGState()
            // Clip to head so blush doesn't spill outside face
            cg.addPath(headPath(for: character).cgPath)
            cg.clip()
            cg.drawRadialGradient(gradient, startCenter: cheekCenter, startRadius: 0,
                                  endCenter: cheekCenter, endRadius: radius, options: [])
            cg.restoreGState()
        }
    }
    
    // MARK: - Eyes
    
    private static func drawEyes(in cg: CGContext, character: GameCharacter, expression: Expression) {
        let spacing: CGFloat
        let eyeW: CGFloat
        let eyeH: CGFloat
        let irisR: CGFloat
        let pupilR: CGFloat
        let irisColor: UIColor
        let outlineW: CGFloat
        
        switch character {
        case .theo:
            spacing = 11; eyeW = 16; eyeH = 18; irisR = 6.5; pupilR = 4
            irisColor = UIColor(red: 0.28, green: 0.45, blue: 0.18, alpha: 1.0)
            outlineW = 1.4
        case .ben:
            spacing = 12; eyeW = 13; eyeH = 14; irisR = 5.5; pupilR = 3.5
            irisColor = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1.0)
            outlineW = 1.4
        case .chuck:
            spacing = 11; eyeW = 15; eyeH = 17; irisR = 6; pupilR = 3.8
            irisColor = UIColor(red: 0.22, green: 0.40, blue: 0.58, alpha: 1.0)
            outlineW = 1.4
        case .stella:
            spacing = 11; eyeW = 14; eyeH = 15; irisR = 5.5; pupilR = 3.5
            irisColor = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1.0)
            outlineW = 1.8
        }
        
        let leftX = cx - spacing
        let rightX = cx + spacing
        
        switch expression {
        case .hurt:
            drawSquintEyes(in: cg, leftX: leftX, rightX: rightX, w: eyeW * 0.7)
            return
        case .happy:
            drawHappyEyes(in: cg, leftX: leftX, rightX: rightX, w: eyeW * 0.7)
            return
        case .dizzy:
            drawDizzyEyes(in: cg, leftX: leftX, rightX: rightX, r: eyeW * 0.35)
            return
        case .blink:
            drawBlinkEyes(in: cg, leftX: leftX, rightX: rightX, w: eyeW * 0.7)
            return
        default:
            break
        }
        
        // Full open eyes (normal, attacking)
        for eyeX in [leftX, rightX] {
            let eyeRect = CGRect(x: eyeX - eyeW / 2, y: eyeY - eyeH / 2, width: eyeW, height: eyeH)
            let eyePath = UIBezierPath(ovalIn: eyeRect)
            
            // Drop shadow under eye
            cg.saveGState()
            cg.setShadow(offset: CGSize(width: 0, height: 1.5), blur: 2.5,
                         color: UIColor.black.withAlphaComponent(0.10).cgColor)
            cg.addPath(eyePath.cgPath)
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillPath()
            cg.restoreGState()
            
            // Eye outline
            cg.addPath(eyePath.cgPath)
            cg.setStrokeColor(UIColor(white: 0.18, alpha: 1.0).cgColor)
            cg.setLineWidth(outlineW)
            cg.strokePath()
            
            // Upper lid shadow (subtle darkening at top of eye)
            cg.saveGState()
            cg.addPath(eyePath.cgPath)
            cg.clip()
            let lidRect = CGRect(x: eyeRect.minX - 2, y: eyeRect.minY - 3, width: eyeRect.width + 4, height: eyeRect.height * 0.4)
            let lidPath = UIBezierPath(ovalIn: lidRect)
            cg.addPath(lidPath.cgPath)
            cg.setFillColor(UIColor.black.withAlphaComponent(0.06).cgColor)
            cg.fillPath()
            cg.restoreGState()
            
            // Iris with radial gradient
            let irisCenter = CGPoint(x: eyeX + 1, y: eyeY + 0.5)
            let irisRect = CGRect(x: irisCenter.x - irisR, y: irisCenter.y - irisR,
                                  width: irisR * 2, height: irisR * 2)
            let irisPath = UIBezierPath(ovalIn: irisRect)
            
            cg.saveGState()
            cg.addPath(eyePath.cgPath)
            cg.clip()
            
            // Iris gradient: bright ring outside, darker center
            let irisLight = irisColor.lighter(by: 0.12)
            let irisDark = irisColor.darker(by: 0.08)
            
            if let irisGrad = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [irisLight.cgColor, irisDark.cgColor] as CFArray,
                locations: [0.0, 1.0]
            ) {
                cg.saveGState()
                cg.addPath(irisPath.cgPath)
                cg.clip()
                cg.drawRadialGradient(
                    irisGrad,
                    startCenter: CGPoint(x: irisCenter.x - 1, y: irisCenter.y - 1),
                    startRadius: 0,
                    endCenter: irisCenter,
                    endRadius: irisR,
                    options: [.drawsAfterEndLocation]
                )
                cg.restoreGState()
            }
            
            // Iris ring outline
            cg.addPath(irisPath.cgPath)
            cg.setStrokeColor(irisDark.darker(by: 0.12).cgColor)
            cg.setLineWidth(0.8)
            cg.strokePath()
            
            // Pupil
            let pupilRect = CGRect(x: irisCenter.x - pupilR, y: irisCenter.y - pupilR,
                                   width: pupilR * 2, height: pupilR * 2)
            cg.addEllipse(in: pupilRect)
            cg.setFillColor(UIColor(red: 0.06, green: 0.04, blue: 0.02, alpha: 1.0).cgColor)
            cg.fillPath()
            
            // Main catchlight (upper right)
            cg.addEllipse(in: CGRect(x: irisCenter.x + 1, y: irisCenter.y - 3, width: 3.5, height: 3.5))
            cg.setFillColor(UIColor.white.cgColor)
            cg.fillPath()
            
            // Secondary catchlight (lower left)
            cg.addEllipse(in: CGRect(x: irisCenter.x - 2.5, y: irisCenter.y + 1, width: 1.8, height: 1.8))
            cg.setFillColor(UIColor.white.withAlphaComponent(0.55).cgColor)
            cg.fillPath()
            
            cg.restoreGState()
        }
    }
    
    private static func drawSquintEyes(in cg: CGContext, leftX: CGFloat, rightX: CGFloat, w: CGFloat) {
        for x in [leftX, rightX] {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x - w / 2, y: eyeY))
            path.addQuadCurve(to: CGPoint(x: x + w / 2, y: eyeY), controlPoint: CGPoint(x: x, y: eyeY + 2.5))
            cg.addPath(path.cgPath)
            cg.setStrokeColor(UIColor(white: 0.22, alpha: 1.0).cgColor)
            cg.setLineWidth(2.2)
            cg.setLineCap(.round)
            cg.strokePath()
        }
    }
    
    private static func drawHappyEyes(in cg: CGContext, leftX: CGFloat, rightX: CGFloat, w: CGFloat) {
        for x in [leftX, rightX] {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x - w / 2, y: eyeY + 2))
            path.addQuadCurve(to: CGPoint(x: x + w / 2, y: eyeY + 2), controlPoint: CGPoint(x: x, y: eyeY - 5))
            cg.addPath(path.cgPath)
            cg.setStrokeColor(UIColor(white: 0.22, alpha: 1.0).cgColor)
            cg.setLineWidth(2.2)
            cg.setLineCap(.round)
            cg.strokePath()
        }
    }
    
    private static func drawDizzyEyes(in cg: CGContext, leftX: CGFloat, rightX: CGFloat, r: CGFloat) {
        let color = UIColor(red: 0.55, green: 0.18, blue: 0.18, alpha: 1.0)
        for x in [leftX, rightX] {
            let p1 = UIBezierPath()
            p1.move(to: CGPoint(x: x - r, y: eyeY - r))
            p1.addLine(to: CGPoint(x: x + r, y: eyeY + r))
            let p2 = UIBezierPath()
            p2.move(to: CGPoint(x: x + r, y: eyeY - r))
            p2.addLine(to: CGPoint(x: x - r, y: eyeY + r))
            
            for p in [p1, p2] {
                cg.addPath(p.cgPath)
                cg.setStrokeColor(color.cgColor)
                cg.setLineWidth(2.0)
                cg.setLineCap(.round)
                cg.strokePath()
            }
        }
    }
    
    private static func drawBlinkEyes(in cg: CGContext, leftX: CGFloat, rightX: CGFloat, w: CGFloat) {
        for x in [leftX, rightX] {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x - w / 2, y: eyeY))
            path.addQuadCurve(to: CGPoint(x: x + w / 2, y: eyeY), controlPoint: CGPoint(x: x, y: eyeY + 1.5))
            cg.addPath(path.cgPath)
            cg.setStrokeColor(UIColor(white: 0.22, alpha: 1.0).cgColor)
            cg.setLineWidth(2.0)
            cg.setLineCap(.round)
            cg.strokePath()
        }
    }
    
    // MARK: - Eyebrows
    
    private static func drawEyebrows(in cg: CGContext, character: GameCharacter, expression: Expression) {
        let browColor = character.hairColor.darker(by: 0.15)
        let spacing: CGFloat
        let bW: CGFloat
        let bH: CGFloat
        var angle: CGFloat
        
        switch character {
        case .theo:  spacing = 11; bW = 10; bH = 2.2; angle = 0.08
        case .ben:   spacing = 12; bW = 12; bH = 3.0; angle = -0.08
        case .chuck: spacing = 11; bW = 11; bH = 2.5; angle = 0.15
        case .stella: spacing = 11; bW = 12; bH = 2.0; angle = 0.12
        }
        
        let yAdj: CGFloat
        switch expression {
        case .attacking:
            angle = -0.3; yAdj = 1
        case .hurt, .dizzy:
            angle = 0.35; yAdj = -2
        default:
            yAdj = 0
        }
        
        for (i, bx) in [cx - spacing, cx + spacing].enumerated() {
            let isLeft = i == 0
            let a = isLeft ? angle : -angle
            
            cg.saveGState()
            cg.translateBy(x: bx, y: browY + yAdj)
            cg.rotate(by: a)
            
            let browPath = UIBezierPath(roundedRect: CGRect(x: -bW / 2, y: -bH / 2, width: bW, height: bH), cornerRadius: bH / 2)
            cg.addPath(browPath.cgPath)
            cg.setFillColor(browColor.cgColor)
            cg.fillPath()
            
            cg.restoreGState()
        }
    }
    
    // MARK: - Nose
    
    private static func drawNose(in cg: CGContext, character: GameCharacter) {
        let skin = character.skinColor
        let noseFill = skin.darker(by: 0.06)
        let noseStroke = skin.darker(by: 0.13)
        
        switch character {
        case .theo:
            // Small button nose
            let r: CGFloat = 3
            let path = UIBezierPath(ovalIn: CGRect(x: cx - r, y: noseY - r, width: r * 2, height: r * 2))
            cg.addPath(path.cgPath)
            cg.setFillColor(noseFill.cgColor)
            cg.fillPath()
            cg.addPath(path.cgPath)
            cg.setStrokeColor(noseStroke.cgColor)
            cg.setLineWidth(0.7)
            cg.strokePath()
            // Highlight
            cg.addEllipse(in: CGRect(x: cx - 1.5, y: noseY - 2, width: 2.5, height: 2))
            cg.setFillColor(UIColor.white.withAlphaComponent(0.22).cgColor)
            cg.fillPath()
            
        case .ben:
            // Wider nose with nostrils
            let path = UIBezierPath(ovalIn: CGRect(x: cx - 5, y: noseY - 3, width: 10, height: 6.5))
            cg.addPath(path.cgPath)
            cg.setFillColor(noseFill.cgColor)
            cg.fillPath()
            cg.addPath(path.cgPath)
            cg.setStrokeColor(noseStroke.cgColor)
            cg.setLineWidth(0.7)
            cg.strokePath()
            for side: CGFloat in [-1, 1] {
                cg.addEllipse(in: CGRect(x: cx + side * 2.5 - 1, y: noseY - 0.5, width: 2, height: 1.8))
                cg.setFillColor(skin.darker(by: 0.16).cgColor)
                cg.fillPath()
            }
            
        case .chuck:
            // Round upturned nose
            let r: CGFloat = 3.5
            let path = UIBezierPath(ovalIn: CGRect(x: cx - r, y: noseY - r + 0.5, width: r * 2, height: r * 2 - 1))
            cg.addPath(path.cgPath)
            cg.setFillColor(noseFill.cgColor)
            cg.fillPath()
            cg.addPath(path.cgPath)
            cg.setStrokeColor(noseStroke.cgColor)
            cg.setLineWidth(0.7)
            cg.strokePath()
            cg.addEllipse(in: CGRect(x: cx - 1.5, y: noseY - 2.5, width: 3, height: 2))
            cg.setFillColor(UIColor.white.withAlphaComponent(0.22).cgColor)
            cg.fillPath()
            
        case .stella:
            // Delicate nose bridge
            let path = UIBezierPath()
            path.move(to: CGPoint(x: cx, y: noseY - 5))
            path.addQuadCurve(to: CGPoint(x: cx - 2.5, y: noseY + 1.5), controlPoint: CGPoint(x: cx - 1.5, y: noseY - 1))
            path.addQuadCurve(to: CGPoint(x: cx + 2.5, y: noseY + 1.5), controlPoint: CGPoint(x: cx, y: noseY + 3.5))
            path.addQuadCurve(to: CGPoint(x: cx, y: noseY - 5), controlPoint: CGPoint(x: cx + 1.5, y: noseY - 1))
            cg.addPath(path.cgPath)
            cg.setFillColor(noseFill.cgColor)
            cg.fillPath()
            // Bridge line
            let bridge = UIBezierPath()
            bridge.move(to: CGPoint(x: cx, y: noseY - 4))
            bridge.addLine(to: CGPoint(x: cx - 0.5, y: noseY))
            cg.addPath(bridge.cgPath)
            cg.setStrokeColor(noseStroke.cgColor)
            cg.setLineWidth(0.5)
            cg.setLineCap(.round)
            cg.strokePath()
        }
    }
    
    // MARK: - Mouth
    
    private static func drawMouth(in cg: CGContext, character: GameCharacter, expression: Expression) {
        switch expression {
        case .normal, .blink:
            drawNormalMouth(in: cg, character: character)
        case .happy:
            drawHappyMouth(in: cg, character: character)
        case .attacking:
            drawAttackingMouth(in: cg)
        case .hurt:
            drawHurtMouth(in: cg)
        case .dizzy:
            drawDizzyMouth(in: cg)
        }
    }
    
    private static func drawNormalMouth(in cg: CGContext, character: GameCharacter) {
        let mouthDark = UIColor(red: 0.38, green: 0.06, blue: 0.06, alpha: 1.0)
        let mouthColor = UIColor(red: 0.78, green: 0.28, blue: 0.28, alpha: 1.0)
        let gumColor = UIColor(red: 0.85, green: 0.58, blue: 0.58, alpha: 1.0)
        let toothColor = UIColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1.0)
        let toothStroke = UIColor(white: 0.78, alpha: 1.0)
        
        switch character {
        case .theo:
            // Gentle closed-mouth smile
            let smile = UIBezierPath()
            smile.addArc(withCenter: CGPoint(x: cx, y: mouthY - 2), radius: 6,
                         startAngle: .pi * 0.15, endAngle: .pi * 0.85, clockwise: true)
            cg.addPath(smile.cgPath)
            cg.setStrokeColor(mouthColor.cgColor)
            cg.setLineWidth(1.8)
            cg.setLineCap(.round)
            cg.strokePath()
            // Lip tint
            cg.addEllipse(in: CGRect(x: cx - 5, y: mouthY - 1.5, width: 10, height: 3.5))
            cg.setFillColor(mouthColor.withAlphaComponent(0.22).cgColor)
            cg.fillPath()
            
        case .ben:
            // Open grin with missing front teeth
            let grinW: CGFloat = 17
            let grinH: CGFloat = 9.5
            let grinRect = CGRect(x: cx - grinW / 2, y: mouthY - 3, width: grinW, height: grinH)
            let grin = UIBezierPath(roundedRect: grinRect, cornerRadius: 3.5)
            cg.addPath(grin.cgPath)
            cg.setFillColor(mouthDark.cgColor)
            cg.fillPath()
            cg.addPath(grin.cgPath)
            cg.setStrokeColor(mouthColor.cgColor)
            cg.setLineWidth(1.2)
            cg.strokePath()
            // Gum line
            let gum = UIBezierPath(rect: CGRect(x: cx - grinW / 2 + 1.5, y: mouthY - 2.5, width: grinW - 3, height: 2.5))
            cg.addPath(gum.cgPath)
            cg.setFillColor(gumColor.cgColor)
            cg.fillPath()
            // Teeth with center gap
            let teeth: [(CGFloat, CGFloat, CGFloat)] = [
                (cx - 7.5, 3.2, 4.5), (cx - 3.8, 3.0, 4.0),
                (cx + 1.5, 3.0, 4.0), (cx + 5.2, 3.2, 4.5)
            ]
            for t in teeth {
                let tooth = UIBezierPath(roundedRect: CGRect(x: t.0 - t.1 / 2, y: mouthY - 2.5, width: t.1, height: t.2), cornerRadius: 0.5)
                cg.addPath(tooth.cgPath)
                cg.setFillColor(toothColor.cgColor)
                cg.fillPath()
                cg.addPath(tooth.cgPath)
                cg.setStrokeColor(toothStroke.cgColor)
                cg.setLineWidth(0.35)
                cg.strokePath()
            }
            // Tongue in the gap
            cg.addEllipse(in: CGRect(x: cx - 2.5, y: mouthY + 0.5, width: 5, height: 3.5))
            cg.setFillColor(UIColor(red: 0.92, green: 0.45, blue: 0.45, alpha: 0.65).cgColor)
            cg.fillPath()
            
        case .chuck:
            // HUGE ear-to-ear grin with missing front teeth
            let grinW: CGFloat = 22
            let grinH: CGFloat = 10.5
            let grin = UIBezierPath()
            grin.move(to: CGPoint(x: cx - grinW / 2, y: mouthY - 1.5))
            grin.addQuadCurve(to: CGPoint(x: cx + grinW / 2, y: mouthY - 1.5),
                              controlPoint: CGPoint(x: cx, y: mouthY + grinH))
            grin.close()
            cg.addPath(grin.cgPath)
            cg.setFillColor(mouthDark.cgColor)
            cg.fillPath()
            cg.addPath(grin.cgPath)
            cg.setStrokeColor(mouthColor.cgColor)
            cg.setLineWidth(1.2)
            cg.strokePath()
            // Gum
            let gum = UIBezierPath(roundedRect: CGRect(x: cx - grinW / 2 + 2, y: mouthY - 1, width: grinW - 4, height: 2.5), cornerRadius: 1)
            cg.addPath(gum.cgPath)
            cg.setFillColor(gumColor.cgColor)
            cg.fillPath()
            // Teeth with big gap
            let teethData: [(CGFloat, CGFloat)] = [
                (cx - 9.5, 3.5), (cx - 6.5, 3.0), (cx - 4, 2.5),
                (cx + 4, 2.5), (cx + 6.5, 3.0), (cx + 9.5, 3.5)
            ]
            for td in teethData {
                let tooth = UIBezierPath(roundedRect: CGRect(x: td.0 - 1.3, y: mouthY - 1, width: 2.6, height: td.1), cornerRadius: 0.5)
                cg.addPath(tooth.cgPath)
                cg.setFillColor(toothColor.cgColor)
                cg.fillPath()
                cg.addPath(tooth.cgPath)
                cg.setStrokeColor(toothStroke.cgColor)
                cg.setLineWidth(0.35)
                cg.strokePath()
            }
            // Dark gap at center
            cg.addRect(CGRect(x: cx - 2, y: mouthY - 1.5, width: 4, height: 4.5))
            cg.setFillColor(mouthDark.cgColor)
            cg.fillPath()
            // Bottom lip
            let lip = UIBezierPath()
            lip.addArc(withCenter: CGPoint(x: cx, y: mouthY + 5.5), radius: 7,
                       startAngle: .pi * 1.2, endAngle: .pi * 1.8, clockwise: false)
            cg.addPath(lip.cgPath)
            cg.setStrokeColor(mouthColor.withAlphaComponent(0.4).cgColor)
            cg.setLineWidth(1)
            cg.setLineCap(.round)
            cg.strokePath()
            
        case .stella:
            // Smile showing teeth with braces
            let smileW: CGFloat = 16
            let smileH: CGFloat = 6.5
            let smileBg = UIBezierPath(roundedRect: CGRect(x: cx - smileW / 2, y: mouthY - 2, width: smileW, height: smileH), cornerRadius: 3)
            cg.addPath(smileBg.cgPath)
            cg.setFillColor(UIColor(red: 0.85, green: 0.45, blue: 0.45, alpha: 1.0).cgColor)
            cg.fillPath()
            // Individual teeth
            for i in 0..<7 {
                let tx = cx - smileW / 2 + 1.5 + CGFloat(i) * 2
                let tooth = UIBezierPath(roundedRect: CGRect(x: tx, y: mouthY - 1.5, width: 1.8, height: 4.5), cornerRadius: 0.3)
                cg.addPath(tooth.cgPath)
                cg.setFillColor(toothColor.cgColor)
                cg.fillPath()
                cg.addPath(tooth.cgPath)
                cg.setStrokeColor(UIColor(white: 0.85, alpha: 1.0).cgColor)
                cg.setLineWidth(0.25)
                cg.strokePath()
            }
            // Braces wire
            cg.addRect(CGRect(x: cx - smileW / 2 + 1, y: mouthY + 0.2, width: smileW - 2, height: 0.9))
            cg.setFillColor(UIColor(red: 0.68, green: 0.70, blue: 0.76, alpha: 1.0).cgColor)
            cg.fillPath()
            // Brackets
            for i in 0..<7 {
                let bx = cx - smileW / 2 + 1.8 + CGFloat(i) * 2
                let bracket = UIBezierPath(roundedRect: CGRect(x: bx, y: mouthY - 0.3, width: 1.4, height: 1.8), cornerRadius: 0.3)
                cg.addPath(bracket.cgPath)
                cg.setFillColor(UIColor(red: 0.78, green: 0.80, blue: 0.85, alpha: 1.0).cgColor)
                cg.fillPath()
                cg.addPath(bracket.cgPath)
                cg.setStrokeColor(UIColor(red: 0.58, green: 0.60, blue: 0.66, alpha: 0.8).cgColor)
                cg.setLineWidth(0.25)
                cg.strokePath()
            }
            // Colored elastic bands (pink/blue alternating)
            let elasticColors = [
                UIColor(red: 0.90, green: 0.48, blue: 0.68, alpha: 0.8),
                UIColor(red: 0.48, green: 0.68, blue: 0.90, alpha: 0.8)
            ]
            for i in 0..<7 {
                let ex = cx - smileW / 2 + 2.2 + CGFloat(i) * 2
                cg.addEllipse(in: CGRect(x: ex - 0.7, y: mouthY + 0.1, width: 1.4, height: 1.4))
                cg.setFillColor(elasticColors[i % 2].cgColor)
                cg.fillPath()
            }
            // Lip gloss highlight
            cg.addEllipse(in: CGRect(x: cx - 4, y: mouthY - 2.5, width: 5, height: 2))
            cg.setFillColor(UIColor.white.withAlphaComponent(0.25).cgColor)
            cg.fillPath()
        }
    }
    
    private static func drawHappyMouth(in cg: CGContext, character: GameCharacter) {
        let mouthDark = UIColor(red: 0.38, green: 0.06, blue: 0.06, alpha: 1.0)
        let mouthColor = UIColor(red: 0.78, green: 0.28, blue: 0.28, alpha: 1.0)
        let toothColor = UIColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1.0)
        
        switch character {
        case .theo:
            // Big open smile
            let smile = UIBezierPath()
            smile.move(to: CGPoint(x: cx - 8, y: mouthY - 1))
            smile.addQuadCurve(to: CGPoint(x: cx + 8, y: mouthY - 1),
                               controlPoint: CGPoint(x: cx, y: mouthY + 8))
            smile.close()
            cg.addPath(smile.cgPath)
            cg.setFillColor(mouthColor.cgColor)
            cg.fillPath()
            // Tongue
            cg.saveGState()
            cg.addPath(smile.cgPath)
            cg.clip()
            cg.addEllipse(in: CGRect(x: cx - 3, y: mouthY + 1, width: 6, height: 5))
            cg.setFillColor(UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.8).cgColor)
            cg.fillPath()
            cg.restoreGState()
            
        case .ben:
            // Big grin showing gap teeth
            let grinW: CGFloat = 19
            let grin = UIBezierPath()
            grin.move(to: CGPoint(x: cx - grinW / 2, y: mouthY - 2))
            grin.addQuadCurve(to: CGPoint(x: cx + grinW / 2, y: mouthY - 2),
                              controlPoint: CGPoint(x: cx, y: mouthY + 9))
            grin.close()
            cg.addPath(grin.cgPath)
            cg.setFillColor(mouthDark.cgColor)
            cg.fillPath()
            cg.addPath(grin.cgPath)
            cg.setStrokeColor(mouthColor.cgColor)
            cg.setLineWidth(1.0)
            cg.strokePath()
            // Teeth with gap
            cg.saveGState()
            cg.addPath(grin.cgPath)
            cg.clip()
            let teeth: [CGFloat] = [cx - 7, cx - 3.5, cx + 2, cx + 5.5]
            for tx in teeth {
                cg.addRect(CGRect(x: tx - 1.3, y: mouthY - 2, width: 2.8, height: 4))
                cg.setFillColor(toothColor.cgColor)
                cg.fillPath()
            }
            cg.restoreGState()
            
        case .chuck:
            // HUGE excited grin with gap
            let grinW: CGFloat = 24
            let grin = UIBezierPath()
            grin.move(to: CGPoint(x: cx - grinW / 2, y: mouthY - 2))
            grin.addQuadCurve(to: CGPoint(x: cx + grinW / 2, y: mouthY - 2),
                              controlPoint: CGPoint(x: cx, y: mouthY + 11))
            grin.close()
            cg.addPath(grin.cgPath)
            cg.setFillColor(mouthDark.cgColor)
            cg.fillPath()
            cg.addPath(grin.cgPath)
            cg.setStrokeColor(mouthColor.cgColor)
            cg.setLineWidth(1.0)
            cg.strokePath()
            cg.saveGState()
            cg.addPath(grin.cgPath)
            cg.clip()
            let teeth: [CGFloat] = [cx - 9, cx - 6, cx - 3.5, cx + 3.5, cx + 6, cx + 9]
            for tx in teeth {
                cg.addRect(CGRect(x: tx - 1.2, y: mouthY - 2, width: 2.5, height: 3.5))
                cg.setFillColor(toothColor.cgColor)
                cg.fillPath()
            }
            // Dark gap
            cg.addRect(CGRect(x: cx - 2, y: mouthY - 2, width: 4, height: 5))
            cg.setFillColor(mouthDark.cgColor)
            cg.fillPath()
            cg.restoreGState()
            
        case .stella:
            // Big smile showing braces
            let grinW: CGFloat = 18
            let grin = UIBezierPath()
            grin.move(to: CGPoint(x: cx - grinW / 2, y: mouthY - 1.5))
            grin.addQuadCurve(to: CGPoint(x: cx + grinW / 2, y: mouthY - 1.5),
                              controlPoint: CGPoint(x: cx, y: mouthY + 8))
            grin.close()
            cg.addPath(grin.cgPath)
            cg.setFillColor(UIColor(red: 0.82, green: 0.42, blue: 0.42, alpha: 1.0).cgColor)
            cg.fillPath()
            // Teeth + braces
            cg.saveGState()
            cg.addPath(grin.cgPath)
            cg.clip()
            for i in 0..<7 {
                let tx = cx - 6 + CGFloat(i) * 1.8
                cg.addRect(CGRect(x: tx, y: mouthY - 1.5, width: 1.6, height: 4))
                cg.setFillColor(toothColor.cgColor)
                cg.fillPath()
            }
            // Wire
            cg.addRect(CGRect(x: cx - grinW / 2 + 1, y: mouthY + 0.2, width: grinW - 2, height: 0.8))
            cg.setFillColor(UIColor(red: 0.68, green: 0.70, blue: 0.76, alpha: 1.0).cgColor)
            cg.fillPath()
            cg.restoreGState()
        }
    }
    
    private static func drawAttackingMouth(in cg: CGContext) {
        let mouth = UIBezierPath(ovalIn: CGRect(x: cx - 5.5, y: mouthY - 4, width: 11, height: 9))
        cg.addPath(mouth.cgPath)
        cg.setFillColor(UIColor(red: 0.48, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
        cg.fillPath()
        cg.addPath(mouth.cgPath)
        cg.setStrokeColor(UIColor(red: 0.68, green: 0.22, blue: 0.22, alpha: 1.0).cgColor)
        cg.setLineWidth(1.0)
        cg.strokePath()
    }
    
    private static func drawHurtMouth(in cg: CGContext) {
        let grimace = UIBezierPath()
        grimace.move(to: CGPoint(x: cx - 7, y: mouthY))
        grimace.addQuadCurve(to: CGPoint(x: cx - 2, y: mouthY), controlPoint: CGPoint(x: cx - 4.5, y: mouthY - 3))
        grimace.addQuadCurve(to: CGPoint(x: cx + 2, y: mouthY), controlPoint: CGPoint(x: cx, y: mouthY + 3))
        grimace.addQuadCurve(to: CGPoint(x: cx + 7, y: mouthY), controlPoint: CGPoint(x: cx + 4.5, y: mouthY - 3))
        cg.addPath(grimace.cgPath)
        cg.setStrokeColor(UIColor(red: 0.68, green: 0.22, blue: 0.22, alpha: 1.0).cgColor)
        cg.setLineWidth(2.0)
        cg.setLineCap(.round)
        cg.strokePath()
    }
    
    private static func drawDizzyMouth(in cg: CGContext) {
        let mouth = UIBezierPath(ovalIn: CGRect(x: cx - 6, y: mouthY - 4, width: 12, height: 9))
        cg.addPath(mouth.cgPath)
        cg.setFillColor(UIColor(red: 0.48, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
        cg.fillPath()
        cg.addPath(mouth.cgPath)
        cg.setStrokeColor(UIColor(red: 0.68, green: 0.22, blue: 0.22, alpha: 1.0).cgColor)
        cg.setLineWidth(1.0)
        cg.strokePath()
        // Tongue sticking out
        cg.addEllipse(in: CGRect(x: cx - 3.5, y: mouthY + 2, width: 7, height: 5))
        cg.setFillColor(UIColor(red: 1.0, green: 0.48, blue: 0.48, alpha: 0.85).cgColor)
        cg.fillPath()
    }
    
    // MARK: - Character Details
    
    private static func drawDetails(in cg: CGContext, character: GameCharacter) {
        switch character {
        case .theo:
            break // Glasses are rendered as SKShapeNodes on top
            
        case .ben:
            // Freckles across cheeks and nose
            let freckleColor = character.skinColor.darker(by: 0.18)
            let freckles: [(CGFloat, CGFloat)] = [
                (cx - 14, cheekY - 1), (cx - 12, cheekY - 3), (cx - 10, cheekY), (cx - 16, cheekY - 2),
                (cx + 10, cheekY - 1), (cx + 12, cheekY - 3), (cx + 14, cheekY), (cx + 16, cheekY - 2),
                (cx - 3, cheekY - 2), (cx + 3, cheekY - 2), (cx - 1, cheekY - 1), (cx + 1, cheekY - 3)
            ]
            for f in freckles {
                cg.addEllipse(in: CGRect(x: f.0 - 0.9, y: f.1 - 0.9, width: 1.8, height: 1.8))
                cg.setFillColor(freckleColor.cgColor)
                cg.fillPath()
            }
            
        case .chuck:
            // Dimples near mouth
            for side: CGFloat in [-1, 1] {
                let dimple = UIBezierPath()
                dimple.addArc(withCenter: CGPoint(x: cx + side * 13, y: mouthY + 1),
                              radius: 2.5, startAngle: .pi * 0.2, endAngle: .pi * 0.8, clockwise: true)
                cg.addPath(dimple.cgPath)
                cg.setStrokeColor(character.skinColor.darker(by: 0.12).cgColor)
                cg.setLineWidth(0.8)
                cg.setLineCap(.round)
                cg.strokePath()
            }
            
        case .stella:
            // Eyelashes
            let lashColor = UIColor(red: 0.2, green: 0.12, blue: 0.08, alpha: 0.85)
            for eyeX in [cx - 11.0, cx + 11.0] {
                for i in 0..<3 {
                    let baseAngle = CGFloat(i - 1) * 0.4
                    let startX = eyeX + CGFloat(i - 1) * 4.5
                    let startY = eyeY - 8
                    // Lashes point upward (negative Y in UIKit = upward on screen)
                    let endX = startX + sin(baseAngle) * 4.5
                    let endY = startY - cos(baseAngle) * 4.5
                    
                    let lash = UIBezierPath()
                    lash.move(to: CGPoint(x: startX, y: startY))
                    lash.addLine(to: CGPoint(x: endX, y: endY))
                    cg.addPath(lash.cgPath)
                    cg.setStrokeColor(lashColor.cgColor)
                    cg.setLineWidth(1.3)
                    cg.setLineCap(.round)
                    cg.strokePath()
                }
            }
            // Beauty mark
            cg.addEllipse(in: CGRect(x: cx + 11, y: mouthY - 6, width: 2, height: 2))
            cg.setFillColor(UIColor(red: 0.35, green: 0.22, blue: 0.15, alpha: 0.65).cgColor)
            cg.fillPath()
        }
    }
    
    // MARK: - Specular Highlight
    
    private static func drawHighlight(in cg: CGContext) {
        let hlColor = UIColor.white.withAlphaComponent(0.18)
        let hlClear = UIColor.white.withAlphaComponent(0.0)
        
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [hlColor.cgColor, hlClear.cgColor] as CFArray,
            locations: [0.0, 1.0]
        ) else { return }
        
        let center = CGPoint(x: cx - 8, y: cy - 12)
        cg.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                              endCenter: center, endRadius: 10, options: [])
    }
    
    // MARK: - Helpers
    
    private static func skinComponents(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b)
    }
}
