//
//  UrlHelper.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import Foundation

struct UrlHelper{
    /// 规范化一个 URL 对象。如果它没有网络协议（http/https），则尝试为其添加 https://。
    /// - Parameter url: 一个输入的 URL 对象。
    /// - Returns: 一个带有网络协议的 URL 对象。
    static func normalizeURL(from url: URL) -> URL {
        // 检查 scheme 是否存在并且是网络协议
        if let scheme = url.scheme, scheme.hasPrefix("http") {
            return url
        }
        
        // scheme 不存在或不是 http/https
        let pathComponent = url.path
        
        // 如果路径为空，直接返回原始url，避免创建无效url
        guard !pathComponent.isEmpty else {
            return url
        }
        
        // 用 "https://" 和 path 重新构建一个新的 URL
        if let newURL = URL(string: "https://" + pathComponent) {
            return newURL
        }
        
        // 失败则返回原始的 URL 作为兜底。
        return url
    }
}
