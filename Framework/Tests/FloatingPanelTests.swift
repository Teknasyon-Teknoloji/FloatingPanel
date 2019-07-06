//
//  Created by Shin Yamamoto on 2019/05/23.
//  Copyright © 2019 Shin Yamamoto. All rights reserved.
//

import XCTest
@testable import FloatingPanel

class FloatingPanelTests: XCTestCase {
    override func setUp() {}
    override func tearDown() {}

    func test_scrolllock() {
        let fpc = FloatingPanelController()

        let contentVC1 = UITableViewController(nibName: nil, bundle: nil)
        XCTAssertEqual(contentVC1.tableView.showsVerticalScrollIndicator, true)
        XCTAssertEqual(contentVC1.tableView.bounces, true)
        fpc.set(contentViewController: contentVC1)
        fpc.track(scrollView: contentVC1.tableView)
        fpc.showForTest()

        XCTAssertEqual(fpc.position, .half)
        XCTAssertEqual(contentVC1.tableView.showsVerticalScrollIndicator, false)
        XCTAssertEqual(contentVC1.tableView.bounces, false)

        fpc.move(to: .full, animated: false)
        XCTAssertEqual(contentVC1.tableView.showsVerticalScrollIndicator, true)
        XCTAssertEqual(contentVC1.tableView.bounces, true)

        fpc.move(to: .tip, animated: false)
        XCTAssertEqual(contentVC1.tableView.showsVerticalScrollIndicator, false)
        XCTAssertEqual(contentVC1.tableView.bounces, false)

        let exp1 = expectation(description: "move to full with animation")
        fpc.move(to: .full, animated: true) {
            XCTAssertEqual(contentVC1.tableView.showsVerticalScrollIndicator, true)
            XCTAssertEqual(contentVC1.tableView.bounces, true)
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 1.0)

        let exp2 = expectation(description: "move to tip with animation")
        fpc.move(to: .tip, animated: false) {
            XCTAssertEqual(contentVC1.tableView.showsVerticalScrollIndicator, false)
            XCTAssertEqual(contentVC1.tableView.bounces, false)
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)

        // Reset the content vc
        let contentVC2 = UITableViewController(nibName: nil, bundle: nil)
        XCTAssertEqual(contentVC2.tableView.showsVerticalScrollIndicator, true)
        XCTAssertEqual(contentVC2.tableView.bounces, true)
        fpc.set(contentViewController: contentVC2)
        fpc.track(scrollView: contentVC2.tableView)
        fpc.show(animated: false, completion: nil)
        XCTAssertEqual(fpc.position, .half)
        XCTAssertEqual(contentVC2.tableView.showsVerticalScrollIndicator, false)
        XCTAssertEqual(contentVC2.tableView.bounces, false)
    }

