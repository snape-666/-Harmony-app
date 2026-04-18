/**
 * 解析后端 getData 响应（参见 entry/src/main/doc/后端说明书6.0.md）
 * 支持：双重 JSON、日期→时刻 嵌套结构、扁平结构；字段带单位字符串转数值。
 */

export interface SensorRecord {
  date: string;
  time: string;
  airTemp: number;
  airHumidity: number;
  co2: number;
  soilTemp: number;
  soilHumidity: number;
}

export interface GetDataEnvelope {
  success: boolean;
  count?: number;
  data?: Object;
}

function parseLeadingNumber(s: string | undefined): number {
  if (!s) {
    return NaN;
  }
  const m = s.match(/-?\d+(\.\d+)?/);
  if (!m) {
    return NaN;
  }
  return parseFloat(m[0]);
}

function normalizeDateKey(dateStr: string): string {
  const parts = dateStr.split(/[-/]/);
  if (parts.length < 3) {
    return dateStr;
  }
  const y = parseInt(parts[0], 10);
  const m = parseInt(parts[1], 10);
  const d = parseInt(parts[2], 10);
  if (isNaN(y) || isNaN(m) || isNaN(d)) {
    return dateStr;
  }
  return `${y}-${m}-${d}`;
}

function localTodayKey(): string {
  const now = new Date();
  const y = now.getFullYear();
  const m = now.getMonth() + 1;
  const d = now.getDate();
  return normalizeDateKey(`${y}-${m}-${d}`);
}

function hasSensorShape(o: Object): boolean {
  const r = o as Record<string, string>;
  return (r['air_temperature'] !== undefined) || (r['air_humidity'] !== undefined) ||
    (r['co2'] !== undefined);
}

function isNestedByTime(dayVal: Record<string, Object>): boolean {
  const keys = Object.keys(dayVal);
  if (keys.length === 0) {
    return false;
  }
  const first = dayVal[keys[0]];
  return typeof first === 'object' && first !== null && hasSensorShape(first);
}

function toRecord(dateKey: string, timeKey: string, raw: Record<string, string>): SensorRecord {
  const time = (raw['time'] as string) || timeKey;
  return {
    date: dateKey,
    time: time,
    airTemp: parseLeadingNumber(raw['air_temperature']),
    airHumidity: parseLeadingNumber(raw['air_humidity']),
    co2: parseLeadingNumber(raw['co2']),
    soilTemp: parseLeadingNumber(raw['soil_temperature']),
    soilHumidity: parseLeadingNumber(raw['soil_humidity'])
  };
}

/**
 * 将说明书中的 data（嵌套或扁平）转为按时间排序的记录列表
 */
export function flattenSensorData(data: Object): SensorRecord[] {
  const out: SensorRecord[] = [];
  const top = data as Record<string, Object>;
  const dateKeys = Object.keys(top);
  for (let i = 0; i < dateKeys.length; i++) {
    const dateKey = dateKeys[i];
    const dayVal = top[dateKey];
    if (dayVal === null || typeof dayVal !== 'object') {
      continue;
    }
    const dayObj = dayVal as Record<string, Object>;
    if (isNestedByTime(dayObj)) {
      const timeKeys = Object.keys(dayObj);
      for (let j = 0; j < timeKeys.length; j++) {
        const tk = timeKeys[j];
        const inner = dayObj[tk];
        if (inner && typeof inner === 'object') {
          out.push(toRecord(dateKey, tk, inner as Record<string, string>));
        }
      }
    } else if (hasSensorShape(dayObj)) {
      out.push(toRecord(dateKey, (dayObj['time'] as string) || '', dayObj as Record<string, string>));
    }
  }
  out.sort((a, b) => {
    const dk = normalizeDateKey(a.date).localeCompare(normalizeDateKey(b.date));
    if (dk !== 0) {
      return dk;
    }
    return a.time.localeCompare(b.time);
  });
  return out;
}

/**
 * 说明书：可能为 json 内嵌 json 文本，需解析两次
 */
export function parseGetDataResponseBody(raw: string): GetDataEnvelope | null {
  try {
    let obj = JSON.parse(raw) as Object | string;
    if (typeof obj === 'string') {
      obj = JSON.parse(obj) as GetDataEnvelope;
    }
    const env = obj as GetDataEnvelope;
    if (!env) {
      return null;
    }
    if (env.data !== undefined && typeof env.data === 'string') {
      const innerData = JSON.parse(env.data as string) as Object;
      return { success: env.success, count: env.count, data: innerData };
    }
    return env;
  } catch {
    return null;
  }
}

function compareRecordTime(a: SensorRecord, b: SensorRecord): number {
  const dk = normalizeDateKey(a.date).localeCompare(normalizeDateKey(b.date));
  if (dk !== 0) {
    return dk;
  }
  return a.time.localeCompare(b.time);
}

export function filterRecordsForDay(records: SensorRecord[], preferToday: boolean): SensorRecord[] {
  if (records.length === 0) {
    return [];
  }
  const today = localTodayKey();
  const todayList: SensorRecord[] = [];
  for (let i = 0; i < records.length; i++) {
    if (normalizeDateKey(records[i].date) === today) {
      todayList.push(records[i]);
    }
  }
  if (preferToday && todayList.length > 0) {
    return todayList.sort(compareRecordTime);
  }
  const lastDate = normalizeDateKey(records[records.length - 1].date);
  const out: SensorRecord[] = [];
  for (let i = 0; i < records.length; i++) {
    if (normalizeDateKey(records[i].date) === lastDate) {
      out.push(records[i]);
    }
  }
  return out.sort(compareRecordTime);
}

