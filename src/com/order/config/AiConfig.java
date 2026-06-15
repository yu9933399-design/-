package com.order.config;

/**
 * AI 智能客服配置类
 */
public class AiConfig {
    // 通义千问 DashScope 兼容模式接口地址
    public static final String AI_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";

    // API Key
    public static final String AI_API_KEY = "sk-ws-H.REEDRYD.hnTf.MEYCIQCf8G7qUntBIAjHIGyUFpeSCICRVGIvuPg1LGe_pY7kBwIhAJ5bF6LLt1oITr2P_pu5W646BWMjo4J6oNFueXUj5_85";

    // 模型名称
    public static final String MODEL = "qwen3.6-flash";

    // 超时时间（毫秒）
    public static final int TIMEOUT = 30000;

    // 系统提示词
    public static final String SYSTEM_PROMPT =
        "你是美食点餐系统的专属智能客服。仅解答订单、配送、取消规则相关问题。" +
        "必须依据真实订单数据回复，不得编造。无关问题统一回复：抱歉，我只能解答订单和配送相关问题~" +
        "语言口语化简洁，不超过100字。";
}
