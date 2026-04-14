// entry/src/main/ets/services/PlantIdService.ets
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';

// ============ API 响应类型定义 ============

// 植物识别响应
export interface PlantIdentificationResponse {
  suggestions: PlantSuggestion[];
  status: string;
  language: string;
}

export interface PlantSuggestion {
  plant_name: string;
  probability: number;
  confirmed: boolean;
  plant_details: PlantDetails;
}

export interface PlantDetails {
  common_names: string[];
  taxonomy: PlantTaxonomy;
  description?: Description;
}

export interface PlantTaxonomy {
  genus: string;
  family: string;
  order: string;
  class: string;
  phylum: string;
  kingdom: string;
}

export interface Description {
  value: string;
  language: string;
  citation: string;
}

// 健康评估响应
export interface HealthAssessmentResponse {
  health_assessment: HealthAssessment;
  suggestions: HealthSuggestion[];
}

export interface HealthAssessment {
  is_healthy: boolean;
  diseases: Disease[];
}

export interface Disease {
  name: string;
  probability: number;
  local_name: string;
  description: string;
  treatment: string;
  cause: string;
}

export interface HealthSuggestion {
  plant_name: string;
  probability: number;
  disease: HealthDisease;
}

export interface HealthDisease {
  name: string;
  probability: number;
  local_name: string;
  description: string;
  treatment: DiseaseTreatment;
}

export interface DiseaseTreatment {
  preventive: string[];
  curative: string[];
  chemical: string[];
  biological: string[];
}

// 用量查询响应
export interface UsageResponse {
  remaining_requests: number;
  total_requests: number;
  reset_time: string;
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

class PlantIdService {
  private static instance: PlantIdService;
  // 请替换为你的API Key（从 https://plant.id 注册获取）
  private readonly API_KEY: string = 'hlBPCmY3YwxiysmR5uOzqjjoK7WWQbb1weeoS4jVgZIsXmZS34';
  private readonly HEALTH_URL: string = 'https://api.plant.id/v3/health_assessment';
  private readonly IDENTIFY_URL: string = 'https://api.plant.id/v3/identification';
  private readonly USAGE_URL: string = 'https://api.plant.id/v3/usage';

  static getInstance(): PlantIdService {
    if (!PlantIdService.instance) {
      PlantIdService.instance = new PlantIdService();
    }
    return PlantIdService.instance;
  }

  /**
   * 分析农作物健康状态（病虫害诊断）
   * @returns 诊断结果，失败返回 null
   */
  async analyzeHealth(imageBase64: string): Promise<DiagnosisResult | null> {
    const httpRequest = http.createHttp();

    try {
      console.log('Plant.id API 开始请求...');

      const response = await httpRequest.request(this.HEALTH_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Api-Key': this.API_KEY
        },
        extraData: JSON.stringify({
          images: [imageBase64],
          disease_details: ['description', 'treatment', 'cause', 'local_name'],
          language: 'zh',
          similar_images: true
        }),
        connectTimeout: 5000,
        readTimeout:5000
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as HealthAssessmentResponse;
        return this.parseHealthResponse(result);
      } else {
        console.error(`Plant.id API 错误: ${response.responseCode}`);
        return null;
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error('Plant.id 请求失败:', err.message);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 植物识别（仅识别植物种类，不包含病害）
   * @returns 植物识别结果，失败返回 null
   */
  async identifyPlant(imageBase64: string): Promise<PlantIdentificationResult | null> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(this.IDENTIFY_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Api-Key': this.API_KEY
        },
        extraData: JSON.stringify({
          images: [imageBase64],
          plant_details: ['common_names', 'taxonomy', 'description'],
          language: 'zh'
        }),
        connectTimeout: 5000,
        readTimeout: 5000
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as PlantIdentificationResponse;
        return this.parsePlantResponse(result);
      }
      return null;
    } catch (error) {
      const err = error as BusinessError;
      console.error('植物识别失败:', err.message);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 获取API使用情况
   * @returns 剩余请求次数，失败返回 null
   */
  async getUsageInfo(): Promise<number | null> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(this.USAGE_URL, {
        method: http.RequestMethod.GET,
        header: {
          'Api-Key': this.API_KEY
        }
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as UsageResponse;
        return result.remaining_requests;
      }
      return null;
    } catch (error) {
      const err = error as BusinessError;
      console.error('获取用量失败:', err.message);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 解析健康评估响应
   */
  private parseHealthResponse(response: HealthAssessmentResponse): DiagnosisResult {
    // 默认结果
    let result: DiagnosisResult = {
      isHealthy: true,
      diseaseName: '健康',
      diseaseDescription: '未检测到明显病虫害',
      treatmentAdvice: '继续保持良好的田间管理',
      cause: '',
      confidence: 0,
      plantName: '未知'
    };

    // 解析健康评估
    if (response.health_assessment) {
      result.isHealthy = response.health_assessment.is_healthy;

      if (!result.isHealthy && response.health_assessment.diseases.length > 0) {
        const disease = response.health_assessment.diseases[0];
        result.diseaseName = disease.local_name || disease.name;
        result.diseaseDescription = disease.description;
        result.treatmentAdvice = disease.treatment;
        result.cause = disease.cause;
        result.confidence = disease.probability;
      }
    }

    // 解析植物名称
    if (response.suggestions && response.suggestions.length > 0) {
      const plant = response.suggestions[0];
      result.plantName = plant.plant_name;
    }

    return result;
  }

  /**
   * 解析植物识别响应
   */
  private parsePlantResponse(response: PlantIdentificationResponse): PlantIdentificationResult {
    let result: PlantIdentificationResult = {
      plantName: '未知',
      commonNames: [],
      genus: '',
      family: '',
      probability: 0,
      description: ''
    };

    if (response.suggestions && response.suggestions.length > 0) {
      const plant = response.suggestions[0];
      result.plantName = plant.plant_name;
      result.probability = plant.probability;

      if (plant.plant_details) {
        result.commonNames = plant.plant_details.common_names || [];
        result.genus = plant.plant_details.taxonomy?.genus || '';
        result.family = plant.plant_details.taxonomy?.family || '';
        result.description = plant.plant_details.description?.value || '';
      }
    }

    return result;
  }
}

export default PlantIdService.getInstance();