// entry/src/main/ets/service/PlantIdService.ets
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';

// ============ v3 健康评估响应（与 response_health_assessment.json 对齐） ============

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

interface V3HealthResultPayload {
  is_healthy?: V3IsHealthyBlock;
  disease?: {
    suggestions?: V3DiseaseSuggestion[];
  };
  classification?: {
    suggestions?: V3PlantClassificationSuggestion[];
  };
}

interface V3PlantClassificationSuggestion {
  name?: string;
  probability?: number;
  details?: {
    common_names?: string[];
    taxonomy?: PlantTaxonomy;
    description?: Description;
  };
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

interface V3IdentificationEnvelope {
  result?: {
    classification?: {
      suggestions?: V3PlantClassificationSuggestion[];
    };
  };
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
  'https://api.plant.id/v3/health_assessment?disease_details=description,treatment,cause,local_name&language=zh';
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
      if (!this.isHttpSuccess(response.responseCode)) {
        this.logHttpError(HEALTH_URL_WITH_QUERY, response.responseCode, bodyStr ?? '');
        return null;
      }

      const parsed = this.safeParseObject(bodyStr);
      if (!parsed) {
        return null;
      }

      return this.parseHealthResponse(parsed);
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
  private parseHealthResponse(root: Record<string, Object>): DiagnosisResult {
    const env = root as V3HealthAssessmentEnvelope;
    if (env.result && (env.result.is_healthy !== undefined || env.result.disease !== undefined ||
      env.result.classification !== undefined)) {
      return this.parseHealthResponseV3(env);
    }
    const legacy = root as LegacyHealthAssessmentResponse;
    if (legacy.health_assessment) {
      return this.parseHealthResponseLegacy(legacy);
    }
    console.error('Plant.id: 无法识别的健康评估响应结构');
    return this.defaultDiagnosis();
  }

  private parseHealthResponseV3(env: V3HealthAssessmentEnvelope): DiagnosisResult {
    const out = this.defaultDiagnosis();
    const payload = env.result;
    if (!payload) {
      return out;
    }

    if (payload.is_healthy !== undefined) {
      const binary = payload.is_healthy.binary;
      out.isHealthy = binary !== undefined ? binary : true;
    }

    if (payload.classification?.suggestions && payload.classification.suggestions.length > 0) {
      const top = payload.classification.suggestions[0];
      const cn = top.details?.common_names;
      out.plantName = (cn && cn.length > 0) ? cn[0] : (top.name ?? '未知');
    }

    if (!out.isHealthy && payload.disease?.suggestions && payload.disease.suggestions.length > 0) {
      const s = payload.disease.suggestions[0];
      const d = s.details;
      const local = d?.local_name ?? s.name ?? '未知病害';
      out.diseaseName = local;
      out.diseaseDescription = d?.description ?? '';
      out.treatmentAdvice = this.formatTreatmentObject(d?.treatment);
      out.cause = d?.cause ?? '';
      out.confidence = s.probability ?? 0;
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
      out.diseaseDescription = disease.description ?? '';
      out.treatmentAdvice = disease.treatment ?? '';
      out.cause = disease.cause ?? '';
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
