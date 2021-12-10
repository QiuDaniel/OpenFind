//
//  PopoverReader.swift
//  Popover
//
//  Created by Zheng on 12/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct PopoverReader<Content: View>: View {
    
    @ViewBuilder var content: (Popover.Context) -> Content
    @EnvironmentObject var context: Popover.Context

    var body: some View {
        content(context)
    }
}
