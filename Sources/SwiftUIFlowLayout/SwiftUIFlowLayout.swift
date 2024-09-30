import SwiftUI

public let flowLayoutDefaultItemSpacing: CGFloat = 8

public struct FlowLayout<RefreshBinding, Data: Collection, ItemView: View>: View {
  let mode: Mode
  @Binding var binding: RefreshBinding
  let items: Data
  let itemSpacing: CGFloat
  @ViewBuilder let viewMapping: (Data.Element) -> ItemView

  @State private var totalHeight: CGFloat

  public init(mode: Mode,
              binding: Binding<RefreshBinding>,
              items: Data,
              itemSpacing: CGFloat = flowLayoutDefaultItemSpacing,
              @ViewBuilder viewMapping: @escaping (Data.Element) -> ItemView) {
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
    var width = CGFloat.zero {
      didSet {
        if width == 0 {
          column = 0
        } else {
          column += 1
        }
      }
    }
    var column = 0
    var height = CGFloat.zero{
      didSet {
        if height == 0 {
          row = 0
        } else {
          row += 1
        }
      }
    }
    var row = 0
    var lastHeight = CGFloat.zero
    let itemCount = items.count
    return ZStack(alignment: .topLeading) {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            viewMapping(item)
              .alignmentGuide(.leading, computeValue: { d in
                if (abs(width - d.width) > g.size.width) {
                  width = 0
                  height -= lastHeight
                }
                lastHeight = d.height
                let currentWidth = width
                let extraWidth = -itemSpacing * CGFloat(column)
                if index == itemCount - 1 {
                  width = 0
                } else {
                  width -= d.width
                }
                return currentWidth + extraWidth
              })
              .alignmentGuide(.top, computeValue: { d in
                let currentHeight = height
                let extraHeight = -itemSpacing * CGFloat(row)
                if index == itemCount - 1 {
                  height = 0
                }
                return currentHeight + extraHeight
              })
        }
      }
      .background(HeightReaderView(binding: $totalHeight))
  }

  public enum Mode {
    case scrollable, vstack
  }
}

private struct HeightPreferenceKey: PreferenceKey {
  static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
  static var defaultValue: CGFloat = 0
}

private struct HeightReaderView: View {
  @Binding var binding: CGFloat
  var body: some View {
    GeometryReader { geo in
      Color.clear
           .preference(key: HeightPreferenceKey.self, value: geo.frame(in: .local).size.height)
    }
    .onPreferenceChange(HeightPreferenceKey.self) { h in
      binding = h
    }
  }
}


public extension FlowLayout where RefreshBinding == Never? {
    init(mode: Mode,
         items: Data,
         itemSpacing: CGFloat = flowLayoutDefaultItemSpacing,
         @ViewBuilder viewMapping: @escaping (Data.Element) -> ItemView) {
        self.init(mode: mode,
                  binding: .constant(nil),
                  items: items,
                  itemSpacing: itemSpacing,
                  viewMapping: viewMapping)
    }
}

struct FlowLayout_Previews: PreviewProvider {
  static var previews: some View {
    FlowLayout(mode: .scrollable,
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

struct TestWithDeletion: View {
    @State private var items = ["Some long item here", "And then some longer one",
                                "Short", "Items", "Here", "And", "A", "Few", "More",
                                "And then a very very very long long long long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long long long one", "and", "then", "some", "short short short ones"]
    
    var body: some View {
        VStack {
        Button("Delete all") {
            items.removeAll()
        }
            Button("Restore") {
                items = ["Some long item here", "And then some longer one",
                         "Short", "Items", "Here", "And", "A", "Few", "More",
                         "And then a very very very long long long long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long long long one", "and", "then", "some", "short short short ones"]
            }
            Button("Add one") {
                items.append("\(Date().timeIntervalSince1970)")
            }
        FlowLayout(mode: .vstack,
                   items: items) {
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
}

struct TestWithDeletion_Previews: PreviewProvider {
  static var previews: some View {
    TestWithDeletion()
  }
}

struct TestWithRange_Previews: PreviewProvider {
    static var previews: some View {
        FlowLayout(mode: .scrollable,
                   items: 1..<100) {
            Text("\($0)")
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding()
                .background(RoundedRectangle(cornerRadius: 4)
                    .border(Color.gray)
                    .foregroundColor(Color.gray))
        }.padding()
    }
}