/** 最近 7 个自然日（以数据中最后一天为结束日），每日一条聚合值 */
export function aggregateLast7Days(
  records: SensorRecord[],
  pick: (list: SensorRecord[]) => number
): number[] {
  if (records.length === 0) {
    return [];
  }
  const byDate: Record<string, SensorRecord[]> = {};
  for (let i = 0; i < records.length; i++) {
    const k = normalizeDateKey(records[i].date);
    const arr = byDate[k];
    if (arr) {
      arr.push(records[i]);
    } else {
      byDate[k] = [records[i]];
    }
  }
  const keys: string[] = Object.keys(byDate);
  keys.sort((a, b) => a.localeCompare(b));
  const last7: string[] = [];
  const start = Math.max(0, keys.length - 7);
  for (let i = start; i < keys.length; i++) {
    last7.push(keys[i]);
  }
  const result: number[] = [];
  for (let i = 0; i < last7.length; i++) {
    const list = byDate[last7[i]];
    if (list && list.length > 0) {
      result.push(pick(list));
    }
  }
  return result;
}

export function seriesFromRecords(records: SensorRecord[], field: 'airTemp' | 'airHumidity' | 'co2'): number[] {
  const out: number[] = [];
  for (let i = 0; i < records.length; i++) {
    const r = records[i];
    let v = 0;
    if (field === 'airTemp') {
      v = r.airTemp;
    } else if (field === 'airHumidity') {
      v = r.airHumidity;
    } else {
      v = r.co2;
    }
    out.push(v);
  }
  return out;
}

function avgField(list: SensorRecord[], field: 'airTemp' | 'airHumidity' | 'co2'): number {
  let sum = 0;
  let n = 0;
  for (let i = 0; i < list.length; i++) {
    let v = 0;
    if (field === 'airTemp') {
      v = list[i].airTemp;
    } else if (field === 'airHumidity') {
      v = list[i].airHumidity;
    } else {
      v = list[i].co2;
    }
    if (!isNaN(v)) {
      sum += v;
      n++;
    }
  }
  return n > 0 ? sum / n : NaN;
}

export function weekSeriesTemp(records: SensorRecord[]): number[] {
  return aggregateLast7Days(records, (list) => avgField(list, 'airTemp'));
}

export function weekSeriesHumidity(records: SensorRecord[]): number[] {
  return aggregateLast7Days(records, (list) => avgField(list, 'airHumidity'));
}

export function weekSeriesCo2(records: SensorRecord[]): number[] {
  return aggregateLast7Days(records, (list) => avgField(list, 'co2'));
}

export function formatPercentChange(values: number[]): string {
  if (values.length < 2) {
    return '--';
  }
  const first = values[0];
  const last = values[values.length - 1];
  if (isNaN(first) || isNaN(last) || first === 0) {
    return '--';
  }
  const d = ((last - first) / Math.abs(first)) * 100;
  const sign = d >= 0 ? '+' : '';
  return `${sign}${d.toFixed(1)}%`;
}

export function co2StatusText(lastPpm: number): string {
  if (isNaN(lastPpm)) {
    return '--';
  }
  if (lastPpm >= 350 && lastPpm <= 550) {
    return '最佳';
  }
  if (lastPpm > 550) {
    return '偏高';
  }
  return '偏低';
}

export function formatTempDisplay(v: number): string {
  if (isNaN(v)) {
    return '--';
  }
  return `${v.toFixed(1)}℃`;
}

export function formatHumidityDisplay(v: number): string {
  if (isNaN(v)) {
    return '--';
  }
  return `${Math.round(v)}%`;
}

export function formatCo2Display(v: number): string {
  if (isNaN(v)) {
    return '--';
  }
  return `${Math.round(v)}ppm`;
}

export function lastNumeric(values: number[]): number {
  if (values.length === 0) {
    return NaN;
  }
  return values[values.length - 1];
}

export function padSeries(values: number[], minLen: number): number[] {
  if (values.length >= minLen) {
    return values;
  }
  if (values.length === 0) {
    return [];
  }
  const last = values[values.length - 1];
  const out = values.slice();
  while (out.length < minLen) {
    out.push(last);
  }
  return out;
}

/** 与 aggregateLast7Days 顺序一致：最近最多 7 天的中文星期标签 */
export function last7WeekdayLabels(records: SensorRecord[]): string[] {
  const byDate: Record<string, boolean> = {};
  for (let i = 0; i < records.length; i++) {
    byDate[normalizeDateKey(records[i].date)] = true;
  }
  const keys: string[] = Object.keys(byDate);
  keys.sort((a, b) => a.localeCompare(b));
  const last7: string[] = [];
  const start = Math.max(0, keys.length - 7);
  for (let i = start; i < keys.length; i++) {
    last7.push(keys[i]);
  }
  const CN: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  const labels: string[] = [];
  for (let i = 0; i < last7.length; i++) {
    const parts = last7[i].split('-');
    const y = parseInt(parts[0], 10);
    const m = parseInt(parts[1], 10);
    const d = parseInt(parts[2], 10);
    const dt = new Date(y, m - 1, d);
    const w = dt.getDay();
    labels.push(CN[w]);
  }
  return labels;
}

/** 取末尾 n 个值中最大值的索引（0..n-1） */
export function indexOfMaxLastN(values: number[], n: number): number {
  if (values.length === 0) {
    return 0;
  }
  const start = Math.max(0, values.length - n);
  let maxI = 0;
  for (let i = 1; i < values.length - start; i++) {
    const vi = values[start + i];
    const vm = values[start + maxI];
    if (vi > vm) {
      maxI = i;
    }
  }
  return maxI;
}
