// Copyright © 2017-2019 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import TrustWalletCore
import XCTest

class QtumTests: XCTestCase {
    func testAddress() {
        let privateKey1 = PrivateKey(data: Data(hexString: "a22ddec5c567b4488bb00f69b6146c50da2ee883e2c096db098726394d585730")!)!
        let publicKey1 = privateKey1.getPublicKeySecp256k1(compressed: true)

        let legacyAddress = BitcoinAddress(publicKey: publicKey1, prefix: P2PKHPrefix.qtum.rawValue)
        XCTAssertEqual(BitcoinAddress(string: "QWVNLCXwhJqzut9YCLxbeMTximr2hmw7Vr")!.description, legacyAddress.description)

        let privateKey2 = PrivateKey(data: Data(hexString: "55f9cbb0376c422946fa28397c1219933ac60b312ede41bfacaf701ecd546625")!)!
        let publicKey2 = privateKey2.getPublicKeySecp256k1(compressed: true)
        let bech32Address = Bech32Address(hrp: .qtum, publicKey: publicKey2)
        XCTAssertEqual(Bech32Address(string: "qc1qytnqzjknvv03jwfgrsmzt0ycmwqgl0as6uywkk")!.description, bech32Address.description)
    }

    func testQtumBlockchain() {
        let chain = CoinType.qtum
        XCTAssertTrue(chain.validate(address: "qc1qn9gjawre2t6xmcv5gyqkujqhd8cfvvyx0rx2mp"))
        XCTAssertTrue(chain.validate(address: "Qbmj3ufB1TaRSSP5DYR4KQxsyHBNrk8Y4p"))
        XCTAssertFalse(chain.validate(address: "Qb4j3ufB1TaRSSP5DYR4KQxsyHBNrk8Y4p"))
        XCTAssertFalse(chain.validate(address: "qc2qn9gjawre2t6xmcv5gyqkujqhd8cfvvyx0rx2mp"))
    }

    func testExtendedKeys() {
        let wallet = HDWallet.test

        // .bip44
        let xprv = wallet.getExtendedPrivateKey(purpose: .bip44, coin: .qtum, version: .xprv)
        let xpub = wallet.getExtendedPubKey(purpose: .bip44, coin: .qtum, version: .xpub)

        XCTAssertEqual(xprv, "xprv9yBPu3rkmyffD3A4TngwcpffYASEEfYnShyhuUsL3h9GiYdUjJh9S2s3vcYMoKi8L2cDqQcsFU5TkC1zgusTENCjatpnxp72X4uYkrej2tj")
        XCTAssertEqual(xpub, "xpub6CAkJZPecMDxRXEXZpDwyxcQ6CGie8GdovuJhsGwc2gFbLxdGr1PyqBXmsL7aYds1wfY2rB3YMVZiEE3CB3Lkj6KGoq1rEJ1wuaGkMDBf1m")

        // .bip49
        let yprv = wallet.getExtendedPrivateKey(purpose: .bip49, coin: .qtum, version: .yprv)
        let ypub = wallet.getExtendedPubKey(purpose: .bip49, coin: .qtum, version: .ypub)
        XCTAssertEqual(yprv, "yprvAJdTrS1VXxDTRFGxPLJmjSECVCwqePCeCH7i6pLP3SiDg6G5omNiwEt88ENDy9nWMPmErGT5c1nGBsZRUjaTunFqw1w6xhWsAsLG6x8fR7d")
        XCTAssertEqual(ypub, "ypub6XcpFwYPNKmkdjMRVMqn6aAw3EnL3qvVZW3JuCjzbnFCYtbEMJgyV3CbyY8jVCtSBfSB5H12uLcFYUSEtsBYNaf46Zv2smueAZKGmDgT8k8")

        // .bip84
        let zprv = wallet.getExtendedPrivateKey(purpose: .bip84, coin: .qtum, version: .zprv)
        let zpub = wallet.getExtendedPubKey(purpose: .bip84, coin: .qtum, version: .zpub)
        XCTAssertEqual(zprv, "zprvAdJxRo2izCdp1NZQShHqyXXwNrkAbYqi9YwAkG6kCJ2V5JZY7s2TdmbF2YxTzQKVx3SWQiHpVpsKyZ59Y8Th7edf2hJBWuyTvnCadLMLxAz")
        XCTAssertEqual(zpub, "zpub6rJJqJZcpaC7DrdsYiprLfUfvtaf11ZZWmrmYeWMkdZTx6tgfQLiBZuisraogskwBRLMGWfXoCyWRrXSypwPdNV2UWJXm5bDVQvBXvrzz9d")
    }

    func testDeriveFromXpub() {
        let xpub = "xpub6CAkJZPecMDxRXEXZpDwyxcQ6CGie8GdovuJhsGwc2gFbLxdGr1PyqBXmsL7aYds1wfY2rB3YMVZiEE3CB3Lkj6KGoq1rEJ1wuaGkMDBf1m"
        let qtum = CoinType.qtum
        let xpubAddr2 = HDWallet.derive(from: xpub, at: DerivationPath(purpose: qtum.purpose, coinType: qtum, account: 0, change: 0, address: 2))!
        let xpubAddr9 = HDWallet.derive(from: xpub, at: DerivationPath(purpose: qtum.purpose, coinType: qtum, account: 0, change: 0, address: 9))!

        XCTAssertEqual(BitcoinAddress(publicKey: xpubAddr2, prefix: P2PKHPrefix.qtum.rawValue).description, "QStYeAAfiYKxsABzY9yugHDpm5bsynYPqc")
        XCTAssertEqual(BitcoinAddress(publicKey: xpubAddr9, prefix: P2PKHPrefix.qtum.rawValue).description, "QfbKFChfhx1s4VXS9BzaVJgyKw5a1hnFg4")
    }

    func testDeriveFromZPub() {
        let zpub = "zpub6rJJqJZcpaC7DrdsYiprLfUfvtaf11ZZWmrmYeWMkdZTx6tgfQLiBZuisraogskwBRLMGWfXoCyWRrXSypwPdNV2UWJXm5bDVQvBXvrzz9d"
        let qtum = CoinType.qtum
        let zpubAddr4 = HDWallet.derive(from: zpub, at: DerivationPath(purpose: .bip84, coinType: qtum, account: 0, change: 0, address: 4))!
        let zpubAddr11 = HDWallet.derive(from: zpub, at: DerivationPath(purpose: .bip84, coinType: qtum, account: 0, change: 0, address: 11))!

        XCTAssertEqual(Bech32Address(hrp: .qtum, publicKey: zpubAddr4).description, "qc1q3cvjmc2cgjkz9y58waj3r9ccchmrmrdzq03783")
        XCTAssertEqual(Bech32Address(hrp: .qtum, publicKey: zpubAddr11).description, "qc1qrlk0ajg6khu2unsdppggs3pgpxxvdeymky58af")
    }
}
