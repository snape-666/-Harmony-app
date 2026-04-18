import { Canvas, CanvasRenderingContext2D, RenderingContextSettings } from '@kit.ArkUI';

function sanitizeSeries(values: number[]): number[] {
  if (values.length === 0) {
    return [0];
  }
  const out: number[] = [];
  let last = values[0];
  if (isNaN(last)) {
    last = 0;
  }
  for (let i = 0; i < values.length; i++) {
    let v = values[i];
    if (isNaN(v)) {
      v = last;
    } else {
      last = v;
    }
    out.push(v);
  }
  return out;
}

function minMax(values: number[]): [number, number] {
  let min = values[0];
  let max = values[0];
  for (let i = 1; i < values.length; i++) {
    if (values[i] < min) {
      min = values[i];
    }
    if (values[i] > max) {
      max = values[i];
    }
  }
  if (min === max) {
    min = min - 1;
    max = max + 1;
  }
  return [min, max];
}

@Component
export struct StatAreaLineChart {
  @Prop values: number[] = [];
  @Prop lineColor: string = '#22C55E';
  @Prop chartHeight: number = 90;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width('100%')
      .height(this.chartHeight)
      .onReady(() => {
        this.draw(300, this.chartHeight);
      })
      .onAreaChange((oldVal: Area, newVal: Area) => {
        if (newVal.width > 1 && newVal.height > 1) {
          this.draw(newVal.width, newVal.height);
        }
      });
  }

  private draw(w: number, h: number): void {
    const ctx = this.context;
    const vals = sanitizeSeries(this.values.length > 0 ? this.values : [0]);
    const [minV, maxV] = minMax(vals);
    const padL = 8;
    const padR = 8;
    const padT = 6;
    const padB = 4;
    const innerW = w - padL - padR;
    const innerH = h - padT - padB;
    ctx.clearRect(0, 0, w, h);
    const n = vals.length;
    const xAt = (i: number): number => {
      if (n === 1) {
        return padL + innerW / 2;
      }
      return padL + (innerW * i) / (n - 1);
    };
    const yAt = (v: number): number => {
      const t = (v - minV) / (maxV - minV);
      return padT + innerH * (1 - t);
    };
    ctx.beginPath();
    ctx.moveTo(xAt(0), yAt(vals[0]));
    for (let i = 1; i < n; i++) {
      ctx.lineTo(xAt(i), yAt(vals[i]));
    }
    ctx.lineTo(xAt(n - 1), h - padB);
    ctx.lineTo(xAt(0), h - padB);
    ctx.closePath();
    const g = ctx.createLinearGradient(0, padT, 0, h - padB);
    g.addColorStop(0, 'rgba(34,197,94,0.35)');
    g.addColorStop(1, 'rgba(34,197,94,0.02)');
    ctx.fillStyle = g;
    ctx.fill();
    ctx.beginPath();
    ctx.moveTo(xAt(0), yAt(vals[0]));
    for (let i = 1; i < n; i++) {
      ctx.lineTo(xAt(i), yAt(vals[i]));
    }
    ctx.strokeStyle = this.lineColor;
    ctx.lineWidth = 2;
    ctx.stroke();
  }
}

@Component
export struct StatSparkLineChart {
  @Prop values: number[] = [];
  @Prop lineColor: string = '#3B82F6';
  @Prop chartHeight: number = 50;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width('100%')
      .height(this.chartHeight)
      .onReady(() => {
        this.draw(200, this.chartHeight);
      })
      .onAreaChange((oldVal: Area, newVal: Area) => {
        if (newVal.width > 1 && newVal.height > 1) {
          this.draw(newVal.width, newVal.height);
        }
      });
  }

  private draw(w: number, h: number): void {
    const ctx = this.context;
    const vals = sanitizeSeries(this.values.length > 0 ? this.values : [0]);
    const [minV, maxV] = minMax(vals);
    const padL = 6;
    const padR = 6;
    const padT = 4;
    const padB = 4;
    const innerW = w - padL - padR;
    const innerH = h - padT - padB;
    ctx.clearRect(0, 0, w, h);
    const n = vals.length;
    const xAt = (i: number): number => {
      if (n === 1) {
        return padL + innerW / 2;
      }
      return padL + (innerW * i) / (n - 1);
    };
    const yAt = (v: number): number => {
      const t = (v - minV) / (maxV - minV);
      return padT + innerH * (1 - t);
    };
    ctx.beginPath();
    ctx.moveTo(xAt(0), yAt(vals[0]));
    for (let i = 1; i < n; i++) {
      ctx.lineTo(xAt(i), yAt(vals[i]));
    }
    ctx.strokeStyle = this.lineColor;
    ctx.lineWidth = 2;
    ctx.stroke();
  }
}

@Component
export struct StatBarSparkChart {
  @Prop values: number[] = [];
  @Prop activeIndex: number = 0;
  @Prop chartHeight: number = 50;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width('100%')
      .height(this.chartHeight)
      .onReady(() => {
        this.draw(160, this.chartHeight);
      })
      .onAreaChange((oldVal: Area, newVal: Area) => {
        if (newVal.width > 1 && newVal.height > 1) {
          this.draw(newVal.width, newVal.height);
        }
      });
  }

  private draw(w: number, h: number): void {
    const ctx = this.context;
    const raw = this.values.length > 0 ? this.values : [0];
    const take = 5;
    const vals: number[] = [];
    const start = Math.max(0, raw.length - take);
    for (let i = start; i < raw.length; i++) {
      vals.push(raw[i]);
    }
    while (vals.length < take) {
      vals.push(vals.length > 0 ? vals[vals.length - 1] : 0);
    }
    const vmax = Math.max(...vals, 1);
    const padL = 8;
    const padR = 8;
    const padT = 4;
    const padB = 6;
    const gap = 6;
    const barCount = take;
    const innerW = w - padL - padR;
    const barW = (innerW - gap * (barCount - 1)) / barCount;
    const innerH = h - padT - padB;
    ctx.clearRect(0, 0, w, h);
    const relActive = Math.min(barCount - 1, Math.max(0, this.activeIndex));
    for (let i = 0; i < barCount; i++) {
      const x = padL + i * (barW + gap);
      const bh = (vals[i] / vmax) * innerH;
      const y = padT + innerH - bh;
      const isHi = i === relActive;
      ctx.fillStyle = isHi ? '#16A34A' : 'rgba(34,197,94,0.25)';
      ctx.fillRect(x, y, barW, bh);
    }
  }
}
