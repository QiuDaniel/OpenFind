//
//  CameraVC+Highlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func setupHighlights() {
        /// for highlights, make appear after frames are set

        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        scrollZoomViewController.addChildViewController(highlightsViewController, in: scrollZoomViewController.drawingView)
    }
    
    /// fast live preview
    func getHighlights(from fastSentences: [FastSentence]) -> Set<Highlight> {
        var highlights = Set<Highlight>()
        for sentence in fastSentences {
            for (string, gradient) in self.searchViewModel.stringToGradients {
                let indices = sentence.string.lowercased().indicesOf(string: string.lowercased())
                for index in indices {
                    let word = sentence.getWord(word: string, at: index)
 
                    let highlight = Highlight(
                        string: word.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: .init(
                            originalPoint: .zero,
                            pivotPoint: .zero,
                            center: word.frame.center,
                            size: word.frame.size,
                            angle: .zero
                        )
                    )
                    highlights.insert(highlight)
                }
            }
        }
        return highlights
    }
    
    /// scanned
    func getHighlights(from sentences: [Sentence]) -> Set<Highlight> {
        var highlights = Set<Highlight>()
        for sentence in sentences {
            let rangeResults = sentence.ranges(of: Array(self.searchViewModel.stringToGradients.keys))
            for rangeResult in rangeResults {
                let gradient = self.searchViewModel.stringToGradients[rangeResult.string] ?? SearchViewModel.Gradient()
                for range in rangeResult.ranges {
                    let highlight = Highlight(
                        string: rangeResult.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: sentence.position(for: range)
                    )
                    highlights.insert(highlight)
                }
            }
        }
        return highlights
    }
    
    /// replaces highlights completely
    func updateHighlightColors() {
        var newHighlights = Set<Highlight>()
        let stringToGradients = searchViewModel.stringToGradients
        
        for index in highlightsViewModel.highlights.indices {
            let highlight = highlightsViewModel.highlights[index]
            let gradient = stringToGradients[highlight.string]
            var newHighlight = highlight
            
            if let gradient = gradient {
                newHighlight.colors = gradient.colors
                newHighlight.alpha = gradient.alpha
            }
            
            newHighlights.insert(newHighlight)
        }
        
        self.highlightsViewModel.highlights = newHighlights
    }
}
