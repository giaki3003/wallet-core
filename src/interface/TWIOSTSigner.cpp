// Copyright © 2017-2019 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

#include <TrustWalletCore/TWData.h>
#include <TrustWalletCore/TWIOSTSigner.h>

#include "Base58.h"
#include "../IOST/Signer.h"
#include "../proto/IOST.pb.h"

using namespace TW;
using namespace TW::IOST;

TW_IOST_Proto_SigningOutput TWIOSTSignerSign(TW_IOST_Proto_SigningInput data) {
    Proto::SigningInput input;
    input.ParseFromArray(TWDataBytes(data), TWDataSize(data));
    auto protoOutput = Signer().sign(input);
    auto serialized = protoOutput.SerializeAsString();
    return TWDataCreateWithBytes(reinterpret_cast<const uint8_t*>(serialized.data()),
                                 serialized.size());
}
