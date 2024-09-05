import SwiftUI

public let flowLayoutDefaultItemSpacing: CGFloat = 4

public struct FlowLayout<Trigger, Data, Content>: View where Data: RandomAccessCollection, Data.Element: Hashable, Content: View {
  let mode: Mode
  @Binding var trigger: Trigger
  let data: Data
  let spacing: CGFloat
  @ViewBuilder let content: (Data.Element) -> Content

  @State private var totalHeight: CGFloat

  public init(mode: Mode,
              trigger: Binding<Trigger>,
              data: Data,
              spacing: CGFloat = flowLayoutDefaultItemSpacing,
              @ViewBuilder content: @escaping (Data.Element) -> Content) {
    self.mode = mode
    _trigger = trigger
    self.data = data
    self.spacing = spacing
    self.content = content
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
    let itemCount = data.count
    return ZStack(alignment: .topLeading) {
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
            content(item)
              .padding([.horizontal, .vertical], spacing)
              .alignmentGuide(.leading, computeValue: { d in
                if (abs(width - d.width) > g.size.width) {
                  width = 0
                  height -= lastHeight
                }
                lastHeight = d.height
                let result = width
                if index == itemCount - 1 {
                  width = 0
                } else {
                  width -= d.width
                }
                return result
              })
              .alignmentGuide(.top, computeValue: { d in
                let result = height
                if index == itemCount - 1 {
                  height = 0
                }
                return result
              })
        }
      }
      .background(HeightReaderView(trigger: $totalHeight))
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
  @Binding var trigger: CGFloat
  var body: some View {
    GeometryReader { geo in
      Color.clear
           .preference(key: HeightPreferenceKey.self, value: geo.frame(in: .local).size.height)
    }
    .onPreferenceChange(HeightPreferenceKey.self) { h in
      trigger = h
    }
  }
}


public extension FlowLayout where Trigger == Never? {
    init(mode: Mode,
         data: Data,
         spacing: CGFloat = flowLayoutDefaultItemSpacing,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.init(mode: mode,
                  trigger: .constant(nil),
                  data: data,
                  spacing: spacing,
                  content: content)
    }
}

struct FlowLayout_Previews: PreviewProvider {
  static var previews: some View {
    FlowLayout(mode: .scrollable,
               data: ["Some long item here", "And then some longer one",
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
    @State private var data = ["Some long item here", "And then some longer one",
                                "Short", "Items", "Here", "And", "A", "Few", "More",
                                "And then a very very very long long long long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long long long one", "and", "then", "some", "short short short ones"]
    
    var body: some View {
        VStack {
        Button("Delete all") {
            data.removeAll()
        }
            Button("Restore") {
                data = ["Some long item here", "And then some longer one",
                         "Short", "Items", "Here", "And", "A", "Few", "More",
                         "And then a very very very long long long long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long long long one", "and", "then", "some", "short short short ones"]
            }
            Button("Add one") {
                data.append("\(Date().timeIntervalSince1970)")
            }
        FlowLayout(mode: .vstack,
                   data: data) {

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
                   data: 1..<100) {
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

// MARK: Migration Helpers

public extension FlowLayout {
    @available(swift, obsoleted: 1.1.0, renamed: "attemptConnection")
    var viewMapping: (Data.Element) -> Content { content }

    @available(swift, obsoleted: 1.1.0, renamed: "init(mode:trigger:data:spacing:content:)")
    init(mode: Mode,
         binding: Binding<Trigger>,
         items: Data,
         itemSpacing: CGFloat = flowLayoutDefaultItemSpacing,
         @ViewBuilder viewMapping: @escaping (Data.Element) -> Content) {
        self.init(mode: mode,
                  trigger: binding,
                  data: items,
                  spacing: itemSpacing,
                  content: viewMapping)
    }
}

public extension FlowLayout where Trigger == Never? {
    @available(swift, obsoleted: 1.1.0, renamed: "init(mode:data:spacing:content:)")
    init(mode: Mode,
         items: Data,
         itemSpacing: CGFloat = flowLayoutDefaultItemSpacing,
         @ViewBuilder viewMapping: @escaping (Data.Element) -> Content) {
        self.init(
            mode: mode,
            trigger: .constant(nil),
            data: items,
            spacing: itemSpacing,
            content: viewMapping
        )
    }
}
