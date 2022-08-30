// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NFT.sol";

contract Comment is CoAnswer {
    using Counters for Counters.Counter;
    
    function setSpecificAnswer() public {
        setAnswer(0, "import");
    }
}
