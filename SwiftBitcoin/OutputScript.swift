//
//  OutPutScript.swift
//  TCPClientTest
//
//  Created by Yusuke Asai on 2016/12/24.
//  Copyright © 2016年 Yusuke Asai. All rights reserved.
//

import Foundation

public func == (left: OutputScript.P2PKHScript, right: OutputScript.P2PKHScript) -> Bool {
    return left.hash160 == right.hash160
}

public struct OutputScript {
    
    //P2PKH outputScript only!!
    //Need to support other script formats
    public struct P2PKHScript: Equatable {
        
        public let hash160 : RIPEMD160HASH
        
        public init(hash160: RIPEMD160HASH) {
            self.hash160 = hash160
        }
    }
}

extension OutputScript.P2PKHScript: BitcoinSerializable {
    public var bitcoinData: NSData {
        let data = NSMutableData()
        data.appendOPCode(OPCode.OP_DUP)
        data.appendOPCode(OPCode.OP_HASH160)
        data.appendUInt8(0x14) //length
        data.appendNSData(hash160.bitcoinData)
        data.appendOPCode(OPCode.OP_EQUALVERIFY)
        data.appendOPCode(OPCode.OP_CHECKSIG)
        return data
    }
    
    public static func fromBitcoinStream(_ stream: InputStream) -> OutputScript.P2PKHScript? {
        
        if stream.readOPCode() != OPCode.OP_DUP {
            print("Not OP_DUP")
            return nil
        }
        
        if stream.readOPCode() != OPCode.OP_HASH160 {
            print("Not OP_HASH160")
            return nil
        }
        
        if stream.readUInt8() != 0x14 {
            print("Not length")
            return nil
        }
        
        guard let hash160 = RIPEMD160HASH.fromBitcoinStream(stream) else {
            print("Failed to parse RIPEMD160HASH")
            return nil
        }
        
        if stream.readOPCode() != OPCode.OP_EQUALVERIFY {
            print("Not OP_EQUALVERIFY")
            return nil
        }
        
        
        if stream.readOPCode() != OPCode.OP_CHECKSIG {
            print("Not OP_CHECKSIG")
            return nil
        }
        
        return OutputScript.P2PKHScript(hash160: hash160)
    }
    
}
   