    func test_targetPosition_2positions() {
        class FloatingPanelLayout2Positions: FloatingPanelTestLayout {
            let initialPosition: FloatingPanelPosition = .half
            let supportedPositions: Set<FloatingPanelPosition> = [.half, .full]
        }
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout2Positions()

        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()

        let fullPos = fpc.originYOfSurface(for: .full)
        let halfPos = fpc.originYOfSurface(for: .half)

        fpc.move(to: .full, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 1000.0), .half), // project to half
            (#line, fullPos, CGPoint(x: 0.0, y: -1000.0), .full), // redirect
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .half), // project to half
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, halfPos - 10.0, CGPoint(x: 0.0, y: -100.0), .half), // redirect
            (#line, halfPos, CGPoint(x: 0.0, y: -1000.0), .full),  // project to full
            (#line, halfPos, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .half), // redirect
            (#line, halfPos + 10.0, CGPoint(x: 0.0, y: -1000.0), .full), // project to full
            ])
        fpc.move(to: .half, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 1000.0), .half), // project to half
            (#line, fullPos, CGPoint(x: 0.0, y: -1000.0), .full), // redirect
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .half), // project to half
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, halfPos - 10.0, CGPoint(x: 0.0, y: -100.0), .half), // redirect
            (#line, halfPos, CGPoint(x: 0.0, y: -1000.0), .full),  // project to full
            (#line, halfPos, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .half), // redirect
            (#line, halfPos + 10.0, CGPoint(x: 0.0, y: -1000.0), .full), // project to full
            ])
    }

    func test_targetPosition_2positionsWithHidden() {
        class FloatingPanelLayout2Positions: FloatingPanelTestLayout {
            let initialPosition: FloatingPanelPosition = .hidden
            let supportedPositions: Set<FloatingPanelPosition> = [.hidden, .full]
        }
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout2Positions()

        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()

        let fullPos = fpc.originYOfSurface(for: .full)
        let hiddenPos = fpc.originYOfSurface(for: .hidden)

        fpc.move(to: .full, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 1000.0), .hidden), // project to hidden
            (#line, fullPos, CGPoint(x: 0.0, y: -1000.0), .full), // redirect
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .hidden), // project to hidden
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, hiddenPos - 10.0, CGPoint(x: 0.0, y: -100.0), .hidden), // redirect
            (#line, hiddenPos, CGPoint(x: 0.0, y: -1000.0), .full),  // project to full
            (#line, hiddenPos, CGPoint(x: 0.0, y: -100.0), .hidden),
            (#line, hiddenPos, CGPoint(x: 0.0, y: 0.0), .hidden),
            (#line, hiddenPos, CGPoint(x: 0.0, y: 100.0), .hidden),
            (#line, hiddenPos, CGPoint(x: 0.0, y: 1000.0), .hidden), // redirect
            (#line, hiddenPos + 10.0, CGPoint(x: 0.0, y: -1000.0), .full), // project to full
            ])
        fpc.move(to: .hidden, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 1000.0), .hidden), // project to hidden
            (#line, fullPos, CGPoint(x: 0.0, y: -1000.0), .full), // redirect
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .hidden), // project to hidden
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, hiddenPos - 10.0, CGPoint(x: 0.0, y: -100.0), .hidden), // redirect
            (#line, hiddenPos, CGPoint(x: 0.0, y: -1000.0), .full),  // project to full
            (#line, hiddenPos, CGPoint(x: 0.0, y: -100.0), .hidden),
            (#line, hiddenPos, CGPoint(x: 0.0, y: 0.0), .hidden),
            (#line, hiddenPos, CGPoint(x: 0.0, y: 100.0), .hidden),
            (#line, hiddenPos, CGPoint(x: 0.0, y: 1000.0), .hidden), // redirect
            (#line, hiddenPos + 10.0, CGPoint(x: 0.0, y: -1000.0), .full), // project to full
            ])
    }

    func test_targetPosition_2positionsFromFull() {
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout3Positions()
        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()

        let fullPos = fpc.originYOfSurface(for: .full)
        let halfPos = fpc.originYOfSurface(for: .half)
        let tipPos = fpc.originYOfSurface(for: .tip)
        // From .full
        fpc.move(to: .full, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: -100.0), .full), // far from topMostState
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: 0.0), .full), // far from topMostState
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: 100.0), .full), // far from topMostState
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 3000.0), .half), // block projecting to tip at half
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 500.0), .half), // project to half
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .half), // block projecting to tip at half
            (#line, fullPos, CGPoint(x: 0.0, y: 3000.0), .half), // block projecting to tip at half
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, halfPos - 10.0, CGPoint(x: 0.0, y: -100.0), .half), // redirect
            (#line, halfPos, CGPoint(x: 0.0, y: -1000.0), .full), //project to full
            (#line, halfPos, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .tip), // project to tip
            (#line, halfPos + 10.0, CGPoint(x: 0.0, y: 100.0), .half), // redirect
            (#line, tipPos - 10.0, CGPoint(x: 0.0, y: -100.0), .tip), // redirect
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .half), // block projecting to full at half
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .half), // block projecting to full at half
            (#line, tipPos, CGPoint(x: 0.0, y: -500.0), .half), // project to half
            (#line, tipPos, CGPoint(x: 0.0, y: -100.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 0.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 100.0), .tip),
            (#line, tipPos + 10.0, CGPoint(x: 0.0, y: -3000.0), .half), // block projecting to full at half
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: -100.0), .tip), // far from bottomMostState
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: 0.0), .tip), // far from bottomMostState
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: 100.0), .tip), // far from bottomMostState
            ])
    }

    func test_targetPosition_3positionsFromHalf() {
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout3Positions()
        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()

        let fullPos = fpc.originYOfSurface(for: .full)
        let halfPos = fpc.originYOfSurface(for: .half)
        let tipPos = fpc.originYOfSurface(for: .tip)
        // From .half
        fpc.move(to: .half, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: -100.0), .full), // far from topMostState
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: 0.0), .full), // far from topMostState
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: 100.0), .full), // far from topMostState
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 500.0), .half), // project to half
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .half), // block projecting to tip at half
            (#line, fullPos, CGPoint(x: 0.0, y: 3000.0), .half), // block projecting to tip at half
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, halfPos - 10.0, CGPoint(x: 0.0, y: -100.0), .half), // redirect
            (#line, halfPos, CGPoint(x: 0.0, y: -1000.0), .full),// project to full
            (#line, halfPos, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .tip), // project to tip
            (#line, halfPos + 10.0, CGPoint(x: 0.0, y: 100.0), .half), // redirect
            (#line, tipPos - 10.0, CGPoint(x: 0.0, y: -100.0), .tip), // redirect
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .half), // block projecting to full at half
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .half), // block projecting to full at half
            (#line, tipPos, CGPoint(x: 0.0, y: -500.0), .half), // project to half
            (#line, tipPos, CGPoint(x: 0.0, y: -100.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 0.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 100.0), .tip),
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: -100.0), .tip), // far from bottomMostState
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: 0.0), .tip), // far from bottomMostState
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: 100.0), .tip), // far from bottomMostState
            ])
    }

    func test_targetPosition_3positionsFromTip() {
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout3Positions()
        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()

        let fullPos = fpc.originYOfSurface(for: .full)
        let halfPos = fpc.originYOfSurface(for: .half)
        let tipPos = fpc.originYOfSurface(for: .tip)

        // From .tip
        fpc.move(to: .tip, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: -100.0), .full), // far from topMostState
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: 0.0), .full), // far from topMostState
            (#line, fullPos - 500.0, CGPoint(x: 0.0, y: 100.0), .full), // far from topMostState
            (#line, fullPos, CGPoint(x: 0.0, y: -100.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 0.0), .full),
            (#line, fullPos, CGPoint(x: 0.0, y: 500.0), .half), // project to half
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .half), // block projecting to tip at half
            (#line, fullPos, CGPoint(x: 0.0, y: 3000.0), .half), // block projecting to tip at half
            (#line, fullPos + 10.0, CGPoint(x: 0.0, y: 100.0), .full), // redirect
            (#line, halfPos - 10.0, CGPoint(x: 0.0, y: -100.0), .half), // redirect
            (#line, halfPos, CGPoint(x: 0.0, y: -3000.0), .full), // project to full
            (#line, halfPos, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .tip), // project to tip
            (#line, halfPos + 10.0, CGPoint(x: 0.0, y: 100.0), .half), // redirect
            (#line, tipPos - 10.0, CGPoint(x: 0.0, y: -100.0), .tip), // redirect
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .half), // block projecting to full at half
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .half), // block projecting to full at half
            (#line, tipPos, CGPoint(x: 0.0, y: -500.0), .half), // project to half
            (#line, tipPos, CGPoint(x: 0.0, y: -100.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 0.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 100.0), .tip),
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: -100.0), .tip), // far from bottomMostState
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: 0.0), .tip), // far from bottomMostState
            (#line, tipPos + 500.0, CGPoint(x: 0.0, y: 100.0), .tip), // far from bottomMostState
            ])
    }

    func test_targetPosition_3positionsAllProjection() {
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout3Positions()
        delegate.behavior = FloatingPanelProjectionalBehavior()

        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()

        let fullPos = fpc.originYOfSurface(for: .full)
        let halfPos = fpc.originYOfSurface(for: .half)
        let tipPos = fpc.originYOfSurface(for: .tip)

        // From .full
        fpc.move(to: .full, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 3000.0), .tip),
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .tip),
            (#line, fullPos, CGPoint(x: 0.0, y: 3000.0), .tip),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .tip),
            (#line, halfPos, CGPoint(x: 0.0, y: -1000.0), .full),
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .full),
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .full),
            (#line, tipPos + 10.0, CGPoint(x: 0.0, y: -3000.0), .full),
            ])

        // From .half
        fpc.move(to: .tip, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .tip),
            (#line, fullPos, CGPoint(x: 0.0, y: 3000.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .full),
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .full),
            ])

        // From .tip
        fpc.move(to: .tip, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fullPos - 10.0, CGPoint(x: 0.0, y: 3000.0), .tip),
            (#line, fullPos, CGPoint(x: 0.0, y: 1000.0), .tip),
            (#line, fullPos, CGPoint(x: 0.0, y: 3000.0), .tip),
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .tip),
            (#line, halfPos, CGPoint(x: 0.0, y: -1000.0), .full),
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .full),
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .full),
            (#line, tipPos + 10.0, CGPoint(x: 0.0, y: -3000.0), .full),
            ])
    }

    func test_targetPosition_3positionsWithHidden() {
        class FloatingPanelLayout3PositionsWithHidden: FloatingPanelTestLayout {
            let initialPosition: FloatingPanelPosition = .hidden
            let supportedPositions: Set<FloatingPanelPosition> = [.hidden, .half, .full]
        }
        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout3PositionsWithHidden()

        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()
        XCTAssertEqual(fpc.position, .hidden)

        fpc.move(to: .full, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fpc.surfaceView.frame.minY, CGPoint(x: 0.0, y: 1000.0), .half),
            ])
        fpc.move(to: .half, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, fpc.surfaceView.frame.minY, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, fpc.surfaceView.frame.minY, CGPoint(x: 0.0, y: -1000.0), .full),
            (#line, fpc.surfaceView.frame.minY, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, fpc.surfaceView.frame.minY, CGPoint(x: 0.0, y: 1000.0), .hidden),
            ])
    }

    func test_targetPosition_3positionsWithHiddenWithoutFull() {
        class FloatingPanelLayout3Positions: FloatingPanelTestLayout {
            let initialPosition: FloatingPanelPosition = .hidden
            let supportedPositions: Set<FloatingPanelPosition> = [.hidden, .tip, .half]
        }

        let delegate = FloatingPanelTestDelegate()
        delegate.layout = FloatingPanelLayout3Positions()
        delegate.behavior = FloatingPanelProjectionalBehavior()

        let fpc = FloatingPanelController(delegate: delegate)
        fpc.showForTest()
        XCTAssertEqual(fpc.position, .hidden)

        let halfPos = fpc.originYOfSurface(for: .half)
        let tipPos = fpc.originYOfSurface(for: .tip)
        //let hiddenPos = fpc.originYOfSurface(for: .hidden)

        fpc.move(to: .half, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, halfPos, CGPoint(x: 0.0, y: -100.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 0.0), .half),
            (#line, halfPos, CGPoint(x: 0.0, y: 385.0), .tip), // projection
            (#line, halfPos, CGPoint(x: 0.0, y: 1000.0), .hidden), // projection
            (#line, halfPos + 10.0, CGPoint(x: 0.0, y: 100.0), .half), // redirection
            (#line, tipPos - 10.0, CGPoint(x: 0.0, y: -100.0), .tip), // redirection
            (#line, tipPos, CGPoint(x: 0.0, y: -3000.0), .half), //projection
            (#line, tipPos, CGPoint(x: 0.0, y: -10.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 0.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 10.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 1000.0), .hidden), //projection
            (#line, tipPos + 10.0, CGPoint(x: 0.0, y: 10.0), .tip), // redirection
            (#line, tipPos - 10.0, CGPoint(x: 0.0, y: 10.0), .tip), // redirection
            ])
        fpc.move(to: .tip, animated: false)
        assertTargetPosition(fpc.floatingPanel, with: [
            (#line, tipPos, CGPoint(x: 0.0, y: -100.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: -1000.0), .half),
            (#line, tipPos, CGPoint(x: 0.0, y: 0.0), .tip),
            (#line, tipPos, CGPoint(x: 0.0, y: 1000.0), .hidden),
            ])
    }
}

private class FloatingPanelLayout3Positions: FloatingPanelTestLayout {
    let initialPosition: FloatingPanelPosition = .tip
    let supportedPositions: Set<FloatingPanelPosition> = [.tip, .half, .full]
}

private typealias TestParameter = (UInt, CGFloat,CGPoint, FloatingPanelPosition)
private func assertTargetPosition(_ floatingPanel: FloatingPanel, with params: [TestParameter]) {
    params.forEach { (line, pos, velocity, result) in
        floatingPanel.surfaceView.frame.origin.y = pos
        XCTAssertEqual(floatingPanel.targetPosition(from: pos, with: velocity), result, line: line)
    }
}

private protocol FloatingPanelTestLayout: FloatingPanelFullScreenLayout {}
private extension FloatingPanelTestLayout {
    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 20.0
        case .half: return 250.0
        case .tip: return 60.0
        default: return nil
        }
    }
}
private class FloatingPanelProjectionalBehavior: FloatingPanelBehavior {
    func shouldProjectMomentum(_ fpc: FloatingPanelController, for proposedTargetPosition: FloatingPanelPosition) -> Bool {
        return true
    }
}
