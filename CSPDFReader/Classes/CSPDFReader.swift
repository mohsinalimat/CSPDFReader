
//
//  CSPDFReader.swift
//  CSPDFReader
//
//  Created by WeiRuJian on 2018/11/13.
//  Copyright © 2018年 Choshim丶Wy. All rights reserved.
//

import CoreGraphics
import UIKit

public struct CSPDFReader {
    /// PDF总页数
    public let pageCount: Int
    /// PDF名称
    public let fileName: String
    /// URL
    private let fileUrl: URL?
    /// PDF data
    private let fileData: Data
    /// PDFDocument
    private let coreDocument: CGPDFDocument
    /// 密码
    private let password: String?
    /// 分页图片集合
    private let images = NSCache<NSNumber, UIImage>()
    /// 生成预览图高度
    private let constantHeight: CGFloat

    /// 通过URL初始化
    ///
    /// - Parameters:
    ///   - url: PDF的URL地址
    ///   - password: 打开PDF的密码
    ///   - constant: 生成预览图的高度(默认240)
    public init?(url: URL, password: String? = nil, constant: CGFloat = 240) {
        guard let fileData = try? Data(contentsOf: url) else { return nil }
        self.init(fileData: fileData, fileUrl: url, fileName: url.lastPathComponent, password: password, constant: constant)
    }

    /// 通过Data初始化
    ///
    /// - Parameters:
    ///   - fileData: PDF的Data数据
    ///   - fileName: PDF的名称
    ///   - password: PDF密码
    ///   - constant: 生成预览图的高度(默认240)
    public init?(fileData: Data, fileName: String, password: String? = nil, constant: CGFloat = 240) {
        self.init(fileData: fileData, fileUrl: nil, fileName: fileName, password: password, constant: constant)
    }

    private init?(fileData: Data, fileUrl: URL?, fileName: String, password: String?, constant: CGFloat) {
        guard let provider = CGDataProvider(data: fileData as CFData) else { return nil }
        guard let coreDocument = CGPDFDocument(provider) else { return nil }

        self.fileData = fileData
        self.fileUrl = fileUrl
        self.fileName = fileName
        constantHeight = constant
        if let password = password, let cPassword = password.cString(using: .utf8) {
            if coreDocument.isEncrypted, !coreDocument.unlockWithPassword("") {
                if !coreDocument.unlockWithPassword(cPassword) {
                    print("Unable to unlock \(fileName)")
                }
                self.password = password
            } else {
                self.password = nil
            }
        } else {
            self.password = nil
        }

        self.coreDocument = coreDocument
        pageCount = coreDocument.numberOfPages
        loadPages()
    }

    /// 在后台线程中提取每个页面的图像表示并将它们存储在缓存中
    private func loadPages() {
        DispatchQueue.global(qos: .background).async {
            for page in 1 ... self.pageCount {
                guard let image = self.imageWithPDFPage(page) else { return }
                self.images.setObject(image, forKey: NSNumber(value: page))
            }
        }
    }

    /// 从PDF文档中获取指定页面的原始图像
    private func imageWithPDFPage(_ pageNum: Int) -> UIImage? {
        guard let page = coreDocument.page(at: pageNum) else { return nil }

        let originalPageRect = page.originalPageRect

        let pdfScale = min(constantHeight / originalPageRect.width, constantHeight / originalPageRect.height)
        let scaledPageSize = CGSize(width: originalPageRect.width * pdfScale, height: originalPageRect.height * pdfScale)
        let scaledPageRect = CGRect(origin: originalPageRect.origin, size: scaledPageSize)

        UIGraphicsBeginImageContextWithOptions(scaledPageSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        /// 填充白色背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(scaledPageRect)
        context.saveGState()

        /// 旋转上下文,保证PDF页面显示朝上
        let rotationAngle: CGFloat
        switch page.rotationAngle {
        case 90:
            rotationAngle = 270
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        case 180:
            rotationAngle = 180
            context.translateBy(x: 0, y: scaledPageSize.height)
        case 270:
            rotationAngle = 90
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        default:
            rotationAngle = 0
            context.translateBy(x: 0, y: scaledPageSize.height)
        }

        context.scaleBy(x: 1, y: -1)
        context.rotate(by: rotationAngle.degreesToRadians)

        /// 缩放上下文,保证PDF页面显示大小合适
        context.scaleBy(x: pdfScale, y: pdfScale)
        context.drawPDFPage(page)
        context.restoreGState()

        /// 关闭
        defer { UIGraphicsEndImageContext() }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// PDF指定页图片
    private func pdfPageWithImage(_ pageNum: Int) -> UIImage? {
        if let image = self.images.object(forKey: NSNumber(value: pageNum)) {
            return image
        } else {
            guard let image = self.imageWithPDFPage(pageNum) else { return nil }
            images.setObject(image, forKey: NSNumber(value: pageNum))
            return image
        }
    }

    /// 所有页面的图片
    public func allPageImages() -> [UIImage]? {
        var imgs: [UIImage] = []
        for pageNum in 0 ..< pageCount {
            guard let image = self.pdfPageWithImage(pageNum + 1
            ) else { return nil }
            imgs.append(image)
        }
        return imgs
    }
}
