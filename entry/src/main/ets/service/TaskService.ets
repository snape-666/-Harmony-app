// common/TaskService.ets
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';

// 任务接口
export interface TaskItem {
  id: string;
  name: string;
  description: string;
  category: string;
  time: string;        // 格式 "HH:MM" 24小时制
  period: string;      // "上午" 或 "下午"
  repeatMode: string;  // "weekly" 或 "once"
  repeatDays: string[]; // 周几 ["周一", "周二"...]
  isCompleted: boolean; // 是否已完成
  createdAt: number;   // 创建时间戳
  completedDate?: string; // 完成日期 "YYYY-MM-DD"
}

export class TaskService {
  private static instance: TaskService;
  private context: common.UIAbilityContext | null = null;
  private tasks: TaskItem[] = [];
  private notificationTimer: number = -1;

  static getInstance(): TaskService {
    if (!TaskService.instance) {
      TaskService.instance = new TaskService();
    }
    return TaskService.instance;
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context;
    this.loadTasks();
    this.startNotificationScheduler();
  }

  // 加载任务
  private async loadTasks(): Promise<void> {
    if (!this.context) return;
    try {
      const prefs = await preferences.getPreferences(this.context, 'tasks_db');
      const tasksStr = await prefs.get('tasks', '[]') as string;
      this.tasks = JSON.parse(tasksStr);
      console.log('任务加载成功，数量:', this.tasks.length);
    } catch (error) {
      console.error('加载任务失败:', error);
      this.tasks = [];
    }
  }

  // 保存任务
  private async saveTasks(): Promise<void> {
    if (!this.context) return;
    try {
      const prefs = await preferences.getPreferences(this.context, 'tasks_db');
      await prefs.put('tasks', JSON.stringify(this.tasks));
      await prefs.flush();
    } catch (error) {
      console.error('保存任务失败:', error);
    }
  }

  // 获取今天的日期字符串 YYYY-MM-DD
  private getTodayStr(): string {
    const today = new Date();
    return `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate().toString().padStart(2, '0')}`;
  }

  // 获取当前星期几
  private getCurrentWeekday(): string {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[new Date().getDay()];
  }

  // 将12小时制转换为24小时制
  private convertTo24Hour(hour: number, minute: number, period: string): string {
    let hour24 = hour;
    if (period === '下午' && hour !== 12) {
      hour24 = hour + 12;
    } else if (period === '上午' && hour === 12) {
      hour24 = 0;
    }
    return `${hour24.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
  }

  // 添加任务
  async addTask(
    name: string,
    description: string,
    category: string,
    hour: number,
    minute: number,
    period: string,
    repeatMode: string,
    repeatDays: string[]
  ): Promise<TaskItem> {
    const newTask: TaskItem = {
      id: Date.now().toString(),
      name: name,
      description: description || '',
      category: category,
      time: this.convertTo24Hour(hour, minute, period),
      period: period,
      repeatMode: repeatMode,
      repeatDays: repeatDays,
      isCompleted: false,
      createdAt: Date.now()
    };
    this.tasks.push(newTask);
    await this.saveTasks();
    console.log('任务添加成功:', newTask);
    return newTask;
  }

  // 完成任务（软删除，当天不再提醒）
  async completeTask(taskId: string): Promise<boolean> {
    const taskIndex = this.tasks.findIndex(t => t.id === taskId);
    if (taskIndex === -1) return false;

    const today = this.getTodayStr();
    this.tasks[taskIndex].isCompleted = true;
    this.tasks[taskIndex].completedDate = today;
    await this.saveTasks();
    return true;
  }

  // 删除任务（永久删除）
  async deleteTask(taskId: string): Promise<boolean> {
    const taskIndex = this.tasks.findIndex(t => t.id === taskId);
    if (taskIndex === -1) return false;
    this.tasks.splice(taskIndex, 1);
    await this.saveTasks();
    return true;
  }

  // 获取今日需要显示的任务（未完成 + 符合重复规则）
  getTodayTasks(): TaskItem[] {
    const today = this.getTodayStr();
    const todayWeekday = this.getCurrentWeekday();

    return this.tasks.filter(task => {
      // 已完成的检查是否今天完成
      if (task.isCompleted) {
        return false;
      }

      // 检查重复模式
      if (task.repeatMode === 'once') {
        // 仅一次的任务，根据创建日期判断是否同一天（简化：仅当天有效）
        const taskDate = new Date(task.createdAt);
        const todayDate = new Date();
        return taskDate.toDateString() === todayDate.toDateString();
      } else {
        // 每周重复
        return task.repeatDays.includes(todayWeekday);
      }
    }).sort((a, b) => a.time.localeCompare(b.time));
  }

  // 获取待定数目（今日未完成任务数）
  getPendingCount(): number {
    return this.getTodayTasks().length;
  }

  // 获取指定日期的任务
  getTasksForDate(date: Date): TaskItem[] {
    const dateStr = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
    const weekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][date.getDay()];

    return this.tasks.filter(task => {
      if (task.isCompleted && task.completedDate === dateStr) return false;
      if (task.repeatMode === 'once') {
        const taskDate = new Date(task.createdAt);
        return taskDate.toDateString() === date.toDateString();
      } else {
        return task.repeatDays.includes(weekday);
      }
    }).sort((a, b) => a.time.localeCompare(b.time));
  }

  // 启动通知调度器（每分钟检查一次）
  private startNotificationScheduler(): void {
    this.notificationTimer = setInterval(() => {
      this.checkAndSendNotifications();
    }, 60000); // 每分钟检查一次
  }

  // 检查并发送通知
  private async checkAndSendNotifications(): Promise<void> {
    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const currentWeekday = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][now.getDay()];

    // 查找当前时间需要提醒的任务
    const tasksToNotify = this.tasks.filter(task => {
      if (task.isCompleted) return false;
      if (task.time !== currentTime) return false;
      if (task.repeatMode === 'once') {
        const taskDate = new Date(task.createdAt);
        return taskDate.toDateString() === now.toDateString();
      } else {
        return task.repeatDays.includes(currentWeekday);
      }
    });

    for (const task of tasksToNotify) {
      await this.sendNotification(task);
    }
  }

  // 发送通知
  private async sendNotification(task: TaskItem): Promise<void> {
    // 顶部横幅提示
    promptAction.openToast({
      message: `⏰ 任务提醒: ${task.name}`,
      duration: 3000
    });

    // 通知栏消息
    try {
      await notificationManager.publish({
        id: parseInt(task.id),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          text: `${task.name} - ${task.category}`
        }
      } as notificationManager.NotificationRequest);
    } catch (error) {
      console.error('发送通知失败:', error);
    }

    console.log(`提醒任务: ${task.name} 时间: ${task.time}`);
  }

  // 停止调度器
  stopScheduler(): void {
    if (this.notificationTimer !== -1) {
      clearInterval(this.notificationTimer);
      this.notificationTimer = -1;
    }
  }
}