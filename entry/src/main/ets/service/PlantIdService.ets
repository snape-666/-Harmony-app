// entry/src/main/ets/service/PlantIdService.ets
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';

// ============ v3 健康评估响应（与 response_health_assessment.json 对齐） ============
// 在文件顶部添加病害中英文映射表
const DISEASE_NAME_MAP: Record<string, string> = {
  // 真菌病害
  'Botrytis': '灰霉病',
  'Powdery Mildew': '白粉病',
  'Downy Mildew': '霜霉病',
  'Late Blight': '晚疫病',
  'Early Blight': '早疫病',
  'Rust': '锈病',
  'Anthracnose': '炭疽病',
  'Fusarium Wilt': '枯萎病',
  'Verticillium Wilt': '黄萎病',
  'Sclerotinia': '菌核病',
  'Septoria': '叶斑病',
  'Cercospora': '褐斑病',
  'Alternaria': '黑斑病',
  'Rhizoctonia': '立枯病',
  'Phytophthora': '疫病',
  'Pythium': '腐霉病',

  // 细菌病害
  'Bacterial Blight': '细菌性疫病',
  'Bacterial Leaf Spot': '细菌性叶斑病',
  'Bacterial Wilt': '青枯病',
  'Crown Gall': '冠瘿病',
  'Fire Blight': '火疫病',
  'Soft Rot': '软腐病',

  // 病毒病害
  'Mosaic Virus': '花叶病毒病',
  'Yellow Vein Mosaic': '黄脉花叶病',
  'Leaf Curl Virus': '卷叶病毒病',
  'Ring Spot Virus': '环斑病毒病',

  // 虫害
  'Aphid': '蚜虫',
  'Whitefly': '白粉虱',
  'Spider Mite': '红蜘蛛',
  'Thrips': '蓟马',
  'Leaf Miner': '潜叶蝇',
  'Caterpillar': '毛虫',
  'Beetle': '甲虫',
  'Weevil': '象鼻虫',
  'Nematode': '线虫',
  'Slug': '蛞蝓',
  'Snail': '蜗牛',

  // 生理性病害
  'Nutrient Deficiency': '缺素症',
  'Sunburn': '日灼病',
  'Water Stress': '水分胁迫',
  'Cold Injury': '冷害',
  'Frost Damage': '冻害'
};



// ============ 新增：本地病害知识库（包含详细描述和治疗建议） ============

interface DiseaseKnowledge {
  description: string;
  treatment: string;
  cause: string;
}

