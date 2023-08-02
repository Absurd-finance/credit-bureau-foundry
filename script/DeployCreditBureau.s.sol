// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import { BaseScript } from "./Base.s.sol";
import { CreditBureau } from "../src/CreditBureau.sol";

contract DeployCreditBureau is BaseScript {
    function run() public broadcast returns (CreditBureau cb) {
        address axelarGateway =
            vm.envOr({ name: "AXELAR_GATEWAY", defaultValue: 0xe432150cce91c13a887f7D836923d5597adD8E31 });
        address axelarGasReceiver =
            vm.envOr({ name: "AXELAR_GASRECEIVER", defaultValue: 0x2d5d7d31F671F86C782533cc367F14109a082712 });

        cb = new CreditBureau(axelarGateway, axelarGasReceiver);
    }
}
