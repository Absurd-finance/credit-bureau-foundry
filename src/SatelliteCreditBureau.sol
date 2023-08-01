// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AxelarExecutable } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import { IAxelarGateway } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import { IAxelarGasService } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import { ICreditBureau } from "./interfaces/ICreditBureau.sol";

contract SatelliteCreditBureau is AxelarExecutable {
    IAxelarGasService public immutable gasService;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    function submitCreditReport(
        string calldata destinationChain,
        string calldata destinationAddress,
        ICreditBureau.Report memory report,
        address user
    )
        external
        payable
    {
        bytes memory payload = abi.encode(report, user);
        gasService.payNativeGasForContractCall{ value: msg.value }(
            address(this), destinationChain, destinationAddress, payload, msg.sender
        );
        gateway.callContract(destinationChain, destinationAddress, payload);
    }
}
