//
//  Sentence.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct FastSentence {
    var string: String
    var frame: CGRect

    /// If self is a sentence
    func getWord(word: String, at index: Int) -> FastSentence {
        let wordCount = CGFloat(word.count)
        let individualCharacterLength = frame.width / CGFloat(string.count)

        let wordOriginX = frame.minX + individualCharacterLength * CGFloat(index)
        let wordWidth = individualCharacterLength * wordCount
        let wordFrame = CGRect(x: wordOriginX, y: frame.minY, width: wordWidth, height: frame.height)

        let word = FastSentence(
            string: word,
            frame: wordFrame
        )

        return word
    }
}

struct Sentence {
    static var calculatingFont = UIFont.systemFont(ofSize: 10)

    var string: String

    var confidence: Double

    /// normalized points from `0` to `1`
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint

    func getText(in range: Range<Int>) -> String {
        let start = string.index(string.startIndex, offsetBy: range.lowerBound)
        let end = string.index(string.startIndex, offsetBy: range.upperBound)
        let text = string[start ..< end]
        return String(text)
    }

    func getWidth(of text: String) -> CGFloat {
        let textWidth = Sentence.calculatingFont.sizeOfString(text).width
        return textWidth
    }

    /// pass in `imageSize` to calculate angle
    func getPosition(for range: Range<Int>, imageSize: CGSize?) -> ScannedPosition {
        /// width, height, and center for the entire sentence
        let sentenceWidth = CGPointDistance(from: topLeft, to: topRight)
        let sentenceHeight = CGPointDistance(from: topLeft, to: bottomLeft)

        let originString = getText(in: 0 ..< range.lowerBound) /// text before the highlight
        let highlightText = getText(in: range) /// the highlight's text

        let sentenceStringWidth = getWidth(of: string)
        let originStringWidth = getWidth(of: originString) / sentenceStringWidth
        let highlightStringWidth = getWidth(of: highlightText) / sentenceStringWidth

        let highlightXOffset = originStringWidth * sentenceWidth
        let highlightWidth = highlightStringWidth * sentenceWidth

        let yDifference = topRight.y - topLeft.y
        let xDifference = topRight.x - topLeft.x
        let normalizedAngle = atan2(yDifference, xDifference)

        var scaledAngle = CGFloat(0)
        if let imageSize = imageSize {
            let topRightScaled = CGPoint(
                x: topRight.x * imageSize.width,
                y: topRight.y * imageSize.height
            )
            let topLeftScaled = CGPoint(
                x: topLeft.x * imageSize.width,
                y: topLeft.y * imageSize.height
            )
            let yDifference = topRightScaled.y - topLeftScaled.y
            let xDifference = topRightScaled.x - topLeftScaled.x
            scaledAngle = atan2(yDifference, xDifference)
        }

        let sentenceWidthCenter = sentenceWidth / 2
        let highlightCenterRelativeToSentenceCenter = highlightXOffset + highlightWidth / 2

        let highlightDistanceToSentenceCenter = highlightCenterRelativeToSentenceCenter - sentenceWidthCenter
        let highlightRotationalXOffset = highlightDistanceToSentenceCenter * cos(normalizedAngle)
        let highlightRotationalYOffset = highlightDistanceToSentenceCenter * sin(normalizedAngle)

        let sentenceCenter = CGPoint(
            x: (topRight.x + bottomLeft.x) / 2,
            y: (topRight.y + bottomLeft.y) / 2
        )

        let highlightCenter = CGPoint(
            x: sentenceCenter.x + highlightRotationalXOffset,
            y: sentenceCenter.y + highlightRotationalYOffset
        )

        let highlightSize = CGSize(width: highlightWidth, height: sentenceHeight)

        let position = ScannedPosition(
            center: highlightCenter,
            size: highlightSize,
            angle: scaledAngle
        )

        return position
    }
}
