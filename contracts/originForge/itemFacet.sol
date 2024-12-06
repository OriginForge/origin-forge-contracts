// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC1155} from "../shared/interfaces/IERC1155.sol";
import {svg} from "../shared/libraries/svg.sol";
import {Metadata, DisplayType} from "../shared/libraries/Metadata.sol";
import {json} from "../shared/libraries/json.sol";
import {Solarray} from "../shared/libraries/Solarray.sol";
import {LibString} from "solady/src/utils/LibString.sol";

contract itemFacet is modifiersFacet {
    using svg for *;
    using Metadata for *;

    function setItem(uint _tokenId, string memory _uri) external onlyAdmin {}

    function item_getUri(uint _tokenId) external view returns (string memory) {}

    function _renderItem(uint _tokenId) internal view returns (string memory) {}

    // 

}