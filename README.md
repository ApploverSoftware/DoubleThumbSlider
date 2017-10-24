# DoubleFader
### Double Slider, Fader iOS

![Lhe5Ys](https://i.makeagif.com/media/10-24-2017/Lhe5Ys.gif)


### Example usage
    let fader = Fader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fader.frame = UIScreen.main.bounds.insetBy(dx: 32, dy: UIScreen.main.bounds.height / 2.3)
        fader.delegate = self
        fader.minValue = 4
        fader.maxValue = 20
        fader.leftThumbBackgroundColor = UIColor.orange
        fader.rightThumbBackgroundColor = UIColor.orange
        fader.rangeLineColor = UIColor.orange
        fader.lineHeight = 6
        fader.thumbRadius = 15
        
        view.addSubview(fader)
    }
    
    func rangeDidChage(left: CGFloat, right: CGFloat) {
        print("Left value: \(left)")
        print("Left value: \(right)")
    }

Value of each thumb change by integer value, so already you can't get value like 6.5, 6.25 etc. To do that, you need to go to the **newRangeValue** function and change some of the implementations.