const DISEASE_KNOWLEDGE_BASE: Record<string, DiseaseKnowledge> = {
  'Botrytis': {
    description: '由灰葡萄孢菌引起的真菌性病害，主要危害花、果、叶。病部产生灰色霉层，湿度大时霉层明显，果实腐烂。',
    treatment: '【防治措施】\n1. 及时摘除病花、病果、病叶，减少传染源\n2. 降低棚内湿度，加强通风透光\n3. 发病初期可使用50%腐霉利可湿性粉剂1500倍液喷雾\n4. 也可使用40%嘧霉胺悬浮剂1000倍液或50%异菌脲可湿性粉剂1000倍液\n5. 每隔7-10天喷一次，连续2-3次，交替用药',
    cause: '由灰葡萄孢菌（Botrytis cinerea）引起，高湿（90%以上）、低温（15-20℃）环境易发病，植株伤口多、氮肥过量会加重病情。'
  },
  'Powdery Mildew': {
    description: '叶片表面出现白色粉状霉层，严重时叶片枯黄脱落，影响光合作用。',
    treatment: '【防治措施】\n1. 选用抗病品种，合理密植\n2. 发病初期喷洒25%三唑酮可湿性粉剂2000倍液\n3. 或使用40%氟硅唑乳油8000倍液、10%苯醚甲环唑水分散粒剂1500倍液\n4. 加强田间管理，避免氮肥过量，增施磷钾肥\n5. 每隔7-10天喷一次，连续2-3次',
    cause: '由白粉菌科（Erysiphaceae）真菌引起，温暖（20-25℃）、干燥、通风不良环境易发病，氮肥过多会加重病情。'
  },
  'Downy Mildew': {
    description: '叶片出现水渍状淡黄色病斑，叶背产生灰白色霉层，严重时叶片干枯死亡。',
    treatment: '【防治措施】\n1. 选用抗病品种，实行轮作\n2. 发病初期喷洒72%霜脲氰·锰锌可湿性粉剂800倍液\n3. 或使用25%甲霜灵可湿性粉剂600倍液、50%烯酰吗啉水分散粒剂2000倍液\n4. 加强通风，降低田间湿度\n5. 每隔5-7天喷一次，连续2-3次',
    cause: '由霜霉菌（Peronosporaceae）引起，高湿（85%以上）、多雨、昼夜温差大环境易发病。'
  },
  'Late Blight': {
    description: '叶片出现水渍状暗绿色病斑，潮湿时病斑边缘有白色霉层，茎部出现黑褐色条斑，果实出现褐色硬斑。',
    treatment: '【防治措施】\n1. 选用抗病品种，避免连作\n2. 发病初期喷洒72%霜脲氰·锰锌可湿性粉剂600-800倍液\n3. 或使用50%烯酰吗啉水分散粒剂2000倍液、68%精甲霜灵·锰锌水分散粒剂600倍液\n4. 加强通风，降低田间湿度\n5. 每隔5-7天喷一次，连续2-3次',
    cause: '由致病疫霉（Phytophthora infestans）引起，高湿（90%以上）、凉爽（15-22℃）环境易发病，连续阴雨天会快速蔓延。'
  },
  'Early Blight': {
    description: '叶片出现褐色轮纹斑，病斑有同心轮纹，严重时叶片枯死。',
    treatment: '【防治措施】\n1. 实行轮作，减少病原积累\n2. 发病初期喷洒75%百菌清可湿性粉剂600倍液\n3. 或使用50%异菌脲可湿性粉剂1000倍液、10%苯醚甲环唑水分散粒剂1500倍液\n4. 加强肥水管理，增强植株抗性\n5. 每隔7-10天喷一次，连续2-3次',
    cause: '由茄链格孢菌（Alternaria solani）引起，温暖（25-30℃）、高湿环境易发病，植株衰弱时更易感病。'
  },
  'Anthracnose': {
    description: '叶片出现褐色凹陷病斑，边缘呈红褐色，病斑上有小黑点，果实腐烂。',
    treatment: '【防治措施】\n1. 选用抗病品种，合理密植\n2. 发病初期喷洒80%代森锰锌可湿性粉剂600倍液\n3. 或使用25%咪鲜胺乳油1000倍液、10%苯醚甲环唑水分散粒剂1500倍液\n4. 及时清除病叶病果\n5. 每隔7-10天喷一次，连续2-3次',
    cause: '由炭疽菌（Colletotrichum）引起，高温（25-30℃）、高湿环境易发病，伤口多会加重病情。'
  },
  'Fusarium Wilt': {
    description: '植株萎蔫，叶片从下向上逐渐变黄枯死，维管束变褐。',
    treatment: '【防治措施】\n1. 选用抗病品种，实行轮作\n2. 发病初期用50%多菌灵可湿性粉剂500倍液灌根\n3. 或使用70%甲基硫菌灵可湿性粉剂800倍液、3%甲霜灵·噁霉灵水剂500倍液\n4. 加强排水，避免田间积水\n5. 发现病株及时拔除，病穴消毒',
    cause: '由镰刀菌（Fusarium oxysporum）引起，连作、土壤带菌、根部受伤、高温高湿环境易发病。'
  },
  'Rust': {
    description: '叶片出现锈褐色粉末状病斑，严重时叶片干枯脱落。',
    treatment: '【防治措施】\n1. 选用抗病品种，合理密植\n2. 发病初期喷洒25%三唑酮可湿性粉剂2000倍液\n3. 或使用12.5%烯唑醇可湿性粉剂3000倍液、30%苯醚甲环唑·丙环唑乳油3000倍液\n4. 加强通风透光，降低湿度\n5. 每隔7-10天喷一次，连续2-3次',
    cause: '由锈菌（Pucciniales）引起，温暖（20-25℃）、高湿环境易发病，氮肥过多会加重病情。'
  },
  'Aphid': {
    description: '蚜虫聚集在嫩叶、嫩芽上吸食汁液，导致叶片卷曲、黄化，分泌蜜露引发煤污病。',
    treatment: '【防治措施】\n1. 悬挂黄色粘虫板诱杀有翅蚜\n2. 发病初期喷洒10%吡虫啉可湿性粉剂2000倍液\n3. 或使用50%抗蚜威可湿性粉剂3000倍液、2.5%高效氯氟氰菊酯乳油2000倍液\n4. 保护天敌如瓢虫、草蛉\n5. 每隔7-10天喷一次，连续2-3次',
    cause: '由蚜虫（Aphidoidea）引起，温暖、干旱环境易大量繁殖，氮肥过多会吸引蚜虫。'
  },
  'Whitefly': {
    description: '白粉虱聚集在叶背吸食汁液，导致叶片黄化、脱落，分泌蜜露引发煤污病，传播病毒病。',
    treatment: '【防治措施】\n1. 悬挂黄色粘虫板诱杀成虫\n2. 发病初期喷洒25%噻嗪酮可湿性粉剂1500倍液\n3. 或使用10%吡虫啉可湿性粉剂2000倍液、2.5%联苯菊酯乳油2000倍液\n4. 保护天敌如丽蚜小蜂\n5. 每隔5-7天喷一次，连续2-3次',
    cause: '由白粉虱（Trialeurodes vaporariorum）引起，温暖、干燥、通风不良环境易大量发生。'
  },
  'Spider Mite': {
    description: '红蜘蛛在叶背吸食汁液，叶片出现黄白色小点，严重时叶片枯黄脱落，有细丝网。',
    treatment: '【防治措施】\n1. 及时清除杂草，减少越冬场所\n2. 发病初期喷洒15%哒螨灵乳油2000倍液\n3. 或使用1.8%阿维菌素乳油3000倍液、20%螨死净可湿性粉剂2000倍液\n4. 高温干燥天气注意预防\n5. 每隔5-7天喷一次，连续2-3次',
    cause: '由叶螨（Tetranychus urticae）引起，高温（25-35℃）、干旱、通风不良环境易大量繁殖。'
  },
  'Thrips': {
    description: '蓟马锉吸叶片和花器，导致叶片银灰色斑驳，花畸形，果实疤痕。',
    treatment: '【防治措施】\n1. 悬挂蓝色粘虫板诱杀\n2. 发病初期喷洒10%吡虫啉可湿性粉剂2000倍液\n3. 或使用25%噻虫嗪水分散粒剂5000倍液、2.5%高效氯氟氰菊酯乳油2000倍液\n4. 清除田间杂草\n5. 每隔5-7天喷一次，连续2-3次',
    cause: '由蓟马（Thripidae）引起，温暖、干旱环境易大量发生。'
  }
};

