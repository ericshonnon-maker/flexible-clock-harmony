/**
 * 设置页面
 * 配置弹性上下班时间、工作时长、午休等参数
 */
import router from '@ohos.router'
import { StorageManager } from '../common/storage'

@Entry
@Component
struct Settings {
  @State flexStartBegin: string = '08:00'
  @State flexStartEnd: string = '09:30'
  @State flexEndBegin: string = '17:00'
  @State flexEndEnd: string = '18:30'
  @State workHours: number = 8.0
  @State excludeLunch: boolean = true
  @State lunchStart: string = '12:00'
  @State lunchEnd: string = '13:00'

  private storage: StorageManager = StorageManager.getStorageManager()

  aboutToAppear() {
    let cfg = this.storage.getConfig()
    this.flexStartBegin = cfg.flex_start_begin
    this.flexStartEnd = cfg.flex_start_end
    this.flexEndBegin = cfg.flex_end_begin
    this.flexEndEnd = cfg.flex_end_end
    this.workHours = cfg.work_hours
    this.excludeLunch = cfg.exclude_lunch
    this.lunchStart = cfg.lunch_start
    this.lunchEnd = cfg.lunch_end
  }

  parseTimeHHMM(str: string): number[] {
    let parts = str.split(':')
    return [parseInt(parts[0]), parseInt(parts[1])]
  }

  formatHHMM(hour: number, minute: number): string {
    return `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`
  }

  saveSettings() {
    let cfg = this.storage.getConfig()
    cfg.flex_start_begin = this.flexStartBegin
    cfg.flex_end_begin = this.flexEndBegin
    cfg.flex_end_end = this.flexEndEnd
    cfg.work_hours = this.workHours
    cfg.exclude_lunch = this.excludeLunch
    cfg.lunch_start = this.lunchStart
    cfg.lunch_end = this.lunchEnd
    this.storage.saveConfig(cfg)
    router.back()
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('设置')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('取消')
          .fontSize(14)
          .fontColor('#9CA3AF')
          .backgroundColor('transparent')
          .onClick(() => router.back())
      }
      .width('100%')
      .padding({ left: 20, right: 16, top: 16, bottom: 12 })
      .backgroundColor('#1F1F1F')

      Scroll() {
        Column() {
          // 弹性上班时间
          this.sectionTitle('弹性上班时间区间')
          Row() {
            Text('从')
              .fontColor('#9CA3AF')
              .fontSize(14)
            Blank()
            TimePicker({ selected: new Date(2024, 0, 1, this.parseTimeHHMM(this.flexStartBegin)[0], this.parseTimeHHMM(this.flexStartBegin)[1]) })
              .width(120)
              .height(120)
              .format({ hour: '2digit', minute: '2digit' })
              .onChange((value: Date) => {
                this.flexStartBegin = this.formatHHMM(value.getHours(), value.getMinutes())
              })
            Text('到')
              .fontColor('#9CA3AF')
              .fontSize(14)
              .margin({ left: 12 })
            TimePicker({ selected: new Date(2024, 0, 1, this.parseTimeHHMM(this.flexStartEnd)[0], this.parseTimeHHMM(this.flexStartEnd)[1]) })
              .width(120)
              .height(120)
              .format({ hour: '2digit', minute: '2digit' })
              .onChange((value: Date) => {
                this.flexStartEnd = this.formatHHMM(value.getHours(), value.getMinutes())
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 弹性下班时间
          this.sectionTitle('弹性下班时间区间')
          Row() {
            Text('从')
              .fontColor('#9CA3AF')
              .fontSize(14)
            Blank()
            TimePicker({ selected: new Date(2024, 0, 1, this.parseTimeHHMM(this.flexEndBegin)[0], this.parseTimeHHMM(this.flexEndBegin)[1]) })
              .width(120)
              .height(120)
              .format({ hour: '2digit', minute: '2digit' })
              .onChange((value: Date) => {
                this.flexEndBegin = this.formatHHMM(value.getHours(), value.getMinutes())
              })
            Text('到')
              .fontColor('#9CA3AF')
              .fontSize(14)
              .margin({ left: 12 })
            TimePicker({ selected: new Date(2024, 0, 1, this.parseTimeHHMM(this.flexEndEnd)[0], this.parseTimeHHMM(this.flexEndEnd)[1]) })
              .width(120)
              .height(120)
              .format({ hour: '2digit', minute: '2digit' })
              .onChange((value: Date) => {
                this.flexEndEnd = this.formatHHMM(value.getHours(), value.getMinutes())
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 工作时长
          this.sectionTitle('工作时长')
          Row() {
            Text('每日工作')
              .fontColor('#9CA3AF')
              .fontSize(14)
            Blank()
            Text(`${this.workHours.toFixed(1)} 小时`)
              .fontColor('#FFFFFF')
              .fontSize(14)
              .width(60)
              .textAlign(TextAlign.Center)
            Button('-')
              .width(40)
              .height(40)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .backgroundColor('#3D3D3D')
              .borderRadius(8)
              .onClick(() => {
                if (this.workHours > 1) {
                  this.workHours = Math.round((this.workHours - 0.5) * 10) / 10
                }
              })
            Button('+')
              .width(40)
              .height(40)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .backgroundColor('#3D3D3D')
              .borderRadius(8)
              .margin({ left: 8 })
              .onClick(() => {
                if (this.workHours < 16) {
                  this.workHours = Math.round((this.workHours + 0.5) * 10) / 10
                }
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 午休设置
          this.sectionTitle('午休设置')
          Row() {
            Checkbox()
              .select(this.excludeLunch)
              .onChange((value: boolean) => {
                this.excludeLunch = value
              })
            Text('排除午休时间')
              .fontColor('#E0E0E0')
              .fontSize(14)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .visibility(this.excludeLunch ? Visibility.Visible : Visibility.Collapsed)

          if (this.excludeLunch) {
            Row() {
              Text('午休')
                .fontColor('#9CA3AF')
                .fontSize(14)
              Blank()
              TimePicker({ selected: new Date(2024, 0, 1, this.parseTimeHHMM(this.lunchStart)[0], this.parseTimeHHMM(this.lunchStart)[1]) })
                .width(100)
                .height(100)
                .format({ hour: '2digit', minute: '2digit' })
                .onChange((value: Date) => {
                  this.lunchStart = this.formatHHMM(value.getHours(), value.getMinutes())
                })
              Text('至')
                .fontColor('#9CA3AF')
                .fontSize(14)
                .margin({ left: 8 })
              TimePicker({ selected: new Date(2024, 0, 1, this.parseTimeHHMM(this.lunchEnd)[0], this.parseTimeHHMM(this.lunchEnd)[1]) })
                .width(100)
                .height(100)
                .format({ hour: '2digit', minute: '2digit' })
                .onChange((value: Date) => {
                  this.lunchEnd = this.formatHHMM(value.getHours(), value.getMinutes())
                })
            }
            .width('100%')
            .padding({ left: 40, right: 20 })
          }

          // 保存按钮
          Button('保存设置')
            .width('80%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#60A5FA')
            .borderRadius(12)
            .margin({ top: 32, bottom: 40 })
            .onClick(() => this.saveSettings())
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#2D2D2D')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#2D2D2D')
  }

  @Builder
  sectionTitle(title: string) {
    Text(title)
      .fontColor('#60A5FA')
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 8 })
  }
}
