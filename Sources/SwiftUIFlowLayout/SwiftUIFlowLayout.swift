import SwiftUI

public struct FlowLayout<B, T: Hashable, V: View>: View {
  let mode: Mode
  @Binding var binding: B
  let items: [T]
  let itemSpacing: CGFloat
  @ViewBuilder let viewMapping: (T) -> V

  @State private var totalHeight: CGFloat

  public init(mode: Mode,
              binding: Binding<B>,
              items: [T],
              itemSpacing: CGFloat = 4,
              @ViewBuilder viewMapping: @escaping (T) -> V) {
    self.mode = mode
    _binding = binding
    self.items = items
    self.itemSpacing = itemSpacing
    self.viewMapping = viewMapping
    _totalHeight = State(initialValue: (mode == .scrollable) ? .zero : .infinity)
  }

  public var body: some View {
    let stack = VStack {
       GeometryReader { geometry in
         self.content(in: geometry)
       }
    }
    return Group {
      if mode == .scrollable {
        stack.frame(height: totalHeight)
      } else {
        stack.frame(maxHeight: totalHeight)
      }
    }
  }

  private func content(in g: GeometryProxy) -> some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    return ZStack(alignment: .topLeading) {
      ForEach(self.items, id: \.self) { item in
        self.viewMapping(item)
          .padding([.horizontal, .vertical], itemSpacing)
          .alignmentGuide(.leading, computeValue: { d in
            if (abs(width - d.width) > g.size.width) {
              width = 0
              height -= d.height
            }
            let result = width
            if item == self.items.last {
              width = 0
            } else {
              width -= d.width
            }
            return result
          })
          .alignmentGuide(.top, computeValue: { d in
            let result = height
            if item == self.items.last {
              height = 0
            }
            return result
          })
        }
      }
      .background(viewHeightReader($totalHeight))
  }

  private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
    return GeometryReader { geo -> Color in
      DispatchQueue.main.async {
        binding.wrappedValue = geo.frame(in: .local).size.height
      }
      return .clear
    }
  }

  public enum Mode {
    case scrollable, vstack
  }
}
