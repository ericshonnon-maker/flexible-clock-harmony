// Flex Harmony - Main Countdown Card Page
// 弹性下班提醒主页面

@Entry
@Component
struct Index {
  @State currentTime: string = "00:00:00"
  @State isClockedIn: boolean = false
  @State isLate: boolean = false
  @State overtimeLabelVisible: boolean = false
  @State cardX: number = 50
  @State cardY: number = 200

  private workStartHour: number = 9
  private workStartMinute: number = 0
  private flexHours: number = 2
  private timerController: number = -1

  // Calculate expected end time based on work start and flex hours
  private calculateEndTime(): string {
    let endHour = this.workStartHour + 8 + this.flexHours
    let endMinute = this.workStartMinute
    let endSecond = 0

    let hours = endHour
    let minutes = endMinute
    let seconds = endSecond

    if (seconds < 0) {
      minutes += Math.floor(seconds / 60)
      seconds = seconds % 60
    }
    if (minutes < 0) {
      hours += Math.floor(minutes / 60)
      minutes = minutes % 60
    }

    hours = hours % 24

    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  // Format time as HH:MM:SS
  private formatTime(hours: number, minutes: number, seconds: number): string {
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  // Calculate remaining countdown
  private calculateCountdown(): string {
    let now = new Date()
    let currentSeconds = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()

    let endHour = this.workStartHour + 8 + this.flexHours
    let endSeconds = endHour * 3600 + this.workStartMinute * 60

    let diff = endSeconds - currentSeconds

    if (diff <= 0) {
      // Overtime
      this.overtimeLabelVisible = true
      this.isLate = true
      return "00:00:00"
    }

    this.overtimeLabelVisible = false
    this.isLate = false

    let hours = Math.floor(diff / 3600)
    let minutes = Math.floor((diff % 3600) / 60)
    let seconds = diff % 60

    return this.formatTime(hours, minutes, seconds)
  }

  // Update countdown every second
  private startCountdown() {
    this.timerController = setInterval(() => {
      this.currentTime = this.calculateCountdown()
    }, 1000)
  }

  // Load today's record from storage
  private loadTodayRecord() {
    // TODO: Load from storage persistence
    // For now, simulate clocked in state
    this.isClockedIn = true
  }

  // Clock in action
  private onClockIn() {
    this.isClockedIn = true
    this.startCountdown()
  }

  // Navigate to settings page
  private navigateToSettings() {
    // router.push({ url: 'pages/Settings' })
    console.info("Navigate to Settings")
  }

  // Close card action
  private onClose() {
    if (this.timerController !== -1) {
      clearInterval(this.timerController)
    }
    console.info("Card closed")
  }

  aboutToAppear() {
    this.loadTodayRecord()
    if (this.isClockedIn) {
      this.currentTime = this.calculateCountdown()
      this.startCountdown()
    } else {
      this.currentTime = this.calculateEndTime()
    }
  }

  aboutToDisappear() {
    if (this.timerController !== -1) {
      clearInterval(this.timerController)
    }
  }

  build() {
    Stack() {
      // Main card
      Column() {
        // Title row with settings and close buttons
        Row() {
          Text('弹性下班提醒')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)

          Blank()

          Button('⚙')
            .fontSize(16)
            .width(32)
            .height(32)
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(16)
            .onClick(() => this.navigateToSettings())

          Button('✕')
            .fontSize(16)
            .width(32)
            .height(32)
            .backgroundColor('rgba(255,255,255,0.1)')
            .borderRadius(16)
            .onClick(() => this.onClose())
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 8 })

        // Late tag - shown only when scenario is 'late'
        if (this.isLate) {
          Text('迟到')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#EF4444')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .margin({ bottom: 8 })
        }

        // Main countdown display
        Text(this.currentTime)
          .fontSize(42)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)

        // Overtime label with blink effect
        if (this.overtimeLabelVisible) {
          Text('已到下班时间!')
            .fontSize(14)
            .fontColor('#22C55E')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 8 })
            .animation({
              duration: 1000,
              iterations: -1,
              playMode: PlayMode.Alternate
            })
            .opacity(this.overtimeLabelVisible ? 1 : 0.3)
        }

        // Info label
        Text(`上班: ${this.workStartHour.toString().padStart(2, '0')}:${this.workStartMinute.toString().padStart(2, '0')}  预计下班: ${this.calculateEndTime().substring(0, 5)}`)
          .fontSize(12)
          .fontColor('#9CA3AF')
          .margin({ top: 8 })

        // Clock in button - shown only before clock in
        if (!this.isClockedIn) {
          Button('打卡上班')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#60A5FA')
            .borderRadius(20)
            .width(120)
            .height(36)
            .margin({ top: 12 })
            .onClick(() => this.onClockIn())
        }
      }
      .width(280)
      .height(180)
      .backgroundColor('rgba(32,32,32,200)')
      .borderRadius(12)
      .border({
        width: 1,
        color: 'rgba(255,255,255,0.3)'
      })
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.3)',
        offsetX: 0,
        offsetY: 4
      })
      .position({ x: this.cardX, y: this.cardY })
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent) => {
            // Record start position
          })
          .onActionUpdate((event: GestureEvent) => {
            this.cardX += event.deltaX
            this.cardY += event.deltaY
          })
          .onActionEnd((event: GestureEvent) => {
            // Snap to position
          })
      )
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.1)')
  }
}