// 默认病害信息（当病害不在知识库中时使用）
const DEFAULT_DISEASE_KNOWLEDGE: DiseaseKnowledge = {
  description: '检测到疑似病虫害，建议及时采取防治措施，防止扩散蔓延。',
  treatment: '【通用防治建议】\n1. 及时清除病叶、病株，减少传染源\n2. 保持田间通风透光，降低湿度\n3. 避免过度浇水，采用滴灌方式\n4. 发病初期可使用广谱杀菌剂喷洒\n5. 建议咨询当地农业技术人员获取针对性方案',
  cause: '环境因素或病原体感染，具体原因需进一步诊断。'
};
// ✅ 在这里添加在线翻译函数
async function onlineTranslate(text: string): Promise<string | null> {
  try {
    const httpRequest = http.createHttp();
    const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=en|zh`;
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      connectTimeout: 5000,
      readTimeout: 5000
    });

    if (response.responseCode === 200) {
      const data = JSON.parse(response.result as string) as Record<string, Object>;
      const translatedText = (data.responseData as Record<string, string>)?.translatedText;
      if (translatedText && translatedText !== text) {
        console.info(`翻译成功: ${text} -> ${translatedText}`);
        return translatedText;
      }
    }
    httpRequest.destroy();
    return null;
  } catch (error) {
    console.error('翻译API调用失败:', error);
    return null;
  }
}

// 默认翻译函数
async function translateDiseaseName(englishName: string): Promise<string> {
  if (!englishName) return '未知病害';
  if (DISEASE_NAME_MAP[englishName]) {
    return DISEASE_NAME_MAP[englishName];
  }
  const keys = Object.keys(DISEASE_NAME_MAP);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (englishName.toLowerCase().includes(key.toLowerCase()) ||
    key.toLowerCase().includes(englishName.toLowerCase())) {
      return DISEASE_NAME_MAP[key];
    }
  }
  // 3. 调用在线翻译API（兜底方案）
  try {
    const translated = await onlineTranslate(englishName);
    if (translated) {
      // 将翻译结果缓存到映射表，下次直接使用
      DISEASE_NAME_MAP[englishName] = translated;
      return translated;
    }
  } catch (error) {
    console.error('在线翻译失败:', error);
  }
  return englishName;
}

// 获取病害知识（描述、治疗建议、原因）
function getDiseaseKnowledge(diseaseName: string): DiseaseKnowledge {
  // 先尝试直接匹配
  if (DISEASE_KNOWLEDGE_BASE[diseaseName]) {
    return DISEASE_KNOWLEDGE_BASE[diseaseName];
  }
  // 使用 Object.keys + for 循环替代 for...in
  const keys = Object.keys(DISEASE_KNOWLEDGE_BASE);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (diseaseName.toLowerCase().includes(key.toLowerCase()) ||
    key.toLowerCase().includes(diseaseName.toLowerCase())) {
      return DISEASE_KNOWLEDGE_BASE[key];
    }
  }
  return DEFAULT_DISEASE_KNOWLEDGE;
}

interface V3IsHealthyBlock {
  probability?: number;
  binary?: boolean;
  threshold?: number;
}

interface V3DiseaseDetails {
  local_name?: string;
  description?: string;
  cause?: string | null;
  treatment?: Record<string, string[]>;
}

interface V3DiseaseSuggestion {
  id?: string;
  name?: string;
  probability?: number;
  details?: V3DiseaseDetails;
}

interface GeneratedTypeLiteralInterface_1 {
  suggestions?: V3DiseaseSuggestion[];
}

interface GeneratedTypeLiteralInterface_2 {
  suggestions?: V3PlantClassificationSuggestion[];
}

interface V3HealthResultPayload {
  is_healthy?: V3IsHealthyBlock;
  disease?: GeneratedTypeLiteralInterface_1;
  classification?: GeneratedTypeLiteralInterface_2;
}

interface GeneratedTypeLiteralInterface_3 {
  common_names?: string[];
  taxonomy?: PlantTaxonomy;
  description?: Description;
}

interface V3PlantClassificationSuggestion {
  name?: string;
  probability?: number;
  details?: GeneratedTypeLiteralInterface_3;
}

interface V3HealthAssessmentEnvelope {
  result?: V3HealthResultPayload;
}

// ============ 旧版 / v2 形态（兼容保留） ============

export interface PlantIdentificationResponse {
  suggestions?: PlantSuggestion[];
  status?: string;
  language?: string;
}

export interface PlantSuggestion {
  plant_name?: string;
  probability?: number;
  confirmed?: boolean;
  plant_details?: PlantDetails;
}

export interface PlantDetails {
  common_names?: string[];
  taxonomy?: PlantTaxonomy;
  description?: Description;
}

export interface PlantTaxonomy {
  genus?: string;
  family?: string;
  order?: string;
  class?: string;
  phylum?: string;
  kingdom?: string;
}

export interface Description {
  value?: string;
  language?: string;
  citation?: string;
}

export interface LegacyHealthAssessmentResponse {
  health_assessment?: LegacyHealthAssessment;
  suggestions?: LegacyPlantSuggestion[];
}

export interface LegacyHealthAssessment {
  is_healthy?: boolean;
  diseases?: LegacyDisease[];
}

export interface LegacyDisease {
  name?: string;
  probability?: number;
  local_name?: string;
  description?: string;
  treatment?: string;
  cause?: string;
}

export interface LegacyPlantSuggestion {
  plant_name?: string;
  probability?: number;
}

export interface HealthDisease {
  name?: string;
  probability?: number;
  local_name?: string;
  description?: string;
  treatment?: DiseaseTreatment;
}

export interface DiseaseTreatment {
  preventive?: string[];
  curative?: string[];
  chemical?: string[];
  biological?: string[];
}

// ============ v3 物种识别（与 response_species_identification.json 对齐） ============

interface GeneratedTypeLiteralInterface_5 {
  suggestions?: V3PlantClassificationSuggestion[];
}

interface GeneratedTypeLiteralInterface_4 {
  classification?: GeneratedTypeLiteralInterface_5;
}

interface V3IdentificationEnvelope {
  result?: GeneratedTypeLiteralInterface_4;
}

// 用量查询响应
export interface UsageResponse {
  remaining_requests?: number;
  total_requests?: number;
  reset_time?: string;
}

// 诊断结果类型
export interface DiagnosisResult {
  isHealthy: boolean;
  diseaseName: string;
  diseaseDescription: string;
  treatmentAdvice: string;
  cause: string;
  confidence: number;
  plantName: string;
}

// 植物识别结果类型
export interface PlantIdentificationResult {
  plantName: string;
  commonNames: string[];
  genus: string;
  family: string;
  probability: number;
  description: string;
}

// ============ 服务类 ============

const CONNECT_MS = 10000;
const READ_MS = 30000;
const ERROR_BODY_MAX = 500;

// v3：details 类参数须放在 URL query，不能放在 JSON body（否则 400 Unknown modifier）
const HEALTH_URL_WITH_QUERY: string =
  'https://api.plant.id/v3/health_assessment?disease_details=description,treatment,cause,local_name&language=zh&full_disease_list=true';
const IDENTIFY_URL_WITH_QUERY: string =
  'https://api.plant.id/v3/identification?details=common_names,taxonomy,description&language=zh';

class PlantIdService {
  private static instance: PlantIdService;
  // https://web.plant.id 申请 Api-Key
  private readonly API_KEY: string = 'hlBPCmY3YwxiysmR5uOzqjjoK7WWQbb1weeoS4jVgZIsXmZS34';
  private readonly USAGE_URL: string = 'https://api.plant.id/v3/usage';

  static getInstance(): PlantIdService {
    if (!PlantIdService.instance) {
      PlantIdService.instance = new PlantIdService();
    }
    return PlantIdService.instance;
  }

  private logHttpError(url: string, code: number, body: string): void {
    const snippet = body.length > ERROR_BODY_MAX ? body.substring(0, ERROR_BODY_MAX) + '...' : body;
    console.error(`Plant.id HTTP ${code} ${url} body: ${snippet}`);
  }

  /** v3 创建识别成功时返回 201，部分接口也可能返回 200 */
  private isHttpSuccess(code: number): boolean {
    return code === 200 || code === 201;
  }

  private safeParseObject(body: string): Record<string, Object> | null {
    try {
      return JSON.parse(body) as Record<string, Object>;
    } catch {
      console.error('Plant.id: 响应体不是合法 JSON');
      return null;
    }
  }

  /**
   * 将 v3 treatment 对象格式化为可读文本
   */
  private formatTreatmentObject(treatment: Record<string, string[]> | undefined): string {
    if (!treatment) {
      return '';
    }
    const labelByKey: Record<string, string> = {
      'prevention': '预防',
      'preventive': '预防',
      'biological': '生物防治',
      'chemical': '化学防治',
      'curative': '治疗'
    };
    const orderedKeys: string[] = ['prevention', 'preventive', 'biological', 'chemical', 'curative'];
    const parts: string[] = [];
    for (let i = 0; i < orderedKeys.length; i++) {
      const key = orderedKeys[i];
      const lines = treatment[key];
      if (lines && lines.length > 0) {
        const label = labelByKey[key] ?? key;
        parts.push(`【${label}】\n${lines.join('\n')}`);
      }
    }
    return parts.join('\n\n');
  }



  /**
   * 分析农作物健康状态（病虫害诊断）
   * @returns 诊断结果，失败返回 null
   */
  async analyzeHealth(imageBase64: string): Promise<DiagnosisResult | null> {
    if (!imageBase64 || imageBase64.length === 0) {
      console.error('Plant.id: 图片 Base64 为空');
      return null;
    }

    const httpRequest = http.createHttp();

    try {
      console.info('Plant.id health_assessment 请求开始');

      const response = await httpRequest.request(HEALTH_URL_WITH_QUERY, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Api-Key': this.API_KEY
        },
        extraData: JSON.stringify({
          images: [imageBase64],
          similar_images: true
        }),
        connectTimeout: CONNECT_MS,
        readTimeout: READ_MS
      });

      const bodyStr = response.result as string;
      console.info('Plant.id 响应状态码:', response.responseCode);
      console.info('Plant.id 完整响应:', bodyStr); //  打印完整响应
      if (!this.isHttpSuccess(response.responseCode)) {
        this.logHttpError(HEALTH_URL_WITH_QUERY, response.responseCode, bodyStr ?? '');
        return null;
      }

      const parsed = this.safeParseObject(bodyStr);
      if (!parsed) {
        return null;
      }

      //  添加 await
      return await this.parseHealthResponse(parsed);
    } catch (error) {
      const err = error as BusinessError;
      console.error('Plant.id health_assessment 请求异常:', err.message);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 植物识别（仅识别植物种类，不包含病害）
   */
  async identifyPlant(imageBase64: string): Promise<PlantIdentificationResult | null> {
    if (!imageBase64 || imageBase64.length === 0) {
      console.error('Plant.id: 图片 Base64 为空');
      return null;
    }

    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(IDENTIFY_URL_WITH_QUERY, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Api-Key': this.API_KEY
        },
        extraData: JSON.stringify({
          images: [imageBase64]
        }),
        connectTimeout: CONNECT_MS,
        readTimeout: READ_MS
      });

      const bodyStr = response.result as string;
      if (!this.isHttpSuccess(response.responseCode)) {
        this.logHttpError(IDENTIFY_URL_WITH_QUERY, response.responseCode, bodyStr ?? '');
        return null;
      }

      const parsed = this.safeParseObject(bodyStr);
      if (!parsed) {
        return null;
      }

      return this.parsePlantResponse(parsed);
    } catch (error) {
      const err = error as BusinessError;
      console.error('Plant.id identification 请求异常:', err.message);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 获取API使用情况
   */
  async getUsageInfo(): Promise<number | null> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(this.USAGE_URL, {
        method: http.RequestMethod.GET,
        header: {
          'Api-Key': this.API_KEY
        },
        connectTimeout: CONNECT_MS,
        readTimeout: READ_MS
      });

      const bodyStr = response.result as string;
      if (!this.isHttpSuccess(response.responseCode)) {
        this.logHttpError(this.USAGE_URL, response.responseCode, bodyStr ?? '');
        return null;
      }

      const parsed = this.safeParseObject(bodyStr);
      if (!parsed) {
        return null;
      }
      const usage = parsed as UsageResponse;
      return usage.remaining_requests ?? null;
    } catch (error) {
      const err = error as BusinessError;
      console.error('Plant.id usage 请求异常:', err.message);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  private defaultDiagnosis(): DiagnosisResult {
    return {
      isHealthy: true,
      diseaseName: '健康',
      diseaseDescription: '未检测到明显病虫害',
      treatmentAdvice: '继续保持良好的田间管理',
      cause: '',
      confidence: 0,
      plantName: '未知'
    };
  }

  /**
   * 解析健康评估：优先 v3（result.is_healthy / result.disease），否则尝试旧版字段
   */
  private async parseHealthResponse(root: Record<string, Object>): Promise<DiagnosisResult> {
    const env = root as V3HealthAssessmentEnvelope;
    if (env.result && (env.result.is_healthy !== undefined || env.result.disease !== undefined ||
      env.result.classification !== undefined)) {
      return await this.parseHealthResponseV3(env);
    }
    const legacy = root as LegacyHealthAssessmentResponse;
    if (legacy.health_assessment) {
      return this.parseHealthResponseLegacy(legacy);
    }
    console.error('Plant.id: 无法识别的健康评估响应结构');
    return this.defaultDiagnosis();
  }

  private async parseHealthResponseV3(env: V3HealthAssessmentEnvelope): Promise<DiagnosisResult> {
    const out = this.defaultDiagnosis();
    const payload = env.result;
    if (!payload) {
      console.warn('V3响应: payload为空');
      return out;
    }

    if (payload.is_healthy !== undefined) {
      const binary = payload.is_healthy.binary;
      out.isHealthy = binary !== undefined ? binary : true;
      console.info(`健康状态: ${out.isHealthy}`);
    }

    if (payload.classification?.suggestions && payload.classification.suggestions.length > 0) {
      const top = payload.classification.suggestions[0];
      const cn = top.details?.common_names;
      out.plantName = (cn && cn.length > 0) ? cn[0] : (top.name ?? '未知');
      console.info(`植物名称: ${out.plantName}`);
    }

    if (!out.isHealthy && payload.disease?.suggestions && payload.disease.suggestions.length > 0) {
      const s = payload.disease.suggestions[0];
      const d = s.details;
      const englishName = d?.local_name ?? s.name ?? '未知病害';
      console.info(`病害名称: ${out.diseaseName}`);
      const knowledge = getDiseaseKnowledge(englishName);
      //  使用 await 等待异步结果
      const chineseName = await translateDiseaseName(englishName);
      out.diseaseName = chineseName;
      out.diseaseDescription = d?.description ?? knowledge.description;

      // 修复：治疗建议 - 优先使用API返回的，如果为空则使用本地知识库
      const apiTreatment = this.formatTreatmentObject(d?.treatment);
      out.treatmentAdvice = (apiTreatment && apiTreatment.trim() !== '') ? apiTreatment : knowledge.treatment;

      out.cause = d?.cause ??knowledge.cause;

      out.confidence = s.probability ?? 0;
      console.info(`病害描述: ${out.diseaseDescription.substring(0, 50)}...`);
    }

    return out;
  }

  private parseHealthResponseLegacy(response: LegacyHealthAssessmentResponse): DiagnosisResult {
    const out = this.defaultDiagnosis();
    const ha = response.health_assessment;
    if (!ha) {
      return out;
    }

    if (ha.is_healthy !== undefined) {
      out.isHealthy = ha.is_healthy;
    }

    const diseases = ha.diseases;
    if (!out.isHealthy && diseases && diseases.length > 0) {
      const disease = diseases[0];
      out.diseaseName = disease.local_name ?? disease.name ?? '未知病害';
      out.diseaseDescription = disease.description ?? '暂无详细描述';
      out.treatmentAdvice = disease.treatment ?? '暂无治疗方案';
      out.cause = disease.cause ?? '环境因素或病原体感染';
      out.confidence = disease.probability ?? 0;
    }

    const sugg = response.suggestions;
    if (sugg && sugg.length > 0 && sugg[0].plant_name) {
      out.plantName = sugg[0].plant_name as string;
    }

    return out;
  }

  /**
   * 解析植物识别：优先 v3 result.classification.suggestions，否则旧版顶层 suggestions
   */
  private parsePlantResponse(root: Record<string, Object>): PlantIdentificationResult {
    const v3 = root as V3IdentificationEnvelope;
    if (v3.result?.classification?.suggestions && v3.result.classification.suggestions.length > 0) {
      return this.parsePlantResponseV3(v3.result.classification.suggestions[0]);
    }
    const legacy = root as PlantIdentificationResponse;
    return this.parsePlantResponseLegacy(legacy);
  }

  private parsePlantResponseV3(s: V3PlantClassificationSuggestion): PlantIdentificationResult {
    const details = s.details;
    const common = details?.common_names ?? [];
    const name = (common.length > 0) ? common[0] : (s.name ?? '未知');
    return {
      plantName: name,
      commonNames: common,
      genus: details?.taxonomy?.genus ?? '',
      family: details?.taxonomy?.family ?? '',
      probability: s.probability ?? 0,
      description: details?.description?.value ?? ''
    };
  }

  private parsePlantResponseLegacy(response: PlantIdentificationResponse): PlantIdentificationResult {
    let result: PlantIdentificationResult = {
      plantName: '未知',
      commonNames: [],
      genus: '',
      family: '',
      probability: 0,
      description: ''
    };

    const suggestions = response.suggestions;
    if (suggestions && suggestions.length > 0) {
      const plant = suggestions[0];
      result.plantName = plant.plant_name ?? '未知';
      result.probability = plant.probability ?? 0;

      if (plant.plant_details) {
        result.commonNames = plant.plant_details.common_names ?? [];
        result.genus = plant.plant_details.taxonomy?.genus ?? '';
        result.family = plant.plant_details.taxonomy?.family ?? '';
        result.description = plant.plant_details.description?.value ?? '';
      }
    }

    return result;
  }
}

export default PlantIdService.getInstance();
