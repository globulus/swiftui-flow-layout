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
    var lastHeight = CGFloat.zero
    return ZStack(alignment: .topLeading) {
      ForEach(self.items, id: \.self) { item in
        self.viewMapping(item)
          .padding([.horizontal, .vertical], itemSpacing)
          .alignmentGuide(.leading, computeValue: { d in
            if (abs(width - d.width) > g.size.width) {
              width = 0
              height -= lastHeight
            }
            lastHeight = d.height
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

struct FlowLayout_Previews: PreviewProvider {
  static var previews: some View {
    FlowLayout(mode: .scrollable,
                               binding: .constant(5),
                               items: ["Some long item here", "And then some longer one",
                                          "Short", "Items", "Here", "And", "A", "Few", "More",
                                          "And then a very very very long long long long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long long long one", "and", "then", "some", "short short short ones"]) {
      Text($0)
        .font(.system(size: 12))
        .foregroundColor(.black)
        .padding()
        .background(RoundedRectangle(cornerRadius: 4)
                               .border(Color.gray)
                               .foregroundColor(Color.gray))
    }.padding()
  }
}
