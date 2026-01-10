//
//  Entry+InfoZip.swift
//  ZIPFoundation
//
//  Copyright © 2017-2025 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

extension Entry {

    struct InfoZipUnicodePath: ExtensibleDataField {
        var headerID: UInt16 { ExtraFieldHeaderID.infoZipUnicodePath.rawValue }
        let dataSize: UInt16
        let version: UInt8
        let nameCRC32: UInt32
        let unicodeName: Data
    }

    var infoZipExtraField: InfoZipUnicodePath? {
        let extraField = self.localFileHeader.extraFields?.first { $0 is InfoZipUnicodePath }
        return extraField as? InfoZipUnicodePath
    }
}

extension Entry.InfoZipUnicodePath {

    static func scanForUnicodePath(in data: Data) -> Entry.InfoZipUnicodePath? {
        guard data.isEmpty == false else { return nil }
        var offset = 0
        var headerID: UInt16
        var dataSize: UInt16
        let extraFieldLength = data.count
        let headerSize = 4

        while offset < extraFieldLength - headerSize {
            headerID = data.scanValue(start: offset)
            dataSize = data.scanValue(start: offset + 2)
            let nextOffset = offset + headerSize + Int(dataSize)
            guard nextOffset <= extraFieldLength else { return nil }

            if headerID == ExtraFieldHeaderID.infoZipUnicodePath.rawValue {
                let fieldData = data.subdata(in: offset..<nextOffset)
                let version: UInt8 = fieldData.scanValue(start: 4)
                let nameCRC32: UInt32 = fieldData.scanValue(start: 5)
                let unicodeNameData = fieldData.subdata(in: 9..<fieldData.count)

                return Entry.InfoZipUnicodePath(
                    dataSize: dataSize,
                    version: version,
                    nameCRC32: nameCRC32,
                    unicodeName: unicodeNameData
                )
            }
            offset = nextOffset
        }
        return nil
    }
}
