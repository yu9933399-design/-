package com.order.utils;

import com.order.config.AiConfig;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * AI 接口调用工具类
 */
public class AiChatUtil {

    public static String chat(String userMessage) {
        HttpURLConnection conn = null;
        try {
            String jsonBody = buildRequestBody(userMessage);
            System.out.println("[AI] 请求体: " + jsonBody);

            URL url = new URL(AiConfig.AI_API_URL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("Authorization", "Bearer " + AiConfig.AI_API_KEY);
            conn.setConnectTimeout(AiConfig.TIMEOUT);
            conn.setReadTimeout(AiConfig.TIMEOUT);
            conn.setDoOutput(true);

            // 发送请求
            byte[] bodyBytes = jsonBody.getBytes(StandardCharsets.UTF_8);
            conn.setRequestProperty("Content-Length", String.valueOf(bodyBytes.length));
            try (OutputStream os = conn.getOutputStream()) {
                os.write(bodyBytes);
                os.flush();
            }

            // 读取响应
            int code = conn.getResponseCode();
            System.out.println("[AI] 响应码: " + code);

            InputStream is;
            if (code >= 200 && code < 300) {
                is = conn.getInputStream();
            } else {
                is = conn.getErrorStream();
                if (is == null) is = conn.getInputStream();
            }
            String response = readStream(is);
            System.out.println("[AI] 响应内容: " + response);

            if (code >= 200 && code < 300) {
                return parseContent(response);
            } else {
                return "AI服务暂不可用(错误码:" + code + ")，请稍后再试~";
            }
        } catch (java.net.ConnectException e) {
            System.out.println("[AI] 连接失败: " + e.getMessage());
            return "无法连接AI服务，请检查网络~";
        } catch (java.net.SocketTimeoutException e) {
            System.out.println("[AI] 连接超时: " + e.getMessage());
            return "AI服务响应超时，请稍后再试~";
        } catch (Exception e) {
            System.out.println("[AI] 请求异常: " + e.getMessage());
            e.printStackTrace();
            return "智能客服暂时出了点问题~";
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private static String buildRequestBody(String userMessage) {
        String sysPrompt = escapeJson(AiConfig.SYSTEM_PROMPT);
        String userMsg = escapeJson(userMessage);
        return "{\"model\":\"" + AiConfig.MODEL + "\","
             + "\"messages\":["
             + "{\"role\":\"system\",\"content\":\"" + sysPrompt + "\"},"
             + "{\"role\":\"user\",\"content\":\"" + userMsg + "\"}"
             + "],\"max_tokens\":300,\"temperature\":0.7}";
    }

    private static String parseContent(String json) {
        try {
            // 找最后一个 "content":" (AI回复的)
            int idx = json.lastIndexOf("\"content\":\"");
            if (idx == -1) {
                idx = json.indexOf("\"content\":\"");
            }
            if (idx == -1) {
                // 尝试找 content 后面没有冒号引号的情况
                idx = json.indexOf("\"content\" : \"");
                if (idx == -1) return "回复解析失败，请重试~";
                idx = json.indexOf("\"content\" : \"");
            }
            int start = idx + "\"content\":\"".length();
            int end = start;
            boolean escaped = false;
            while (end < json.length()) {
                char c = json.charAt(end);
                if (escaped) {
                    escaped = false;
                    end++;
                } else if (c == '\\') {
                    escaped = true;
                    end++;
                } else if (c == '"') {
                    break;
                } else {
                    end++;
                }
            }
            String content = json.substring(start, end);
            content = content.replace("\\n", "\n").replace("\\\"", "\"").replace("\\\\", "\\");
            return content.trim();
        } catch (Exception e) {
            return "回复解析失败，请重试~";
        }
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "")
                .replace("\t", "\\t");
    }

    private static String readStream(InputStream is) throws IOException {
        if (is == null) return "";
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        reader.close();
        return sb.toString();
    }
}
