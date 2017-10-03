////
///  StreamableScreen.swift
//

protocol StreamableScreenProtocol: class {
    var navigationBarTopConstraint: NSLayoutConstraint! { get }
    var navigationBar: ElloNavigationBar { get }
    func viewForStream() -> UIView
}

class StreamableScreen: Screen, StreamableScreenProtocol {
    let navigationBar = ElloNavigationBar()
    var navigationBarTopConstraint: NSLayoutConstraint!
    let streamContainer = UIView()

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    override func arrange() {
        addSubview(streamContainer)
        addSubview(navigationBar)

        navigationBar.snp.makeConstraints { make in
            let c = make.top.equalTo(self).constraint
            navigationBarTopConstraint = c.layoutConstraints.first!
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
        streamContainer.snp.makeConstraints { make in
            make.edges.equalTo(self)
            streamContainer.frame = self.bounds
        }
    }

    func viewForStream() -> UIView {
        return streamContainer
    }

}
